use Mix.Config
config :blister,
  midi_driver_module: Blister.MIDI.MockDriver,
  gui_module: Blister.GUI.Text
config :logger, :blister_logger,
  path: "/tmp/blister_test.log",
  level: :warn
