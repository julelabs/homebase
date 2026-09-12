# Flur-Tablet: Aufgabenboard für die Kinder

## Kontext

Ein altes iPad Air 1 hängt im Flur und zeigt den beiden Kindern (6 und 9) ihre regelmäßigen Aufgaben: Brotbox und Trinkflasche in die Küche, Schuhe wegräumen, Schwimmsachen packen. Julia macht Produkt und UI/UX, ihr Mann die technische Umsetzung und den Einbau (Kiosk, Strom, Guided Access).

Das Ziel ist nicht Kontrolle und nicht Belohnung. Das Tablet ist ein Helfer: Die Kinder sehen selbst, was dran ist, ohne dass jemand es ihnen sagt. Der Lohn ist der leere Bildschirm.

Diese Datei hält die Ideensammlung, die geklärten Constraints, das UI-Konzept und die offenen Entscheidungen fest. Sie ist die Grundlage für einen klickbaren Prototyp, den Julia mit den Kindern testen kann, bevor ihr Mann das Backend baut.

## Geklärte Constraints

| Constraint | Entscheidung | Konsequenz |
|---|---|---|
| Gerät | iPad Air 1, iOS 12 (Safari 12) | Eine HTML-Datei, kein Framework, kein Build. Nur JS und CSS, das Safari 12 kann (siehe Technik). |
| Form | Web-Seite auf dem Homescreen, Vollbild, Guided Access | Kein App Store, keine Updates über Apple. Aktualisieren heißt Datei tauschen. |
| Tageszeit | Zeitgesteuert: bis mittags Morgenliste, danach Abendliste | Pro Kind genau eine Spalte, immer nur die Liste, die jetzt dran ist. |
| Elternbereich | Versteckte Geste (lange auf eine Ecke drücken), kein Passwort | Config, Avatare, Wochenplan und Nachricht sind am Tablet erreichbar. |
| Daten und Nachrichten-Slot | Entscheidet Julias Mann (drei Optionen unten) | Die UI wird so gebaut, dass sie mit jeder Variante läuft. Nur eine kleine Speicherschicht unterscheidet sich. |
| Sprache | Deutsch | Alle Texte, Wochentage, Datum auf Deutsch. |
| Ausrichtung | Querformat | Zwei Spalten nebeneinander brauchen die Breite (1024 x 768 CSS-Pixel). |

## Was es nicht wird

- Keine Punkte, keine Sterne, keine Wochenauswertung. Kein "3 von 5 geschafft".
- Kein Rot. Unerledigtes bleibt einfach stehen, in derselben Farbe wie alles andere.
- Keine Spuren von gestern. Um Mitternacht ist alles wieder unerledigt, ohne graue Liste.
- Kein Sound pro Haken. Der Flur um 6:45 will keine Fanfare. Eine kleine Animation am Haken reicht. Nur wenn eine Spalte komplett ist, gibt es einen kurzen, leisen Klang (abschaltbar, Ergänzung vom 12.09. nachmittags).
- Keine Bestätigungsdialoge, keine Wischgesten. Tippen ist die einzige Geste für die Kinder.

## UI-Konzept

### Bildschirm 1: Das Board (99 Prozent der Zeit)

```
+--------------------------------------------------------------+
|  Dienstag, 12. September          [Nachricht der Eltern]     |
+------------------------------+-------------------------------+
|  (Avatar)  NAME KIND 1       |  (Avatar)  NAME KIND 2        |
|                              |                               |
|  [Icon]  Brotbox             |  [Icon]  Brotbox in die Küche |
|  [Icon]  Trinkflasche        |  [Icon]  Trinkflasche         |
|  [Icon]  Schuhe              |  [Icon]  Schuhe wegräumen     |
|  [Icon]  Zähne               |  [Icon]  Zähne putzen         |
|                              |  [Icon]  Schwimmsachen        |
|                              |                               |
|                              |  [ + ]  eigene Aufgabe        |
+------------------------------+-------------------------------+
```

- **Eine Spalte pro Kind.** Jedes Kind hat Avatar, Namen und eigene Haken. Es gibt keine gemeinsame Liste, damit "wer hat die Brotbox vergessen" nicht zum Geschwister-Audit wird.
- **Zwei Lesestufen, gleiche Liste.** Das jüngere Kind sieht große Icons mit kleinem Wort darunter (hilft beim Lesenlernen, stört nicht). Das ältere Kind sieht Icon plus Text in normaler Größe. Pro Kind in der Config einstellbar: `icons` oder `text`.
- **Zeilen sind groß.** Mindestens 88 Pixel hoch, Icon mindestens 56 Pixel, die ganze Zeile ist Tippfläche. Daneben tippen darf nichts kaputt machen.
- **Tippen = Haken. Nochmal tippen = Haken weg.** Kein Dialog. Der Haken bekommt eine kurze, weiche Animation (Zeile wird etwas heller, Haken wächst rein, unter einer halben Sekunde).
- **Reihenfolge bleibt.** Erledigte Zeilen springen nicht nach unten und verschwinden nicht. Sie werden nur heller. Sonst verliert das jüngere Kind die Orientierung.
- **Tageszeit-Umschaltung ohne Bedienung.** Bis 12:00 Morgenliste, danach Abendliste. Die Grenze steht in der Config. Oben im Datum steht klein, welche Liste gerade gezeigt wird (Sonne oder Mond als Symbol).
- **Der Abend kennt morgen.** Steht im Wochenplan für morgen Schwimmen, zeigt die Abendliste heute "Schwimmsachen packen". Das läuft über den Wochenplan, nicht über eine Extra-Regel.
- **Nachrichten-Slot oben.** Eine Zeile, groß genug, um vom Flur aus lesbar zu sein: "Heute Oma-Anruf um 17 Uhr", "Papa holt euch ab". Gilt nur für heute, um Mitternacht ist der Slot leer. Leerer Slot zeigt nichts, keinen Platzhalter.
- **Eigene Aufgabe (Kind 2).** Ein "+" am Ende der Spalte. Tippen öffnet eine große Eingabe: ein Icon aus einer kleinen Auswahl wählen, kurzer Text eintippen, fertig. Das Item gilt für heute und ist morgen weg. Ein "jeden Tag behalten"-Schalter kommt erst, wenn er danach fragt.

### Bildschirm 2: Alles erledigt (pro Spalte)

Wenn in einer Spalte alle Haken gesetzt sind, ersetzt eine ruhige Ansicht die Liste dieser Spalte: der Avatar, eine Sonne (morgens) oder ein Mond (abends) und "Fertig für heute". Die andere Spalte bleibt normal. Tippt man auf die Fertig-Ansicht, kommt die Liste kurz zurück (falls ein Haken versehentlich war), nach ein paar Sekunden ohne Tippen wieder die Fertig-Ansicht.

### Bildschirm 3: Nacht

Ab 19:00 (Config) wechselt die Palette auf warm und dunkel: dunkler Hintergrund, gedämpfte Icons, weniger Kontrast. Kein Baustrahler im Flur. Zusätzlich kann Night Shift in iOS 12 zeitgesteuert die Farbtemperatur senken, das ist eine Einstellung am Gerät und Sache des Tech-Leads. Bildschirmhelligkeit kann eine Web-Seite nicht steuern.

### Bildschirm 4: Elternbereich

Erreichbar durch langes Drücken (drei Sekunden) auf die obere rechte Ecke. Enthält, in dieser Reihenfolge, weil das die Häufigkeit widerspiegelt:

1. Nachricht für heute eintippen oder löschen.
2. Wochenplan: pro Wochentag und Kind die Aufgaben für morgens und abends. Standardaufgaben werden nur einmal angelegt und dann Tagen zugewiesen.
3. Kinder: Name, Avatar aus einer Auswahl, Lesestufe.
4. Zeiten: Wechsel morgens/abends, Nachtmodus ab wann.
5. Zurück zum Board.

Der Elternbereich sieht bewusst anders aus als das Board (kleiner, dichter, schlichter), damit klar ist, dass das nicht für Kinder ist.

## Ideen-Backlog (nicht für Version 1)

- "Gute Nacht"-Ansicht ab 20:30: nur das Datum von morgen und der erste Punkt der Morgenliste.
- Eltern sehen vom Handy, ob die Haken gesetzt sind. Kein Score, nur Zustand. Braucht Server.
- Feiertage und Ferien: Wochenplan pausieren.
- Geburtstag: Avatar bekommt einen Hut.

## Entscheidungsvorlage für den Tech-Lead: Wo leben die Daten?

Die UI ist in allen drei Varianten identisch. Unterschiedlich ist nur eine kleine Speicherschicht mit drei Funktionen: laden, speichern, auf Änderungen von außen reagieren. Das Board braucht drei Datensätze: die Config (Kinder, Aufgaben, Wochenplan, Zeiten), den Tageszustand (welche Haken heute gesetzt sind, eigene Aufgaben) und die Nachricht.

| Variante | Wie es geht | Was die Eltern bekommen | Aufwand und Risiko |
|---|---|---|---|
| **A: Heimserver** (Pi, NAS, Home Assistant, irgendein Rechner, der immer läuft) | Statische Dateien plus eine winzige JSON-Datei pro Datensatz, per HTTP im WLAN. Das iPad fragt alle 30 Sekunden nach. Nachricht und Config vom Handy über dieselbe Seite im Elternmodus. | Nachricht vom Handy, Config vom Rechner, spätere Erweiterungen (Zustand sehen) möglich. | Klein, wenn es schon einen Server gibt. Kein Internet nötig. Muss laufen, sonst zeigt das iPad den letzten Stand aus dem localStorage. |
| **B: Cloud ohne eigenen Server** | Zum Beispiel ein Google Apps Script als Web-Endpoint mit einem Sheet dahinter, oder ein kleiner kostenloser Worker mit Key-Value-Speicher. | Wie A, zusätzlich von unterwegs. | Externe Abhängigkeit, Zugangsdaten liegen in der Seite (im Heimnetz vertretbar, aber unschön). iOS 12 kann TLS 1.2, das reicht für alle gängigen Dienste. |
| **C: Nur das iPad** | Alles im localStorage der Seite. Nachricht und Config werden im Elternbereich am Tablet eingegeben. | Kein Handy-Zugriff. Nachrichten tippt man im Vorbeigehen am Tablet. | Praktisch null Aufwand und null Ausfallrisiko. Der Nachrichten-Slot verliert seinen größten Charme (vom Handy aus dem Büro schreiben). |

Empfehlung aus Produktsicht: A, falls ein Server da ist, sonst C zum Start und später auf A oder B wechseln. Die Speicherschicht ist dafür gebaut. Der Prototyp läuft in jedem Fall mit C, damit Julia sofort mit den Kindern testen kann.

## Technik-Constraints für Safari 12 (iOS 12)

Was geht: Flexbox, CSS Grid, CSS Custom Properties, `position: sticky`, Transitions und Keyframe-Animationen, `async`/`await`, `fetch`, `localStorage`, Service Worker, Inline-SVG, `-webkit-tap-highlight-color`, `touch-action`, Vollbild über `apple-mobile-web-app-capable`.

Was nicht geht (typische Stolperfallen):

- Optional Chaining `?.` und Nullish Coalescing `??` (erst iOS 13.4). Alles Vanilla-JS in ES2017-Stil, kein Transpiler nötig, aber Disziplin.
- `gap` in Flexbox (erst iOS 14.5). Abstände über Margin oder Grid-`gap`, das geht.
- `prefers-color-scheme` (erst iOS 13). Nachtmodus deshalb über Uhrzeit, nicht über das System.
- Wake Lock API gibt es nicht. Der Bildschirm bleibt nur über die Geräteeinstellung an (Auto-Sperre: Nie).
- Emoji: iOS 12 kennt nur den Emoji-Stand von 2018. Zahnbürste, Lunchbox-Varianten und anderes fehlen oder sehen anders aus. Deshalb alle Icons als Inline-SVG aus einem konsistenten Set, keine Emoji.
- `100vh` ist im Vollbild unzuverlässig. Layout über `position: fixed` auf dem Wurzelelement, das verhindert auch das Gummiband-Scrollen.
- Web-Fonts über Google CDN gehen nur mit Internet. Font lokal mitliefern (WOFF, eine Datei) oder Systemschrift nehmen.

Die Seite läuft tage- oder wochenlang ohne Neuladen. Deshalb: Jede Minute prüfen, ob das Datum gewechselt hat (Reset), und einmal nachts um 03:00 die Seite neu laden, damit Speicher und Zustand sauber bleiben.

## Gerätefragen an den Tech-Lead (Checkliste, nicht mein Teil)

- Guided Access an, Auto-Sperre auf Nie, Helligkeit fest, Night Shift mit Zeitplan.
- Dauerstrom hinter dem Rahmen. Alter Akku unter Dauerladung: gelegentlich auf Aufblähen prüfen.
- Seite auf dem Homescreen: Vollbild-Meta-Tags, eigenes Icon, Startbild.
- Wie kommt eine neue Version der Seite aufs iPad (bei A und B: Datei auf dem Server tauschen und Seite neu laden; bei C: Datei muss erreichbar sein, zum Beispiel kurz über einen Rechner im WLAN).

## Nächste Schritte

1. **Fähigkeitstest fürs iPad.** Eine winzige HTML-Seite, die auf dem iPad anzeigt, welche Features tatsächlich gehen (Speicher, Vollbild, SVG, Animationen, Datum). Der Tech-Lead öffnet sie einmal, wir sehen die echte iOS-Version und Safari-Eigenheiten. Dauer: kurz.
2. **Klickbarer Prototyp als eine HTML-Datei.** Board, Fertig-Ansicht, Nachtmodus und Elternbereich mit Beispielkindern, Beispielaufgaben und Wochenplan. Speicherschicht in Variante C, damit er ohne Backend läuft. Lokal im Browser öffnen (Desktop, Querformat 1024 x 768) und dann im WLAN aufs iPad. Ziel: Julia testet mit den Kindern, ob Tippen, Icons und Lesestufen funktionieren, bevor irgendetwas "richtig" gebaut wird.
3. **Icon-Set festlegen.** Etwa 20 Alltagsaufgaben als SVG in einem Stil (Brotbox, Trinkflasche, Schuhe, Jacke, Zähne, Schulranzen, Schwimmsachen, Sportsachen, Hausaufgaben, Tisch decken, Zimmer, Haustier, Müll, Wäsche, Schlafanzug, Licht aus). Julias Teil, mit Sonnet als Umsetzer nach klarer Spec.
4. **Backend-Entscheidung** anhand der Tabelle oben, dann die Speicherschicht auf A oder B umstellen.

## Verifikation

- Prototyp im Desktop-Browser bei 1024 x 768 öffnen: Board, Haken setzen und lösen, Fertig-Ansicht, Nachtmodus (Uhrzeit im Elternbereich künstlich vorstellen), Reset bei Datumswechsel.
- Dann auf dem iPad Air 1 im Vollbild: Tippen ohne Verzögerung, kein Gummiband-Scrollen, Animationen flüssig, nach 24 Stunden Dauerlauf noch responsiv.
- Mit den Kindern: Findet der Sechsjährige seine Spalte und seinen Haken ohne Erklärung? Nutzt der Neunjährige das "+"?

## Nachträge 12.09. nachmittags

- Kind 1 ist der Sechsjährige (Icon-Tiles), Kind 2 der Neunjährige (Textzeilen, eigene Aufgaben). Namen tragen die Kinder selbst im Elternbereich ein.
- Kind-Farben aus zehn gedämpften Tönen wählbar (Salbei, Staubblau, Sand, Mauve, Terrakotta, Olive, Schiefer, Rosé, Petrol, Ocker), definiert in `PALETTE` in index.html.
- Feiersound bei kompletter Spalte, synthetisch über Web Audio, Schalter unter Zeiten.
- Beim Icon-Tile ist die ganze Karte Tippfläche, innere Elemente fangen keine Events.
- Abendliste für den ersten Test: Tisch abräumen, Zähne putzen, Duschen oder baden, Schlafanzug.
- Die Config trägt eine Versionsnummer (`CONFIG_VERSION`). Höhere Version ersetzt die gespeicherte Config durch die Defaults.
- Auch der Sechsjährige hat das Plus. Text im Eingabefenster ist optional, Standardname kommt vom Icon (`ICON_LABELS`).
