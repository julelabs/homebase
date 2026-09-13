# Flur-Tablet: Handover für neue Sessions

Für eine Claude-Session, die dieses Projekt weiterführt. Reihenfolge zum Einlesen: diese Notiz, dann [[00 Briefing]], dann [[01 Entscheidungen]], dann [[Konzept]]. Erst danach `src/index.html` öffnen.

## Wo was liegt

Alles in diesem Ordner (`Flur-Tablet/` im Vault "Julia"):

- `src/index.html`: der komplette Prototyp. Eine Datei, CSS, JS und SVG-Icons inline. Etwa 1900 Zeilen.
- `src/check.html`: Gerätecheck fürs iPad, zeigt iOS-Version und Browser-Fähigkeiten.
- `backend/`: Phoenix JSON-API mit Postgres (Migrationen, Seeds, Tests, Fly-Config). Setup und API-Übersicht in `backend/README.md`.
- `Konzept.md`: Produktkonzept, Constraints, Backend-Optionen.
- `Anleitung Tech-Lead.md`: aufs iPad bringen, Geräteeinstellungen, Server starten.
- `03 Testprotokoll.md`: Beobachtungen aus den Tests mit den Kindern.

Repo: [github.com/julelabs/Homebase](https://github.com/julelabs/Homebase) (public, Account julelabs). Julias Mann (`klausbreyer`) hat Admin-Rechte als Collaborator, eingeladen am 12.09.2026.

## Rollen

Julia: Produkt, UI/UX, Tests mit den Kindern. Ihr Mann: Technik, Backend, Einbau. Claude: Konzept und Verifikation (Fable), Umsetzung nach Spec (Sonnet). Größere UI-Änderungen an Sonnet mit klarer Spec geben und die Safari-12-Regeln aus [[Konzept]] mitgeben. Kleine gezielte Edits direkt machen.

## Elternbereich erreichen

Drei Sekunden ununterbrochen auf die obere rechte Ecke des Boards drücken (am Rechner: Maustaste dort gedrückt halten). Die Zone ist unsichtbar, etwa 140 x 140 Pixel. Während des Haltens erscheint ein Ring, der sich langsam aufbaut. Am Rechner geht auch Shift+E oder `?eltern=1` in der Adresse. Auf jedem Gerät geht außerdem: fünfmal innerhalb von 2,5 Sekunden auf das Datum oben links tippen (seit 13.09., weil der Langdruck auf dem iPad im ersten Test nicht auslöste). Auf dem iPad blockiert die Ecke die System-Langdruck-Geste per preventDefault, sonst bricht iOS den Touch nach etwa einer Sekunde ab. Dann links Kinder (Name, Avatar, Farbe, Lesestufe, Plus erlauben), Zeiten (Umschaltzeiten, Nachtmodus, Feiersound), Wochenplan, Aufgaben, Vorschau.

## Lokal laufen lassen

Die Seite braucht das Backend: `cd backend && mix phx.server` (Postgres lokal, siehe `backend/README.md`). Am Rechner nimmt die Seite automatisch `http://localhost:4000`, sonst `?api=...` in der Adresse. Für den Browser-Test über die Chrome-Erweiterung braucht es HTTP:

```
cd "$HOME/Documents/Vault Julia/Julia/Flur-Tablet"
python3 -m http.server 8765 --directory src
```

Dann `http://localhost:8765/index.html`. Alle Daten liegen in Postgres, file:// und localhost zeigen denselben Stand.

Testparameter: `?zeit=19:30&tag=sat` simuliert Uhrzeit und Wochentag. Während der Simulation werden Haken nicht gespeichert (steht auch unten rechts im Board).

Elternbereich: drei Sekunden auf die obere rechte Ecke drücken. Per JavaScript im Test: `document.getElementById('corner-hit').dispatchEvent(new MouseEvent('mousedown', {bubbles:true}))` und 3,5 Sekunden warten.

## Aufbau von index.html

- Oben CSS mit Custom Properties. Nachtmodus ist die Klasse `night` auf dem Wurzelelement.
- SVG-Sprite mit `<symbol id="i-...">` für Aufgaben-Icons und Avatare. Neue Icons dort ergänzen und den Namen in `ICON_CHOICES` eintragen.
- `PALETTE` und `COLOR_CHOICES`: die Kind-Farben (Tag- und Nachtwert).
- `ICON_LABELS`: Standardname pro Icon für eigene Aufgaben ohne Text.
- Die Config (Kinder, Aufgaben, Aktivitäten, Wochenplan, Zeiten, Sound) kommt nur vom Server. Die Ausgangsdaten liegen in `backend/priv/repo/seeds.exs`, die Seeds laufen nur, wenn noch keine Config existiert. Ohne Config zeigt die Seite einen Hinweis statt des Boards.
- `Store` mit `loadBoard`/`saveConfig`/`saveDay`/`saveMessage`: die einzige Stelle, die die API anfasst. `apiRequest` wiederholt bei Netzfehlern und 502/503/504 mit Backoff. Kein localStorage.
- `boot()`: lädt den Zustand, zeigt bis dahin `#loading`, versucht es ohne Verbindung weiter. `tick()` alle 30 Sekunden: Datumswechsel, `refresh()` vom Server, Render.
- Haken, eigene Aufgaben und Nachricht gelten erst nach Serverbestätigung (`commitDay`, `commitMessage`). Bis dahin ist die Zeile `pending`. Config-Änderungen im Elternbereich gelten sofort lokal und werden im Hintergrund gespeichert.
- `now()`: die einzige Zeitquelle, berücksichtigt die Simulation. Nie `new Date()` direkt für Logik nehmen.
- `commitDay(next)` statt direkter Mutation von `day`: schickt den ganzen Tag, übernimmt die Serverantwort. In der Simulation bleibt der Zustand nur im Speicher.
- `render()` baut Kopf und beide Spalten neu. Event-Delegation auf dem Board (`onBoardClick`), Rollen über `data-role`.
- `playDoneChime()` und `columnComplete()`: Feiersound, wird in `onBoardClick` ausgelöst, wenn eine Spalte durch diesen Tipp komplett wird.
- Elternbereich: `renderSection...` pro Abschnitt, Aktionen über `data-action` in `handleParentAction` und `handleParentChange`.

## Safari-12-Regeln (nicht verhandelbar)

Kein `?.`, kein `??`, keine Class Fields, kein `Object.fromEntries`, kein `replaceAll`, keine ES-Module. Kein `gap` in Flexbox (Grid-`gap` geht). Kein `aspect-ratio`, `inset`, `clamp()`, `prefers-color-scheme`, `<dialog>`, `100vh`. Keine Emoji. Nach jeder Änderung:

```
grep -nE '\?\.|\?\?|Object\.fromEntries|replaceAll' src/index.html
node --check <extrahierter Script-Block>
```

## Fehler auf dem iPad sehen

Die Seite fängt JavaScript-Fehler ab und zeigt sie 15 Sekunden unten links als kleine Zeile ("Fehler: ..."). Die letzten fünf stehen in `window.__errors`. Für echtes Debugging: iPad per Kabel an den Mac, in Safari am Mac das Entwickler-Menü einschalten (Einstellungen > Erweitert), dann Entwickler > iPad > Seite. Das öffnet den Web-Inspector mit Konsole für die Seite auf dem iPad, auch bei iOS 12.

Ton auf iOS: Web Audio spielt nur, wenn die Freigabe innerhalb einer Berührung passiert. `unlockAudio()` startet dafür bei jeder Berührung auf dem Board einen stillen Puffer. Der Feiersound selbst kommt erst nach der Serverbestätigung, deshalb ist diese vorherige Freigabe nötig.

## Bekannte Eigenheiten

- Chrome-Erweiterung im Test: Nach einem `navigate` kommen Klicks erst an, wenn einmal ein Screenshot gemacht wurde. Das ist das Tool, nicht die App.
- Die Datumszeile zeigt bei simuliertem Wochentag das Datum dieses Wochentags in der aktuellen Woche.
- Eine Nachricht, die während einer Simulation gespeichert wird, trägt das simulierte Datum und erscheint am echten Tag nicht.
- Der Homescreen-Link merkt sich die Adresse samt `?api=` und `?token=`.
- Das Tablet fragt alle 30 Sekunden den Server. Eine Fly-Maschine mit Scale-to-zero schläft dadurch tagsüber nie ein.
- Feiersound braucht auf dem iPad Stummschalter aus. Web Audio wird durch den ersten Tipp freigeschaltet.

## Nächste sinnvolle Schritte

1. Ergebnis des Abendtests aus [[03 Testprotokoll]] lesen und die UI danach anpassen.
2. `src/check.html` auf dem iPad öffnen, Ergebnis in [[03 Testprotokoll]] notieren.
3. Backend auf Fly anlegen (Kommandos in `backend/README.md`), `DATABASE_URL` setzen, dann die Seite auf dem iPad gegen die Fly-Adresse testen.
4. Icons und Avatare gestalterisch überarbeiten (Sonnet mit Spec, gegen die Palette prüfen).
