use Mix.Config
config :blister,
  midi_driver_module: PortMidi
config :logger, :blister_logger,
  path: "/tmp/blister.log",
  level: :warn
