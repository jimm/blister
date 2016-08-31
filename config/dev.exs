use Mix.Config
config :blister,
  midi_driver_module: Blister.MIDI.MockDriver,
  use_gui: true
config :logger, :blister_logger,
  path: "/tmp/blister_dev.log",
  level: :debug
