(
SynthDef(\sine_lead, {
	var sig, env, freq = \freq.kr(400), amp = \amp.kr(0.5), noiseSig, pan = \pan.kr(0), ampJitter, jitterAmount = \jitterAmount.kr(0.3);

	//breaking = min((pressure*4) + (pressure * excitation), 1.0);
	//invBreaking = max(0.99 - breaking.pow(2), 0.0) + 0.01;

	env = EnvGen.kr(Env.perc(\attack.kr(0.02), \decay.kr(0.5), 1.0, -12.0), doneAction:2);
	ampJitter = LFNoise2.kr(10 + (jitterAmount*100)).range(0.5-(jitterAmount*0.5), 1.0);

	noiseSig = RHPF.ar(RLPF.ar(PinkNoise.ar()*0.1, freq, 0.02), freq, 0.01) * 0.08;
	//noiseSig = (noiseSig*10).tanh * 0.5;
	noiseSig = Pan2.ar(noiseSig*env*ampJitter, pan);

	sig = SinOsc.ar(freq)*0.05;
	// sig = noiseSig + sig;
	sig = sig * env * \active.kr(1, 0.02) * ampJitter;
	sig = Pan2.ar(sig, pan);

	//Out.ar(\revOut.kr(14), noiseSig*amp*\revMix.kr(0));
	Out.ar(\out.kr(0), noiseSig*amp);
	//Out.ar(\out2.kr(0), sig*amp);
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
var gPitches = [31, 38, 47].midicps,
fissPitches = [54, 58, 61, 64, 68, 71, 74, 76, 77].midicps; // 78 is the next f#
fork {
	~score.do { | node |
		var freq = 50, octave;
		if(node.sourceName == "App", {
			freq = gPitches[node.depth % gPitches.size]; // get pitch from G chord
			octave = (node.depth / gPitches.size).floor + 1; // how many times the depth value "wraps" the array length
			freq = freq * octave;
		}, {
			freq = fissPitches[node.depth % fissPitches.size]; // get pitch from F# chord
			octave = (node.depth / fissPitches.size).floor + 1; // how many times the depth value "wraps" the array length
			//freq = freq * octave;
		});

		//Synth(\sine_lead, [\amp, 1/(node.depth+1), \freq, (node.depth+1)*200, \decay, 10/(node.depth+1)]);
		Synth(\sine_lead, [\amp, 0.1, \freq, (node.depth+1)*50, \decay, (10/(node.depth+1)).pow(3), \pan, rrand(-1, 1)]);
		0.01.wait;
	}
}
)
~score[1].sourceName == "App"