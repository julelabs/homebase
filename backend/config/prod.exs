import Config

# Kein force_ssl: HTTPS erzwingt Fly am Edge (force_https in fly.toml). Der interne
# Health-Check kommt per HTTP und darf nicht umgeleitet werden.

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
