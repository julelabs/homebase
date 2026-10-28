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

Die Ausgangs-Config kommt aus `priv/repo/seeds.exs` und wird nur eingespielt, wenn noch keine existiert. Im Container laufen Migrationen und Seeds vor dem Serverstart automatisch (`rel/start.sh`). Beispieldaten für heute (Nachricht, Haken) liegen in `priv/repo/dev_seeds.exs` und laufen nur über `mix ecto.setup` und `mix ecto.reset`.

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

## Bunny Magic Containers

Das Backend läuft als einzelne Instanz in Deutschland. Postgres bleibt auf dem
bestehenden Hetzner-Server, mit derselben `DATABASE_URL` und TLS-Prüfung über
`sqlca.pem`. Es gibt kein lokales Datenvolume. Die Oberfläche bleibt auf
Cloudflare Pages unter https://homebase.breyer.berlin.

`../bunny.json` enthält App-ID und API-Adresse. Datenbank-Zugang und
`SECRET_KEY_BASE` wurden von Fly übernommen und liegen nur in der
Bunny-Containerkonfiguration. Die Datenbankverbindung verwendet auf Bunny IPv4
(`ECTO_IPV6=false`). Ein optionales `API_TOKEN` bleibt bei Deployments ebenfalls
erhalten.

Das Container-Image setzt `RELEASE_MODE=interactive`: Kompilierte Module werden
erst bei ihrer ersten Verwendung geladen. Das reduziert den RAM-Bedarf, während
der erste Aufruf eines Moduls dessen Ladezeit trägt. Alle konfigurierten
Anwendungen starten weiterhin. Die Einstellung gilt für den Serverstart;
Migrationen und Seeds laufen wie bisher vorab über `eval`.

Den RAM-Verbrauch nach einem Deployment erst vergleichen, wenn der alte Pod
beendet ist und `/health` sowie `/api/board?date=YYYY-MM-DD` aufgerufen wurden.
Die Pod-Werte stehen unter `regions[].pods[].ramUsageBytes` in:

```sh
bunny api GET /mc/apps/yCv3OlaYMqaVlGf/overview
```

Für einen Vergleich mit dem bisherigen Ladeverhalten kann die
Container-Umgebungsvariable auf `RELEASE_MODE=embedded` gesetzt werden.

`.github/workflows/ci.yml` führt bei Pull Requests die Backend-Tests, SPA-Prüfung
und Deployment-Tests aus. Auf `main` baut es danach das Linux-amd64-Image
`ghcr.io/julelabs/homebase-api:<commit-sha>`, deployt dessen exakten Digest und
veröffentlicht erst nach erfolgreicher Prüfung die Cloudflare-Seite. Laufende
Deployments werden nicht abgebrochen.

Benötigte GitHub-Secrets:

- `BUNNYNET_API_KEY` für Bunny
- `CLOUDFLARE_API_TOKEN` und `CLOUDFLARE_ACCOUNT_ID` für Pages, bereits vorhanden

Die Image-Veröffentlichung nutzt das automatische `GITHUB_TOKEN`. Bunny liest
das Image über die konfigurierte GitHub-Registry. Es werden keine Datenbank-Secrets
an GitHub Actions übergeben.

Manuell bauen und deployen:

```sh
gh workflow run ci.yml --repo julelabs/Homebase --ref main
```

Nur bauen, ohne Deployment: zusätzlich `-f deploy=false` übergeben.
Ein lokaler, lesender Check aus dem Repository-Verzeichnis:

```sh
python3 scripts/deploy.py --check
```

Das Deployment ändert ausschließlich Image-Tag und Digest des vorhandenen
Containers. Es wartet auf den neuen, bereiten Pod und prüft `/health` sowie
`/api/board?date=YYYY-MM-DD` per HTTPS. Migrationen und vorhandene Seeds werden
vor dem Serverstart ausgeführt. Bei Fehlern wird die Oberfläche nicht deployt;
Logs und App-Status in Bunny prüfen, bevor erneut deployt wird.

Der CDN-Endpunkt erzwingt HTTPS und speichert API-Antworten nicht zwischen.

### Rückweg zu Fly

`fly.toml` bleibt als Referenz erhalten. Die bisherige Fly-App `homebase-api`
und ihre Secrets werden nicht gelöscht. Ein Rückwechsel braucht eine laufende
Fly-Maschine und die alte API-Adresse `https://homebase-api.fly.dev` in
`../src/index.html`, gefolgt von einem Pages-Deployment. Die Datenbank ist dieselbe.
`FLY_API_TOKEN` wird vom neuen Workflow nicht mehr verwendet.
