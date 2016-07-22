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
    [applications: [:logger, :portmidi],
     mod: (if Mix.env == :test, do: [], else: {Blister, []})]
  end

  defp deps do
    [{:portmidi, "~> 5.0"},
     {:cecho, git: "https://github.com/mazenharake/cecho.git"} ] #,
     # {:logger_file_backend, "~> 0.0.8"}]
  end
end
