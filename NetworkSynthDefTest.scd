s.boot;


// 1. connecting:
~remoteComp = NetAddr("169.254.144.182", 57120); // replace the IP ("Tesla.local") with the IP or name of the machine you want to connect to



(
var sd,array;
sd=SynthDef(\netPlay, {
	arg amp,freqMul,choose,freqPulse;
	amp=0.1;
	freqMul=900;
	choose=0;
	freqPulse=4;
	array=[Saw.ar(LFNoise0.kr([2, 3],
	freqMul,Dust.kr(0.9,1900,100)),
	mul:LFPulse.kr([freqPulse,freqPulse+(freqPulse*0.25)]) * amp),

	       SinOsc.ar(LFNoise0.kr([2, 3],
	freqMul,Dust.kr(0.9,1900,100)),
	mul:LFPulse.kr([freqPulse,freqPulse+(freqPulse*0.25)]) * amp),

	       Pulse.ar(LFNoise0.kr([2, 3],
	freqMul,Dust.kr(0.9,1900,100)),
	mul:LFPulse.kr([freqPulse,freqPulse+(freqPulse*0.25)]) * amp)];

	Out.ar(0,Select.ar(choose,array));
}).play;
)


// 1. connecting:
~remoteComp = NetAddr("169.254.144.182", 57120); // replace the IP ("Tesla.local") with the IP or name of the machine you want to connect to



// 2. making a responder for receiving
r = OSCresponder(~remoteComp, 'stmIncoming', { arg time, resp, msg;
	[time, msg[1]].postln;
	{~recKnob.value_(msg[1])}.defer;
	~note.amp_(msg[1])
	}).add;

~waveform=OSCresponder(~remoteComp, 'waveform', { arg time, resp, msg;
	[time, msg[2]].postln;
	{~recKnob.value_(msg[2])}.defer;
	~note.choose_(msg[2]*2.round(1))
	}).add;

~pulseFreq=OSCresponder(~remoteComp, 'waveform', { arg time, resp, msg;
	[time, msg[3]].postln;
	{~recKnob.value_(msg[3])}.defer;
	~note.choose_(msg[3]*25+1)
	}).add;

// 2a. making a responder for receiving from the analysis data from the synthdef, and moving the knob
~pitch = OSCresponder(~remoteComp, 'pitch', { arg time, resp, msg;
	msg[4].postln;
	{~sendKnob.valueAction_(msg[4]*1000+50)}.defer; // naturally, it would be more efficient to send the message directly to the remote server, this is just for demonstration purposes...
	}).add;


// 3. Making a GUI window with a knob to send, and a knob to receive:
(
var window = Window.new("Networking test",Rect(318, 456, 400, 400)).front;
~recKnob = Knob.new(window,Rect(175, 205, 217, 189))
	.action_{|v| };
~sendKnob = Knob.new(window,Rect(8, 11, 216, 188))
	.action_{|v|
		~remoteComp.sendMsg('dxlab8', v.value); // << action: sending to remote machine
		};
StaticText.new(window,Rect(24, 333, 148, 50))
	.string_("Receive some data -->>");
StaticText.new(window,Rect(229, 15, 130, 47))
	.string_("<<-- Send some data");
)
