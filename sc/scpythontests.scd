s.boot;
SynthDef(\playbuf, { |out = 0, bufnum = 0, gain = 0.0|
    var data = PlayBuf.ar(1, bufnum, loop: 1) * gain.dbamp;
    Out.ar(out, Pan2.ar(data));
}).store;

SynthDef(\sine, { |out = 0, freq = 440.0, gain = 0.0|
    Out.ar(out, SinOsc.ar(freq) * gain.dbamp);
}).store;
