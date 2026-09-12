# Flur-Tablet: Briefing

Stand: 2026-09-12. Projektordner: dieser Ordner im Vault. Die Dateien `index.html` (Prototyp) und `check.html` (Gerätecheck) liegen direkt hier.

## Die Idee

Beim Frühstück am 12.09.2026 entstanden: Ein altes iPad Air hängt im Flur und zeigt den beiden Kindern (6 und 9) ihre regelmäßigen Aufgaben. Brotbox und Trinkflasche in die Küche, Schuhe wegräumen, Schwimmsachen packen. Die Kinder haken selbst ab.

Rollen: Julia macht Produkt und UI/UX. Ihr Mann macht die technische Umsetzung und den Einbau (Kiosk, Strom, Guided Access, Backend).

## Wofür es da ist

Das Tablet ist ein Helfer, kein Aufseher. Die Kinder sollen sehen, was dran ist, ohne dass es ihnen jemand sagt. Der Lohn ist der leere Bildschirm, nicht ein Punktestand.

Deshalb bewusst nicht: Punkte, Sterne, Wochenauswertung, Rot für Unerledigtes, Verlauf von gestern, Geschwistervergleich auf einer gemeinsamen Liste.

## Julias Ausgangsliste (Kurzfassung)

- Icons statt Wörter für den Sechsjährigen, Icon plus Text für den Neunjährigen. Gleiche Liste, zwei Lesestufen.
- Eine Spalte pro Kind. Kein "wer hat die Brotbox vergessen".
- Tagesabhängig: Schultage, Wochenende, Schwimmtag.
- Kein Rot. Unerledigtes bleibt einfach stehen.
- "Alles erledigt"-Ansicht: etwas Warmes, Kurzes.
- Nachrichten-Slot für die Eltern: "Papa holt euch ab". Vom Handy getippt, im Flur gelesen. Das ist der Grund, jeden Tag hinzuschauen.
- Avatar selbst wählen. Ownership.
- Abends gedimmt, ab 19 Uhr.
- Der Neunjährige darf eigene Aufgaben eintragen.
- Kiosk-Modus, Dauerstrom, Guided Access: Sache des Tech-Leads.

Nachtrag vom selben Tag: Farben selbst wählbar, aber aus einer gedämpften Palette. Kurzer Feiersound, wenn eine Spalte fertig ist. Beim Sechsjährigen ist die ganze Karte die Tippfläche.

## Zielgerät

iPad Air 1 mit iOS 12. Das ist die wichtigste Constraint: eine einzige HTML-Datei ohne Framework, JavaScript im Stand von 2017, keine Emoji, kein Flexbox-gap. Details in [[Konzept]].

## Erfolgskriterium für den ersten Test

Findet der Sechsjährige seine Spalte und seinen Haken ohne Erklärung? Nutzt der Neunjährige das Plus für eigene Aufgaben? Schaut jemand freiwillig ein zweites Mal hin?

## Verwandte Notizen

- [[Konzept]]: Constraints, die vier Bildschirme, Entscheidungsvorlage für das Backend
- [[01 Entscheidungen]]: was wann warum entschieden wurde
- [[02 Handover]]: für neue Claude-Sessions
- [[03 Testprotokoll]]: Beobachtungen aus den Tests mit den Kindern
- [[Anleitung Tech-Lead]]: aufs iPad bringen, Geräteeinstellungen
