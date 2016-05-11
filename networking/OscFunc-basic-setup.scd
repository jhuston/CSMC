(
//replace p with your name!
p = '/jeff';
NetAddr.langPort;
~local = NetAddr("127.0.0.1", NetAddr.langPort); // local machine
~robert = NetAddr("Nsa-Data-Collection.local", 57120);
~james = NetAddr("river.local", 57120);
~jason = NetAddr("draft.local", 57120);
~jeff = NetAddr("codedoval.local", 57120);

~myFunc = OSCFunc.newMatching({|msg, time, addr, recvPort| \matching.postln; msg[1].postln}, p); // path matching

//you can delete your own name, or replace it with ~local if you want to send yourself messages
~james.sendMsg("/james", "Test from jeff");
~jeff.sendMsg("/jeff", "Test from jeff");
~jason.sendMsg("/jason", "Test from jeff");
~robert.sendMsg("/robert", "Test from jeff");
)

// good citizenry to free the responder function when you are done.
~myFunc.free()

//see all the registered responder functions in your global store. We still haven't figured out a good way to clear all the functions.
OSCFunc.allFuncProxies()

OSCFunc.allDisabled()