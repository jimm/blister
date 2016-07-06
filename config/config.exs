use Mix.Config
config :logger,
  backends: [{LoggerFileBackend, :jex_logger}]
import_config "#{Mix.env}.exs"
