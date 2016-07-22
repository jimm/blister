use Mix.Config
config :blister,
  driver: Blister.MIDI.PortMidi,
  gui: Blister.GUI.Text
config :logger, :blister_logger,
  path: "/tmp/blister_test.log",
  level: :warn
