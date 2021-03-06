use Mix.Config

config :blister,
  midi_driver_module: Blister.MIDI.MockDriver,
  use_gui: false

config :logger, :blister_logger,
  path: "/tmp/blister_test.log",
  level: :warn
