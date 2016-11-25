# hexaphone
Hexaphone for iOS


I built Hexaphone in 2010 to attempt to provide an improvisational keyboard app to the iPhone platform.  It's sat idle for years, and even though the codebase is poorly documented, I'm releasing it in case it's useful to anyone trying to build audio software.

Apologies for having all files dumped in one directory - in XCode they're organized into folder groups.

The sound engine is demoscene-inspired; using small waveforms that are set up to loop when sustained.  The important files are:

* https://github.com/glenn-barnett/hexaphone/blob/master/Classes/Instrument.m
* https://github.com/glenn-barnett/hexaphone/blob/master/patches.json
* All the tiny .caf files like IIx_1C.caf (sample IIx, octave 1, C)

The UI uses a six-note scale, set to the hexatonic blues scale by default, but configurable to other scales.  5 octaves are available, by dragging the "minimap" to scroll the view.

* https://github.com/glenn-barnett/hexaphone/blob/master/scales.json
* all the pngs

Background drum loops came from two sources:
* https://github.com/glenn-barnett/hexaphone/blob/master/loops.json
* Apple's Garage Band's public set
* The now-defunct Beatserv

There are two types of recording capabilities - note data and waveform (used for audiocopy).

There's also a ~24db lowpass "Motion Filter" which you can see in action here:
* https://vimeo.com/15212762

