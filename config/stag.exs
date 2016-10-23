use Mix.Config

config :phoenix, Djay.Router,
  url: [host: System.get_env("BLEACHERBOT_HOST"), port: 80],
  http: [port: System.get_env("PORT") || 4010],
  secret_key_base: SECRET_KEY_BASE
  debug_errors: true

config :logger, :console,
  level: :debug

config :bleacherbot, Repo,
  url: {:system, "PSQL_URL"}
