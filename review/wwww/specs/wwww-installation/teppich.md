---
tags: [spec, wwww-installation, fdn, teppich]
created: 2026-09-28
updated: 2026-11-02
topic: 'Der Rauschteppich des Installationsrechners -- er entsteht aus den Antworten der Modelle auf die Handys, laesst jede einmal als erstes, zweites oder drittes Echo erklingen, verschluckt sie und umhuellt die Installation'
verification: 'Zweck, Modelle, das Erklingen als Echo, die Wahl des Echos durch die Hoerweite und die Wiederkehr vom Nutzer im Gespraech am 2026-09-28 und 2026-09-29 festgelegt. Der Raum als vierte Stimme statt ACE-Step am 2026-10-15. Aufteilung der Leitungen, Verschlucken und Zuordnung der Verfahren aus denselben Sitzungen, nicht bestaetigt. Nichts gebaut, nichts gehoert.'
---

# Teppich — das Rauschen, das die Installation umhüllt

Stand 2026-11-02. **Nichts davon ist gebaut.**

> [!abstract] Der Teppich entsteht aus dem, was er verschluckt
> Er hat keinen eigenen Rauschgenerator. Magenta RT2, AFTER und SA3 antworten auf die Handys, der Raum kommt in Fängen vom Mikrofon dazu. Jede Antwort erklingt einmal als erstes, zweites oder drittes Echo, die Hörweite auf dem Handy wählt welches. Danach versinkt sie im Teppich. Die Aufteilung der 16 Leitungen im Bild ist ein Vorschlag.
>
> ```mermaid
> flowchart TD
>   H[Handys] -->|OSC| MOD[Modelle]
>   MOD --> S[Gruppe 0<br/>4 Stimmen]
>   MIC[Raummikrofon] -->|Fang| S
>   S -->|Echo k| G1
>   S -->|Echo k| G2
>   S -->|Echo k| G3
>   S <-->|Lage 3| T1[Gruppe 1<br/>Punkte 1–4]
>   S <-->|Lage 4| T2[Gruppe 2<br/>Punkte 5–8]
>   T1 <-->|Lage 4| T3[Gruppe 3<br/>Punkte 9–12]
>   T2 <-->|Lage 3| T3
>   T1 --> G1[Genelec 1]
>   T2 --> G2[Genelec 2]
>   T3 --> G3[Genelec 3]
> ```

^blick

**Was hier steht:** was für den Teppich von wwww entschieden, vorgeschlagen und offen ist.

**Was hier nicht steht:** wie Rauschen aus einer Schleife entsteht und wie ein Klang darin versinkt. Das erklärt `learning\max-msp\fdn-6-rauschen-aus-der-schleife.md`, aufbauend auf den Teilen 1 bis 4 derselben Reihe. Verweise wie „Teil 6 §5“ zeigen dorthin. Die Liste aller sieben Teile steht in `fdn.md`.

**Verwandt:** `fdn.md` (das Netz), `modelle.md` (welches Modell wo rechnet), `kommunikation.md` (Handys, Mikrofon, Genelec), `specs\wwww-threejs\steuerung.md` (Gesten, die 12 Punkte), `specs\wwww-main\morphing.md` (das Versinken als gebackene Tabelle; ein Vorschlag).

---

## Festgelegt

| Was | Wie | Seit |
|---|---|---|
| Zweck des Installationsrechners | ein Rauschteppich, der die Installation umhüllt und die Atmosphäre gibt | 2026-09-28 |
| Stimmen | Magenta RT2, AFTER und SA3 antworten auf die Handys. Der Raum kommt in Fängen vom Raummikrofon dazu (`kommunikation.md`). ACE-Step läuft nicht live. | 2026-09-28, geändert 2026-10-15 |
| Verschlucken | der Teppich verschluckt und umhüllt die Antworten immer wieder | 2026-09-28 |
| **Erklingen als Echo** | Eine Antwort erklingt nicht trocken, sondern aus dem Netz: als erstes, zweites oder drittes Echo. Hörbar ist nur dieses eine Echo. | 2026-09-29 |
| **Wahl des Echos** | Die **Hörweite** wählt, welches Echo hörbar wird. Die Besucherin stellt sie mit zwei Fingern ein, indem sie sie auseinander- oder zusammenzieht (`specs\wwww-threejs\steuerung.md`). Eng heißt Echo 1, nah und klar. Weit heißt Echo 3, fern und verändert. Bei gleicher Hörweite kommt dasselbe Echo. | 2026-09-29 |
| **Wiederkehr** | Danach erklingt sie nur noch im Teppich. Klar taucht sie erst wieder auf, wenn sich die Wolke zurückrechnet. | 2026-09-29 |
| **Wiederkehr trocken und vorwärts** | Das Netz hält im Fenster an, in dem die Antwort ganz und unverändert in ihrer Stimmen-Leitung lag, und kehrt um. Die Antwort erklingt, wie das Modell sie gemacht hat, mit dem Teppich darunter. | 2026-09-29 |
| Maschine | das FDN aus `fdn.md`: Hadamard-Weg, 16 Leitungen | 2026-09-28 |

---

## Vorgeschlagen, nicht bestätigt

### Welches Rauschen

Der Teppich ist vor allem **Phasenrauschen**. Er klingt dann nach dem, was er verschluckt hat: nach RT2, AFTER, SA3 und dem Raum. **Spektralrauschen**, bei dem das Vorzeichen in jedem Sample wechselt, kommt nur an Spitzen dazu. Den Unterschied erklärt Teil 6 §1–2.

### Die 16 Leitungen

Das Bild dazu steht oben im Blick.

| Gruppe | Leitungen | Rolle | Ausgang |
|---|---|---|---|
| 0 | 0–3, eine pro Stimme: RT2, AFTER, SA3, Raum | **Stimmen** | nur während des hörbaren Echos, auf dem Genelec des Punkts, von dem die Antwort ausging, beim Raum offen; bei der Wiederkehr noch einmal |
| 1 | 4–7 | **Teppich**, Punkte 1–4 | Genelec 1 |
| 2 | 8–11 | Teppich, Punkte 5–8 | Genelec 2 |
| 3 | 12–15 | Teppich, Punkte 9–12 | Genelec 3 |

**Das sind die 16 Leitungen des Butterfly, keine zusätzlichen.** Der Hadamard-Weg braucht eine Zweierpotenz. Die Aufteilung legt nur fest, welche Leitung welche Aufgabe hat und welche Paare welchen Winkel bekommen. Stünden alle Winkel auf 45°, wäre es genau die 16er-Hadamard-Matrix.

Die Teppich-Leitungen sind die Rausch-Leitungen aus Teil 6 §5.

- Die Lagen 1 und 2 des Butterfly mischen innerhalb jeder Gruppe. In der Stimmen-Gruppe stehen ihre Winkel auf 0, damit jedes Modell in seiner Leitung bleibt.
- Die Lagen 3 und 4 verbinden die Gruppen (Teil 3 §7). Zwischen den Teppich-Gruppen stehen ihre Winkel fest. Zwischen einer Stimme und dem Teppich sind sie das Verschlucken.
- Leitung 0 trifft zuerst die Teppich-Leitungen 4 und 8, Leitung 1 die Leitungen 5 und 9. Eine Vertauschung vor dem Butterfly legt das anders.

Das ist „3 in 1 in 3“: drei Teppich-Räume, einer pro Genelec, in der Mitte die Stimmen.

### Wie eine Antwort versinkt

Nach Teil 6 §6, Form „das `k`-te Echo“, für RT2, AFTER, SA3 und den Raum:

1. **Hineinschreiben.** Die Antwort läuft in ihre Stimmen-Leitung. Die Leitung ist mindestens so lang wie die Antwort und wird nicht abgehört.
2. **Das Echo `k`.** Die Hörweite wählt `k` = 1, 2 oder 3. Vorgeschlagen: das untere Drittel ihres Bereichs heißt 1, das mittlere 2, das obere 3. Bei RT2, das auf alle Handys an einem Punkt antwortet, zählt der Mittelwert der Hörweiten an diesem Punkt. Bei AFTER und SA3 zählt die Hörweite des Handys, das die Antwort ausgelöst hat. Einen Fang des Raums löst kein Handy aus; welches Echo er bekommt, ist offen. Nur während des Umlaufs `k` öffnet sich die Stimmen-Leitung, auf dem Genelec ihres Punkts. Bis dahin bleibt ihr `d` niedrig. Echo 1 ist die Antwort, wie sie hineinging. Echo 2 und 3 sind ein- oder zweimal durch Allpässe und Vorzeichen gelaufen und deshalb leicht verändert.
3. **Zerfließen und Versinken.** Nach dem Umlauf `k` steigen `d` und die Kopplung zum Teppich. Die Kopplung ist frequenzabhängig: Erst wandern die Höhen hinüber, dann die Tiefen.
4. **Wiederkehr.** Beim Zurückholen läuft das Netz rückwärts bis in das Fenster, in dem die Antwort ganz in ihrer Leitung lag, aber noch nie gelesen war. Dort kehrt es um und öffnet die Stimmen-Leitung für einen Umlauf. Die Antwort erklingt trocken und vorwärts, mit dem Teppich, der damals schon in der Leitung lag (Teil 4 §18).

**Ein Beispiel:** RT2 antwortet mit 2 s, die Stimmen-Leitung ist 3 s lang.

| Zeit ab der Antwort | `k` = 1 | `k` = 2 | `k` = 3 |
|---|---|---|---|
| 0–2 s | stumm | stumm | stumm |
| 3–5 s | **hörbar** | stumm | stumm |
| 6–8 s | versinkt | **hörbar** | stumm |
| 9–11 s | — | versinkt | **hörbar** |

**Der Preis:** Die Antwort kommt `k` Leitungslängen nach dem Modell, hier 3, 6 oder 9 s.

**Der Raum** bekommt die vierte Stimmen-Leitung, die bis zum 2026-10-15 ACE-Step gehörte. Ein Beispiel: Jemand lacht laut, der Raum-Anteil steigt über die Schwelle. Das Tor nimmt einen Atemzug vom Mikrofon auf, 3,33 s, roh oder durch RAVE v2. Bei einer Leitung von 4 s erklingt der Fang frühestens nach 4 s als Echo 1, und nur aus dem Netz. Danach fängt das Tor erst wieder, wenn das letzte Echo des Fangs verklungen ist, bei Echo 3 also nach gut 12 s. Sonst fängt das Mikrofon sein eigenes Echo, und der Teppich schaukelt sich auf.

### Umhüllen

Die Energie der Antwort wandert selbst in den Teppich, und Teppich fließt an ihre Stelle. Man hört eine Schicht, die sich verwandelt. Reicht das nicht, kommt am Ausgang eine spektrale Kopplung dazu (Teil 6 §7).

### Die Verfahren in wwww

Welches Verfahren wo sitzen kann, zeigt Teil 6 §4. Für wwww vorgeschlagen:

| Ort | Verfahren |
|---|---|
| Stimmen-Leitungen | Allpässe, Körner-Tausch, Vorzeichen, frequenzabhängige Kopplung zum Teppich |
| Teppich-Leitungen | Butterfly nahe `d` = 1, Allpässe, bewegte Winkel; der Frequenzshift nur im komplexen Netz |
| vor dem Netz, pro Antwort | nichts fest; Bit-XOR, Modulo-Folding oder Zeitverzerrung als Färbung möglich |
| Ausgang | Lautheitskompensation, Limiter |

### Die Modelle als Stimmen

Alle Einträge sind Beispiele. Welches Modell auf welchem Rechner läuft, regelt `modelle.md`.

| Modell | Rechner | antwortet auf | Antwort | hörbares Echo | Stimmen-Leitung | Versinken |
|---|---|---|---|---|---|---|
| **RT2** (`mrt2~`) | Installationsrechner, live | die ☉, gewichtet nach der Zahl der Handys an jedem Punkt | 2-s-Stücke | 1, 2 oder 3 | mindestens 2 s | Sekunden |
| **AFTER** (`nn~`) | Installationsrechner, live | Handy-Daten über `fluid.kdtree~` oder ein Fang vom Raummikrofon | Phrasen | 1, 2 oder 3 | mindestens eine Phrase lang | Sekunden bis eine Minute |
| **SA3 Small** | Installationsrechner, live | ein ☉ | ein Sample | 1, 2 oder 3 | mindestens so lang wie das Sample | offen |
| **SA3 Medium** | Vorproduktion | Eintritt in einen der 12 Punkte | der vorab gerechnete Fächer, denoise 0,1 → 0,9 | 1, 2 oder 3 | mindestens so lang wie das gespielte Stück | Der Fächer ist die erste Hälfte, aufgelöst im Rauschen des Modells. Das Netz macht die zweite. |
| **Raum** | Installationsrechner, live | Raum-Anteil über der Schwelle | ein Atemzug, 3,33 s, roh oder durch RAVE v2 | offen | mindestens 3,33 s | offen |

SA3 Small und SA3 Medium teilen sich eine Stimmen-Leitung. Die vier Stimmen leben auf vier Zeitskalen: RT2 in Sekunden, AFTER in Phrasen, SA3 bei Ereignissen, der Raum in Atemzügen, wenn Menschen laut werden. **Der Teppich klingt nur, solange ihn jemand trägt** (`raum.md`, „Aktivierung“). Ist niemand da, schließen die Tore, und er verklingt mit seiner Nachhallzeit, dann ist es still. Festgelegt am 2026-11-02, davor stand hier: „Der Teppich hört nie auf.“

### Pegel

Je länger die Nachhallzeit des Teppichs, desto lauter wird er bei gleichem Zufluss (Teil 6 §8). Die Lautheitskompensation am Ausgang hält ihn hörbar gleich. Das Raummikrofon darf die Nachhallzeit steuern, wie in `fdn.md` unter „Steuerung“.

### Kollaps im Teppich

Solange jemand spielt, ist im Teppich der Eingang nie ganz zu. Deshalb geht der Kollaps mit oder ohne Abzug (Teil 4 §15):

- **Mit Abzug** läuft der Teppich exakt zurück. Die Antworten treten rückwärts aus der Wolke.
- **Ohne Abzug** verdichtet sich jede Antwort zu ihrem Einsatz und zerfließt dahinter wieder.

Mit einer Nachhallzeit von 60 s reicht der Rückweg etwa fünf Minuten weit (Teil 4 §14).

**Der Rückweg läuft in Echtzeit.** Fünf Minuten zurück dauern fünf Minuten. Schneller geht es, wenn das Netz pro ausgegebenem Sample mehrere Schritte zurückrechnet. Dann klingt es höher, wie ein Band im Rücklauf.

**Nach dem Umkehren fehlen die späteren Antworten.** Mit Abzug nimmt der Rückweg alles heraus, was nach dem Ziel hineinging. Läuft das Netz danach vorwärts, sind diese Antworten nicht mehr im Teppich. In der Aufzeichnung des Tors sind sie noch.

---

## Was für den Bau gilt

- **Kein Rauschgenerator im Teppich.** Rauschen entsteht nur im Netz.
- **Spektralrauschen nur an Spitzen.**
- **Jede Antwort geht über ihr Tor ins Netz.** Das Tor zeichnet auf, was hineingeht, dazu Einsatz, Dauer und `k`. Das braucht der Kollaps mit Abzug, das Echo-Fenster und die Wiederkehr. Die Hörweite kann sich danach ändern, das aufgezeichnete `k` nicht.
- **Jede Stimmen-Leitung ist mindestens so lang wie die Antworten ihres Modells.** Sonst überlappen die Echos, und keines lässt sich allein öffnen.
- **Die Parameter einer Stimme folgen aus dem Sample-Zähler und ihrem Einsatz.** Nur so rechnet das Zurückholen sie rückwärts wieder aus (Teil 4 §13).
- **Die Kopplung zwischen Stimme und Teppich geht nie ganz zurück.** Sonst kreist in der Stimmen-Leitung eine Schleife aus Teppich (Teil 6 §5).
- **Das Raummikrofon geht nur in Fängen durchs Tor ins Netz, nie laufend** (`kommunikation.md`). Nach einem Fang fängt das Tor erst wieder, wenn sein letztes Echo verklungen ist.

## Bewusst nicht drin

| Draußen | Warum |
|---|---|
| ein Rauschgenerator als Quelle | Der Teppich soll nach dem Verschluckten klingen. |
| Überblenden zwischen Antwort und Teppich | klingt nach zwei Schichten (Teil 6 §6) |
| ein trockener Weg | Am 2026-09-29 entschieden: Die Antwort soll aus dem Netz kommen, als Echo. |
| Audio von den Handys | Die Handys senden kein Audio (`kommunikation.md`). |
| ACE-Step als Stimme | Mit mindestens 6 GB passt es nicht neben den Rest in die 16 GB des Mac mini. Am 2026-10-15 entschieden; es bleibt in der Vorproduktion. |

## Was offen ist

- **Was mit den Antworten geschieht, die nach dem Ziel des Zurückholens kamen:** aus der Aufzeichnung des Tors neu einspeisen, sodass sie noch einmal und anders versinken, oder weglassen. Dasselbe gilt für Antworten, die während des Rückwärtslaufs kommen.
- **Was der Teppich tut, wenn lange keine Antwort kommt:** verklingen oder in den Freeze gehen.
- **Wer den Kollaps auslöst**, offen in `fdn.md`.
- **Wie lange jedes Modell zum Versinken braucht**, und was das Versinken einer Antwort startet.
- **Die Nachhallzeit des Teppichs**, und ob der Raumpegel sie steuert.
- **Welches Echo ein Fang bekommt und auf welchem Genelec er erklingt.** Bei den anderen Stimmen wählt die Hörweite des auslösenden Handys das Echo, und es erklingt auf dem Genelec seines Punkts. Einen Fang löst kein Handy aus.
- **Ob der Fächer von SA3 Medium neben SA3 Small bleibt.** Beide teilen sich eine Stimmen-Leitung.
- **Ob der Zustand des Teppichs über Nacht gespeichert wird.** Er besteht nur aus den Delay-Puffern, wenige MB. Er enthielte dann auch Fänge vom Raum, und ein Fang wird nie als Datei gespeichert (`kommunikation.md`).
