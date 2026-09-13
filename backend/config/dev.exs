import Config

# Lokale Datenbank. Ohne DATABASE_URL wird die Postgres-Instanz auf localhost
# mit dem eigenen Systembenutzer verwendet (Homebrew-Standard, ohne Passwort).
config :homebase, Homebase.Repo,
  url: System.get_env("DATABASE_URL", "ecto://localhost/homebase_dev"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# ip: {0, 0, 0, 0}, damit das iPad im WLAN den Rechner erreichen kann.
config :homebase, HomebaseWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "S3kKxLOuiGUQci5VoP2nBAVULxmVOPsNHexu27tbLwmlR3aKXU1iGyq3nJrt7vVM",
  watchers: []

# Do not include metadata nor timestamps in development logs
config :logger, :default_formatter, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
