import Config

# Configure your database
config :delivery_map, DeliveryMap.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "delivery_map_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.
config :delivery_map, DeliveryMapWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "d+M2oJ4O+ZmNCWuszVMqrUyWt2N+hGnXzF/D9tHp0ZzmjU92jN/KeWSh5XGzMimS",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:delivery_map, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:delivery_map, ~w(--watch)]}
  ]

# ## SSL Support
#

# Watch static and templates for browser reloading.
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
config :delivery_map, DeliveryMapWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/delivery_map_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
config :delivery_map, dev_routes: true, token_signing_secret: "/NnS7hEgMj1ZkegWwQG2R+Pg6Bsix94m"

# Do not include metadata nor timestamps in development logs
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
config :logger, :console, format: "[$level] $message\n"

# Initialize plugs at runtime for faster development compilation
# configured to run both http and https servers on
# different ports.
# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :plug_init_mode, :runtime
config :phoenix, :stacktrace_depth, 20

config :phoenix_live_view,
  # Include HEEx debug annotations as HTML comments in rendered markup
  debug_heex_annotations: true,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false
