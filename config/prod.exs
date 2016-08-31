use Mix.Config
config :blister,
  midi_driver_module: PortMidi,
  use_gui: true
config :logger, :blister_logger,
  path: "/tmp/blister.log",
  level: :warn
