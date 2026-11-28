---
tags: [spec, wwww-main, wwww-installation, wwww-threejs, morphing]
created: 2026-11-04
topic: 'Was aus der Anleitung zum Makro-Morphing noch in wwww passt -- Gruppenkurven und Glaettung auf dem Handy, gebackene Tabellen fuer Versinken und d auf dem Installationsrechner'
verification: 'Der Abgleich mit den Specs ist am 2026-11-04 gegen deren Text gemacht. Alle Vorschlaege stammen aus derselben Sitzung und sind nicht bestaetigt, nichts ist gebaut oder gehoert. Festgelegt ist nur, dass der Nutzer die Werte der Gruppenkurven am Ende justiert. Die Aussagen der Anleitung sind nicht einzeln geprueft. Die Lesart von sample() stuetzt sich auf ein mitgeliefertes Max-Beispiel, nicht auf die Referenz.'
---

# Morphing — was aus der Anleitung noch in wwww passt

Stand 2026-11-04. **Alles hier ist ein Vorschlag, nichts ist gebaut oder gehört.**

> [!abstract] Gebacken wird, was an einem einzigen Wert hängt, alles andere rechnet pro Frame
> Auf dem Installationsrechner hängen das Versinken am Sample-Zähler und die Kurven von `d` an `d`, beide lassen sich also als Tabelle backen. Auf dem Handy hängt die Mischung an Standpunkt, Blick und Pinch zugleich, deshalb rechnet sie JS pro Frame. Gelerntes wie der Korpus entsteht einmal in der Vorproduktion. Die Werte der Gruppenkurven justiert der Nutzer am Ende.
>
> ```mermaid
> flowchart TD
>   P[Standpunkt,<br/>Blick, Pinch] --> JS[JS pro Frame<br/>Gruppenkurven]
>   VP[Vorproduktion<br/>FluCoMa] --> JS
>   JS --> RN[RNBO-Patch<br/>glätten, umrechnen]
>   VP --> KD[fluid.kdtree~]
>   V[v8 beim Laden] --> B[buffer~<br/>Versinken, d]
>   B --> GEN[gen~ liest,<br/>über Zähler und d]
> ```

^blick

**Was hier steht:** was aus der Anleitung noch fehlt, wo jeder Parameter gebacken oder gerechnet wird und welche Widersprüche dabei aufgefallen sind.

**Was hier nicht steht:** wie Morphing funktioniert. Das erklärt die Anleitung `specs\wwww-rnbo\raw\makro-morphing-maxmsp (2).md`. Die Datei ohne `(2)` ist derselbe Text ohne deine Markierungen.

**Verwandt:** `specs\wwww-threejs\steuerung.md` (die Mischung auf dem Handy), `specs\wwww-installation\teppich.md` (das Versinken), `specs\wwww-installation\fdn.md` (der Regler `d`), `specs\wwww-installation\kommunikation.md` (was wo läuft), `learning\max-msp\fdn-7-bau-in-gen.md` (Glätten im FDN).

---

## Festgelegt

| Was | Wie | Seit |
|---|---|---|
| Werte der Gruppenkurven | Die konkreten Gewichte und Koeffizienten justiert der Nutzer erst am Ende. Bis dahin steht hier nur die Richtung. | 2026-11-04 |

---

## Was schon in den Specs steht

| Inhalt der Anleitung | Wo |
|---|---|
| Zustände normalisiert speichern | `steuerung.md`, „Die Welt“ |
| Diskrete Parameter nicht mitteln | `steuerung.md`, „Wie der Klang entsteht“ |
| Freie Punkte nach Abstand gewichten | `steuerung.md`, eigene Formel |
| Feedback als Nachhallzeit steuern | `fdn.md`, Stufe Dämpfung |
| Staffelung, Riskantes kommt spät | `fdn.md`, „Der Regler `d`“ |
| Korpus und UMAP offline, Ergebnis als Datei | `modelle.md`, `kommunikation.md` |
| Nachbarsuche mit KD-Tree, noch ohne Standardisierung | `teppich.md`, `modelle.md` |
| Glätten über 5–50 ms, nur für das FDN | `fdn-7-bau-in-gen.md` §7 |

---

## Wo jeder Parameter entsteht

| Parameter | Wann | Wo | Wer liest |
|---|---|---|---|
| **Handy** | | | |
| Gruppengewichte | nicht gebacken, pro Frame | JS | RNBO über den Inport |
| Bildwerte im Preset-Vektor | nicht gebacken, pro Frame | JS | three.js |
| Glättung und Umrechnung in echte Werte | nicht gebacken, laufend | RNBO-Patch | der Klang im Patch |
| Korpus und UMAP | einmal, Vorproduktion | FluCoMa am PC, als JSON | JS |
| **Installationsrechner** | | | |
| Versinken: Kopplung Höhen, Kopplung Tiefen, Allpass | beim Laden | `v8` schreibt in einen `buffer~` pro Stimme | `gen~`, über den Sample-Zähler |
| `d` → Winkel, Allpass, Vorzeichen-Wechsel | beim Laden | `v8` schreibt in einen `buffer~` | `gen~`, über `d` |
| Standardisierung für den KD-Tree | einmal, Vorproduktion | FluCoMa, als Datei | `fluid.standardize` vor `fluid.kdtree~` |
| Echo-Fenster | nicht gebacken | Formel aus dem Sample-Zähler in `gen~` | Auskopplung |
| Echo `k` | nicht gebacken | das Tor zeichnet es auf | `gen~` |
| Nachhallzeit, von Hand gedrehte Regler | nicht gebacken, laufend | geglättet und aufgezeichnet | `gen~` |

---

## Vorgeschlagen, nicht bestätigt: Handy

### Zuerst hören

Bevor die Gruppenkurven in `steuerung.md` wandern, klärt eine Testseite mit vier Presets und einem Regler, ob man den Unterschied zwischen Crossfade und Verwandlung hört.

### Gruppenkurven

Heute ist die Mischung ein einziges gewichtetes Mittel. Bei jedem Abstand steht also jeder Parameter an derselben Stelle zwischen den Presets. Die Anleitung nennt das in §4 einen Crossfade. Der Pinch ist schon ein Exponent, gilt aber für alle Parameter gleich.

Vorschlag: Jede Parametergruppe bekommt einen eigenen Exponenten auf das Gewicht und füllt ihren Rest selbst mit dem Zwischenraum-Preset auf.

```js
const wG = felder.map((f) => f.w ** k[gruppe]);        // k: justiert am Ende
const S = summe(wG);
const wert = (summe(wG, (w, i) => w * felder[i].preset[p]) + Math.max(0, 1 - S) * zwischenraum[p]) / Math.max(1, S);
```

| Gruppe | Richtung von `k` | Wirkung beim Einflug |
|---|---|---|
| Klangfarbe | unter 1 | kommt früh |
| Raum | um 1 | kommt mit dem Abstand |
| Extreme wie Resonanz, Feedback, Modulationstiefe | über 1 | kommt erst nahe am Kern |

Reicht ein Exponent nicht, etwa für eine Resonanz, die im Übergang aufblüht, wird die Gruppe eine PCHIP-Kurve über dem Gewicht. Diese eine Kurve lässt sich beim Laden der Seite in JS als Tabelle backen.

### Glätten und Umrechnen im Patch

`steuerung.md` schickt bis zu 60 Listen pro Sekunde, nennt aber keine Glättung. Die Liste über den Inport umgeht außerdem `normalizedValue` und damit die Skalierung des Parameters. Der Patch braucht deshalb diese Kette:

1. Liste zerlegen.
2. Im normalisierten Bereich glätten, als Startwert der Anleitung 20–50 ms. Welche Objekte RNBO dafür hat, ist nicht geprüft.
3. Mit derselben Kurve wie der Parameter auf echte Werte umrechnen, nicht mit einer zweiten.

Die harten Schnitte aus `specs\wwww-installation\schnitte.md` laufen nicht durch diese Glättung, sonst wird aus 1 ms ein Übergang von 20 ms. Der Schnitt sitzt deshalb im Signalweg dahinter.

### Mittel oder Regression

`steuerung.md` mischt mit dem gewichteten Mittel, `modelle.md` plant für dieselbe Aufgabe eine FluCoMa-Regression. Eine Regression trifft die Presets nur ungefähr. Vorschlag: beim Mittel bleiben. Die Regression kommt nur dazu, wenn zwischen den Punkten etwas klingen soll, das aus keinem Mittel entsteht.

### Kleinere Ergänzungen

- **Zwei RAVE-Modelle:** Das Überblenden nach Standpunkt (`modelle.md`) läuft über Equal-Power, also `cos` und `sin`, sonst sackt die Lautstärke in der Mitte ab.
- **Bild aus derselben Quelle:** Farbe und andere Bildwerte kommen in den Preset-Vektor und mischen sich mit. Farben mischen im linearen Farbraum oder in Oklab, der Farbton zirkulär über den kürzesten Weg.
- **z1–z4 vorerst nicht glätten.** Die Stufen könnten Artefakte sein, die `artefakte.md` hörbar machen will. Das entscheidet das Hören.

---

## Vorgeschlagen, nicht bestätigt: Teppich und FDN

### Das Versinken als gebackene Tabelle

`teppich.md` verlangt, dass die Parameter einer Stimme aus Sample-Zähler und Einsatz folgen, damit das Zurückholen sie wieder ausrechnen kann. Eine Tabelle erfüllt das von selbst.

```
t = clamp((n - (einsatz + k * L + dauer)) / versinkdauer, 0, 1);
```

- `einsatz`, `dauer` und `k` zeichnet das Tor auf, `L` ist die Länge der Stimmen-Leitung. Damit beginnt `t` dort, wo das Echo-Fenster aus `fdn-7-bau-in-gen.md` §7 endet.
- `gen~` liest damit Kopplung Höhen, Kopplung Tiefen und Allpass. Jede der vier Stimmen hat einen eigenen `buffer~`, ein Kanal pro Parameter.
- Vorwärts und rückwärts ergeben sich dieselben Werte, ohne Aufzeichnung und ohne weiteres Glätten.
- Die Kopplung erreicht auch in der Tabelle nie ganz 0, wie es `teppich.md` unter „Was für den Bau gilt“ verlangt.
- Die Kurven entstehen zuerst zur Laufzeit in `function`-Objekten, nach Gehör. Erst was trägt, wird gebacken.

**Die Bedingung:** Während eines Rückwegs wird nicht neu gebacken, sonst stimmen die Werte rückwärts nicht mehr.

### PCHIP für `d`

`fdn.md` kalibriert die Bereiche von `d` mit dem Crest-Faktor. Die Messungen werden Stützstellen einer PCHIP-Kurve. Weil PCHIP nicht überschwingt, bleibt der Allpass-Koeffizient unter seinem Höchstwert von 0,85. Der Vorzeichen-Wechsel ist eine Stufe und wird gerundet, nicht interpoliert.

### Nachbarsuche

- **`fluid.standardize` vor `fluid.kdtree~`.** Die Handy-Merkmale mischen Hz, Lautheit und MFCC (`kommunikation.md`). Ohne Standardisierung bestimmt der Centroid die Suche, weil seine Zahlen am größten sind.
- **Spread für AFTER.** Eine Auswahl aus den `k` nächsten Treffern statt immer des nächsten bringt Abwechslung. Das Tor zeichnet die Wahl auf, damit der Rückweg sie kennt.

---

## Tests

Aus §8 der Anleitung, zusätzlich zu `fdn-7-bau-in-gen.md` §9:

| Test | Erwartung |
|---|---|
| Spieler im Kern jedes Felds, jede Blickrichtung | Es klingt genau das gespeicherte Preset. |
| Spieler fliegt schnell durch ein Feld | Es klickt nicht. |
| Tabelle bis zum Ende vorwärts, dann rückwärts lesen | Jeder Wert ist in beiden Richtungen gleich. |
| Zweimal starten, gleiche Handy-Merkmale | Bei `k` = 1 wählt der KD-Tree dasselbe Stück. |

---

## Was nicht übernommen wird

| Draußen | Warum |
|---|---|
| One-Pole mit `History` im Kern | Sein Zustand lässt sich rückwärts nicht einfach ausrechnen. Ein gedrehter Regler wird deshalb nach dem Glätten aufgezeichnet (`fdn-7-bau-in-gen.md` §7). |
| `metro` und `v8` im Echtzeitpfad | `gen~` hat keinen Scheduler, `v8` backt nur vorab. |
| TPT-Filter und `filtercoeff~` im Kern | Der Kern aus Allpässen und Butterfly braucht sie nicht. |
| die `k`-Werte aus den Beispielen der Anleitung | Der Nutzer justiert am Ende. |

---

## Was offen ist

- **Der Kern in `steuerung.md`.** Die Tabelle sagt: Im Kern klingt nur dieses Preset. Die Formel sagt etwas anderes: Mitten im Feld, mit abgewandtem Blick, ist `w` = 0,6, also kommen 40 % Zwischenraum dazu. Auch andere Felder, die den Kern überlappen, mischen mit.
- **Der Winkel in `fdn.md`.** Unter „Festgelegt“ steht `d` · 45°, die Tabelle zum Regler lässt 45° schon bei `d` = 0,5 erreichen. Vor dem Backen muss eines davon gelten.
- **Wie `sample()` in `gen~` liest.** Der Code in §6 der Anleitung gibt einen Frame-Index. Ein mitgeliefertes Max-Beispiel nutzt `sample(win, i/(len-1))`, also einen Wert von 0 bis 1. Das klärt ein Test im Patch.
- **Welche Parameter in welche Gruppe gehören.** `steuerung.md` lässt auch die Parameter 1 bis 3 noch offen.
- **Ob `v8` und `gen~` im Runtime-Modus laufen**, offen in `specs\mac-mini\konzept.md`. Wenn `v8` dort nicht läuft, liegen die Tabellen als fertige Dateien vor und `buffer~` liest sie.
