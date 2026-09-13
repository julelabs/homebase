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

Tabellen: `kids`, `tasks`, `activities`, `schedule_tasks` und `schedule_activities` (Wochenplan), `settings` (Zeiten, Sound, eine Zeile), `checks` (Haken pro Kind, Aufgabe, Tag), `own_tasks` (eigene Aufgaben der Kinder), `messages` (Nachricht pro Tag).

Die Ausgangs-Config kommt aus `priv/repo/seeds.exs` und wird nur eingespielt, wenn noch keine existiert. Auf Fly laufen Migrationen und Seeds bei jedem Deploy automatisch (`release_command` in `fly.toml`). Beispieldaten für heute (Nachricht, Haken) liegen in `priv/repo/dev_seeds.exs` und laufen nur über `mix ecto.setup` und `mix ecto.reset`.

`mix ecto.reset` braucht exklusiven Zugriff: vorher TablePlus trennen und den Server stoppen.

## API

Alle Antworten JSON. Datum immer `YYYY-MM-DD` in der Lokalzeit des Tablets.

| Methode | Pfad | Body | Antwort |
|---|---|---|---|
| GET | `/health` | | `{status: "ok"}`, ohne Token, ohne DB |
| GET | `/api/board?date=` | | `{config, day, message}` |
| PUT | `/api/config` | `{config}` | `{config}` (Aufgaben und Aktivitäten kommen in Positionsreihenfolge zurück, neue werden hinten angehängt) |
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

Danach deployt `.github/workflows/ci.yml` bei jedem Push auf `main`, sobald Tests und SPA-Lint grün sind (braucht das Repo-Secret `FLY_API_TOKEN`). Pull Requests laufen nur durch die Tests. Migrationen und Seeds laufen als `release_command` vor dem Start.

Die SPA erwartet die API unter `https://homebase-api.fly.dev`. Anderer App-Name: `API_BASE` in `../src/index.html` anpassen.
