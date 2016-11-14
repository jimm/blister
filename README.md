# Blister

**NOTE**: Blister isn't anywhere near done yet.

Blister is a MIDI processing and patching system. It allows a musician to
reconfigure a MIDI setup instantaneously and modify the MIDI data in real
time.

With Blister a performer can split controlling keyboards, layer MIDI
channels, transpose them, send program changes and System Exclusive
messages, limit controller and velocity values, and much more. At the stomp
of a foot switch (or any other MIDI event), an entire MIDI system can be
totally reconfigured.

## About

Blister is a rewrite of [PatchMaster](http://patchmaster.org/) in Elixir.

## Installation

Blister requires [PortMidi](http://portmedia.sourceforge.net/portmidi/).
I use MacPorts. Here's how I compiled and installed PortMidi:

```sh
sudo port install portmidi
sudo ln -s /opt/local/include/portmidi.h /usr/local/include
sudo ln -s /opt/local/lib/libportmidi.dylib /usr/local/lib
sudo ln -s /opt/local/lib/libportmidi_s.a /usr/local/lib
```

You can try setting the `CPATH`, `LIBRARY_PATH`, and `LD_LIBRARY_PATH`
environment variables to point to the MacPorts files in /opt/local instead
of creating soft links, but I had better luck doing the latter.

## Running

Execute the shell script `bin/blister`, optionally specifying a file to
load. Open your browser to http://localhost:4000.

# To Do

- Triggers and messages can take either lists of messages or functions
- Better names for IO, at least in config files
- Better handle DSL errors
- How should filters be displayed?
