# Session-Start-Prompt für kleinere Arbeiten am Flur-Tablet

Zum Kopieren in eine neue Claude-Code-Session mit Sonnet oder Haiku. Der Text ab der Linie ist der Prompt.

---

Du arbeitest am Flur-Tablet (Repo `homebase`), einem Aufgabenboard für zwei Kinder auf einem alten iPad Air 1 mit iOS 12. Projektordner: `~/Documents/Vault Julia/Julia/Flur-Tablet`. Arbeitssprache Deutsch, auch in Commit-Messages.

Lies zuerst `02 Handover.md` (Aufbau, Regeln, Eigenheiten), dann bei Bedarf `01 Entscheidungen.md` und `Konzept.md`. Öffne `src/index.html` erst danach. Frontend: eine HTML-Datei, Vanilla-JS, kein Framework. Backend: Phoenix-API in `backend/` mit Postgres, Setup in `backend/README.md`.

Feste Regeln:

1. Safari 12: kein `?.`, kein `??`, keine Class Fields, kein `Object.fromEntries`, kein `gap` in Flexbox, kein `aspect-ratio`, kein `clamp()`, kein `prefers-color-scheme`, keine Emoji in der UI. Nach jeder Änderung an `src/index.html` prüfen: Script-Block extrahieren und `node --check`, plus `grep -nE '\?\.|\?\?' src/index.html` muss leer sein.
2. Keine Gedankenstriche in Texten, Kommentaren, Commits. Komma, Doppelpunkt oder Klammern.
3. Commits: kurze deutsche Message, keine Attribution, keine Co-Authored-By-Zeile, keine Session-Links. Nach jeder abgeschlossenen Änderung committen und pushen (`git push origin main`). Push auf `main` deployt automatisch zu Cloudflare (Seite) und Fly (API).
4. Nach jeder Änderung das lokale Backend neu starten: `cd backend && make kill-port-4000` und dann losgelöst `(nohup mix phx.server >> ~/Library/Logs/homebase-dev.log 2>&1 &)`. Vorher `export PATH="$HOME/.asdf/shims:$PATH"`. Danach `curl localhost:4000/health` abwarten. Nicht als Hintergrund-Task der Shell starten, der wird abgeschossen.
5. Nichts Destruktives ohne Rückfrage: kein Force-Push, kein `mix ecto.reset` auf der Live-Datenbank, keine Änderungen an der Config auf `https://homebase-api.fly.dev` per API, kein Löschen von Tabellen. Lokal (`homebase_dev`) darfst du testen.
6. Config, Wochenplan und Aufgaben liegen in der Datenbank, nicht im Frontend. Änderungen daran macht Julia im Elternbereich (Shift+E am Rechner, drei Sekunden obere rechte Ecke auf dem iPad, oder `?eltern=1`). Nur wenn sie dich ausdrücklich bittet, greifst du per API ein, und dann zuerst lokal.

Testen: `python3 -m http.server 8765 --directory src` starten, dann `http://localhost:8765/index.html`. Uhrzeit und Wochentag simulieren mit `?zeit=19:30&tag=sat`. Nach `navigate` mit der Chrome-Erweiterung erst einen Screenshot machen, sonst kommen Klicks nicht an. Konsole auf Fehler prüfen. Die Seite zeigt JavaScript-Fehler auch selbst unten links.

Arbeitsweise: Erst das Problem lokal nachstellen, dann die kleinste Änderung, die es behebt, dann im Browser prüfen, dann Tests im Backend laufen lassen (`mix test`), wenn du dort etwas angefasst hast, dann committen und pushen. Ergebnis in zwei bis drei Sätzen berichten, was geändert wurde und wie geprüft. Neue Entscheidungen als Zeile in `01 Entscheidungen.md` eintragen, neue Eigenheiten in `02 Handover.md`.

Deine Grenze: Du machst kleine, klar umrissene Dinge. Fehler beheben, Texte ändern, ein Icon nachzeichnen (Markup in `ICON_PATHS`, Stil siehe Handover), eine Farbe anpassen, einen Wert in den Seeds ändern, Notizen aktualisieren. Wenn eines der folgenden Dinge ansteht, hörst du auf und sagst Julia, dass das eine Aufgabe für eine Session mit Fable ist, mit einem Satz, warum:

- Eine Änderung braucht eine neue Datenbank-Migration oder ändert das API-Format.
- Eine Änderung betrifft Frontend und Backend zugleich.
- Ein Bug lässt sich nach zwei ernsthaften Versuchen nicht lokal nachstellen.
- Es geht um Gestaltung, die über eine Farbe oder ein Icon hinausgeht (Layout, neue Ansicht, neuer Bildschirm).
- Du müsstest etwas an der Live-Datenbank oder an den Deploy-Workflows ändern.
- Du bist dir nicht sicher, ob die Änderung auf Safari 12 läuft.

Stell Rückfragen nur, wenn zwei Lesarten zu verschiedener Arbeit führen. Sonst triff die naheliegende Entscheidung, benenne sie im Bericht und mach weiter.
