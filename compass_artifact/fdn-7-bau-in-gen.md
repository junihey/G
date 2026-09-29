---
tags: [learning, max-msp, gen, fdn]
created: 2026-09-29
topic: 'FDN Teil 7 -- warum gen~, Leitungen als Data mit eigenem Zeiger, ein Sample-Zaehler fuer beide Richtungen, die Matrix in der Codebox, Presets in buffer~, ein Hash statt noise, der Koerner-Tausch, Glaetten und Messen'
verification: 'aus specs\wwww-installation\fdn.md (Stand 2026-09-28) umgeschrieben; GenExpr-Skizzen aus dem Gedaechtnis, nicht in Max 9 ausprobiert; ob Data 64 Bit speichert, ist nicht geprueft'
---

# FDN 7 — Der Bau in `gen~`

Teil 7 von 7 über Feedback Delay Networks. Die Datei, die du beim Patchen offen hast.

**Setzt Teil 1 bis 4 voraus**, dazu Teil 6 für die Stimmen-Leitungen.

**Antwort zuerst:** Das ganze Netz sitzt in einem `gen~`. Die Leitungen liegen in `Data` und haben einen eigenen Zeiger, damit sie auch rückwärts laufen können. Die Matrix wird in der Codebox mit Schleifen über die Leitungen gerechnet. Winkel, Längen und andere Listen kommen aus `buffer~`. Das Vorzeichen kommt aus einem Hash des Sample-Zählers.

**Was hier nicht steht:** fertiger Code. Die Skizzen zeigen den Aufbau, sie sind nicht ausprobiert.

## 1 · Warum `gen~`

MSP rechnet Signale in Blöcken, dem **Signalvektor**, etwa 64 Samples auf einmal. Eine Rückführung in MSP mit `tapin~` und `tapout~` kann deshalb nicht kürzer sein als ein Block. Innerhalb des Blocks lässt sich nichts Sample für Sample entscheiden.

`gen~` rechnet jedes Sample einzeln. Das brauchen die Allpässe in der Schleife, das Vorzeichen pro Sample und der Rückwärtsschritt.

Zwei Wege gehen deshalb nicht:

| Weg | Warum nicht |
|---|---|
| MSP mit `tapin~`, `tapout~` und `matrix~` | ein Signalvektor Latenz im Kreis, kein Rückwärtsschritt |
| `mc.gen~` mit einer Instanz pro Leitung | die Instanzen können sich nicht innerhalb eines Samples speisen |

## 2 · Leitungen als `Data`

`Data` ist ein Speicher, der nur diesem `gen~` gehört, eine Art kleiner `buffer~` im Innern. Mit `peek` liest man daraus, mit `poke` schreibt man hinein.

Der eingebaute Operator `delay` liest und schreibt selbst, und seine Schreibstelle läuft immer nur vorwärts. Für den Rückwärtslauf aus Teil 4 §11 braucht jede Leitung einen Zeiger, den man zurücksetzen kann. Deshalb liegen die Leitungen in `Data`.

**Ein Zähler für alle Leitungen:** Ein Sample-Zähler `n` läuft vorwärts um 1 hoch, rückwärts um 1 herunter. Leitung `i` mit der Länge `L_i` nutzt die Stelle `n % L_i`, also den Rest beim Teilen durch `L_i`.

- Vorwärts liegt an dieser Stelle der älteste Wert. Er wird gelesen, dann wird der neue Wert an dieselbe Stelle geschrieben.
- Rückwärts liegt an dieser Stelle der neueste Wert. Er wird gelesen, der alte wird zurückgerechnet und an dieselbe Stelle geschrieben.

Der Zähler startet bei einer großen Zahl, damit er rückwärts nie negativ wird.

```
// Skizze, nicht ausprobiert: der Rahmen
Data lines(96000, 16);    // 16 Leitungen, je bis 2 s bei 48 kHz
Data lens(16);            // die Länge jeder Leitung in Samples
Data vec(16);             // Zwischenwerte eines Samples
History n(10000000);      // Sample-Zähler, startet groß
Param richtung(1);        // 1 vorwärts, -1 rückwärts

// vorwärts, Schritt 1: alle ältesten Werte lesen
for (i = 0; i < 16; i += 1) {
    L = peek(lens, i, 0);
    alt = peek(lines, n % L, i);
    poke(vec, alt, i, 0);
}
// Schritt 2: Allpässe, Vorzeichen, Matrix auf vec
// Schritt 3: vec plus Eingang an dieselben Stellen schreiben
n = n + richtung;
```

Alle Leitungen werden zuerst gelesen, dann gemeinsam verarbeitet, dann geschrieben. Die Matrix braucht alle Werte eines Samples gleichzeitig. GenExpr kennt keine lokalen Listen, deshalb liegen die Zwischenwerte in `vec`, einem kleinen `Data`.

## 3 · Die Matrix in der Codebox

Pro Lage des Butterfly (Teil 3 §4) laufen die Paare in einer Schleife durch. Jedes Paar liest zwei Werte aus `vec`, dreht sie und schreibt sie zurück:

```
// Skizze: eine Drehung um den Winkel w zwischen Leitung i und j
x = peek(vec, i, 0);
y = peek(vec, j, 0);
poke(vec, cos(w) * x - sin(w) * y, i, 0);
poke(vec, sin(w) * x + cos(w) * y, j, 0);
```

Rückwärts laufen dieselben Paare in umgekehrter Reihenfolge, mit `-w`.

## 4 · Listen in `buffer~`

Winkelsätze, Längen, Vertauschungen und Vorzeichen-Muster stehen in `buffer~` im Patch. `gen~` liest sie über `Buffer`, einen Verweis auf einen `buffer~` außerhalb. Ein Preset füllt die Puffer, etwa mit `peek~` oder aus `js`. Eine andere Liste ist ein anderes Netz, ohne neuen Patch.

`buffer~` speichert 32 Bit. Für Listen, die sich nur beim Umschalten ändern, reicht das.

## 5 · Das Vorzeichen aus einem Hash

Der Operator `noise` in `gen~` liefert frei laufenden Zufall. Rückwärts lässt er sich nicht wiederholen.

Ein **Hash** des Sample-Zählers liefert für dieselbe Zahl immer dasselbe Ergebnis, vorwärts wie rückwärts:

```
// Skizze: +1 oder -1 für Leitung i, Wechsel alle K Samples
k = floor(n / K) * 16 + i;
h = fract(sin(k * 12.9898) * 43758.5453);
c = h < 0.5 ? -1 : 1;
```

`K` ist die Wechselrate aus Teil 3 §5: 1 für jedes Sample, 500 für einen Wechsel alle 500 Samples.

## 6 · Der Körner-Tausch

Beim Körner-Tausch aus Teil 4 §10 besucht eine Leitung ihre Stellen in jedem Umlauf in anderer Reihenfolge. Die Reihenfolge muss in jedem Umlauf jede Stelle genau einmal treffen, sonst geht etwas verloren.

Der einfachste Fall: Benachbarte Körner tauschen paarweise den Platz. Ob ein Paar tauscht, entscheidet ein Hash aus der Nummer des Umlaufs und der Nummer des Paars. Rückwärts rechnet derselbe Hash dieselbe Reihenfolge aus.

## 7 · Glätten und Umschalten

- **Parameter glätten**, über 5 bis 50 ms, damit es beim Drehen nicht knackt. Während eines Kollapses stehen die Parameter fest (Teil 4 §13).
- **Längen und `N` ändern sich nur bei leerer Schleife.** Sonst laufen zwei Netze nebeneinander, und am Ausgang wird überblendet. Am Ausgang ist Überblenden harmlos, im Kreis nicht (Teil 3 §2).
- **Senken-Leitungen** aus Teil 4 §7 sind gewöhnliche Leitungen im selben `Data`.

## 8 · Rechenlast

16 Leitungen mit je 8 Allpässen, 32 Drehungen und ein Diffusor mit 4 Schritten sind einige hundert Rechenschritte pro Sample. Neben einem Audiomodell ist das verschwindend wenig.

## 9 · Messen

| Test | Wie | Ziel |
|---|---|---|
| **Identität** | `d` = 0, Nachhallzeit unendlich, ein Impuls | `N` getrennte Echoreihen, jedes Echo eine bitgenaue Kopie des Impulses, um die Zahl der Allpass-Stufen verzögert |
| **Freeze** | Energie des Zustands über 10 Minuten | bleibt auf 0,01 dB gleich |
| **Echodichte** | ein Klick durch Diffusor und Schleife, Echos pro Sekunde zählen | 2000–4000 pro Sekunde |
| **Hin und zurück** | ein Impuls, 30 Umläufe vorwärts, 30 rückwärts, mit dem Impuls vergleichen | Abweichung unter −120 dB, laut `data\noise-invertierbarkeit.md` Teil XI praktisch perfekt |
| **Regler** | Crest-Faktor über `d` | nach dem Kalibrieren gleichmäßig |

## 10 · Ausgangspunkt

`gen~.gigaverb` aus Teil 1 §9 zeigt Leitungen, Tiefpässe und Rückführung in `gen~`. Seine Leitungen sind `delay`-Operatoren, deshalb kann es nicht rückwärts laufen. Zum Lesen taugt es, als Vorlage für den Rückwärtslauf nicht.
