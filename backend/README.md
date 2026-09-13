# Flur-Tablet Backend

Phoenix als JSON-API, Postgres als einzige dauerhafte Datenquelle. Die SPA in `../src/index.html` spricht nur mit dieser API.

## Lokal einrichten

Voraussetzungen: asdf (Versionen in `../.tool-versions`), Postgres auf localhost ohne Passwort (Homebrew: `brew install postgresql@17 && brew services start postgresql@17`).

```
cd backend
asdf install
mix setup        # deps, Datenbank homebase_dev, Migrationen, Seeds
mix phx.server   # http://localhost:4000
```

Ohne `DATABASE_URL` wird `ecto://localhost/homebase_dev` mit dem eigenen Systembenutzer verwendet. Abweichende Datenbank: `DATABASE_URL=ecto://user:pass@host/db mix phx.server`.

Tests: `mix test` (Datenbank `homebase_test`). Alles zurücksetzen: `mix ecto.reset`.

Der Server hört auf allen Interfaces, damit das iPad im WLAN den Rechner erreicht. Die SPA nimmt am Rechner automatisch `http://localhost:4000`. Vom iPad aus: `index.html?api=http://<IP des Rechners>:4000`.

## TablePlus

Neue Verbindung, Postgres:

- Host `localhost`, Port `5432`, User: eigener Systembenutzer (`whoami`), kein Passwort, Datenbank `homebase_dev`.
- Als URL: `postgresql://localhost:5432/homebase_dev`

Tabellen: `configs` (Board-Config als JSON, eine Zeile), `checks` (Haken pro Kind, Aufgabe, Tag), `own_tasks` (eigene Aufgaben der Kinder), `messages` (Nachricht pro Tag).

## API

Alle Antworten JSON. Datum immer `YYYY-MM-DD` in der Lokalzeit des Tablets.

| Methode | Pfad | Body | Antwort |
|---|---|---|---|
| GET | `/api/board?date=` | | `{config, day, message}` |
| PUT | `/api/config` | `{config}` | `{config}` |
| PUT | `/api/days/:date` | `{checked, own}` | `{day}` |
| PUT | `/api/messages/:date` | `{text}` (leer löscht) | `{message}` |

Schreibende Aufrufe ersetzen den ganzen Datensatz. Wiederholen nach einem Netzfehler ist unschädlich.

Optionaler Schutz: Umgebungsvariable `API_TOKEN` setzen, dann braucht jeder Aufruf `Authorization: Bearer <token>`. Die SPA nimmt das Token aus `?token=` in der Adresse (bleibt im Homescreen-Lesezeichen erhalten).

## Fly.io

Config in `fly.toml`, gleiche Struktur wie medixir (Scale-to-zero, eine Maschine, 512 MB). Einmalig:

```
cd backend
fly apps create homebase-api --org <org wie medixir>
fly secrets set -a homebase-api DATABASE_URL='ecto://...' SECRET_KEY_BASE="$(mix phx.gen.secret)"
fly secrets set -a homebase-api API_TOKEN='...'   # optional
fly deploy
```

Danach deployt `.github/workflows/fly.yml` bei jedem Push auf `main`, der `backend/` ändert (braucht das Repo-Secret `FLY_API_TOKEN`). Migrationen laufen als `release_command` vor dem Start.

Die SPA erwartet die API unter `https://homebase-api.fly.dev`. Anderer App-Name: `API_BASE` in `../src/index.html` anpassen.
