use Mix.Config
config :blister,
  driver: PortMidi,
  gui: Blister.GUI.Text
config :logger, :blister_logger,
  path: "/tmp/blister_dev.log",
  level: :debug
