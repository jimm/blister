use Mix.Config
config :blister,
  midi_driver_module: PortMidi,
  gui_module: Blister.GUI.Curses
config :logger, :blister_logger,
  path: "/tmp/blister.log",
  level: :warn
