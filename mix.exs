defmodule Blister.Mixfile do
  use Mix.Project

  def project do
    [app: :blister,
     version: "0.1.0",
     elixir: "~> 1.3-rc",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: case Mix.env do
                     :test -> [:logger]
                     _ -> [:logger, :portmidi]
                   end,
     env: case Mix.env do
            :prod ->
              [midi_driver_module: PortMidi,
               gui_module: Blister.GUI.Curses]
            :dev ->
              [midi_driver_module: PortMidi,
               gui_module: Blister.GUI.Text]
            :test ->
              [midi_driver_module: Blister.MIDI.MockDriver,
               gui_module: nil]
          end,
     mod: {Blister, []}]
  end

  defp deps do
    [{:portmidi, "~> 5.0"},
     {:cecho, git: "https://github.com/mazenharake/cecho.git"},
     {:logger_file_backend, "~> 0.0.8"}]
  end
end
