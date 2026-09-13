# Flur-Tablet: Anleitung

## Dateien

- `Konzept.md`: Produktkonzept, Constraints, Entscheidungsvorlage für das Backend.
- `00 Briefing.md`, `01 Entscheidungen.md`, `02 Handover.md`, `03 Testprotokoll.md`: Projektnotizen.
- `src/check.html`: Gerätecheck. Einmal auf dem iPad öffnen, zeigt iOS-Version und welche Browser-Features gehen.
- `src/index.html`: Der Prototyp. Eine Datei, keine Abhängigkeiten, läuft ohne Server im Browser.
- `backend/`: Phoenix JSON-API mit Postgres. Setup, TablePlus, API und Fly in `backend/README.md`.
- `Anleitung Tech-Lead.md`: diese Datei.

## Am Rechner ansehen

Erst das Backend starten (`cd backend && mix phx.server`), dann `src/index.html` öffnen. Für ein iPad-ähnliches Fenster: Browserfenster auf etwa 1024 x 768 ziehen.

Testparameter in der Adresszeile: `index.html?zeit=19:30&tag=sat` simuliert Uhrzeit und Wochentag. Ohne Parameter gilt die echte Zeit.

Elternbereich: drei Sekunden auf die obere rechte Ecke drücken (Maus gedrückt halten geht auch, ein Ring baut sich dabei auf). Am Rechner zusätzlich Shift+E oder `index.html?eltern=1`.

## Aufs iPad bringen

Das iPad braucht die Datei über HTTP im WLAN. Kurzfristig geht ein Rechner im selben Netz:

```
cd "$HOME/Documents/Vault Julia/Julia/Flur-Tablet"
python3 -m http.server 8765 --directory src
```

Dann am iPad in Safari `http://<IP des Rechners>:8765/index.html?api=http://<IP des Rechners>:4000` öffnen (die IP steht unter Systemeinstellungen > Netzwerk). Im Dauerbetrieb liegt die Seite bei Cloudflare Pages und das Backend bei Fly, dann reicht die Cloudflare-Adresse ohne `?api=`.

Auf dem iPad: Teilen-Symbol > "Zum Home-Bildschirm". Danach vom Home-Bildschirm starten, dann läuft die Seite im Vollbild ohne Safari-Leiste. Der Link merkt sich die Adresse samt Parametern.

## Geräteeinstellungen (iOS 12)

- Einstellungen > Anzeige & Helligkeit > Automatische Sperre: Nie.
- Einstellungen > Anzeige & Helligkeit > Night Shift: Zeitplan, zum Beispiel 19:00 bis 06:00.
- Einstellungen > Allgemein > Bedienungshilfen > Geführter Zugriff: einschalten, Code setzen. In der App dreimal Home-Taste drücken, um den geführten Zugriff zu starten.
- Helligkeit fest einstellen, Auto-Helligkeit aus.
- Dauerstrom. Akku gelegentlich auf Aufblähen prüfen.

## Feiersound

Wenn eine Spalte komplett ist, spielt die Seite einen kurzen synthetischen Klang (Web Audio, keine Datei). Auf dem iPad gilt: Stummschalter aus und Lautstärke hörbar, sonst bleibt es still. Abschaltbar im Elternbereich unter Zeiten.

## Was die Seite selbst macht

- Um Mitternacht setzt sie alle Haken zurück und löscht die Nachricht.
- Um 03:00 lädt sie sich einmal neu, damit sie über Wochen stabil bleibt.
- Alle Daten liegen in Postgres hinter der JSON-API. Die Seite zeigt beim Start einen Ladezustand, wiederholt Anfragen bei Netzfehlern und übernimmt Haken erst nach Serverbestätigung. Alle 30 Sekunden holt sie den Stand vom Server, so kommt die Nachricht vom Handy an (Seite auf dem Handy mit `?eltern=1` öffnen).
