use Mix.Config
config :blister,
  driver: PortMidi,
  gui: Blister.GUI.Curses
config :logger, :blister_logger,
  path: "/tmp/blister.log",
  level: :warn
