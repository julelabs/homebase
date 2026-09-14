# Flur-Tablet: Testprotokoll

Pro Test ein Abschnitt. Beobachtungen, nicht Bewertungen. Was die Kinder tun, was sie sagen, wo sie zögern.

## Test 1: 2026-09-12, Abend, am Rechner oder iPad

Setup: Abendliste mit Tisch abräumen, Zähne putzen, Duschen oder baden, Schlafanzug. Der Sechsjährige Icon-Tiles, der Neunjährige Textzeilen.

Beobachten:

- Findet der Sechsjährige seine Spalte ohne Hinweis?
- Tippt er auf die Karte oder sucht er den Kreis?
- Versteht er das Duschen-Icon (Duschkopf mit Tropfen) und das Tisch-Icon (Teller mit Besteck)?
- Nimmt jemand einen Haken versehentlich zurück? Wie reagiert er?
- Reaktion auf die Fertig-Ansicht und den Klang. Zu laut, zu leise, egal?
- Nutzt der Neunjährige das Plus? Was trägt er ein?
- Fragt jemand nach der anderen Spalte?

Ergebnis:

(hier eintragen)

Änderungswünsche danach:

(hier eintragen)

## Test 2: 2026-09-13, Abend, iPad im Flur (Online-Version)

Rückmeldung der Kinder und Eltern:

- Eigene Aufgaben müssen löschbar sein (Verklicken, falsch angelegt). Der versteckte Langdruck wurde nicht gefunden. Behoben am 14.09.: sichtbares ×.
- Mehr Avatare gewünscht, zweiter Kaktus, mehr Brawl-Stars-Richtung. Behoben: sechs neue.
- Farben zu gedeckt. Behoben: kräftigere Palette, Grenze "nicht wie ein Spielautomat".
- Schwimmen (Brille) wurde als Eule gelesen. Behoben: Schwimmring.
- Nachtmodus in Braun kam nicht an. Behoben am 13.09. spät: dunkles Blau.
- Langdruck für den Elternbereich funktioniert auf dem iPad online. Feiersound kam nicht, geparkt.

## Gerätecheck iPad

`src/check.html` auf dem iPad geöffnet am: 2026-09-13, 17:03, über `homebase.breyer.berlin` in Safari (nicht vom Homescreen).

iOS-Version laut Seite: 12.5.8 (iPad Air 1, letzter Stand für das Gerät). Bildschirm in Safari 1024 x 698 CSS-Pixel quer, Pixeldichte 2. Vom Homescreen ohne Safari-Leisten werden es 1024 x 768.

Ergebnis, alles wie im Konzept erwartet:

- Geht: async/await, fetch, Service Worker, Array.flat, Object.fromEntries, IntersectionObserver, Touch-Events, CSS Grid, position: sticky, overflow-scrolling: touch, Keyframe-Animation (Kasten pulsiert), localStorage.
- Geht nicht: Optional Chaining, Nullish Coalescing, Class Fields, Wake Lock, Flexbox gap (die zwei Kästen kleben aneinander), CSS min()/clamp(), aspect-ratio, prefers-color-scheme.
- Emoji: Zahnbürste, Shorts, Drachen und Flamingo erscheinen als Kästchen. Bestätigt die Entscheidung für SVG-Icons.
- Tippen: Zähler reagiert ohne spürbare Verzögerung (8 Tipps).

Fehlalarm: Die Seite zeigte "CSS Custom Properties: nein". Das war ein Fehler der Prüfmethode (`CSS.supports` mit Custom Property liefert auf alten Safaris false), nicht des Geräts. Safari 12 kann Custom Properties. Die Prüfung wurde am 13.09. durch eine echte Messung ersetzt.

Offen: das Board (`src/index.html`) selbst auf dem iPad öffnen: Farben, Tippen, Elternbereich per Langdruck, Feiersound (Stummschalter aus).
