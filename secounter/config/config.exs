# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :secounter, Secounter.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "xC2jok2TET+6c60GHv9n6+AY0hBZH12i/83ObwXd8TGRsJGTrvWybnQ8Mwf2Fa0M",
  render_errors: [view: Secounter.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Secounter.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
