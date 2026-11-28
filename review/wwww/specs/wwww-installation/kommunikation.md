---
tags: [spec, wwww-installation, wwww-rnbo, kommunikation]
created: 2026-09-27
topic: 'Wer mit wem spricht -- Handys, Installationsrechner, Mikrofon, Kamera, Beamer und Genelecs, und die drei Schleifen dazwischen'
verification: 'Abschnitt "Festgelegt" im Gespraech am 2026-09-27 vom Nutzer beschrieben, "Das Raummikrofon" und "Was wo laeuft" am 2026-10-15 vom Nutzer bestaetigt, der Hinweis auf den Blaettern und die Umstehenden am 2026-11-24; Abschnitt "Vorgeschlagen" nicht bestaetigt; nichts davon gebaut'
nutzt:
  - "[[Apple Mac mini]]"
  - "[[Kurokesu C3]]"
  - "[[GL.iNet Slate AX GL-AXT1800]]"
  - "[[Audient iD14 MKII]]"
  - "[[Max]]"
  - "[[RNBO]]"
  - "[[Jitter]]"
  - "[[Timbre-Transfer]]"
  - "[[Hall]]"
  - "[[Schallaufnahme]]"
  - "[[Projektion]]"
---

# Kommunikation — wer mit wem spricht

Festgelegt im Gespräch am 2026-09-27, ergänzt am 2026-10-15. **Nichts davon ist gebaut.**

> [!abstract] Der Installationsrechner ist die Mitte
> Jede Schleife läuft durch ihn. Die Bild-Schleife geht über Beamer, Raum und Kamera, die Klang-Schleife über Genelec, Raum und Mikrofon, die Handy-Schleife über OSC zu den Handys und zurück. Der Raum mit den Menschen ist ein eigener Knoten, weil Licht und Schall beide durch ihn gehen.
>
> ```mermaid
> flowchart TD
>   subgraph Handys
>     H[Besucher-Handys]
>     F[festes Handy]
>   end
>   R[Installationsrechner<br/>Max]
>   RAUM((Raum<br/>mit Menschen))
>   H <-->|OSC| R
>   F <-->|OSC| R
>   R -->|Bild| B[Beamer]
>   B -->|Licht| RAUM
>   RAUM -->|Licht| K[Kurokesu C3]
>   K -->|Video| R
>   R -->|Klang| G[drei Genelec]
>   G -->|Schall| RAUM
>   RAUM -->|Schall| M[Raummikrofon]
>   M -->|Audio| R
> ```

^blick

**Verwandt:** `specs\wwww-threejs\steuerung.md` (welche Gesten es gibt), `zaehlen\wwww\ARCHITEKTUR.md` (Rechner, Pfade, Ports), `specs\wwww-installation\modelle.md` (welche Modelle wwww auf welchem Rechner nimmt), `zaehlen\MODELLE.md` (welches Modell auf welchem Rechner laufen kann), `specs\wwww-installation\schnitte.md` (wie Handy, Kamera und Raummikrofon in Klang und Bild schneiden; ein Versuch).

---

## Festgelegt

### Die Teile

| Teil | Rolle |
|---|---|
| **Handys der Besucher** | spielen RNBO und RAVE im Browser, senden Gesten und Klangmerkmale |
| **Das feste Handy** | ein Handy, fest im Raum installiert. Sendet wie die anderen und ist immer da. |
| **Installationsrechner** | Max. Empfängt alles, gibt Bild und Klang aus, schickt Daten zurück an die Handys. |
| **Raummikrofon** | am Installationsrechner, hört den ganzen Raum |
| **Kurokesu C3** | Kamera am Installationsrechner, filmt das Beamerbild |
| **Beamer** | zeigt das Bild des Installationsrechners |
| **Drei Genelec** | geben den Klang des Installationsrechners aus |

**Alle Handys senden**, die der Besucher und das feste. Bestätigt am 2026-09-27.

**Kein Mikrofon am Handy.** RAVE spielt dort ohne Mikrofon: über die Regler z1 bis z4 oder mit einer Quelle aus RNBO.

### Die Flüsse

| Von | Nach | Was | Wie |
|---|---|---|---|
| Handys | Installationsrechner | Gesten, Position, Blick, z1–z4, Mischung der Felder; dazu die Klangmerkmale aus `AnalyserNode` und Meyda | OSC |
| Installationsrechner | Handys | Rückweg, etwa Klangmerkmale des Raums | OSC |
| Raummikrofon | Installationsrechner | Audio | Audio-Interface |
| Kurokesu C3 | Installationsrechner | Video | USB |
| Installationsrechner | Beamer | Bild | Videoausgang |
| Installationsrechner | drei Genelec | Klang | Audio-Interface |

### Die drei Schleifen

Das Bild dazu steht oben im Blick.

Der Raum ist ein eigener Knoten, weil Licht und Schall beide durch ihn gehen. Die Menschen darin greifen in beide Schleifen ein.

| Schleife | Weg | Wer greift ein |
|---|---|---|
| **Bild** | Rechner → Beamer → Raum → Kamera → Rechner | Menschen, die zwischen Beamer und Kamera durchlaufen |
| **Klang** | Rechner → Genelec → Raum → Mikrofon → Rechner | alles, was im Raum klingt, auch die Besucher |
| **Handy** | Handy → Rechner → Handy | die Gesten |

**Ein Beispiel für die Handy-Schleife**, verbunden mit der Klang-Schleife: Die Zahl der Handys an jedem der 12 Punkte gewichtet die Stil-Vorgaben von Magenta RT2. RT2 klingt über die Genelecs. FluCoMa misst die Ausgabe (`fluid.loudness~`, `fluid.spectralshape~`), und die Werte gehen per OSC an alle Handys. Dort verschieben sie z4 oder das Licht in three.js.

### Das Raummikrofon

Festgelegt am 2026-10-15.

**Die Grundregel:** Das Mikrofon geht nie laufend auf die Genelecs. Sein Klang kommt nur in **Fängen** ins Netz: Das Tor des FDN öffnet sich für einen Atemzug (3,33 s) und schließt sich wieder.

**Der Raum-Anteil** ist der Teil des Mikrofonsignals, den die Genelecs nicht erklären. Max weiß, was auf die Genelecs geht. FluCoMa misst die Lautheit dieses Ausgangs und die des Mikrofons. Einmal im leeren Raum eingemessen, sagt der Ausgang voraus, wie laut das Mikrofon ohne Menschen wäre. Ein Beispiel: Erwartet sind −30 dB, gemessen werden −22 dB. Die 8 dB darüber kommen von Menschen.

| Abzweig | Was passiert | Wohin | Wann |
|---|---|---|---|
| Messen | Lautheit, spektrale Form, Raum-Anteil | FDN (Nachhallzeit, `d`), Gewichte von RT2, Jitter, `/raum/merkmale` an die Handys, Zahlen für den ☽ | laufend |
| Hören | Transkription | ☽ | Stücke von etwa 30 s, nur aus den Atemzügen mit hohem Raum-Anteil |
| Fangen | ein Atemzug Mikrofonklang durchs Tor | Teppich, in der Stimmen-Leitung des Raums | wenn der Raum-Anteil über eine Schwelle steigt |
| Verwandeln | derselbe Fang durch RAVE v2 oder AFTER, dann durchs Tor | Teppich: RAVE in der Leitung des Raums, AFTER in seiner eigenen | wie beim Fangen |

Die Transkription entscheidet pro Atemzug, nicht pro Stück. Singt SA3 und niemand spricht, wird nichts transkribiert. Was das für den ☽ heißt, steht in `specs\wwww-main\kette-entwurf.md`, Teil 2.

**Was den Klang öffnet,** festgelegt am 2026-11-02: Interaktion, also eine Geste am Handy oder jemand auf dem Teppich. Das Mikrofon zählt nur, solange jemand dort steht. Die Raumlautstärke regelt nur den Pegel und startet nichts, sonst lösen die Nachbarn der Gruppenausstellung aus (`raum.md`, „Aktivierung“).

**Das Mikrofon** ist eine Kugel oder ein Grenzflächenmikrofon, an der Stelle aus `aufbau.json` in der Mitte. Eine Richtwirkung hilft dort nicht: Die drei Genelecs kommen aus drei Richtungen, etwa 120° auseinander. Die Trennung leistet der Raum-Anteil.

**Der Hinweis,** festgelegt am 2026-11-24: Auf jedem Blatt „barfuß“ (`O9`) steht unter dem Wort der Satz „Ein Mikrofon hört diesen Raum. Nichts wird gespeichert. Was hier gesprochen wird, kehrt verwandelt als Klang und als Sätze zurück.“ Ein Schild am Eingang gibt es nicht, das Mikrofon bleibt unauffällig. Der Ort folgt aus der Regel oben: Das Mikrofon zählt nur, solange jemand auf dem Teppich steht, und wer dorthin geht, zieht an einem Blatt die Schuhe aus. Nichts wird dauerhaft gespeichert, und der ☽ übernimmt nichts wörtlich. Wer neben dem Teppich steht, wird mitgehört, solange dort jemand interagiert, und liest das Blatt nicht. Das bleibt so: keine eigene Schwelle, kein Hinweis an den Blättern „einlesen“ (`O14`). Was rechtlich offen bleibt, steht in `specs\wwww-main\einordnung.md`, „Was offen ist“.

### Was wo läuft

Festgelegt am 2026-10-15, RAM, GPU und CPU ergänzt am 2026-10-16. Bei jedem Wert steht, ob er gemessen, geschätzt oder ungemessen ist. Welche Modelle auf dem PC liegen, steht im Bestand in `zaehlen\modelle\README.md`.

**Handy**, im Browser des Besuchers, ohne Mikrofon:

| Was | Wozu | RAM | GPU | CPU |
|---|---|---|---|---|
| RNBO | der Klang des Handys | wenige MB, geschätzt | – | AudioWorklet, ungemessen |
| RNBO-Patches mit `fft~` und `ifft~` | spektrale Patches; die Wunschliste steht in `specs\wwww-rnbo\raw\20260808 infos allgemein.md` unter „fft“ | wenige MB, geschätzt | – | steigt mit FFT-Größe und Überlappung, ungemessen |
| RAVE v1 als ONNX | Klangfarbe, gesteuert über z1–z4 oder eine Quelle aus RNBO | Modell im Prototyp 4,4 MB, ein Dummy | – | läuft als WASM auf der CPU; 10 % auf dem Desktop gemessen, auf dem Handy ungemessen |
| Loris | spielt Teiltöne ab, die vorab am PC analysiert wurden | gering | – | steigt mit der Zahl der Teiltöne, ungemessen |
| three.js | die Welt, die 12 Punkte, die Gesten | gering | laufend | gering |
| Analyse über `AnalyserNode`, Meyda | analysieren den eigenen Klang | gering | – | gering |
| FluCoMa-Regression als JSON | Position → RNBO-Parameter, geplant | einige KB | – | gering |
| Textfeld, Historie-Leiste | ☉ schreiben, ☉ und ☽ lesen | gering | – | gering |
| OSC über `wss://` | schickt Gesten, Position, Blick, z1–z4, Merkmale und Prompts; empfängt `/raum/merkmale` und den ☽ | gering | – | gering |

^handy-klang

**Mac mini.** Der Speicher der GPU ist derselbe RAM. Die Spalte GPU sagt deshalb, wann die GPU rechnet.

| Was | Wo | Wozu | RAM | GPU | CPU |
|---|---|---|---|---|---|
| macOS, Max | – | – | ~3 GB, geschätzt | – | – |
| FDN in `gen~` mit Tor | Max | der Teppich, die Fänge | wenige MB, die Delay-Puffer | – | Audio-Thread, ungemessen |
| FluCoMa | Max | Messen, Raum-Anteil, Strukturwahl für AFTER | gering | – | gering |
| `node.script` | Max | WebSocket, packt OSC aus | gering | – | gering |
| Jitter | Max | Beamer, Kamera, Bild-Schleife, Historie am Rand | in Max enthalten | laufend | gering |
| Magenta RT2 Small (`mrt2~`) | Max | spielt die ☉ als Stil-Vorgaben, gewichtet nach der Zahl der Handys pro Punkt | ~1 GB, gemessen | laufend über MLX; laut README hält `mrt2~` die GPU absichtlich wach, damit sie nicht heruntertaktet | Max 25–28 %, gemessen |
| RAVE v2, AFTER (`nn~`) | Max | verwandeln die Fänge | je 0,1–0,5 GB, geschätzt | – | RAVE nur bei Fängen, AFTER pro Phrase, ungemessen |
| SA3 Small Music (MLX) | neben Max | antwortet auf jeden ☉ | 1,5–2,1 GB, gemessen | ein Stoß pro ☉: 30 s Audio in 1,06 s, gemessen | gering |
| Transkription | neben Max | Raummikrofon → Text für den ☽ | Whisper 1,61 GB; Apple unbekannt | Whisper: ein Stoß alle 30 s; Apple unbekannt | gering |
| Sprachmodell für den ☽ | neben Max | alle 240 s zwei bis vier Sätze | Qwen 3.5 in 4 Bit: 0,63, 1,72 oder 3,03 GB | ein Stoß alle 240 s, geschätzt einige Sekunden | gering |
| three.js im Browser | neben Max | der Zwilling auf dem Bildschirm V4: die Welt von M1, einzelne Objekte mit anderen Parametern (`specs\wwww-threejs\steuerung.md`, „Der Zwilling auf V4“), seit 2026-10-30 | ~0,3–0,5 GB, geschätzt | laufend | gering |
| Caddy | Linux-VM | liefert die Seite aus, leitet `/ws` an Max | 3 GB für die VM, mit dem Schalter für die Ausstellung | – | gering |
| **zusammen** | | | **~13,5–14,5 GB von 16**, geschätzt | | |

**Die GPU teilen sich mehrere.** RT2 und Jitter rechnen laufend, SA3, Transkription und ☽ kommen in Stößen dazu. RT2 puffert 170 ms (`buffersize 8192`). Ob das reicht, zeigt erst ein Lauf mit allem zusammen, siehe `handoffs\2026-10-16-wwww-prototyp-mac-last.md`.

**Nicht live, Vorproduktion am PC:** SA3 Medium (Fächer, Kette), ACE-Step (Cover, Repaint), das Training von RAVE und AFTER, der FluCoMa-Korpus.

---

## Vorgeschlagen, nicht bestätigt

### OSC aus dem Browser

Ein Browser kann kein UDP senden. OSC reist deshalb als Bytes in einer WebSocket-Verbindung, gepackt mit `osc.js`.

| Strecke | Wie | Warum so |
|---|---|---|
| Handy → Caddy | `wss://installation.julianniklasheynert.xyz/ws` | Die Seite läuft über HTTPS, sonst gibt es keine Sensoren. Eine HTTPS-Seite darf nur `wss://` öffnen, kein `ws://`. |
| Caddy → Max | `ws://` im Rechner selbst | Caddy hat das Zertifikat schon und leitet `/ws` weiter. Max braucht keins. |
| in Max | `node.script` mit einem WebSocket-Server, packt OSC aus | Kein zweiter Dienst neben Max. Die Nachrichten kommen als Max-Listen an. |

Der Rückweg nimmt dieselbe Verbindung in der Gegenrichtung.

**`node.script`, keine eigene Brücke.** Bestätigt am 2026-09-27.

### OSC-Adressen

| Adresse | Inhalt |
|---|---|
| `/handy/<id>/pos` | x y z |
| `/handy/<id>/blick` | x y z |
| `/handy/<id>/geste/<name>` | je nach Geste |
| `/handy/<id>/z` | z1 z2 z3 z4 |
| `/handy/<id>/merkmale` | Centroid, Flatness, Lautheit, 13 MFCC |
| `/raum/merkmale` | dasselbe, gemessen am Raummikrofon, an alle Handys |

Das feste Handy hat die `<id>` `fest`. Ein Besucher-Handy bekommt beim Eintreten eine zufällige.

### Takt

Etwa 30 Nachrichten pro Sekunde und Handy, jeweils einige hundert Byte. Bei 20 Handys sind das etwa 1,4 Mbit/s im WLAN des Routers.

### Wo gerechnet wird

**Was auf dem Handy klingt, rechnet das Handy. Was im Raum klingt, rechnet der Installationsrechner.**

Gelerntes wie eine FluCoMa-Regression ist nicht live. Es entsteht einmal in der Vorproduktion und liegt danach als JSON vor. Live sind nur die Eingabe, etwa die Position, und das Ergebnis, etwa die RNBO-Parameter. Die Regel entscheidet, wo beide zusammenkommen.

| | Auf dem Handy | Auf dem Installationsrechner |
|---|---|---|
| Wo das Gelernte liegt | als JSON in der Seite, in JS nachgerechnet | in FluCoMa in Max |
| Was live durchs WLAN geht | nichts | Eingabe hin, Ergebnis zurück |
| Wenn das WLAN stockt | der Klang läuft weiter | der Klang bleibt stehen |
| Gelerntes ändern | neue JSON nach `site/`, neues Image, neues Bündel | in Max neu lernen, wirkt sofort |
| Raumdaten als Eingabe | nicht möglich | Mikrofon und Kamera möglich |

| Was | Wo |
|---|---|
| Regression Position → Parameter für den Handy-Klang | Handy |
| Nachbarsuche im Korpus, wenn der Korpus auf dem Handy klingt | Handy |
| Wahl der Struktur für AFTER, Gewichte der Stil-Vorgaben für Magenta RT2 | Installationsrechner |
| alles mit Mikrofon oder Kamera als Eingabe | Installationsrechner |

Die Beispiele zu Regression, Nachbarsuche, Korpus und NMF stehen in `learning\max-msp\flucoma-lernen-und-anwenden.md`.

### Verbindungen zwischen den Schleifen

Der Installationsrechner hat drei Eingänge und drei Ausgänge. Jede Schleife verbindet einen Eingang mit seinem Ausgang. Verbunden sind zwei Schleifen, wenn der Eingang der einen den Ausgang der anderen steuert.

| Eingang ↓ / Ausgang → | an die Handys | Genelec | Beamer |
|---|---|---|---|
| **von den Handys** | *Handy-Schleife.* **Festgelegt:** Zahl der Handys pro Punkt gewichtet RT2, dessen Messung geht zurück (Beispiel oben) | Gewichte der RT2-Vorgaben, Strukturwahl für AFTER | Positionen der Handys als Punkte im Beamerbild |
| **Mikrofon** | Lautheit des Raums → z4 auf allen Handys | *Klang-Schleife.* **Festgelegt:** Fänge durchs Tor in den Teppich, roh oder durch RAVE v2 und AFTER (siehe „Das Raummikrofon“). Dazu als Beispiel: Raum-Lautheit steuert RT2 | Lautheit → Stärke des Bild-Feedbacks |
| **Kamera** | Bewegung im Bild → Streuung auf allen Handys, wie beim Schütteln | Menschen im Bild → `guidance_structure` von AFTER | *Bild-Schleife:* Feedback |

Die Diagonale sind die drei Schleifen selbst. Außer den beiden festgelegten Einträgen sind alle Einträge Beispiele.

---

## Was für den Bau gilt

- **Das Mikrofon hört die Genelecs.** Geht sein Signal laufend auf die Genelecs, pfeift es oder schaukelt sich auf. Es geht nur in Fängen durchs Tor ins Netz, nie laufend auf die Genelecs.
- **Nach einem Fang fängt das Tor erst wieder, wenn das letzte Echo des Fangs verklungen ist.** Bei einer Stimmen-Leitung von 4 s und Echo 3 sind das gut 12 s. Sonst fängt das Mikrofon sein eigenes Echo.
- **Ein Fang wird nie als Datei gespeichert**, wie der Wortlaut der Transkription.
- **Die Kamera sieht den Beamer.** Die Bild-Schleife ist gewollt. Ohne Dämpfung im Rechner läuft sie in Weiß oder Schwarz.

## Bewusst nicht drin

| Draußen | Warum |
|---|---|
| Mikrofon am Handy | Das Raummikrofon am Installationsrechner hört alles. |
| Audio vom Handy zum Rechner | 768 kbit/s pro Handy gegen einige kbit/s für Merkmale. Die Merkmale reichen für FluCoMa. |
| ein Richtmikrofon, Niere oder Richtrohr | In der Mitte zwischen drei Genelecs blendet es höchstens einen aus. Ein Richtrohr hört zudem nur einen schmalen Kegel und auch nach hinten. Am 2026-10-15 entschieden. |

## Was offen ist

- **Was im Rechner die drei Schleifen koppelt.** Welche Einträge der Tabelle „Verbindungen zwischen den Schleifen“ gebaut werden.
- **Der Port für `/ws`** und sein Eintrag in `zaehlen\wwww\ARCHITEKTUR.md` unter „Wer welchen Port hält“.
- **Wo Caddy auf dem Mac mini läuft.** Mit `node.script` geht eine WebSocket-Verbindung von Caddy zu Max auf dem macOS-Host. `specs\mac-mini\konzept.md` erlaubt der Linux-VM aber nur OSC an den Host. Läuft Caddy in der VM, braucht es dort eine Ausnahme. Sonst läuft Caddy nativ auf dem Host, wie in `zaehlen\wwww\OFFEN.md` für die Standort-Erkennung erwogen.
- **Ob der Klang der Handy-Seite in Max ankommt.** Gemeint ist, was RNBO und RAVE auf dem Handy erzeugen, kein Mikrofon. Das Max-Objekt `jweb~` gibt den Klang einer Webseite als Signal aus, zwei Kanäle pro Objekt. Zwei Wege: Der Installationsrechner lädt die Seite selbst in `jweb~` und spielt sie mit den OSC-Daten des Handys nach, ohne Audio im WLAN. Oder das Handy schickt seinen Klang, dann gilt die Zeile „Audio vom Handy zum Rechner“ unter „Bewusst nicht drin“. Nicht geplant, eingetragen am 2026-10-15.
- **Die Werte für den Raum-Anteil:** Schwelle und Einmessung, erst vor Ort messbar. Ob Stimmen über den Teppich hinausragen, hängt vor allem davon ab, wie laut die Genelecs spielen.
- **Kugel oder Grenzfläche**, und welches Gerät.
- **Ob das Tor auch fängt, wenn der Raum-Anteil plötzlich fällt**, also wenn alle verstummen. Dann verschluckt der Teppich auch den leeren Raum. Vorgeschlagen am 2026-10-15, nicht bestätigt.
