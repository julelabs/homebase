defmodule Homebase.Repo.SSL do
  @moduledoc """
  Leitet die TLS-Optionen für Postgrex aus der DATABASE_URL ab. Postgrex wertet
  `sslmode` und `sslrootcert` in der URL nicht selbst aus, deshalb passiert das hier.

    * `sslmode=verify-full`: TLS mit Prüfung gegen die CA-Datei aus `sslrootcert`
      (relativ zum Arbeitsverzeichnis, im Image `/app/sqlca.pem`)
    * `sslmode=require`: TLS ohne Prüfung
    * sonst: kein TLS
  """

  @doc "Keyword-Liste mit `ssl:` für die Repo-Config, oder leer."
  def options(database_url) when is_binary(database_url) do
    uri = URI.parse(database_url)
    params = if uri.query, do: URI.decode_query(uri.query), else: %{}

    case Map.get(params, "sslmode") do
      "verify-full" ->
        cacert = Map.get(params, "sslrootcert", "sqlca.pem")

        [
          ssl: [
            verify: :verify_peer,
            cacertfile: Path.expand(cacert, File.cwd!()),
            server_name_indication: String.to_charlist(uri.host),
            customize_hostname_check: [
              match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
            ]
          ]
        ]

      "require" ->
        [ssl: [verify: :verify_none]]

      _ ->
        []
    end
  end
end
