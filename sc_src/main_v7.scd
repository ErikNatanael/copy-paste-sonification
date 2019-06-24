(
s.waitForBoot( {

	SynthDef(\sine_lead, {
		var sig, env, freq = \freq.kr(400), amp = \amp.kr(0.5), noiseSig, pan = \pan.kr(0), ampJitter, jitterAmount = \jitterAmount.kr(0.3);

		env = EnvGen.kr(Env.perc(\attack.kr(0.02), \decay.kr(0.5), 1.0, -12.0), doneAction:2);
		ampJitter = LFNoise2.kr(10 + (jitterAmount*100)).range(0.5-(jitterAmount*0.5), 1.0);

		noiseSig = RHPF.ar(RLPF.ar(PinkNoise.ar()*0.1, freq, 0.02), freq, 0.01) * 0.08 * AmpCompA.ir(freq);
		noiseSig = Pan2.ar(noiseSig*env*ampJitter, pan);

		Out.ar(\revOut.kr(14), noiseSig*amp*\revMix.kr(0));
		Out.ar(\out.kr(0), noiseSig*amp);
	}).add;

	// adopted from code by Eli Fieldsteel, http://sccode.org/1-5bF
	SynthDef(\osc, {
		arg buf=0, freq=200, detune=0.2,
		amp=0.2, pan=0, out=0, rout=0, rsend=0.1, dout = 0, dsend = 0, lowpassTime = 0.001,
		atk=0.01, sus=1, rel=0.01, c0=1, c1=(-1), lowpass = 19000, highpass = 20;
		var sig, env, detuneCtrl;
		env = EnvGen.ar(
			Env([0,1,1,0],[atk,sus,rel],[c0,0,c1]),
			doneAction:2
		);

		lowpass = Select.kr(lowpassTime > 0, [XLine.ar(freq, lowpass, lowpassTime), lowpass]);

		//array of eight Oscs with uniquely detune frequencies
		//and unique initial phase offsets
		detuneCtrl = LFNoise1.kr(0.1!8).bipolar(detune).midiratio;
		sig = Osc.ar(buf, freq * detuneCtrl, {Rand(0,2pi)}!8);

		sig = Splay.ar(sig); //spread 8 signals over stereo field
		sig = LeakDC.ar(sig); //remove DC bias
		sig = LPF.ar(sig, lowpass);
		sig = HPF.ar(sig, highpass);
		sig = Balance2.ar(sig[0], sig[1], pan, amp); //L/R balance (pan)
		sig = sig * env;
		Out.ar(out, sig);
		Out.ar(rout, sig * rsend); //"post-fader" send to reverb
		Out.ar(dout, sig * dsend); //"post-fader" send to delay
	}).add;

	SynthDef(\delay_network, {
		var inSig, in = \in.kr(10), mix = \mix.kr(0.3), sig, src, feed, feedback = \feedback.kr(0.3), amp, revAmp = \revMix.kr(0.5);

		inSig = In.ar(in, 2);
		feed = LocalIn.ar(2);
		// XFadeDelay from wslib quark, to avoid artificts when changing delaytime
		src = Limiter.ar(XFadeDelay.ar((inSig*min(feedback, 1.0)) + feed, 1, \delaytime.kr(0.2)));
		LocalOut.ar(src * feedback);
		sig = (src * mix) + (inSig * (1-mix));

		amp = 1.0 - revAmp;

		Out.ar(\revOut.kr(10), sig*revAmp);
		Out.ar(\out.kr(0), sig*amp);

	}).add;

	SynthDef(\reverb, {
		var sig, predelay = \predelay.kr(0.01), force = \force.kr(0);
		sig = In.ar(\in.kr(14), 2);
		sig = DelayN.ar(sig, predelay, predelay);
		sig = NHHall.ar(sig, \rt60.kr(0.5), 0.5, 200, 0.5, 5000, 0.2, earlyDiffusion: 0.55, lateDiffusion: 0.4, modRate: 0.2, modDepth: 0.3);

		Out.ar(\out.kr(0), sig);
	}).add;

	s.sync();


	{
		var file_content;

		// read score from file
		file_content = File.readAllString("score1.csv".resolveRelative);

		// Event factory for nodes
		~make_node = { |line|
			var items = line.split($,);
			(
				depth: items[0].asFloat,
				sourceName: items[1].asString, // source is a reserved name in an Event
				relevance: items[2].asFloat
			)
		};

		// convert lines of text to node Events (proto-instance of object)
		~score = file_content.split($\n).collect({|str, i| i.postln; ~make_node.(str)});
		"Score loaded".postln;

		// run wavetable setup code using the ~score
		"wavetable_setup.scd".loadRelative;
	}.value();

	{
		var bPitches = ([31, 38, 47, 55, 62] + 4).midicps,
		fissPitches = [54, 58, 61, 64, 68, 71, 74, 76, 77,
			78, 82, 85, 88, 92, 95, 98, 100, 101, 102
		].midicps;
		fork { var tempo = 0.095;
			~revBus = Bus.audio(s, 2);
			~delayBus = Bus.audio(s, 2);
			s.sync();
			Synth(\reverb, [\in, ~revBus, \rt60, 2.0]);
			~delay = Synth(\delay_network, [\out, 0, \revOut, ~revBus, \revMix, 0.5, \in, ~delayBus, \mix, 1.0, \feedback, 0.4, \delaytime, 0.2]);
			s.sync();
			~score.do { | node |
				var freq = 50, octave, amp = 0.1, decay, revAmp = 0;
				if(node.sourceName == "App", {
					freq = bPitches[node.depth % bPitches.size]; // get pitch from G chord
					octave = (node.depth / bPitches.size).floor + 1; // how many times the depth value "wraps" the array length
					freq = freq * octave;
				}, {
					freq = fissPitches[node.depth % fissPitches.size]; // get pitch from F# chord, wrapping around it
					octave = ((node.depth / fissPitches.size).floor); // how many times the depth value "wraps" the array length
				});

				decay = (10/((node.depth+1)*0.9)).pow(2);
				decay = min(decay, 60);

				amp = 1.0 / (node.depth+1);
				amp = min(amp, 0.1);
				amp = amp * (node.relevance.pow(2));
				amp = min(amp, 0.5);

				revAmp = (node.depth/30.0).pow(3);

				~delay.set(\delaytime, (node.depth/44.0).pow(2.0) + 0.03, \revMix, node.depth/70.0, \feedback, node.depth/50.0);

				if(node.sourceName == "App", {
					Synth(\sine_lead, [\amp, amp*1.8, \freq, max(min(freq, 18000), 20), \decay, decay, \pan, rrand(-0.2, 0.2),
						\revOut, ~revBus, \revMix, revAmp]);
					[freq*0.5, freq*1.01, freq*3].do { |fr|
						Synth(\osc, [\buf, ~wt_buf, \amp, amp*0.3, \freq, fr, \rel, decay*0.5, \atk, 0.0001, \detune, 0.15,
							\c1, -30, \sus, 0,  \lowpass, min(freq*14, 20000), \lowpassTime, 0,
							\rout, ~revBus, \rsend, revAmp*(10/(node.depth + 1))])
					};
				}, {
					var pan = rrand(-1, 1), attack, decayMult, c0, lowpassTime;
					pan = pan * (1/max(node.depth-15, 1).pow(0.5));
					decay = min(decay, 10);

					if(node.relevance > 12, {
						attack = (node.depth/44.0).pow(6) * 60;
						attack = max(attack, 0.001);
						if((node.relevance > 10) || (freq > 2000)) { attack = 0.001 };
						c0 = min(attack * 15, 20);
						lowpassTime = attack;
					}, {
						attack = 0.001;
						c0 = 0;
						lowpassTime = 0;
					});


					if(lowpassTime < 0.01) {lowpassTime = 0; }; // avoid the lowpass ramp creating an impulse noise transient

					decayMult = max(node.depth/25.0, 1.0)*10.0;

					Synth(\sine_lead, [\amp, min(amp*2, 0.5), \freq, max(min(freq, 18000), 20), \decay, decay, \pan, pan,
						\revOut, ~revBus, \revMix, revAmp]);
					Synth(\osc, [\buf, ~wt_buf, \lowpass, min(freq*8, 20000), \lowpassTime, attack, \highpass, freq*0.5,
						\amp, amp.pow(2) * 0.15, \freq, max(min(freq, 18000), 20), \rel, decay * 2.0, \atk, attack,
						\detune, 0.05, \c0, c0, \c1, -20, \sus, 0, \dout, ~delayBus, \dsend, 0.5,
						\rout, ~revBus, \rsend, revAmp*1.0, \pan, pan])
				});

				0.095.wait;
			}
		}
	}.value();
});
)