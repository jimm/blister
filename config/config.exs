use Mix.Config
config :logger,
  backends: [{LoggerFileBackend, :blister_logger}]
import_config "#{Mix.env}.exs"
