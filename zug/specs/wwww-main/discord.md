---
tags: [spec, wwww-main, discord, prod]
created: 2026-11-12
topic: 'Discord hinter der Wurst -- ein Textfeld, zwei Knoepfe, ein Bot im eigenen Container, Threads in similis und varius, Struktur aus 1, 3, 7 und 12'
verification: 'Vom Nutzer am 2026-11-12 Frage fuer Frage entschieden. Was ein Bot und ein Webhook koennen, stammt aus dem Gedaechtnis von Claude und aus einem Abschnitt der Discord-Doku, gelesen fuer den Handoff vom 2026-11-05. Vor dem Bau in der Doku pruefen. Nichts gebaut.'
---

# Discord — ein Anliegen wird ein Thread

Stand 2026-11-12. **Nichts davon ist gebaut.**

> [!abstract] Wer schreibt, wählt mit dem Absenden zwischen Berührung und Begegnung
> Hinter der Wurst steht ein Textfeld mit zwei Knöpfen. Ein Bot im eigenen Container auf dem VPS legt daraus einen Thread an, in `similis` für Gleichgesinnte oder in `varius` für Widerstände, und gibt den Link zurück. Die Zahlen 1, 3, 7 und 12 bestimmen die ganze Struktur: Stufen der Teilnahme und Tage der Erinnerung.
>
> ```mermaid
> flowchart TD
>   T[Textfeld] -->|Berührung| B["Bot<br/>Container<br/>auf dem VPS"]
>   T -->|Begegnung| B
>   B --> S["Forum<br/>similis"]
>   B --> V["Forum<br/>varius"]
>   S --> L["Link zum Thread<br/>und Einladung"]
>   V --> L
>   B -.->|"Tag 1 · 3 · 7 · 12"| R["Erinnerung<br/>im Thread"]
> ```

^blick

**Was hier steht:** wie ein Anliegen von der Startseite in Discord ankommt und was danach geschieht.

**Was hier nicht steht:** die Startseite selbst, die steht in `startseite.md`.

**Verwandt:** `archive\handoffs\2026-11-05-wwww-ideen-moeglichkeiten.md`, Abschnitt 15 (alle Möglichkeiten), `specs\wwww-main\zahlen.md` (die Zahlen des Rahmens), `specs\wwww-threejs\steuerung.md`, „Der Guide“ (braucht ebenfalls einen Dienst).

---

## Der Wortlaut

Aus der Liste des Nutzers vom 2026-11-05: „Discord Chat mit Textfeld, wo Anliegen hineingeschrieben wird und ein Link zu einem Kanal ggf. sogar Thread generiert wird. similis/varius Unterteilung der Kanäle, zum Finden von Gleichgesinnten (Berührung) oder Widerständen (Begegnung). Schleifen der Wiederholung (1, 7, 12 siehe auch Kopplung in Moodle). Profile mit Symbolen.“

## Das Textfeld

- **Zwei Knöpfe statt eines Absenden-Knopfs:** „Berührung“ legt den Thread in `similis` an, „Begegnung“ in `varius`. Die Wahl ist das Absenden.
- **Danach erscheinen** der Link zum Thread und eine Einladung auf den Server. Den Link öffnen vermutlich nur Mitglieder.
- **Vor dem Absenden steht sichtbar**, dass der Text an Discord geht, einen Dienst in den USA (`startseite.md`, Rechtsfragen).
- Das Formular löst etwas aus. Es trägt deshalb kein `toolautosubmit` (`webmcp.md`, Stufe 3).

## Der Bot

| Punkt | Festgelegt |
|---|---|
| **Art** | ein Bot, kein Webhook. Er kann alles, was ein Webhook kann, dazu Leute zu Threads hinzufügen, private Threads, Rollen und Erinnerungen. |
| **Wo** | ein eigener kleiner Container auf dem VPS, als neuer Ordner in `zaehlen\vps\compose\`, hinter dem Proxy. Die Texte der Besucher bleiben auf dem eigenen Server. |
| **Erste Stufe** | ein Thread pro Anliegen, öffentlich im Forum, ohne Anmeldung. Der Container fragt mit dem Schlüssel des Bots an und muss dafür nicht dauernd verbunden sein. |
| **Spätere Stufe** | Anmeldung mit Discord auf der Seite. Dann kennt der Bot die Person, legt ihren Thread an, fügt sie hinzu und kann privat schreiben. Sie kommt, wenn die Stufen pro Person zählen sollen. |
| **Schutz** | eine Grenze pro Adresse und eine pro Tag, begrenzte Länge, keine Erwähnungen wie `@everyone`. |
| **Später im selben Container** | die Erinnerungen und vielleicht der Guide aus `steuerung.md` |

## Similis und varius

Zwei Forum-Kanäle, `similis` und `varius`. Der Nutzer schreibt „Unterteilung der Kanäle“, und getrennte Kanäle lassen sich getrennt öffnen oder schließen.

## Die Struktur aus 1, 3, 7 und 12

**1, 3, 7 und 12 bestimmen die ganze Struktur** (Nutzer, 2026-11-12). Sie zählen beides:

- **Stufen der Teilnahme**, mit Wechsel der Rollen von Stufe zu Stufe.
- **Tage bis zur Erinnerung:** Der Bot meldet sich im Thread nach 1, 3, 7 und 12 Tagen.

**Vorbild ist die Kopplung in Moodle:** fest strukturierte Phasen, und mit den Phasen wechseln die Rollen. Die Profile mit Symbolen hängen an den Stufen.

## Offen

- Was auf jeder der vier Stufen geschieht und welche Rollen dabei wechseln.
- Was eine Stufe weiterzählt: Beiträge, Besuche oder Tage.
- Welche Symbole die Profile tragen. Unicode im Namen geht immer, Rollen-Icons brauchen laut Gedächtnis Server-Boosts.
- In der Discord-Doku zu prüfen: Threads per Bot in Forum- und Textkanälen, private Threads ohne Boost, ob `channel_id` der Antwort die ID des Threads ist, die leere Liste für `allowed_mentions`.
- Wie die Einladung aussieht: dauerhaft oder pro Anliegen.
