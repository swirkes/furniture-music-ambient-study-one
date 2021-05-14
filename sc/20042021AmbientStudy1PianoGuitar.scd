s.boot;

(
~p_high = Array.new;
~p_med = Array.new;
~p_low = Array.new;
~birds = Array.new;
~guitar = Array.new;

~folder_high = PathName.new("/home/pi/AmbientStudy1Samples/PianoHigh/");
~folder_med = PathName.new("/home/pi/AmbientStudy1Samples/PianoMedium/");
~folder_low = PathName.new("/home/pi/AmbientStudy1Samples/PianoLow/");
~folder_birds = PathName.new("/home/pi/AmbientStudy1Samples/ForestBirds/");
~folder_guitar = PathName.new("/home/pi/AmbientStudy1Samples/BowedGuitar/");

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


SynthDef.new(\bufrd, {
	arg amp=1, out=0, buf;
	var sig, ptr;
	ptr = Line.ar(0, BufFrames.kr(buf) - 1, BufDur.kr(buf), doneAction:2);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;

)
  //--------------------------------------//
 //trigger piano lines with motion sensor//
//--------------------------------------//

(
~p_highSynth = Synth.new(\bufrd, [\buf, ~p_high[rrand(0, 9)].bufnum, \amp, 0.3]);
~p_medSynth = Synth.new(\bufrd, [\buf, ~p_med[rrand(0, 9)].bufnum, \amp, 0.3]);
~p_lowSynth = Synth.new(\bufrd, [\buf, ~p_low[rrand(0, 9)].bufnum, \amp, 0.3]);
~birdSynth = Synth.new(\bufrd, [\buf, ~birds[0].bufnum, \amp, 0.15]);
~guitarSynth = Synth.new(\bufrd, [\buf, ~guitar[0].bufnum, \amp, 0.5]);
)

~p_highSynth.set(\buf, ~p_high[8].bufnum);
(

p = Pdef(\pianolines,
Pxrand([
    Pbind(            // repeated notes
        \instrument, \bufrd,
			\buf, ~p_high[0].bufnum,
			\amp, 0.3
    ),
    Pmono(\bufrd,
        \buf, ~p_high[1].bufnum,
		\amp, 0.3
    ),
		Pmono(\bufrd,
        \buf, ~p_high[2].bufnum,
		\amp, 0.3
    ),
		Pmono(\bufrd,
        \buf, ~p_high[3].bufnum,
		\amp, 0.3
    ),
		Pmono(\bufrd,
        \buf, ~p_high[4].bufnum,
		\amp, 0.3
    ),
		Pmono(\bufrd,
        \buf, ~p_high[5].bufnum,
		\amp, 0.3
    )
], inf)).play(quant: 1);
)
p.stop;







