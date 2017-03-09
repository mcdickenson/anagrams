# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :anagrams,
  ecto_repos: [Anagrams.Repo]

# Configures the endpoint
config :anagrams, Anagrams.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YHocK0lXrPQZDWXhDMukFLMuJVCIxKR3JpwM7pTFKnYMZmob24msM8NzILVH94QT",
  render_errors: [view: Anagrams.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Anagrams.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
