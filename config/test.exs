import Config

config :bcrypt_elixir, log_rounds: 1

# In test we don't send emails
config :delivery_map, DeliveryMap.Mailer, adapter: Swoosh.Adapters.Test

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :delivery_map, DeliveryMap.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "delivery_map_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :delivery_map, DeliveryMapWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Tr+5bNdfJ15j6pG0jBYui/l0Dl1vJ2MnfvpTLfrsXtc/pgcwANaqYRjhIYtU/Rwo",
  server: false

config :delivery_map, token_signing_secret: "pEDljt3665dN8VUAIlrt1n1vaSYnv6pC"

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false
