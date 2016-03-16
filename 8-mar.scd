(
{var env1=Env([200,600,2400,350,3000],[0.5,4,1.1,0.7,2.3,6]), env2=Env([450,800,1800,80],[3,0.8,2]);
    Mix(
        Resonz.ar
        (Saw.ar([440, 443,437,447]
            +SinOsc.ar(100,0,100)),
            EnvGen.kr(env1),
            Line.kr(1,0.05, 10),
        mul: LFSaw.kr(Line.kr(3,17,3),0,0.5,0.5)*Line.kr(1,0,10)
    )
)
}.scope
)

(

var env1=Env([200,600],[0.5]);
//var gen = EnvGen.ar(env1);
{(Saw.ar(EnvGen.ar(env1)))}
)


(
var gen, env1;
env1=Env([200,600,100,300],[1,1,1], \sin, releaseNode:2, loopNode:0);

{
	gen=EnvGen.ar(env1);
	(Saw.ar(gen))
}.scope
)

{ SinOsc.ar(EnvGen.kr(Env.new([60, 40, 50, 40] + 30, [1, 1, 1], releaseNode:2, loopNode:0)).midicps, 0, 0.1) }.play;

{Saw.ar(Rand(300, 1000),Line.kr(500, 3, 2), 0, 0.1)}.scope
