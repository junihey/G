---
tags: [spec, wwww-main, entwurf, kette, historie, edition]
created: 2026-10-12
topic: 'Entwurf -- alle Inhalte der Change-Liste vom 2026-10-12 in einer Datei: Atem-Kette, Prompt-Historie mit Sonne und Mond, Edition als Erinnerung, und die Zeilen fuer vier bestehende Specs'
verification: 'Im Gespraech am 2026-10-12 entwickelt. "Festgelegt" heisst: vom Nutzer im Gespraech bestaetigt. "Vorgeschlagen" heisst: von Claude, nicht einzeln bestaetigt. Nichts gebaut. Keine Plattform, keine Kette fuer den Token, kein Wallet-Dienst geprueft.'
---

# Entwurf — Kette, Historie, Edition

Stand 2026-10-12. **Nichts davon ist gebaut.**

> [!abstract] Ein Block pro Atemzug, eine Historie ohne Ende, eine Erinnerung pro Besuch
> Alle 3,33 s schließt ein Block, das sind 25.920 am Tag. In den Blöcken stehen nur Hashes der Historie, nie Text: ☉ von den Besuchern, alle 72 Atemzüge ein ☽ aus dem Raum, ✶ für jede gekaufte Erinnerung. Nach dem Ausstellungstag verankert der VPS den Tages-Hash in Bitcoin und Base. Eine Erinnerung kostet 72 € und läuft danach wieder im Beamerbild.
>
> ```mermaid
> flowchart TD
>   H["Handys<br/>☉"] --> HI[Historie]
>   R["Raum<br/>☽ alle 72 Atemzüge"] --> HI
>   HI -->|nur Hashes| K["Kette<br/>ein Block alle 3,33 s"]
>   K -->|nach dem Ausstellungstag| V[VPS]
>   V -->|Tages-Hash| B["Bitcoin und Base"]
>   HI --> Q[Quittungsseite]
>   Q -->|72 €| E["Erinnerung<br/>Token, Plot, IPFS-Paket"]
>   E -->|✶| HI
>   E --> BE[Beamerbild]
> ```

^blick

**Was diese Datei ist:** ein Entwurf zum Lesen. Teil 1 bis 3 werden je eine eigene Datei, Teil 4 sind Zeilen für vier bestehende Specs. Ist der Entwurf freigegeben, wird er aufgeteilt und diese Datei gelöscht.

| Teil | wird zu |
|---|---|
| 1 · Atem-Kette | `specs\wwww-main\kette.md`, neu |
| 2 · Prompt-Historie | `specs\wwww-installation\historie.md`, neu |
| 3 · Edition | `specs\wwww-main\edition.md`, neu |
| 4 · Ergänzungen | `kommunikation.md`, `steuerung.md`, `modelle.md`, `zahlen.md` |

---
---

## Teil 1 · künftig `specs\wwww-main\kette.md`

### Kette — ein Block pro Atemzug

**Die Regel, aus der alles folgt:** Ein Block pro Atemzug. In der Kette stehen nur Hashes, nie Text.

**Was hier steht:** wie die Atem-Kette entsteht, wie sie verankert wird und was Besucher als Quittung bekommen.

**Was hier nicht steht:** was in die Einträge hineinkommt. Das regelt `specs\wwww-installation\historie.md`. Was Besucher kaufen können, regelt `edition.md`.

**Verwandt:** `zahlen.md` (25.920 und der Atemzug von 3,33 s), `specs\wwww-installation\teppich.md` (der Teppich entsteht aus dem, was er verschluckt; die Kette auch, nur vergisst sie nichts), `zaehlen\wwww\ARCHITEKTUR.md` (die Installation hat kein Internet).

### Festgelegt

| Was                    | Wie                                                                                                                                                          | Seit       |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------- |
| Zweck                  | Beleg: Es lässt sich nachprüfen, was im Raum geschah. Kein Markt, kein Token für die Kette selbst.                                                           | 2026-10-12 |
| Blocktakt              | ein Block pro Atemzug, alle 3,33 s. Das sind 25.920 Blöcke am Tag.                                                                                           | 2026-10-12 |
| Inhalt eines Blocks    | die Hashes aller Einträge, die in diesem Atemzug entstanden, und der Hash des vorigen Blocks                                                                 | 2026-10-12 |
| Was in die Kette kommt | nur Hashes. Kein Text, keine Personendaten.                                                                                                                  | 2026-10-12 |
| Verankerung | Nach dem Ausstellungstag kommt die Kette auf den VPS. Der VPS schreibt den Tages-Hash, den Hash des letzten Blocks, zweimal: per OpenTimestamps in die Bitcoin-Kette und in den eigenen Vertrag auf Base. „Prüfen“ liest ihn sofort aus Base, Bitcoin hält am längsten. Ein Token zeigt im selben Vertrag auf seinen Tages-Hash. | 2026-10-13 |
| Quittung               | Jeder Besucher bekommt auf Wunsch einen Code und eine Quittungsseite.                                                                                        | 2026-10-12 |
| Keine Gesten | In die Blöcke kommen nur Einträge der Historie (☉, ☽, ✶) und die Erinnerungen, keine Gesten. Jeder Hash gehört zu etwas, das auf der Quittungsseite steht. | 2026-10-13 |
| Weg zum VPS | Nach Schluss verbindet sich der Installationsrechner kurz mit dem Internet, etwa über ein Handy als Hotspot. Er lädt Kette, Antworten und Ansichten hoch und trennt wieder. Während der Öffnung bleibt das WLAN ohne Uplink. | 2026-10-13 |

### Vorgeschlagen, nicht bestätigt

#### Die Blocknummer

Blocknummer = Sekunden seit Mitternacht ÷ 3,33, abgerundet. Block 0 beginnt um 0:00, Block 25.919 endet um 24:00.

Beispiel: Ein Besuch von 14:02 bis 14:20 liegt in Block 15.156 bis 15.480. Das sind 324 Atemzüge, denn 18 Minuten × 18 Atemzüge = 324.

**Auch ein stiller Atemzug bekommt einen Block.** Er enthält dann nur den Hash des vorigen. So hat jeder Tag genau 25.920 Blöcke.

#### Die Quittung

Ein Knopf auf dem Handy, „Quittung", zeigt:

```
ATEM-7K3F
Block 15.156 bis 15.480
Du warst 324 Atemzüge lang hier.
```

**Der Code ist nicht der Hash.** `ATEM-7K3F` ist ein zufälliger, kurzer Name. Er dient nur dazu, die Quittungsseite zu finden. Vier Zeichen aus Buchstaben und Ziffern ergeben 1,7 Millionen Codes.

#### Die Quittungsseite

Zu Hause öffnet der Code `julianniklasheynert.xyz/q/ATEM-7K3F`:

```
Du warst 324 Atemzüge lang hier
13.10.2026, 14:02 bis 14:20 · Block 15.156 bis 15.480

☉ 14:05  „Glocken unter Wasser, sehr langsam"     ▶ Antwort von SA3   (dein Prompt)
☽ 14:08  Der Raum ist leiser geworden. Zwei Stimmen sprechen
         über das Wasser, die Glocken liegen jetzt tief im Teppich.
☉ 14:11  „mehr Metall"                             ▶ Antwort von RT2
☽ 14:12  …
☉ 14:17  „Stille"                                  ▶ Antwort von SA3   (dein Prompt)

Beleg
Tages-Hash 13.10.2026: 5b1e…  ·  in Bitcoin verankert am 14.10.2026
[ Prüfen ]

[ Als Erinnerung kaufen ]   → edition.md
```

#### So hängt der Hash an der Seite

1. Jeder Eintrag der Historie bekommt einen Hash.
2. Jeder Block nimmt die Hashes seiner Einträge auf, dazu den Hash des vorigen Blocks.
3. Der letzte Block des Tages ergibt den Tages-Hash. Nur er geht über OpenTimestamps nach Bitcoin.
4. „Prüfen" lässt den Browser die Hashes aus den angezeigten Einträgen neu rechnen, die Kette bis zum Tages-Hash entlanggehen und das Ergebnis mit dem Beleg in Bitcoin vergleichen. Ist ein Wort geändert, passt der Hash nicht mehr.

Für die Prüfung lädt die Seite die Hashes aller Blöcke des Tages, nicht deren Inhalt: 25.920 × 32 Byte, etwa 0,8 MB.

#### Löschen

Ein Eintrag lässt sich aus der Historie entfernen, etwa ein beleidigender Prompt. In der Kette bleibt sein Hash stehen. Danach lässt sich nur dieser eine Eintrag nicht mehr prüfen, alle anderen schon.

### Was für den Bau gilt

- **Die Uhr des Installationsrechners bestimmt die Blocknummer.** Ohne Internet gibt es keinen Zeitabgleich. Die Uhr wird vor jedem Ausstellungstag gestellt.
- **Ein leerer Block wird trotzdem geschrieben.** Sonst stimmt die Zahl 25.920 nicht mehr.
- **Kein Text in die Kette.** Auch kein Hash von etwas, das allein eine Person erkennbar macht.

### Bewusst nicht drin

| Draußen | Warum |
|---|---|
| Spur als Edition: eine Karte des eigenen Flugs als Token | am 2026-10-12 verworfen, die Edition in `edition.md` ersetzt sie |
| Schichten im Beamerbild: jeder Block als sichtbare Schicht | am 2026-10-12 verworfen |
| Herkunft der Originale, also Scan, Bildbeschreibung und Erweiterung als Hash verankert | nicht gewählt. Passt zu `originale.md`, falls es später gebraucht wird. |
| eigener, handelbarer Token oder Coin | fällt in der EU unter MiCA und lädt zur Spekulation ein |
| Abstimmen per Token, etwa über die 12 Motive | Jeder Besucher bräuchte Wallet und Internet im Raum. |
| Personendaten in der Kette | Die DSGVO verlangt Löschen auf Wunsch. Aus der Kette lässt sich nichts löschen. |

### Was offen ist

- **Wo die Kette läuft.** In Max über `node.script`, wo auch die OSC-Nachrichten ankommen, oder in der Linux-VM.
- **Das Dateiformat der Kette.** Etwa eine Zeile JSON pro Block.

---
---

## Teil 2 · künftig `specs\wwww-installation\historie.md`

### Historie — Sonne fragt, Mond nimmt wahr

**Die Regel, aus der alles folgt:** ☉ ist, was Besucher schreiben. ☽ ist, was der Raum wahrnimmt. Beide stehen in einer Historie, die nie endet.

**Was hier steht:** das Textfeld auf dem Handy, die zwei Arten von Einträgen und wie der ☽ entsteht.

**Was hier nicht steht:** wie die Einträge belegt werden. Das regelt `specs\wwww-main\kette.md`. Wo das Textfeld auf dem Bildschirm liegt, regelt `specs\wwww-threejs\steuerung.md`.

**Verwandt:** `kommunikation.md` (OSC, Raummikrofon, FluCoMa-Messungen), `modelle.md` (welches Modell wo rechnet), `teppich.md` (wohin die Antworten der Modelle gehen).

### Festgelegt

| Was | Wie | Seit |
|---|---|---|
| Textfeld | ein Overlay auf dem Handy. Es schickt einen Prompt an SA3, Magenta RT2 oder ein anderes Prompt-Modell. | 2026-10-12 |
| Modellwahl | Du legst fest, welche Modelle zur Wahl stehen. Besucher wählen nur unter diesen. | 2026-10-12 |
| Endlos-Historie | Jeder Prompt wird gespeichert. Die Historie endet nie. | 2026-10-12 |
| ☉ Sonne | ein Prompt von einem Handy | 2026-10-12 |
| ☽ Mond | eine Zusammenfassung des Zustands durch ein lokales Modell, in festem Takt zwischen den Prompts | 2026-10-12 |
| Was in den ☽ fließt | die Historie seit dem letzten ☽, die Transkription vom Raummikrofon und die lokal berechnete Wahrnehmung | 2026-10-12 |
| Transkription | fließt nur in den ☽ und wird danach verworfen. Der Wortlaut wird nie gespeichert. Ein Schild am Eingang sagt, dass das Mikrofon zuhört. | 2026-10-12 |
| Lokal | Transkription und ☽ rechnen im Raum, ohne Internet. | 2026-10-12 |
| In die Kette | Jeder ☉ und jeder ☽ kommt als Hash in den Block des Atemzugs, in dem er entstand. | 2026-10-12 |
| Takt des ☽ | alle 72 Atemzüge, also alle 240 s. Das ergibt 360 ☽ am Tag, so viele, wie ein Kreis Grad hat (25.920 ÷ 72 = 360). | 2026-10-13 |
| ☽ nur zum Lesen | Der ☽ bleibt Text in der Historie und geht an kein Modell. Die Installation antwortet nur auf Besucher. | 2026-10-13 |
| Anzeige im Raum | auf jedem Handy als ausklappbare Leiste und im Beamerbild als laufende Zeilen am Rand | 2026-10-13 |
| Historie und Bild-Schleife | Die Zeilen liegen auf einer festen Fläche am Rand des Beamerbilds. Die Kamera erfasst diese Fläche nicht, die Zeilen laufen also nicht durch die Bild-Schleife. Die Fläche bleibt immer an derselben Stelle. | 2026-10-13 |
| Kein Eingriff | Jeder Prompt erscheint, wie er geschrieben wurde. Es gibt keinen Filter und keine Wortliste. Was Besucher schreiben, ist Teil des Werks. | 2026-10-13 |
| Länge eines Prompts | höchstens 72 Zeichen, etwa eine Zeile im Beamerbild und am Plot-Rand | 2026-10-13 |

### Vorgeschlagen, nicht bestätigt

#### Die zwei Einträge

| Eintrag | Wer schreibt | Was er enthält | Wann |
|---|---|---|---|
| ☉ Sonne | Besucher über das Textfeld | Zeit, Handy-ID, Modell, Prompt, Verweis auf die Antwort als Audiodatei | jederzeit |
| ☽ Mond | das lokale Modell | Zeit, zwei bis vier Sätze über den Zustand | alle 72 Atemzüge |

Ein Beispiel für einen ☽:

> Der Raum ist leiser geworden. Zwei Stimmen sprechen über das Wasser, die Glocken liegen jetzt tief im Teppich.

Der ☽ sagt, worüber gesprochen wird, und zitiert niemanden.

#### Die Wahrnehmung

Dieselben Messungen wie in `kommunikation.md`: Lautheit und spektrale Form vom Raummikrofon, mit FluCoMa (`fluid.loudness~`, `fluid.spectralshape~`). Das Modell für den ☽ bekommt sie als Zahlen, gemittelt über die 240 s.

#### Die Antworten werden aufbewahrt

Jede Antwort eines Modells auf einen ☉ wird als Datei gespeichert, mit der Handy-ID. Die Quittungsseite und die Edition spielen sie später ab.

#### Recherche vom 2026-10-13: was auf dem Mac mini rechnen kann

Nichts davon ist auf dem Mac mini gemessen.

| Frage | Ergebnis | Quelle |
|---|---|---|
| Speicher | Der Mac mini M6 hat **16 GB**, abgelesen per SSH am 2026-10-13 (`hw.memsize`). Die Linux-VM hält 8 GB (`tart set mini-vm --memory 8192`). Für macOS, Max und alle Modelle bleiben etwa 8 GB. | `specs\mac-mini\einrichtung.md`, SSH auf `wilma@192.168.8.50` |
| SA3 Medium | 1,4 Mrd. Parameter. Auf dem PC mit CUDA gemessen: 2,4 s für 5 s Audio, warm. Für Apple Silicon gibt es ein MLX-Backend mit int8 und int4, aber keine veröffentlichte Messung. Die Hauptplattform ist CUDA. | `zaehlen\sa3-medium\README.md`, soniqo.audio/ru/guides/stable-audio, goodfirstissue.org (vllm-omni #3787) |
| SA3 Small | 459 Mio. Parameter, bis 2 min Audio. Läuft laut einem Bericht auf einem MacBook Pro M4, ohne Zeitangabe. | artintech.substack.com |
| **SA3 Small Music, gemessen** | am 2026-10-13 auf dem Mac mini, offizielle MLX-Laufzeit von Stability (Commit `77e0398`), FP16, 8 Schritte, Prompt „slow bells under water, deep, sparse“. Warm: 5 s Audio in 0,64 s, 10 s in 0,69 s, 30 s in 1,06 s, also 8- bis 28-fach schneller als Echtzeit. Spitze im Speicher 1,5 bis 1,7 GB, `peak memory footprint` 1,8 bis 2,1 GB. Der erste Lauf brauchte 3,9 s ohne Download. Download insgesamt 1,7 GB Gewichte. Jeder Lauf lädt die Modelle neu; ein Dienst, der sie hält, wäre schneller. Gehört noch nicht. | `/Users/wilma/wwww-messung/logs/sa3-small.log` auf dem Mac mini |
| SA3 Small Music, MLX | zwei Fassungen ohne Zugangssperre: `mlx-community/stable-audio-3-small-music` für die Python-Bibliothek `mlx-audio`, 3,49 GB; `aufklarer/Stable-Audio-3-DiT-Small-Music-MLX-4bit` für `speech-swift`, 1,27 GB, DiT in int4. Beide gemessen über die Hugging-Face-API. `mlx-audio` 0.5.8 braucht ohne Modell etwa 148 MB Pakete, gemessen über PyPI. | Hugging-Face-API, PyPI |
| **Magenta RT2 Small, gemessen** | am 2026-10-13 auf dem Mac mini, `mrt2~` aus `CreativeCodeExternals.zip` in Max 9.2 im Konto `exhib`, Abtastrate 48 kHz. Arbeitsspeicher von Max: 0,29 GB ohne, 1,33 GB mit `mrt2~`, also etwa 1 GB für RT2 Small. CPU von Max 25 bis 28 %. **Klang:** Nach Transienten setzt ein Rattern ein, das mit der Lautstärke abklingt, bei beiden Test-Prompts. Ausgeschlossen: Bildschirmfreigabe, Clipping (bleibt bei `volume -12`), Lautsprecher (auch über Kopfhörer). **Ursache gemessen:** In Googles App Jam rattert derselbe Prompt nicht, mit denselben Werten für temperature, topk und CFG rattert `mrt2~` weiter. Eine Aufnahme von 7,2 s aus `mrt2~` (Max: I/O Vector 1024, Signal Vector 128, 48 kHz) zeigt 166 Lücken aus Nullen, bis 256 Samples lang, im festen Abstand von 2048 Samples, also 23 Mal pro Sekunde. 99 % aller Sprünge liegen genau auf einer Grenze der Signal Vectors von 128 Samples. Das Rattern ist also eine Lücke pro Block von `mrt2~`, kein Klang des Modells. Auffällig: 2048 − 128 = 1920 Samples sind genau 40 ms bei 48 kHz. Laut Quellcode (`examples/max/mrt_tilde.mm`, `core/src/realtime_runner.cpp`) füllt `mrt2~` mit Nullen auf, wenn der nächste Block von 1920 Samples noch nicht fertig ist. Signal Vector 64 statt 128 änderte nichts. **Gelöst mit `buffersize 8192`**, gesendet nach dem Laden, bei unveränderten Einstellungen von Max (I/O 1024, Signal Vector 128): Die Aufnahme von 19:53 hat keine Lücken mehr im Takt von 2048 Samples, und das Rattern ist weg. Die README nennt 8192 als Standard; in Max galt ohne die Nachricht offenbar ein kleinerer Wert. Kosten: 170 ms Verzögerung. **Für die Installation:** Der Patch sendet `buffersize 8192` beim Laden. Der Download für Modell und Encoder war 1,8 GB, nicht 450 MB. | `/Users/wilma/wwww-messung/logs/rt2-speicher.log` auf dem Mac mini, Hörtest des Nutzers |
| Transkription: Parakeet v3 | 25 europäische Sprachen, Deutsch dabei. Am schnellsten in einem Vergleich auf einem M4. MLX-Fassung `mlx-community/parakeet-tdt-0.6b-v3`: 2,51 GB, gemessen über die Hugging-Face-API. | Hugging-Face-API, spokenly.app, getvext.app |
| Transkription: Whisper large-v3-turbo | 99 Sprachen, genauer bei schwierigem Ton, etwa halb so schnell wie Parakeet. `mlx-community/whisper-large-v3-turbo`: 1,61 GB, gemessen über die Hugging-Face-API. | Hugging-Face-API, localaimaster.com |
| Sprachmodell für den ☽ | Qwen 3.5, das in `sa3-medium` schon als 2B den Prompt erweitert. In 4 Bit für MLX: 0.8B 0,63 GB, 2B 1,72 GB, 4B 3,03 GB, gemessen am 2026-10-15 über die Hugging-Face-API. Als Vergleich Apples Sprachmodell (Foundation Models, etwa 3 Mrd. Parameter); seine Filter lehnen laut Entwicklern auch Zusammenfassungen ab, auch in der lockereren Stufe. Ob ein kleines Qwen auf Deutsch gut genug zusammenfasst, zeigt der Test in `modelle.md`. | `zaehlen\sa3-medium\README.md`, Hugging-Face-API, developer.apple.com/forums/thread/797955 und /835777 |
| Transkription: Apple SpeechTranscriber | vom System verwaltet, „operates outside of your application's memory space“. Laut Apple „good for long-form and distant audio, such as lectures, meetings, and conversations“. Deutsch laut einer Quelle seit dem Start dabei. Größe unbekannt, das System lädt das Modell selbst. | WWDC25, Sitzung 277; blog.addpipe.com |

**Der ☽ braucht kein Streaming.** Er entsteht alle 240 s. Die Transkription kann also in Stücken laufen, etwa alle 30 s, und muss nicht live mitschreiben.

### Was für den Bau gilt

- **Das Mikrofon hört auch die Genelecs.** Singt eine Antwort von SA3, landet ihr Text in der Transkription. Deshalb gehen seit 2026-10-15 nur die Atemzüge mit hohem Raum-Anteil in die Transkription (`specs\wwww-installation\kommunikation.md`, „Das Raummikrofon“). Singt SA3 und niemand spricht, wird nichts transkribiert. Spricht jemand im selben Atemzug, in dem SA3 singt, beschreibt der ☽ beide.
- **Der Wortlaut der Transkription verlässt nie den Speicher des Modells.** Er wird nicht auf die Platte geschrieben, auch nicht als Log.

### Bewusst nicht drin

| Draußen | Warum |
|---|---|
| Wortlaut der Transkription in der Historie | Er wäre auf jeder Quittungsseite öffentlich. Das ginge nur mit Einwilligung jedes Besuchers. |
| Mikrofon am Handy | schon in `kommunikation.md` ausgeschlossen: Das Raummikrofon hört alles. |

### Was offen ist

- **Welches Modell transkribiert und welches schreibt den ☽.** Der Test steht seit 2026-10-15 in `modelle.md` unter „Was offen ist“.
- **Ob SA3 Small neben Magenta RT2, Transkription und ☽-Modell in die etwa 8 GB passt.** SA3 Small allein braucht 1,5 bis 2,1 GB und ist schnell genug, gemessen am 2026-10-13.
- **Schalter für die Ausstellung: die VM von 8 auf 3 GB.** Bei der Ausstellung liefert die VM nur Caddy und die Seite aus. Mit `tart set mini-vm --memory 3072`, nur bei gestoppter VM, blieben für Max und die Modelle etwa 13 statt 8 GB. Für die Arbeit im Alltag bleiben 8 GB. Ob 3 GB für die VM reichen, ist nicht gemessen.
- **Ob RT2 Base auf dem M6 in Echtzeit läuft.** Google nennt Base in Echtzeit nur für Pro- und Max-Chips (M4 Pro, M2 Max und höher; M2 Pro und M4 Air nicht). Der M6 ist die Grundversion und steht nicht in der Tabelle. Test: in der App Jam auf Base umschalten und hören, ob es aussetzt. Download etwa 2,5 GB, an einem eigenen Tag.
- **Ob SA3 Medium statt Small antwortet.** Stability misst auf einem M4 Pro 30 s Audio in 5,06 s bei 3,9 GB Spitze. Der M6 war bei Small schneller als der M4 Pro. Download 4,6 GB (DiT 2,9 GB, Decoder SAME-L 1,7 GB), an einem eigenen Tag.
- **Die Bilanz des Arbeitsspeichers.** Geschätzt, nicht gemessen, bei etwa 13 GB frei mit dem Schalter für die Ausstellung:

  | | mit Small | mit Base und Medium |
  |---|---|---|
  | macOS und Max | ~3 GB | ~3 GB |
  | RT2 | ~1 GB | ~3 bis 4 GB |
  | SA3, geladen gehalten | ~2 GB | ~4 bis 5 GB |
  | Transkription | ~2 GB | ~2 GB |
  | Sprachmodell für den ☽ | ~2 bis 3 GB | ~2 bis 3 GB |
  | **zusammen** | **~10 bis 11 GB, passt** | **~14 bis 17 GB, passt nicht sicher** |

  Jede Zeile wird durch eine Messung ersetzt, sobald es sie gibt. Fortgeführt seit 2026-10-15 in `modelle.md` unter „Speicher auf dem Mac mini“.

---
---

## Teil 3 · künftig `specs\wwww-main\edition.md`

### Edition — die eigene Erfahrung als Erinnerung

**Die Regel, aus der alles folgt:** Besucher kaufen ihre eigene Erfahrung. Eine Zeichnung trägt Token und Plot zugleich.

**Was hier steht:** was Besucher kaufen, wie es entsteht und wie es zu ihnen kommt.

**Was hier nicht steht:** wie die Erfahrung belegt wird. Das regelt `kette.md`.

**Verwandt:** `kette.md` (Code und Quittungsseite), `specs\wwww-installation\historie.md` (☉ und ☽), `specs\wwww-threejs\steuerung.md` (der Knopf „Erinnerung").

### Festgelegt

| Was | Wie | Seit |
|---|---|---|
| Was gekauft wird | die eigene Erfahrung in der Welt, als Erinnerung | 2026-10-12 |
| Die Ansicht | Besucher wählen sie im Raum selbst. | 2026-10-12 |
| Token | Die Ansicht ist in den Token eingebacken. Den Token bekommen Besucher auch ohne Wallet. | 2026-10-12 |
| Plot | Dieselbe Ansicht wird geplottet und verschickt. | 2026-10-12 |
| Rand des Plots | der Ausschnitt der Historie aus der Zeit des Besuchs: die ☉-Prompts aller Besucher und die ☽ dazwischen, jeder Eintrag unter der Nummer seines Atemzugs | 2026-10-13 |
| Langer Rand | Passt die Historie nicht auf den Rand, läuft sie auf der Rückseite des Blatts weiter. | 2026-10-13 |
| Erinnerung im Raum | Gekaufte Erinnerungen laufen wieder in der Installation, im Beamerbild. Den Atemzug wählen Käufer selbst auf der Quittungsseite. In der Historie steht dann ein dritter Eintrag, etwa „✶ Erinnerung 37 läuft". | 2026-10-13 |
| IPFS vorerst auf dem VPS | Das Paket liegt in einem IPFS-Knoten auf dem eigenen VPS. Käufer erfahren beim Kauf: Der Download steht einen Monat bereit, danach wird er auf der Quittungsseite neu angefordert. | 2026-10-13 |
| Zahlungsdienst | Stripe und PayPal, beide zur Wahl auf der Quittungsseite. Nach der Zahlung meldet der Dienst sie per Webhook an den VPS, der VPS erzeugt dann Token, Plot-Auftrag und IPFS-Paket. | 2026-10-13 |
| Auflage | eine Erinnerung pro Besuch, also pro Code. Insgesamt unbegrenzt. | 2026-10-13 |
| Preis | 72 € pro Erinnerung, mit Plot, Token und IPFS-Paket | 2026-10-13 |
| Wohin der Token geht | Käufer wählen beim Kauf: ein Wallet per E-Mail anlegen, die Adresse eines eigenen Wallets angeben oder später abholen. Beim späteren Abholen liegt der Token bis dahin im Künstler-Wallet, reserviert für den Code. | 2026-10-13 |
| Kette für den Token | Base, eine Ethereum-L2 mit Proof of Stake | 2026-10-13 |
| Vertrag und Wallet | ein eigener ERC-721-Vertrag auf Base, die SVG direkt im Vertrag, ERC-2981 für den Anteil beim Weiterverkauf. Privy legt die Wallets per E-Mail an. Der Vertrag wird vor dem Start geprüft. | 2026-10-13 |
| Quittungsseite | zeigt ebenfalls die ☉-Prompts aller Besucher aus der Zeit des Besuchs, die eigenen markiert | 2026-10-13 |
| IPFS-Paket | Die Erfahrung kommt über IPFS noch einmal, um sie zu wiederholen und den Rest der Welt zu erkunden. | 2026-10-12 |
| Bezahlen | zu Hause auf der Quittungsseite, nicht im Raum | 2026-10-12 |
| Freiwillig | Die Quittungsseite mit Historie und Beleg bekommt jeder. Gekauft wird nur die Erinnerung. | 2026-10-12 |

### Vorgeschlagen, nicht bestätigt

#### Der Ablauf

| Wo | Was passiert | Was entsteht |
|---|---|---|
| im Raum | Besucher fliegen, schicken Prompts, wählen eine Ansicht und drücken „Erinnerung". | Code, Ansicht als SVG, Flugbahn, ein Eintrag in der Kette |
| nach dem Tag, VPS | Die Kette kommt auf den VPS, der Tages-Hash nach Bitcoin. | der Beleg |
| zu Hause | Besucher öffnen die Quittungsseite und drücken „Als Erinnerung kaufen". | der Token mit eingebackener SVG, das IPFS-Paket |
| per Post | Die SVG geht an den Plotter. | der Plot |

#### Eine Zeichnung für Token und Plot

Die Ansicht wird als **Linienzeichnung im Format SVG** gespeichert, etwa mit dem `SVGRenderer` von three.js.

- Ein Plotter zeichnet Linien, kein Foto.
- Eine SVG hat einige Kilobyte und passt direkt in die Kette. Ein Foto wäre dafür zu groß.
- Token und Plot zeigen dadurch genau dasselbe Bild.

#### Der Rand des Plots

```
┌────────────────────────────────────────┐
│                                        │
│        [ die gewählte Ansicht ]        │
│                                        │
├────────────────────────────────────────┤
│ ☉ 15.210  Glocken unter Wasser, sehr   │
│           langsam                      │
│ ☽ 15.264  Der Raum ist leiser          │
│           geworden…                    │
│ ☉ 15.318  mehr Metall                  │
│ ☽ 15.336  …                            │
├────────────────────────────────────────┤
│ 324 Atemzüge · 15.156 bis 15.480       │
│ ATEM-7K3F · 13.10.2026 · Tages-Hash    │
│ 5b1e…                                  │
└────────────────────────────────────────┘
```

Jeder Eintrag steht unter der Nummer seines Atemzugs, nicht unter der Uhrzeit. Die Nummer ist zugleich der Block, in dem sein Hash liegt.

#### Token ohne Wallet

Der Token wird erzeugt und liegt zunächst im Wallet des Künstlers, reserviert für den Code. Wollen Besucher ihn selbst halten, holen sie ihn mit dem Code ab. Dabei entsteht ein Wallet im Browser, per E-Mail oder Fingerabdruck. Holen sie ihn nie ab, verwahrt der Künstler ihn.

Im Token stehen:

| Feld | Inhalt |
|---|---|
| Nummer | fortlaufend |
| Besitzer | zuerst das Künstler-Wallet, nach dem Abholen das des Besuchers |
| Bild | die SVG der Ansicht, direkt in der Kette |
| Paket | `ipfs://…` |
| Beleg | Code, Blockbereich, Tages-Hash |

#### Das IPFS-Paket

| Was | Wofür |
|---|---|
| die Welt: three.js, RNBO, RAVE v1, die Assets | den Rest der Welt erkunden |
| der Startpunkt: Position und Blick der Ansicht | die Erfahrung dort beginnen, wo sie gewählt wurde |
| die Flugbahn | den eigenen Weg noch einmal abfliegen |
| die Antworten der Modelle als Audiodateien | hören, was damals auf die eigenen Prompts kam |
| der Ausschnitt der Historie | lesen, was der Raum wahrgenommen hat |

**Das Paket startet offline.** Alles liegt im Ordner, nichts wird nachgeladen, wie heute schon in `site/vendor/three/`. Gestartet wird es mit dem Code in der Adresse, etwa `index.html?code=ATEM-7K3F`.

**IPFS und nicht direkt in der Kette,** weil das Paket mehrere MB groß ist. In der Kette steht nur die SVG.

#### Was Käufer davon haben

| Vorteil       | Was es heißt                                                   |
| ------------- | -------------------------------------------------------------- |
| Besitz        | Öffentlich steht fest, dass diese Erinnerung ihnen gehört.     |
| Einmaligkeit  | Die Ansicht haben sie selbst gewählt, in ihrem Moment im Raum. |
| Plot          | ein Blatt, das sonst niemand hat                               |
| Weiterverkauf | Ein Bruchteil des Preises kann an den Künstler gehen.          |

#### Recherche vom 2026-10-13: Kette, Vertrag, Wallet, Zahlung

Nicht gemessen, aus Sekundärquellen und den Docs der Anbieter. Vor dem Bau wird jede Zahl auf der Seite des Anbieters geprüft.

| Frage | Ergebnis | Quelle |
|---|---|---|
| Kette: Base | Ethereum-L2, über Ethereum Proof of Stake. Ein Mint kostet weniger als einen Cent bis wenige Cent. Eine SVG von 20 kB direkt im Vertrag: 200 Gas pro Byte, also etwa 4 Mio. Gas, je nach Gaspreis grob 0,10 bis 1 $. Die Zahl für die SVG ist selbst gerechnet. | skills.sh/austintgriffith/ethskills/gas, web3.university |
| Kette: Tezos | Proof of Stake, starke Kunstszene um objkt. Speicher kostet 0,00025 Tez pro Byte, eine SVG von 20 kB also etwa 5 Tez. Kurs nicht geprüft. Weniger Wallet-Dienste. | ligo.tezos.com, madfish.crunch.help |
| Vertrag und Mint: Crossmint | Mint per API ohne eigenen Vertrag. Base: 0,08 $ pro Mint plus Gas. Mint an eine E-Mail-Adresse legt ein verwahrtes Wallet an, abgeholt wird durch Anmelden bei Crossmint. Offen: ob die SVG direkt in der Kette liegen kann, ob ein eigener Vertrag geht, ob sich das Wallet nach MetaMask übertragen lässt. | docs.crossmint.com, Seiten pricing und specify-recipient |
| Wallet: Privy | gehört seit Juni 2025 zu Stripe. Wallet per E-Mail oder Social Login, ohne Seed-Phrase. | siliconangle.com, 2025-06-11 |
| Eigener Vertrag | ERC-721 mit der SVG im Vertrag und ERC-2981 für den Anteil beim Weiterverkauf. Volle Kontrolle, aber eigener Code, der geprüft werden muss. | — |
| Bitcoin statt Base | geht über Ordinals: Die SVG wird direkt in Bitcoin eingeschrieben. Eine SVG von 20 kB sind etwa 5.000 vB, bei 2 bis 10 sat/vB also 10.000 bis 50.000 sat. Kein Standard für den Anteil beim Weiterverkauf, weniger Wallets per E-Mail. Nicht gewählt, Bitcoin trägt bereits den Tages-Hash. | spark.money, bitcoinmagazine.com, eigene Rechnung |
| Stripe | 1,5 % + 0,25 € bei EWR-Standardkarten, 2,8 % + 0,25 € bei Premiumkarten, SEPA 0,35 € | ki-syndikat.de, meetergo.com |
| PayPal | 2,99 % + 0,39 € im Inland, Stand 15.07.2026. Ältere Quellen nennen 2,49 % + 0,35 €. | PayPal-Gebührenübersicht, de-de-merchant-fees-15-jul-2026.pdf |

Bei 72 € kostet die Zahlung über Stripe etwa 1,33 €, über PayPal etwa 2,54 €.

### Was für den Bau gilt

- **Die Postadresse kommt nie in die Kette.** Sie liegt auf dem VPS und wird nach dem Versand gelöscht.
- **Die Adresse des IPFS-Pakets bleibt gleich.** Wird ein abgelaufenes Paket neu angefordert, hält der VPS denselben Inhalt wieder bereit, unter derselben Adresse. Der Link im Token bleibt gültig. Die Welt selbst ist für alle gleich und bleibt dauerhaft auf dem VPS, ablaufen müssen nur Startpunkt, Flugbahn und Aufnahmen eines Käufers.
- **Das Paket lädt nichts von außen nach.** Sonst startet es offline nicht.

### Bewusst nicht drin

| Draußen | Warum |
|---|---|
| neue Antworten der Modelle im IPFS-Paket | Teppich, SA3 und RT2 rechnen auf dem Installationsrechner, nicht im Browser. Zu Hause gibt es nur die Aufnahmen. |
| Kauf im Raum | Die Installation hat kein Internet, und eine Kasse bräuchte Gerät und Personal. |
| eine Variante, die aus dem Hash des Kaufs entsteht | ersetzt durch die Ansicht, die Besucher selbst wählen |

### Was offen ist

- **Wie aus der Ansicht eine Linienzeichnung wird.** `szene.splat` ist ein Gaussian Splat und hat keine Linien. Der `SVGRenderer` zeichnet nur Geometrie.
- **Welcher Plotter.** `wwww-installation\raw\plotter laser\` ist nicht gelesen.
- **Impressum, Widerrufsrecht für digitale Inhalte, Steuer.**

---
---

## Teil 4 · Ergänzungen in bestehenden Specs

### `specs\wwww-installation\kommunikation.md`, Tabelle „OSC-Adressen"

Vier neue Zeilen unter den bestehenden:

| Adresse | Inhalt |
|---|---|
| `/handy/<id>/prompt` | Modell, Text |
| `/handy/<id>/quittung` | Anfrage. Der Rechner antwortet auf derselben Adresse mit Code und Blockbereich. |
| `/handy/<id>/erinnerung` | Position x y z, Blick x y z |
| `/historie/eintrag` | ☉ oder ☽, Zeit, Text, an alle Handys |

### `specs\wwww-threejs\steuerung.md`

Ein neuer Abschnitt nach „Wo bin ich?":

> ## Prompt und Erinnerung
>
> **Das Textfeld** liegt als Overlay über der Welt. Es ist ein echtes `<input type="text">` mit einer Auswahl der Modelle daneben, wie die Regler im Overlay echte `<input type="range">` sind. Senden schickt den Prompt an den Installationsrechner, siehe `specs\wwww-installation\historie.md`.
>
> **Der Knopf „Erinnerung"** hält Position und Blick fest. Er zeigt die Ansicht als Vorschau. Bestätigen schickt sie an den Installationsrechner und zeigt den Code der Quittung, siehe `specs\wwww-main\edition.md`.

Zwei neue Zeilen in der Tabelle „Tastatur, Maus und Screenreader":

| Handy | Tastatur | Maus |
|---|---|---|
| Textfeld: Prompt | `T` setzt den Fokus ins Textfeld, `Enter` sendet, `Esc` verlässt es | Klick ins Feld |
| Knopf „Erinnerung" | `M` hält die Ansicht fest, ein zweites `M` bestätigt | – |

**Wo sie liegen**, festgelegt am 2026-10-13: in einer schmalen Leiste am unteren Rand. Links das Textfeld mit der Modellwahl, rechts der Knopf „Erinnerung". Beim Tippen schiebt die Tastatur die Leiste hoch. Die drei Ecken bleiben, wie sie sind.

**Gewünscht, noch nicht ausgearbeitet:** Alle Overlays, also Regler, Leiste und Historie, liegen gegebenenfalls in Tabs und lassen sich ganz ausblenden.

### `specs\wwww-installation\modelle.md`, Abschnitt „Was offen ist"

**Eingetragen am 2026-10-15, anders als hier:** SA3 Small läuft live, Transkription und ☽ stehen als Test in `modelle.md`. Beim Aufteilen entfällt dieser Abschnitt.

Drei neue Punkte:

> - **Welches Modell lokal transkribiert.** Für den ☽ in `historie.md`. Rechner nicht festgelegt.
> - **Welches Sprachmodell lokal den ☽ schreibt.** Es fasst alle 240 s Historie, Transkription und Messungen zusammen. Rechner nicht festgelegt.
> - **Ob Stable Audio 3 live auf dem Installationsrechner läuft.** Hier steht es in der Vorproduktion, `teppich.md` und `historie.md` brauchen es live.

### `specs\wwww-main\zahlen.md`, Abschnitt „Wo es anschließen kann"

Der Satz „Offen. Keine Zeile ist entschieden." wird zu „Eine Zeile ist entschieden, die übrigen sind offen." Eine neue Zeile in der Tabelle:

| Teil | mögliche Verwendung |
|---|---|
| `wwww-main` | **entschieden:** der Atemzug als Blocktakt der Atem-Kette, 25.920 Blöcke am Tag; ein ☽ alle 72 Atemzüge, 360 am Tag. Siehe `kette.md` und `historie.md`. |








