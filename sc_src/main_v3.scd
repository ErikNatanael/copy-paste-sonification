(
SynthDef(\sine_lead, {
	var sig, env, freq = \freq.kr(400), amp = \amp.kr(0.5), noiseSig, pan = \pan.kr(0), ampJitter, jitterAmount = \jitterAmount.kr(0.3);

	//breaking = min((pressure*4) + (pressure * excitation), 1.0);
	//invBreaking = max(0.99 - breaking.pow(2), 0.0) + 0.01;

	env = EnvGen.kr(Env.perc(\attack.kr(0.02), \decay.kr(0.5), 1.0, -12.0), doneAction:2);
	ampJitter = LFNoise2.kr(10 + (jitterAmount*100)).range(0.5-(jitterAmount*0.5), 1.0);

	noiseSig = RHPF.ar(RLPF.ar(PinkNoise.ar()*0.1, freq, 0.02), freq, 0.01) * 0.08 * AmpCompA.ir(freq);
	//noiseSig = (noiseSig*10).tanh * 0.5;
	noiseSig = Pan2.ar(noiseSig*env*ampJitter, pan);

	sig = SinOsc.ar(freq)*0.05;
	// sig = noiseSig + sig;
	sig = sig * env * \active.kr(1, 0.02) * ampJitter;
	sig = Pan2.ar(sig, pan);

	Out.ar(\revOut.kr(14), noiseSig*amp*\revMix.kr(0));
	Out.ar(\out.kr(0), noiseSig*amp);
	//Out.ar(\out2.kr(0), sig*amp);
}).add;

SynthDef(\tone_explosion, { | out = 0, amp = 1, length = 5, minRate = 5, maxRate = 70, freq = 12000 |
	var sig, env, transient, tone, toneenv, trig;

	sig = WhiteNoise.ar();
	sig = (sig*100).tanh * 0.04;
	trig = Dust.kr(XLine.kr(minRate, maxRate, length));

	tone = Resonz.ar(sig, freq*TRand.kr(0.99, 1.01, trig), 0.0001, 500);
	tone = tone * EnvGen.kr(Env(
		levels: [ 0, 1, 0.1, 0],
		times: [0.0001, length/8, length*0.875],
		curve: [0, -4, -12, -12]
	), doneAction: 2);

	sig = tone;

	sig = sig * ({Demand.kr(trig + Impulse.kr(0), 0, Dseq([1, 0], inf))}!2);

	Out.ar(out, Pan2.ar(sig * amp));
}).add;

SynthDef(\reverb, {
	var sig, predelay = \predelay.kr(0.01), force = \force.kr(0);
	sig = In.ar(\in.kr(14), 2);
	sig = sig + (PitchShift.ar(sig, 0.2, 0.52, 0.3)*force.linexp(0, 1, 0.001, 1.0));
	sig = DelayN.ar(sig, predelay, predelay);
	sig = NHHall.ar(sig, \rt60.kr(0.5), 0.5, 200, 0.5, 4000, 0.5, earlyDiffusion: 0.5, lateDiffusion: 0.5, modRate: 0.2, modDepth: 0.3);

	Out.ar(\out.kr(0), sig);
}).add;
)


( var file_content;

file_content = File.readAllString("score1.csv".resolveRelative);

~make_node = { |line|
	var items = line.split($,);
	(
		depth: items[0].asFloat,
		sourceName: items[1].asString, // source is a reserved name in an Event
		relevance: items[2].asFloat
	)
};

~score = file_content.split($\n).collect({|str, i| i.postln; ~make_node.(str)});
"Score loaded".postln;

)

(
var gPitches = ([31, 38, 47, 55, 62]).midicps,
fissPitches = [54, 58, 61, 64, 68, 71, 74, 76, 77,
	78, 82, 85, 88, 92, 95, 98, 100, 101, 102
].midicps; // 78 is the next f#
fork {
	~revBus = Bus.audio(s, 2);
	s.sync();
	Synth(\reverb, [\in, ~revBus, \rt60, 2]);
	s.sync();
	~score.do { | node |
		var freq = 50, octave, amp = 0.1, decay, revAmp = 0;
		if(node.sourceName == "App", {
			freq = gPitches[node.depth % gPitches.size]; // get pitch from G chord
			octave = (node.depth / gPitches.size).floor + 1; // how many times the depth value "wraps" the array length
			freq = freq * octave;
		}, {
			freq = fissPitches[node.depth % fissPitches.size]; // get pitch from F# chord, wrapping around it
			octave = ((node.depth / fissPitches.size).floor); // how many times the depth value "wraps" the array length
			//freq = freq * (((octave % 2 ) * 2 ) + 1);
		});

		/*if(node.relevance > 1, {
			fissPitches = fissPitches * 1.01;
		}, {
			fissPitches = fissPitches * 0.999;
		});*/

		if(node.relevance > 10) {
			//Synth(\tone_explosion, [\freq, min(freq * 8, 14000), \amp, 0.1]);
		};

		//decay = (10/(node.depth+1)).pow(3);
		decay = (10/(node.depth+1)).pow(2); // middle decay at low depths and less difference between depths
		//decay = (3/(node.depth+1)).pow(2); // shorter decay at low depths
		decay = min(decay, 90);

		amp = 0.5 / (node.depth+1);
		amp = min(amp, 0.1);
		amp = amp * (node.relevance.pow(2));
		amp = min(amp, 0.5);

		revAmp = (node.depth/30.0).pow(2);

		Synth(\sine_lead, [\amp, amp, \freq, max(min(freq, 18000), 20), \decay, decay, \pan, rrand(-1, 1),\revOut, ~revBus, \revMix, revAmp]);
		0.01.wait;
	}
}
)

// count amount of nodes with relevance over x

( var nNodes = 0, relevance = 10;
~score.do { | node |
	if(node.relevance > relevance) {
		nNodes = nNodes + 1;
		node.relevance.postln;
	};
};
nNodes.postln;
)

(
([31, 38, 47, 55, 62]).midicps.do {|fr| Synth(\sine_lead, [\amp, amp, \freq, max(min(freq, 18000), 20), \decay, decay, \pan, rrand(-1, 1)]);
)