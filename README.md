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

For more information please see the
[Blister Web site](http://www.blister.org/) or, if you're offline, the
[site source files](site/index.md).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `blister` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:blister, "~> 0.1.0"}]
    end
    ```

  2. Ensure `blister` is started before your application:

    ```elixir
    def application do
      [applications: [:blister]]
    end
    ```

## About

Blister is a rewrite of [PatchMaster](http://patchmaster.org/) in Elixir.

# To Do

- Triggers and messages can take either lists of messages or functions
- Fix examples/example.exs format
- Better names for IO, at least in config files
- App needs to accept file name to read on start
