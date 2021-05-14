s.boot;
//test signal
{SinOsc.ar(440)}.play;
Buffer.freeAll;

//
(
~p_high = Array.new;
~p_med = Array.new;
~p_low = Array.new;
~birds = Array.new;
~guitar = Array.new;

~folder_high = PathName.new("/home/pi/ambient_study_one/samples/piano_high/");
~folder_med = PathName.new("/home/pi/ambient_study_one/samples/piano_medium/");
~folder_low = PathName.new("/home/pi/ambient_study_one/samples/piano_low/");
~folder_birds = PathName.new("/home/pi/ambient_study_one/samples/forest_birds/");
~folder_guitar = PathName.new("/home/pi/ambient_study_one/samples/bowed_guitar/");

~folder_high.entries.do({
	arg path;
	~p_high = ~p_high.add(Buffer.read(s, path.fullPath));
});

~folder_med.entries.do({
	arg path;
	~p_med = ~p_med.add(Buffer.read(s, path.fullPath));
});

~folder_low.entries.do({
	arg path;
	~p_low = ~p_low.add(Buffer.read(s, path.fullPath));
});
~folder_birds.entries.do({
	arg path;
	~birds = ~birds.add(Buffer.read(s, path.fullPath));
});
~folder_guitar.entries.do({
	arg path;
	~guitar = ~guitar.add(Buffer.read(s, path.fullPath));
});
~guitar[0]

SynthDef.new(\bufrd, {
	arg amp=1, out=0, buf;
	var sig, ptr;
	ptr = Line.ar(0, BufFrames.kr(buf) - 1, BufDur.kr(buf), doneAction:2);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;


(
SynthDef.new(\twobufrd, {
	arg amp=1, out=0, xfade=0, buf1, buf2;
	var sig, sig1, sig2, ptr1, ptr2;
	ptr1 = Line.ar(0, BufFrames.kr(buf1) - 1, BufDur.kr(buf1), doneAction:2);
	ptr2 = Line.ar(0, BufFrames.kr(buf2) - 1, BufDur.kr(buf2), doneAction:2);
	sig1 = BufRd.ar(2, buf1, ptr1);
	sig2 = BufRd.ar(2, buf2, ptr2);
	sig1 = sig1 * amp;
	sig2 = sig2 * amp;
	Out.ar(out, XFade2.ar(sig1, sig2, xfade));
}).add;
)


)
  //--------------------------------------//
 //trigger piano lines with motion sensor//
//--------------------------------------//

(
~p_highSynth = Synth.new(\bufrd, [\buf, ~p_high[rrand(0, 9)].bufnum, \amp, 0.3]);
~p_medSynth = Synth.new(\bufrd, [\buf, ~p_med[rrand(0, 9)].bufnum, \amp, 0.3]);
~p_lowSynth = Synth.new(\bufrd, [\buf, ~p_low[rrand(0, 9)].bufnum, \amp, 0.3]);
~birdSynth = Synth.new(\bufrd, [\buf, ~birds[0].bufnum, \amp, 0.15]);
~guitarSynth = Synth.new(\bufrd, [\buf, ~guitar[0].bufnum]);
)

x = Synth.new(\twobufrd, [\buf1, ~guitar[0].bufnum, \buf2, ~birds[0].bufnum]);
x.free
x.set(\xfade, 0.55)

~p_highSynth.set(\buf, ~p_high[8].bufnum);
(
~pianopattern = Pdef(\pianolines,
Pxrand([
    Pbind(
        \instrument, \bufrd,
			\buf, ~p_high[0].bufnum,
			\amp, 0.3
    ),
    Pbind(\instrument, \bufrd,
        \buf, ~p_high[1].bufnum,
		\amp, 0.3
    ),
		Pbind(\instrument, \bufrd,
        \buf, ~p_high[2].bufnum,
		\amp, 0.3
    ),
		Pbind(\instrument, \bufrd,
        \buf, ~p_high[3].bufnum,
		\amp, 0.3
    ),
		Pbind(\instrument, \bufrd,
        \buf, ~p_high[4].bufnum,
		\amp, 0.3
    ),
		Pbind(\instrument, \bufrd,
        \buf, ~p_high[5].bufnum,
		\amp, 0.3
    )
], 2)).play(quant: 1);
)
(
~pianopatternmed = Pdef(\pianolinesmed,
Pxrand([
    Pbind(
        \instrument, \bufrd,
			\buf, ~p_med[0].bufnum,
			\amp, 0.3
    ),
    Pbind(\instrument, \bufrd,
        \buf, ~p_med[1].bufnum,
		\amp, 0.3
    ),
		Pbind(\instrument, \bufrd,
        \buf, ~p_med[2].bufnum,
		\amp, 0.3
    ),
		Pbind(\instrument, \bufrd,
        \buf, ~p_med[3].bufnum,
		\amp, 0.3
    ),
		Pbind(\instrument, \bufrd,
        \buf, ~p_med[4].bufnum,
		\amp, 0.3
    ),
		Pbind(\instrument, \bufrd,
        \buf, ~p_med[5].bufnum,
		\amp, 0.3
    )
], 2)).play(quant: 1);
)


~pianopattern.stop
s.prepareForRecord;
s.record;
s.stopRecording;
s.reboot;
NetAddr.langPort;
NetAddr.localAddr;
n = NetAddr.new("192.168.1.114", 57120);
thisProcess.openUDPPort(7771);
~message = "message";
o = OSCFunc({arg msg, time, addr, recvPort; ~message = msg; }, '\hello');
OSCFunc.trace(true);
OSCFunc.trace(false);
~message[1].postln;
~message[1].linlin(20000.0, 60000.0, -1.0, 1.0).postln;
(
~control = Routine.new({
	{
		o = OSCFunc({arg msg, time, addr, recvPort; ~message = msg; }, '\hello');
		x.set(\xfade, ~message[1].linlin(20000, 60000, -1, 1).postln);

		0.1.wait;
    }.loop
}).play;
)