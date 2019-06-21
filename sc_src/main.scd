(
SynthDef(\sine_lead, {
	var sig, env, freq = \freq.kr(400), amp = \amp.kr(0.5), pressure = \pressure.kr(0), excitation = \excitation.kr(0), breaking, invBreaking, noiseSig, pan = \pan.kr(0), ampJitter, jitterAmount = \jitterAmount.kr(0.0);

	//breaking = min((pressure*4) + (pressure * excitation), 1.0);
	//invBreaking = max(0.99 - breaking.pow(2), 0.0) + 0.01;

	env = EnvGen.kr(Env.perc(0.01, 0.2, 0.3), doneAction:2);
	ampJitter = LFNoise2.kr(10 + (jitterAmount*100)).range(0.5-(jitterAmount*0.5), 1.0);

	noiseSig = RHPF.ar(RLPF.ar(PinkNoise.ar()*0.1, freq, 0.02), freq, 0.01) * 0.01;
	noiseSig = Pan2.ar(noiseSig*env*ampJitter, pan);

	sig = SinOsc.ar(freq)*0.05;
	// sig = noiseSig + sig;
	sig = sig * env * \active.kr(1, 0.02) * ampJitter;
	sig = Pan2.ar(sig, pan);

	//Out.ar(\revOut.kr(14), noiseSig*amp*\revMix.kr(0));
	Out.ar(\out.kr(0), noiseSig*amp);
	//Out.ar(\out2.kr(0), sig);
}).add;
)


( var file_content;

file_content = File.readAllString("score1.csv".resolveRelative);

~make_node = { |line|
	var items = line.split($,);
	(
		depth: items[0].asFloat,
		source: items[1],
		relevance: items[2].asFloat
	)
};

~score = file_content.split($\n).collect({|str, i| i.postln; ~make_node.(str)});
"Score loaded".postln;

)

(
fork {
	~score.do { | node |
		Synth(\sine_lead, [\amp, 1/(node.depth+1), \freq, (node.depth+1)*300]);
		0.1.wait;
	}
}
)

"50,erik\n60,Elvira\n".split($\n)

(""+" ").println