---
tags: [learning, max-msp, gen, fdn]
created: 2026-09-29
topic: 'FDN Teil 5 -- vier Regeln, die jede Verschaltung verlustfrei halten, 19 Topologien, die Stellschrauben eines Netzes und die Varianten mit Einstellung und Klang'
verification: 'aus specs\wwww-installation\fdn.md (Stand 2026-09-28) umgeschrieben. Schroeder, Stautner und Puckette, Jot, Gardner, Dattorro, Schlecht und Habets, Das und Abel aus dem Gedaechtnis genannt, nicht nachgelesen; die Varianten sind nicht gehoert, die Klangbeschreibungen erwartet'
---

# FDN 5 — Netze bauen

Teil 5 von 7 über Feedback Delay Networks. Ein Katalog zum Nachschlagen.

**Setzt Teil 1 bis 4 voraus**, alle Begriffe daraus.

**Antwort zuerst:** Vier Regeln halten jede Verschaltung verlustfrei. Aus ihnen folgen 19 Arten von Netzen, die **Topologien**. Danach kommen die Stellschrauben eines Netzes und die Varianten: welche Einstellung welchen Klang gibt.

**Was hier nicht steht:** Rauschen als Ziel, das kommt in Teil 6. Der Bau kommt in Teil 7.

**Eine Quelle vorab:** `data\noise-invertierbarkeit.md` beschreibt Verfahren, die Klang in Rauschen verwandeln und dabei umkehrbar bleiben. Verweise wie „Teil VII.2“ zeigen auf ihre Abschnitte.

## 1 · Vier Regeln

1. **Serie.** Zwei verlustfreie Blöcke hintereinander sind verlustfrei.
2. **Parallel.** Kanäle in Gruppen teilen und getrennt verarbeiten ist verlustfrei. Mischt eine orthogonale Matrix sie danach wieder, bleibt es verlustfrei.
3. **Verschachtelung.** Ersetzt man eine Leitung in einem verlustfreien Netz durch einen verlustfreien Block, etwa einen Allpass oder ein kleines Netz, bleibt das Netz verlustfrei. Die Schleife braucht weiter mindestens ein Sample Delay.
4. **Rückkopplung.** Ein verlustfreier Block mit orthogonaler Rückführung und mindestens einem Sample Delay ist eine verlustfreie Schleife.

Für den Rückwärtslauf gilt dasselbe mit „bijektiv“ statt „verlustfrei“.

## 2 · Die Topologien

| # | Topologie | Aufbau | Klang | Vorbild |
|---|---|---|---|---|
| 1 | **Kammfilter** | eine Leitung | Echo; bei kurzem Delay ein Ton | — |
| 2 | **parallele Kammfilter mit Allpässen** | `N` Leitungen ohne Mischung (`d` = 0), Allpässe dahinter | frühe Hallgeräte, metallisch | Schroeder 1962 |
| 3 | **FDN** | `N` Leitungen mit Matrix | dichte Fahne | Stautner und Puckette 1982, Jot 1991 |
| 4 | **Diffusor → FDN** | Diffusionsschritte vor der Schleife | glatt, farbneutral | Signalsmith |
| 5 | **FDN → Diffusor** | Allpässe hinter der Schleife | glättet oder färbt die Fahne | `gen~.gigaverb` |
| 6 | **Allpässe in der Schleife** | ein Allpass pro Leitung im Kreis | die Dichte wächst im Kreis; Dispersion | Dattorro |
| 7 | **Ring und Acht** | Vertauschen als Matrix; oder zwei Hälften über Kreuz gekoppelt, mit Allpässen darin | lange Wege, Echos wandern | Dattorro 1997 nennt seine Schleife „figure-of-8“ |
| 8 | **Streu-FDN** | Diffusionsschritte in der Schleife | die Echodichte wächst sehr schnell | Schlecht und Habets |
| 9 | **verschachtelte Netze** | eine Leitung ist selbst ein Allpass oder ein kleines FDN | Hall im Hall, unregelmäßige Phase | Gardner |
| 10 | **FDNs in Serie** | ein kurzes Netz speist ein langes | zweistufige Fahne | — |
| 11 | **FDNs parallel** | verschiedene Nachhallzeiten, am Ausgang gemischt | doppelte Abklingkurve | — |
| 12 | **gekoppelte FDNs** | Gruppen von Leitungen, über Drehungen gekoppelt (Teil 3 §7) | gekoppelte Räume, doppelte Abklingkurve; die Kopplung ist ein Winkel | Das und Abel, „Grouped FDN“ |
| 13 | **Mehrband-FDN** | Frequenzweiche aus frequenzabhängigen Drehungen (Teil 3 §11), pro Band eigene Längen und Nachhallzeit | Tiefen und Höhen getrennt stimmbar | — |
| 14 | **bewegtes FDN** | Winkel oder Delaylängen bewegen sich | lebendige Fahne; bewegte Winkel bleiben verlustfrei, bewegte Längen nicht | Dattorro (Längen) |
| 15 | **Freeze** | jede Topologie oben mit `g` = 1 und geschlossenem Eingang (Teil 4 §4) | stehende Fläche | — |
| 16 | **Rückwärts** | jede Topologie oben, nur aus bijektiven Bausteinen (Teil 4 §16) | Kollaps | — |
| 17 | **Netz mit Senke** | Leitungen geben über Drehungen an Senken-Leitungen ab (Teil 4 §7) | die Schleife klingt ab, das Ganze bleibt verlustfrei | `noise-invertierbarkeit.md` Teil VII.2 |
| 18 | **komplexes FDN** | 8 komplexe Leitungen in 16 reellen (Teil 3 §12) | Frequenzverschiebung ohne Verlust | `noise-invertierbarkeit.md` Teil IV.5 |
| 19 | **Integer-Netz** | alles in ganzen Zahlen, Drehungen als Lifting (Teil 4 §17) | bitgenau umkehrbar, auch mit XOR und Überlauf; digital hart | `noise-invertierbarkeit.md` Teile II.4, VI, VII.1 |

## 3 · Die Stellschrauben

| Stellschraube | Werte | neutral |
|---|---|---|
| **`N`** | 4, 8, 16 beim Butterfly | — |
| **Diffusor** | 0–4 Schritte · Bereiche gleich, verdoppelnd oder gemischt · Winkel seiner Matrix | 0 Schritte |
| **frühe Reflexionen** | einer der vier Wege aus Teil 2 §10 · Pegel | aus |
| **Längen der Schleife** | Primzahlen 700–3000 Samples · 100–200 ms · gestimmt auf einen Akkord · lang, 0,2–2 s | — |
| **Winkelsatz** | Hadamard · Zufall · Ring · Streuung | — |
| **`d`** | 0 bis 1, mit versetzten Bereichen (Teil 3 §5) | 0 ist die Identität |
| **Kopplung** | Winkel der Lagen 3 und 4, getrennt von `d` (Teil 3 §7) | gleich `d` |
| **Allpass** | 0–8 Stufen, 1. Ordnung oder Schroeder | 0 Stufen |
| **Körner-Tausch** | Radius 0 bis ganze Leitungslänge, Körner 20–200 Samples | Radius 0 |
| **Nachhallzeit** | 0,1 s bis unendlich, pro Gruppe einstellbar | unendlich ist der Freeze |
| **Färbung** | Shelf · Frequenzshift · bewegte Längen · Sättigung · Lifting | aus |
| **Rechenart** | reell · komplex · ganzzahlig | reell |
| **Richtung** | vor · zurück | vor |
| **Auskopplung** | welche Leitung wie laut auf welchen Lautsprecher | — |

## 4 · Die Varianten

Jede Variante ist eine Einstellung der Stellschrauben, kein eigener Bau.

| Variante | Einstellung | Was man hört |
|---|---|---|
| **Echo** | `N` = 4, lange Längen, `d` = 0, kein Diffusor, Nachhallzeit 3 s | getrennte Echos, jede Leitung ihr eigenes Muster |
| **Wanderecho** | `N` = 4, Winkelsatz Ring, `d` = 1, die Leitungen reihum auf verschiedene Lautsprecher | das Echo wandert von Lautsprecher zu Lautsprecher |
| **Plate** | Schroeder-Kette als Diffusor, Schleife mit 2 s | dicht mit metallischer Kante |
| **Signalsmith-Hall** | `N` = 16, Diffusor mit 4 Schritten (20, 40, 80, 160 ms), Schleife 100–200 ms, kleines `d`, Gain 0,85 | glatte, farbneutrale Fahne von etwa 6 s |
| **Hall aus der Schleife** | `N` = 16, Primzahlen 700–3000, `d` = 1, 2–4 Allpässe, 2–6 s | dichter Hall ohne Diffusor |
| **Diffus ohne Fahne** | nur der Diffusor, keine Schleife | ein Schlag wird zu einem kurzen, dichten Rauschen |
| **Resonator** | `N` = 8, Längen gestimmt auf einen Akkord, `d` 0,1–0,3, 5–20 s | der Klang wird zu einem gehaltenen Akkord |
| **Wolke** | `N` = 16, `d` = 1, 8 Allpässe, Vorzeichen in jedem Sample, 10 s | nach etwa 20 Umläufen Rauschen mit der Hüllkurve des Originals |
| **gekoppelte Räume** | Lagen 1–2 voll, Lagen 3–4 klein, die Gruppen mit verschiedenen Nachhallzeiten | doppelte Abklingkurve: erst schnell, dann lang |
| **bewegte Fahne** | Hall, die Winkel mit einem langsamen LFO | lebendige Fahne ohne Verlust |
| **Körnerwolke** | Hall mit Körner-Tausch, der Radius steigt mit `d` | die Fahne zerfällt in vertauschte Körner |
| **Freeze** | Nachhallzeit unendlich, Eingang zu | eine stehende Fläche, über Minuten unverändert |
| **gefrorene Drehung** | Freeze, dann `d` langsam bewegen | die Fläche verwandelt sich zwischen Echomuster und Rauschen |
| **Fläche wird Ton** | Freeze, dann `(1 − ε) · M + ε · I` mit `ε` 0,01–0,1 | die Fläche fällt über 10–20 s auf einen oder wenige Töne zusammen |
| **Spirale** | Hall mit Frequenzshift ±1–5 Hz | der Klang steigt oder fällt mit jedem Umlauf. Im reellen Netz verschwindet er im Freeze an 0 Hz oder Nyquist, im komplexen pendelt er zwischen beiden. |
| **Kollaps** | Wolke, dann Richtung zurück | die Wolke verdichtet sich zum Klick zurück |

Die gefrorene Drehung und die bewegte Fahne gibt es nur, weil die Matrix gedreht und nicht überblendet wird (Teil 3 §2).
