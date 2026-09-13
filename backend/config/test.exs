import Config

# Testdatenbank, gleiche Konvention wie dev (localhost, Systembenutzer).
config :homebase, Homebase.Repo,
  url: System.get_env("TEST_DATABASE_URL", "ecto://localhost/homebase_test"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :homebase, HomebaseWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "2NF1YTGGF8tv4yA6dssofxS8fZyvHHCb7RO/WJcW1ryDWc1SNFTH9B82qZv/fc0T",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
