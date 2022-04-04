# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :minitwit_elixir,
  ecto_repos: [MinitwitElixir.Repo]

# Configures the endpoint
config :minitwit_elixir, MinitwitElixirWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: MinitwitElixirWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MinitwitElixir.PubSub,
  live_view: [signing_salt: "B4uMJj7t"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :minitwit_elixir, MinitwitElixir.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

#config :logger, backends: [:console, LokiLogger]

#config :logger, :loki_logger,
#       level: :debug,
#       format: "$metadata level=$level $levelpad$message",
#       metadata: :all,
#       max_buffer: 300,
#       loki_labels: %{application: "loki_logger_library", elixir_node: node()},
#       loki_host: "http://localhost:3100"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
