# Flur-Tablet: Entscheidungen

Reverse chronologisch innerhalb eines Tages nicht nötig, einfach nach Datum. Jede Zeile: was, warum, Status. Wenn etwas rückgängig gemacht wird, alte Zeile stehen lassen und neue Zeile ergänzen.

## 2026-09-13

| Entscheidung | Warum | Status |
|---|---|---|
| Zwölf Avatare im Stil A: Fuchs, Eule, Drache, Katze, Roboter, Dino, Kaktus, Bär, Klotz, Schweinchen, Würfelkopf, Hai. Kreis in der Kind-Farbe, Figur mit eigenen Farben, eigene Zeichnungen (angelehnt an Minecraft- und Brawl-Stars-Typen, keine Kopien). Vorschau in `design/Avatare.html` | Alte Avatare waren dunkle Kreise mit weißen Formen und sahen sich zu ähnlich | umgesetzt am 13.09. abends |
| Icon-Stil A "weich gefüllt": eine Zeichnung pro Aufgabe, Hauptform in einer Farbe aus der gedämpften Palette, Nebenformen in Kartenfarbe, Linie in Textfarbe (2,5 px bei 48er Raster). Nachts eigene Farbwerte. Auswahl über `design/Icon-Vergleich.html` (A, B, C nebeneinander) | Farbe und Form zusammen sind für den Sechsjährigen am schnellsten erkennbar; die alten Linien-Icons waren zu abstrakt | umgesetzt am 13.09. abends, Julias Wahl |
| Icons liegen als Inline-SVG in `ICON_PATHS` (Markup pro Icon) statt als `<use>`-Verweise | CSS-Regeln erreichen die Formen in `<use>`-Verweisen nicht, Füllungen wären unmöglich | umgesetzt |
| Neue Icons Eule (Duolingo) und Lautsprecher (Hörbuch), dazu die Aufgaben "Duolingo" und "Hörbuch hören" in Seeds und Live-Config | Julias Wunsch | umgesetzt |
| Dritter Zeitraum "Mittags" zwischen Morgens und Abends (`afternoon`). Grenzen: Mittagsliste ab 12:00, Abendliste ab 17:00, beides unter Zeiten einstellbar. Kopfzeile: Sonnenaufgang, Sonne, Mond | Nach der Schule passieren andere Dinge als vor der Schule (Brotbox in die Küche, Hausaufgaben) | umgesetzt am 13.09. abends. Bestehender Wochenplan bleibt unverändert, Mittags-Aufgaben werden im Elternbereich zugewiesen. Neue Seeds legen Brotbox, Flasche, Schuhe, Jacke (und Hausaufgaben) mittags an |
| Aktivitäten (Schwimmen, Sport) bleiben zweiteilig: Mitnehmen-Aufgabe morgens, Packen-Aufgabe am Vorabend. Kein Mittags-Anteil | Sportbeutel kommt mittags mit nach Hause, das ist keine Aufgabe | gesetzt |
| Backend: Phoenix als JSON-API mit Postgres in `backend/`, SPA bleibt eine Datei bei Cloudflare Pages, Backend bei Fly mit Scale-to-zero, vorhandene Postgres | Nachricht vom Handy und Zustand für die Eltern brauchen einen Server; Elixir ist der Hausstack | umgesetzt, Fly-App noch nicht angelegt |
| Datenmodell: Config als ein JSON-Dokument, Haken, eigene Aufgaben und Nachricht als Tabellen pro Tag | Config ändert sich selten und als Ganzes, der Tageszustand soll in TablePlus lesbar sein | ersetzt, siehe unten |
| Config relational: Tabellen `kids`, `tasks`, `activities`, `schedule_tasks`, `schedule_activities`, `settings`. Die API liefert und nimmt weiter das Tablet-Format, der Server übersetzt | JSON-Blob war in TablePlus nicht lesbar und für den späteren Admin-Bereich ungeeignet | umgesetzt |
| Default-Config und JSON-Import raus aus dem Frontend, Ausgangsdaten nur in den Seeds. Der Abschnitt Daten im Elternbereich entfällt | Eine Quelle für die Defaults, kein Config-JSON mehr im Frontend | umgesetzt |
| Schreibende Aufrufe ersetzen immer den ganzen Datensatz (Tag, Config, Nachricht) | Wiederholen nach Netzfehler bleibt unschädlich, nur das Tablet schreibt den Tag | umgesetzt |
| Haken, eigene Aufgaben und Nachricht gelten erst nach Serverbestätigung, Config-Änderungen im Elternbereich sofort lokal mit Speichern im Hintergrund | Tippen in Namensfeldern darf nicht auf den Server warten | umgesetzt |
| Kein localStorage mehr, auch nicht für den 03:00-Reload (jetzt: Reload nur, wenn die Seite länger als eine Stunde läuft) | Postgres ist die einzige Datenquelle | umgesetzt |
| Admin-Bereich als LiveViews kommt später | Erst muss die API laufen | offen |

## 2026-09-12 (Nachmittag, nach erstem Anschauen)

| Entscheidung | Warum | Status |
|---|---|---|
| Ecken-Langdruck unterdrückt Textmarkierung (Desktop) und System-Langdruck-Geste (iOS), zeigt beim Halten einen Ring. Zusätzlich Shift+E und `?eltern=1` für den Rechner | In Safari am Mac ging der Langdruck nicht | umgesetzt, auf dem iPad noch nicht getestet |
| Auch der Sechsjährige bekommt das Plus für eigene Aufgaben. Text ist optional, ohne Text heißt die Aufgabe wie das gewählte Icon (Buch, Musik, Tier). Tastatur öffnet sich bei ihm nicht automatisch | Er hat danach gefragt | umgesetzt |
| Kind 1 ist der Sechsjährige (Icons), Kind 2 der Neunjährige (Text, Plus für eigene Aufgaben) | Erste Fassung hatte die Alter vertauscht | umgesetzt |
| Beim Sechsjährigen ist die ganze Karte Tippfläche, Kinder-Elemente in der Karte fangen keine Events | Ein Kind trifft nicht den kleinen Kreis | umgesetzt |
| Kind-Farbe frei wählbar aus 10 gedämpften Tönen (Salbei, Staubblau, Sand, Mauve, Terrakotta, Olive, Schiefer, Rosé, Petrol, Ocker) | "Nicht vom Tablet angeschrien werden" | umgesetzt |
| Feiersound, kurz, synthetisch (vier Töne, unter einer Sekunde), abschaltbar unter Zeiten, Default an | Julias Wunsch. Sound nur bei "Spalte fertig", nicht bei jedem Haken | umgesetzt |
| Abendliste für den ersten Test: Tisch abräumen, Zähne putzen, Duschen oder baden, Schlafanzug, an allen Tagen für beide | Test am Abend des 12.09. | umgesetzt, im Elternbereich änderbar |
| Config bekommt eine Versionsnummer; ältere gespeicherte Config wird durch die neuen Defaults ersetzt | Sonst kommen Änderungen an den Defaults nicht bei Julia an | umgesetzt. Nebenwirkung: Eigene Änderungen im Elternbereich gehen bei einem Versionssprung verloren |

## 2026-09-12 (Vormittag, Konzeptphase)

| Entscheidung | Warum | Status |
|---|---|---|
| Zielgerät iPad Air 1 mit iOS 12, deshalb eine HTML-Datei ohne Framework, ES2017, kein Flex-gap, keine Emoji, Inline-SVG | Safari 12 kann vieles Moderne nicht, App Store fällt weg | gesetzt |
| Web-Seite auf dem Homescreen im Vollbild, Guided Access | Einzige realistische Kiosk-Form für ein altes iPad | gesetzt |
| Morgen- und Abendliste zeitgesteuert, nicht als zwei Spalten | Spalten gehören den Kindern. Zwei Kinder mal zwei Tageszeiten wären vier Spalten | gesetzt |
| Eine Spalte pro Kind, zwei Lesestufen (Icon-Tiles / Textzeilen), pro Kind einstellbar | Geschwistervergleich vermeiden, Lesestufe passt sich an | gesetzt |
| Tippen setzt Haken, nochmal Tippen nimmt ihn weg. Keine Dialoge, keine Wischgesten | Fehltipps müssen folgenlos sein | gesetzt |
| Erledigte Zeilen bleiben an ihrer Position, werden nur heller | Sonst verliert der Sechsjährige die Orientierung | gesetzt |
| Um Mitternacht alles zurück, keine Spuren von gestern | Keine Punkte-Ökonomie durch die Hintertür | gesetzt |
| Der Abend kennt den nächsten Tag: Aktivität morgen erzeugt "packen" heute Abend automatisch | Läuft über den Wochenplan, keine Extra-Regel | umgesetzt |
| Nachricht gilt nur für heute, um Mitternacht leer | Keine Woche alte Info im Flur | umgesetzt |
| Elternbereich per drei Sekunden Druck auf die obere rechte Ecke, kein Passwort | Config ist nicht spannend genug, um sie zu schützen | umgesetzt |
| Nachtmodus ab 19:00 über die Uhrzeit, nicht über die Systemeinstellung | Safari 12 kennt prefers-color-scheme nicht | umgesetzt |
| Datenhaltung (Heimserver, Cloud, nur iPad) entscheidet Julias Mann | Technik ist seine Rolle; die UI ist für alle drei Varianten gleich gebaut | offen |
| Prototyp speichert im localStorage; alle Zugriffe laufen über ein `Store`-Objekt mit load/save | Backend später austauschbar ohne UI-Änderung | umgesetzt |
| Simulation von Uhrzeit und Wochentag (Vorschau) hält den Tageszustand nur im Speicher | Erste Fassung hat die echten Haken der Kinder gelöscht | umgesetzt |
| Modellrollen: Fable Konzept und Verifikation, Sonnet Umsetzung nach Spec | Julias Standardmuster | praktiziert |
| Eigene Aufgaben des Neunjährigen gelten nur für heute | Sonst wird die Spalte zum Friedhof. "Behalten"-Schalter erst, wenn er danach fragt | umgesetzt |

## Offen

- Fly-App anlegen und `DATABASE_URL` setzen (siehe `backend/README.md`).
- Admin-Bereich als LiveViews.
- Icon-Set und Avatare gestalterisch überarbeiten. Aktuell geometrisch und einfarbig, Avatare sehen sich zu ähnlich.
- "Gute Nacht"-Ansicht ab 20:30.
- Eltern sehen vom Handy den Zustand (braucht Server).
