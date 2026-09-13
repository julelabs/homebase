defmodule Homebase.Repo.SSLTest do
  use ExUnit.Case, async: true

  alias Homebase.Repo.SSL

  test "verify-full uses the CA file from the URL and checks the hostname" do
    url = "ecto://u:p@db.example.de/homebase?sslmode=verify-full&sslrootcert=sqlca.pem"
    [ssl: opts] = SSL.options(url)
    assert opts[:verify] == :verify_peer
    assert opts[:cacertfile] == Path.expand("sqlca.pem", File.cwd!())
    assert opts[:server_name_indication] == ~c"db.example.de"
  end

  test "require means TLS without verification" do
    assert SSL.options("ecto://u:p@h/db?sslmode=require") == [ssl: [verify: :verify_none]]
  end

  test "no sslmode means no TLS" do
    assert SSL.options("ecto://localhost/homebase_dev") == []
  end
end
