# Flur-Tablet: Datenmodell (Entwurf)

Stand: 2026-09-13. Entwurf für die Tabellen in der Datenbank (Cloudflare D1). Grundlage ist [[Aufgabenlisten]] und die heutige `config` im Prototyp. Noch nichts davon ist gebaut.

## Was auf den Server geht und was nicht

| Daten | Wo | Warum |
|---|---|---|
| Kinder, Aufgabenkatalog, Wochenplan, Tageszeiten, Einstellungen | Datenbank | Sollen vom Handy oder Laptop pflegbar sein, und dürfen nicht an einem Gerät hängen. |
| Nachricht der Eltern | Datenbank | Der ganze Sinn der Nachricht ist, sie von unterwegs zu schreiben. |
| Haken von heute, selbst hinzugefügte Aufgaben | localStorage auf dem iPad | Entscheidung 13.09.: erstmal lokal. Um Mitternacht weg, braucht keine Historie. Kann später umziehen. |

## Grundidee

Eine Tabelle pro Sorte Ding. Jede Zeile ist eine Aussage ("Kind k1 hat am Montag morgens die Aufgabe Brotbox an Position 1"). Verbindungen zwischen Tabellen laufen über Kennungen (IDs): Die Plan-Zeile speichert nicht "Brotbox in die Küche", sondern nur `brotbox`, und der Text steht einmal in der Aufgaben-Tabelle. Wenn ihr den Text ändert, ändert er sich überall.

## Die Tabellen

### kinder

Eine Zeile pro Kind.

| Spalte | Typ | Beispiel | Bedeutung |
|---|---|---|---|
| id | Text, eindeutig | `k1` | Kennung, wird in anderen Tabellen referenziert |
| name | Text | `Kind 1` | Anzeigename, tragen die Kinder selbst ein |
| avatar | Text | `fox` | Name des Avatars im Icon-Set |
| farbe | Text | `salbei` | Name aus der Palette |
| lesestufe | Text | `icons` oder `text` | Icon-Kacheln oder Textzeilen |
| darf_eigene | Ja/Nein | ja | Darf über das Plus eigene Aufgaben anlegen |
| reihenfolge | Zahl | 1 | Welche Spalte links, welche rechts |

### aufgaben

Der Katalog aller Aufgaben, die es überhaupt gibt. Nicht, wann sie dran sind.

| Spalte | Typ | Beispiel | Bedeutung |
|---|---|---|---|
| id | Text, eindeutig | `zaehne` | Kennung |
| label | Text | `Zähne putzen` | Langtext für die Textzeilen (Kind 2) |
| kurz | Text | `Zähne` | Kurztext unter dem Icon (Kind 1) |
| icon | Text | `toothbrush` | Name des Icons im Set |

Aus [[Aufgabenlisten]] kommen dazu, die es im Prototyp noch nicht gibt: `ranzen_check` (Ranzen-Check), `ranzen_zimmer` (Ranzen ins Zimmer), `brotdosen` (Brotdosen und Trinkflaschen, eine Aufgabe statt zwei), `haende` (Hände waschen), `kleidung` (Anziehsachen wegräumen).

### tageszeiten

Die Abschnitte des Tages. Heute hat der Prototyp nur morgens und abends. [[Aufgabenlisten]] braucht drei.

| Spalte | Typ | Beispiel | Bedeutung |
|---|---|---|---|
| id | Text, eindeutig | `mittags` | Kennung |
| label | Text | `Mittags` | Anzeige |
| beginnt_um | Uhrzeit | `12:00` | Ab wann diese Tageszeit gilt |
| reihenfolge | Zahl | 2 | Sortierung |

Zeilen: morgens (06:00), mittags (12:00), abends (17:30). Die Nacht ist keine eigene Tageszeit, sondern eine Einstellung (siehe unten): ab dann zeigt das Board den Nachtmodus.

### plan

Die wichtigste Tabelle. Eine Zeile pro "dieses Kind hat an diesem Wochentag zu dieser Tageszeit diese Aufgabe".

| Spalte | Typ | Beispiel | Bedeutung |
|---|---|---|---|
| id | Zahl, automatisch | 17 | Kennung der Zeile, braucht der Mensch nie |
| kind_id | Text | `k1` | Verweis auf kinder.id |
| wochentag | Text | `mon` | mon, tue, wed, thu, fri, sat, sun |
| tageszeit_id | Text | `morgens` | Verweis auf tageszeiten.id |
| aufgabe_id | Text | `brotbox` | Verweis auf aufgaben.id |
| reihenfolge | Zahl | 1 | Position in der Liste |

Beispiel aus [[Aufgabenlisten]], Montag, Kind 1:

| kind_id | wochentag | tageszeit_id | aufgabe_id | reihenfolge |
|---|---|---|---|---|
| k1 | mon | morgens | tisch_ab | 1 |
| k1 | mon | morgens | ranzen_check | 2 |
| k1 | mon | mittags | schuhe | 1 |
| k1 | mon | mittags | ranzen_zimmer | 2 |
| k1 | mon | mittags | brotdosen | 3 |
| k1 | mon | mittags | haende | 4 |
| k1 | mon | abends | tisch_ab | 1 |
| k1 | mon | abends | zaehne | 2 |
| k1 | mon | abends | duschen | 3 |
| k1 | mon | abends | kleidung | 4 |
| k1 | mon | abends | schlafanzug | 5 |

Das wird viele Zeilen (2 Kinder x 7 Tage x etwa 10 Aufgaben = rund 140). Das ist für eine Datenbank nichts, und es ist ehrlicher als "Werktag/Wochenende", weil Sonntag ("Zimmer aufräumen nur sonntags") und Schwimmtag sonst Sonderfälle wären. Im Elternbereich kann man trotzdem "Montag bis Freitag auf einmal" anbieten, das erzeugt dann einfach fünf Zeilen.

Die Aktivitäten aus dem Prototyp (Schwimmen: abends vorher packen, morgens mitnehmen) brauchen kein eigenes Konzept mehr. Das sind zwei normale Plan-Zeilen: `schwimm_packen` am Montag abends, `schwimm_mit` am Dienstag morgens.

### nachrichten

| Spalte | Typ | Beispiel | Bedeutung |
|---|---|---|---|
| id | Zahl, automatisch | 3 | |
| datum | Datum | `2026-09-13` | Für welchen Tag die Nachricht gilt |
| text | Text, max 80 Zeichen | `Oma kommt um 16 Uhr` | |
| erstellt_am | Zeitstempel | `2026-09-13 08:12` | Wann geschrieben |

Das Board holt die Nachricht mit dem heutigen Datum. Gibt es keine, ist der Slot leer. Alte Nachrichten bleiben stehen, das schadet nichts und ihr könnt später nachsehen.

### einstellungen

Für Einzelwerte, die keine eigene Tabelle verdienen. Eine Zeile pro Einstellung.

| schluessel | wert |
|---|---|
| sound | `1` |
| nacht_ab | `19:00` |
| morgen_ab | `06:00` |

## Wie die Seite an ihre Liste kommt

`plan` ist die zentrale Tabelle, enthält aber nur Verweise. Das Zusammensetzen mit Namen und Icons macht eine SQL-Abfrage mit `JOIN`, die der Worker ausführt. Die Seite bekommt eine fertige Liste und entscheidet nur noch, wie sie aussieht (Kachel oder Zeile, Farbe).

```sql
SELECT aufgaben.kurz, aufgaben.label, aufgaben.icon, plan.reihenfolge
FROM plan
JOIN aufgaben ON aufgaben.id = plan.aufgabe_id
WHERE plan.kind_id = 'k1' AND plan.wochentag = 'sun' AND plan.tageszeit_id = 'morgens'
ORDER BY plan.reihenfolge;
```

## Geklärt am 13.09.

- Die Liste gilt für beide Kinder gleich. Der Plan wird trotzdem pro Kind gespeichert, damit Abweichungen später möglich sind. Beim Befüllen werden die Zeilen einfach für k1 und k2 doppelt angelegt.
- "Brotdosen und Trinkflaschen" ist eine Aufgabe (`brotdosen`): beides aus dem Ranzen in die Küche.
- "Tisch abräumen" kommt nach jeder Mahlzeit. Unter der Woche essen die Kinder mittags in der Schule, also mittags Mo bis Fr kein Tisch abräumen. Am Wochenende mittags ja.
- "Zimmer aufräumen" nur Sonntag mittags.

Daraus ergibt sich der Plan pro Kind (Aufgaben-IDs, in Reihenfolge):

| | morgens | mittags | abends |
|---|---|---|---|
| Mo bis Fr | tisch_ab, ranzen_check | schuhe, ranzen_zimmer, brotdosen, haende | tisch_ab, zaehne, duschen, kleidung, schlafanzug |
| Sa | tisch_ab | tisch_ab | tisch_ab, zaehne, duschen, kleidung, schlafanzug |
| So | tisch_ab | tisch_ab, zimmer | tisch_ab, zaehne, duschen, kleidung, schlafanzug |

Noch nicht im Plan: Schwimmen und Sport (Prototyp hatte Dienstag Schwimmen für Kind 1, Donnerstag Sport für Kind 2). Klären, ob das noch gilt.

## Was danach kommt

1. Fragen oben klären, Tabellen anpassen.
2. Bei Cloudflare die D1-Datenbank anlegen und die Tabellen mit `CREATE TABLE` schreiben. Julia tippt, Claude erklärt.
3. Erste Daten einfüllen (`INSERT`), erste Abfrage (`SELECT`: "was hat k1 heute morgens zu tun").
4. Worker bauen, der genau zwei Dinge kann: Plan und Nachricht ausliefern, Nachricht entgegennehmen.
5. `Store` im Prototyp umbauen: Config kommt vom Worker, Haken bleiben lokal.
