// create wavetable from depth data
// code inspired from Eli Fieldsteel's tutorial http://sccode.org/1-5bF


{ // simplify wave
var depth_values = ~score.collect { |node, i| node.depth/44; }, reduction = 10, numSegs = 0;

// a naive reduction of data points by taking the average of several points

depth_values = (0..((depth_values.size-1)/reduction).floor).collect { |i| var avg = 0, numValues = reduction;
	i.postln;
	if (depth_values.size-1 - (i * reduction) < numValues) {
		numValues = depth_values.size-1 - (i * reduction);
	};
	numValues.do { | j |
		avg = avg +depth_values[(i*10) + j];
	};
	avg = avg / numValues;
};

numSegs = depth_values.size + 1;

~depth_wave = Env(
	//env always begins and ends with zero
	//inner points are random from -1.0 to 1.0
	[0]++depth_values++[0],

	//segment duration
	//{exprand(1,i.linexp(0,9,1,50))}.dup(numSegs),
	{1}.dup(numSegs),

	//low-index wavetables tend to be sinusoidal
	//high index wavetables tend to have sharp angles and corners
	//{[\sine,0,exprand(1,20) * [1,-1].choose].wchoose([9-i,3,i].normalizeSum)}.dup(numSegs)
	{0}.dup(numSegs),
).asSignal(1024);

// load wavetable into buffer
~wt_buf = Buffer.alloc(s, 2048, 1, {
	arg buf, index;
	buf.setnMsg(0, ~depth_wave.asWavetable);
});
}.fork;




// (
// // implementation of the Douglas-Peucker algorithm
// // Either I made a mistake or SuperCollider is unsuitable, but it crashes the system by taking up too much memory (?)
// ~perpendicularDistance = { | point, a, b, c|
// 	// formula: d= ​abs(a(x0​)+b(y0​)+c)​ / sqrt(a.pow(2) + b.pow(2))
// 	abs((a*point[0]) + (b*point[1]) + c) / sqrt(a.pow(2) + b.pow(2));
// };
// ~douglas_peucker_reduce = { | list, epsilon |
// 	var dmax = 0, index = 0, end = list.size, resultsList = [], d,
// 	a, b, c; // for line between end points
//
// 	// calculate the line that goes through the end points
// 	a = list[end-1][1] - list[0][1];
// 	b = list[0][0] - list[end-1][0];
// 	c = ((a * list[0][1]) + (b * list[0][0])) * -1;
//
// 	(1..(end-2)).do { |i|
// 		// this is supposed to be the perpendicular distance to the line between the first and last points
// 		d = ~perpendicularDistance.(list[i], a, b, c);
// 		if( d > dmax) {
// 			dmax = d;
// 			index = i;
// 		}
// 	};
//
// 	if( dmax > epsilon, { var results1 = List[], results2 = List[];
// 		// recursively call itself
// 		results1 = ~douglas_peucker_reduce.(list[0..index], epsilon);
// 		results2 = ~douglas_peucker_reduce.(list[index..end], epsilon);
// 		resultsList = results1 ++ results2;
// 		}, {
// 			resultsList = list;
// 	});
//
// 	resultsList
// };
// var depth_values = ~score.collect { |node, i| [i, node.depth/44.0] };
// depth_values = ~douglas_peucker_reduce.(depth_values, 0.1);
// )
