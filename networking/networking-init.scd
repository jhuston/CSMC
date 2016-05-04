// LOCAL MACHINE NAME
~localMachine = "river.local"



NetAddr(~localMachine, NetAddr.langPort)
~robert = NetAddr("nsa-data-collection.local", 57120);
~jason = NetAddr("192.168.0.101", 57120);
~jeff = NetAddr("codedoval.local", 57120);
~james = NetAddr("river.local", 57120);


// • Step 5: LOCAL & REMOTE
//	Create an OSCresponder. The one below is just for testing, so it only prints out what it received.


~robert.sendMsg('robert', "test ", 0.5);
~jeff.sendMsg('jeff', "test", 0.5);
~jason.sendMsg('jason', "test", 0.5);
~james.sendMsg('james', "test", 0.5);

("Tesla.local") with the IP or name of the machine you want to connect to

// 2. making a responder for receiving
r = OSCresponder(~james, 'james', { arg time, resp, msg;
	[time, msg[1]].postln;
	{~jamesKnob.value_(msg[1])}.defer;
	}).add;


// 3. Making a GUI window with a knob to send, and a knob to receive:
(
var window = Window.new("Networking test",Rect(318, 456, 400, 400)).front;

~jeffKnob = Knob.new(window,Rect(10, 205, 100, 100))
	.action_{|v|
		~jeff.sendMsg('jeff', v.value);
		};
~robertKnob = Knob.new(window,Rect(100, 205, 100, 100))
	.action_{|v|
		~robert.sendMsg('robert', v.value);
		};
~jasonKnob = Knob.new(window,Rect(200, 205, 100, 100))
	.action_{|v|
		~jason.sendMsg('jason', v.value);
		};
~jamesKnob = Knob.new(window,Rect(8, 11, 100, 100))
	.action_{|v|};

StaticText.new(window,Rect(10, 150, 148, 50))
	.string_("jeff");
StaticText.new(window,Rect(100, 150, 130, 47))
	.string_("robert");
StaticText.new(window,Rect(200, 150, 148, 50))
	.string_("jason");

)

/* Now, do the same in the remote machine, replacing in:
1. the IP of the receiving machine to the IP of this one
2. the cmdName of the OSCresponder to the name you're using in (3)
3. Replace the name you're using in (3) with the name you use in (2)
*/

// Don't forget to remove your responder once you're done!
r.remove



// ====== AN EXAMPLE WITH SOUND: LOCAL ======
// In this simple example, we will create the same GUI interface with two knobs, except this time the 'sending' knob will get data from analysis of the sound in the local machine, and will send the data to the remote machine to affect the synthesis there - and vice versa.

// • Synthesis: a self-phase-modulated Sinewave, with analysis to show how noisy it is:

s.boot;

(
~mult = 4;
// buffer for FFT
~buf = Buffer.alloc(s,2048,1);
// the synthdef
~fdbFM = CtkSynthDef(\fdbSine, {arg freq, fdbAmt, amp, pollFreq = 2, gate = 1;
	var sine, mod, fdbIn, fdbOut, env, chain, flatness;
	fdbIn = LocalIn.ar(1);
	env = EnvGen.kr(Env.new([0.00001, 1, 1, 0.00001], [0.05, 0.9, 0.5], [\exp, \sin], 1), gate,  doneAction: 2);
	mod = fdbIn * fdbAmt;
	sine = SinOsc.ar(freq, mod, amp); // fdb phase modulation
	chain = FFT(~buf, sine);
	flatness = SpecFlatness.kr(chain);
	SendReply.kr(Impulse.kr(pollFreq), 'flatness', flatness);
	Out.ar(0, sine * env);
	fdbOut = LocalOut.ar(sine);
})
);

// 1. connecting:
~remoteComp = NetAddr("169.254.144.182", 57120); // replace the IP ("Tesla.local") with the IP or name of the machine you want to connect to



// 2. making a responder for receiving
r = OSCresponder(~remoteComp, 'stmIncoming', { arg time, resp, msg;
	[time, msg[1]].postln;
	{~recKnob.value_(msg[1])}.defer;
	~note.fdbAmt_(msg[1] * ~mult + 1)
	}).add;


// 2a. making a responder for receiving from the analysis data from the synthdef, and moving the knob
~noisiness = OSCresponder(~remoteComp, 'flatness', { arg time, resp, msg;
	msg[3].postln;
	{~sendKnob.valueAction_(msg[3])}.defer; // naturally, it would be more efficient to send the message directly to the remote server, this is just for demonstration purposes...
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



~note = ~fdbFM.new().freq_(160).fdbAmt_(5.5).amp_(0.5).play
// change some numbers
~note.freq_(124)
~note.fdbAmt_(5.4)
~note.fdbAmt_(1244)
~mult = 4.6
~note.pollFreq_(2.6)
~note.release


// remove the responders
r.remove;
~noisiness.remove;





// ====== TROUBLESHOOTING ======

/* ATTENTION: IF THE ABOVE DOESN'T WORK, TRY TO RESET THE FOLLOWING:
- NetAddr ip (IPs may have changed and you may be using an older one)
- disconnect/reconnect to LAN (that has worked many times for me in the past...)
- relaunch SC (maybe something is hanging from before)
*/


// You can use the code below to troubleshoot, and see if there is anything coming in:
(
thisProcess.recvOSCfunc = { |time, addr, msg|
	if(msg[0] != 'status.reply') {
		"time: % sender: %\nmessage: %\n".postf(time, addr, msg);

	}
}
);

// stop posting.
thisProcess.recvOSCfunc = nil;




// ====== ADDITIONAL NETWORKING QUARKS ======

// NetLib is a very nice, small experimental library for collaborative network ensembles
// Republic is a class taking over some of the administrational burdens of organizing LAN group performances
// ListeningClocks 3 clocks that can communicate with other clocks for synchronizing performances over several computer in a nework


// ------ iPhone/iPodTouch/iPad --
// Connecting to an iThing is a very similar process, except the fact that you need a dedicated environment for sending OSC messages from the portable device. Until there is an official port of SC for iThings, a couple (free) examples include the mrmr App and rjdj.

// • Mrmr
// With mrmr you can create interfaces and control SC remotely. There is a quark that lets you create those interfaces from your computer, and which handles some of burdens of communication internally.
Quarks.install( "Mrmr", checkoutIfNeeded: false)
// The helpfile is pretty much all you need to get started

// • rjdj
// rjdj is a port of PureData for the iPhone/iPodTouch. There is also an iPad version, called rjVoyager. What is nice about it is that you can create Pd patches in your computer and load them to the portable device. This is probably worse for using as a controller of a remote machine as there are less GUI widgets, but you can actually do part of the processing in the portable device, and even make sounds with it!

