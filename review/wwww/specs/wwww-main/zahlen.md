---
tags: [spec, wwww-main, zahlen, harmonik]
created: 2026-10-03
topic: 'Das Zahlensystem aus Atem und sieben Planeten -- was die vier Matrizen liefern, wo sie brechen und wie ihre Verhaeltnisse hoerbar werden'
verification: 'zusammengefasst aus raw\zahlen\ am 2026-10-03; das Rechenbeispiel und die vier Matrix-Dateien und berechnungsgrundlagen.html am 2026-10-03 nachgerechnet; nichts davon ist fuer einen Teil von wwww entschieden'
---

# Zahlen — Atem, sieben Planeten und ihre Verhältnisse

Stand 2026-10-03. Gilt für jeden Teil von wwww, der Zahlenverhältnisse zur Komposition nutzt.

> [!abstract] Ein Tag aus 25920 Atemzügen, dazu sieben Planeten
> 18 Atemzüge pro Minute über 1440 Minuten ergeben 25920 am Tag. Der Atem ⟁ und die sieben Planeten bilden 28 Paare, und vier Matrizen lesen jedes Paar als ein anderes Verhältnis. Die Oktavreduktion faltet ein Verhältnis in einen hörbaren Bereich, die Rundung auf Primzahlen hält die Längen teilerfremd. Wo das benutzt wird, ist offen.
>
> ```mermaid
> flowchart TD
>   A["⟁ Atem<br/>25920 am Tag"] --> P[28 Paare]
>   PL["7 Planeten<br/>♄ ♃ ♂ ☉ ♀ ☿ ☽"] --> P
>   P --> M["4 Matrizen<br/>projektiv · überlagert<br/>Geschwindigkeit · synodisch"]
>   M -->|Oktavreduktion| O[eine Oktave]
>   O -->|auf Primzahlen runden<br/>höchstens 6 Cent| L["Längen, Tonhöhen, Tempi"]
>   L -.->|offen| FDN[16 Leitungen im FDN]
>   L -.->|offen| TH[Bewegung in three.js]
>   A -.->|offen| T["3,33 s als Takt<br/>des Teppichs"]
> ```

^blick

**Was hier steht:** das Zahlensystem selbst und der Weg von seinen Zahlen zum Klang.

**Was hier nicht steht:** wo es benutzt wird. Das entscheidet jeder Teil von wwww für sich. Bis dahin ist jede Verwendung unten nur eine offene Zeile.

Die Formeln stehen hier ausgeschrieben, weil `raw\` nicht in git liegt.

---

## Die Basis: 25920

| Rechnung | Ergebnis |
|---|---|
| 18 Atemzüge pro Minute × 1440 Minuten | 25920 Atemzüge am Tag |
| 18 Atemzüge × 4 Pulsschläge pro Atemzug | 72 Schläge pro Minute |
| 25920 Jahre Präzession ÷ 360° | 72 Jahre pro Grad |

Die 72 steht also dreimal: als Ruhepuls, als Präzession pro Grad und als klassische Lebenserwartung. 18 pro Minute und 4:1 sind Richtwerte, keine Naturkonstanten.

**Die Indexmenge** ist in allen Matrizen gleich: der Atem ⟁ und die sieben Planeten der okkulten Reihe ♄ ♃ ♂ ☉ ♀ ☿ ☽. Acht Elemente, also 28 Paare.

Ein Atemzug dauert 3,33 s. Das ist die Basisperiode des Atems in jeder Matrix.

## Vier Matrizen, vier Bedeutungen von „Verhältnis“

Jede Matrix vergleicht dieselben 28 Paare, aber jede meint mit „Verhältnis“ etwas anderes.

| Matrix | Zelle `M_ij` | Was die Zahl ist | Wo sie bricht |
|---|---|---|---|
| projektiv | `DV_j / DV_i`, mit `DV_n = (t²+1)/(t²−3)`, `t = tan(π/n)` | eine reine Zahl aus einer Winkelkonstruktion, ohne Zeit | Saturn (`n` = 3): der Nenner wird null, `DV` ist unendlich |
| überlagert | `d_j / d_i`, `d` ist ein Teiler von 25920 | wie oft ein Zyklus in den anderen passt, meist ein glatter Bruch | Saturn: der Lemniskaten-Radius auf der Diagonale wird imaginär |
| geschwindigkeit | `v_j / v_i`, mit `v = 360° / T · 3600` Bogensekunden pro Tag, `T` siderisch | ein gemessener Geschwindigkeitsvergleich | der Atem hat keine Bahn, er geht nur als „Atemzüge pro Grad“ hinein: `25920 · T / 360` |
| synodisch | `1/T_syn = |1/T_i − 1/T_j|` | eine Zeitspanne, bis zwei Körper wieder gleich zueinander stehen | der Atem ist zu schnell, ohne Oktavreduktion ist jede Schwebung mit ihm gleich |

**Die Diagonale** der ersten beiden ist derselbe Lemniskaten-Radius `r = √(2 · 720 · cos(2π/n))`, mit `n` = 18 für den Atem und 3 bis 9 für die Planeten. Das ist dieselbe Rechnung zweimal, keine Bestätigung.

**Zufälle, die wie Muster aussehen.** Sonne zu Jupiter ist in einer Matrix genau 2, Mars zu Jupiter in einer anderen auch. Der Goldene Schnitt erscheint nur in der projektiven Matrix, bei Mars (`n` = 5). Beides folgt aus kleinen ganzen Zahlen in der Konstruktion, nicht aus den Planeten.

**Nachgerechnet am 2026-10-03: die Zellen stimmen fast überall, der Text oft nicht.** Maßgeblich für jede Zahl ist `berechnungsgrundlagen.html`. Alle 64 Zellen jeder Matrix stimmen dort. In `matrix_projektiv.html` sind zehn Zellen falsch, die übrigen Dateien rechnen richtig.

| Datei | falsch | richtig |
|---|---|---|
| `matrix_projektiv.html` | 10 von 42 Zellen, etwa `M_Mars,Sonne` = 1,2361 | Dort steht der Kehrwert oder das Verhältnis zweier Nachbarn. `M_Mars,Sonne` ist 0,8090. |
| `matrix_projektiv.html`, `berechnungsgrundlagen.html` | `M_Jupiter,Mars` = Φ = 1,618 | `M_Jupiter,Mars` ist 0,618, und `M_Mars,Jupiter` ist Φ. |
| `matrix_projektiv.html` | Sonne zu Jupiter = 2 ist „dieselbe Oktave wie in der ersten Matrix“ | Dort ist Sonne zu Jupiter 8/9. Die 2 steht bei Mars zu Jupiter. |
| `matrix_ueberlagert.html` | Saturn zu Mond = 12 sind zwei Oktaven plus Quinte | Es sind drei Oktaven plus Quinte, denn 12 = 8 × 3/2. |
| `matrix_ueberlagert.html` | `M_Atem,Mond` = 5/3 | 3/5. Der Text vertauscht die Indizes. |
| `matrix_ueberlagert.html` | Die reellen Radien liegen zwischen 21 und 37 | zwischen 0 und 37, denn Jupiter hat 0 |
| `matrix_ueberlagert.html`, `berechnungsgrundlagen.html` | 1440 ist der einzige Teiler, der 25920 exakt teilt | Alle acht teilen exakt. Nur 1440 stammt nicht aus einer gerundeten Umlaufzeit. |
| `matrix_geschwindigkeit_v2.html` | 774.664 Atemzüge für einen Saturn-Grad sind rund 30 Jahre | Es sind 30 Tage, denn 774.664 / 25920 = 29,9. |
| `matrix_geschwindigkeit_v2.html` | Jupiter zu Mars weicht wegen der exzentrischen Marsbahn um 26 % ab | Die mittlere Umlaufzeit hängt nicht von der Exzentrizität ab. Die Abweichung liegt am klassischen Wert 5. |
| `matrix_synodisch_v3.html` | Lesebeispiel Atem/Jupiter = 276.532,4 Tage | 26.532,4 Tage, wie in der Tabelle |
| `matrix_synodisch_v3.html` | Der Faktor zwischen Atem- und Planetenfrequenz ist „bis 708.134 beim Mond“ | Beim Mond ist er am kleinsten. Bei Saturn ist er 279 Millionen. |
| `matrix_synodisch_v3.html` | „Terz-Äquivalenz (3:2)“ | 3:2 ist eine Quinte. |
| `berechnungsgrundlagen.html` | Ein Atemzug verhält sich zum Tag wie ein Grad Präzession zu 72 Jahren | Ein Atemzug verhält sich zum Tag wie ein Jahr zu 25920 Jahren. |
| `berechnungsgrundlagen.html` | Mars hat den kleinsten Radius der Planeten; −1/2 der Sonne ist der einzige glatte DV-Wert | Jupiter hat den kleineren Radius (0) und ebenfalls einen glatten DV-Wert (−1). |
| `berechnungsgrundlagen.html` | „Matrix 4: Saturn hat 774.664 Atemzüge pro Grad“ | Die Zahl stammt aus Matrix 3. |

## Primzahlen, zweimal und gegensätzlich

**In der Harmonik schaffen Primzahlen Übereinstimmung.** Ein Intervall ist ein Verhältnis ganzer Zahlen. Die größte Primzahl darin heißt sein Limit.

| Verhältnis | rein | 12-stufig | Abweichung |
|---|---|---|---|
| 3:2 Quinte | 702 | 700 | 2 Cent |
| 5:4 große Terz | 386 | 400 | 14 Cent |
| 7:4 Naturseptime | 969 | 1000 | 31 Cent |
| 13:8 | 841 | 800 | 41 Cent |
| 11:8 | 551 | 600 | 49 Cent |

Die westliche Musik hält bei 5, weil der Dreiklang 4:5:6 nicht mehr braucht. 7, 11 und 13 trifft die Zwölfteilung nicht. Schlesingers Harmoniai und Partch nutzen genau sie.

**Im Hall verhindern Primzahlen Übereinstimmung.** Die Verzögerungen eines Feedback Delay Network müssen teilerfremd sein, etwa 1009, 1123, 1201, 1289 Samples. Teilen zwei Längen einen Faktor, wiederholt sich das Echomuster bald und klingelt, und Resonanzen fallen aufeinander.

Dieselbe Rechnung liefert also zwei Regeln mit umgekehrtem Ziel. Wer die Planetenverhältnisse hörbar machen will, muss sich pro Stelle für eine entscheiden.

## Der Weg zum Klang: Oktavreduktion

Die Planeten laufen in Tagen bis Jahren, der Atem in Sekunden. Hörbar wird ein Verhältnis erst, wenn man die Periode so oft halbiert oder verdoppelt, bis sie im gewünschten Bereich liegt. Das Verhältnis bleibt dabei bis auf Oktaven erhalten. `matrix_synodisch_v3.html` nutzt diesen Schritt für den Atem.

**Ein Beispiel.** Die siderischen Umlaufzeiten, gefaltet in eine Oktave von 1500 bis 3000 Samples, die Sonne bei 1500, dann auf die nächste Primzahl gerundet:

| Planet | gefaltet | Primzahl | Abweichung |
|---|---|---|---|
| ☉ Sonne | 1500,0 | 1499 | −1,2 Cent |
| ☽ Mond | 1795,2 | 1801 | +5,6 Cent |
| ♀ Venus | 1845,6 | 1847 | +1,4 Cent |
| ♃ Jupiter | 2224,1 | 2221 | −2,4 Cent |
| ♄ Saturn | 2761,6 | 2767 | +3,4 Cent |
| ♂ Mars | 2821,2 | 2819 | −1,4 Cent |
| ☿ Merkur | 2890,1 | 2887 | −1,9 Cent |

Die Rundung auf Primzahlen verschiebt keine Länge um mehr als 6 Cent. So gelten beide Regeln zugleich: das Verhältnis der Planeten und die Teilerfremdheit.

Dieselbe Faltung geht in jeden Bereich: Samples, Tonhöhen, Tempi, Minuten einer Aufführung.

## Wo es anschließen kann

Offen. Keine Zeile ist entschieden. Wird eine entschieden, steht die Entscheidung im jeweiligen Spec, und hier bleibt nur der Verweis.

| Teil | mögliche Verwendung |
|---|---|
| `wwww-installation` | Längen der 16 Leitungen im FDN (`fdn.md`); der Atemzug von 3,33 s als Takt des Teppichs |
| `wwww-performance` | Tonhöhen oder Stimmung aus den Verhältnissen; Abschnitte nach synodischen Perioden |
| `wwww-rnbo` | Verhältnisse als Parameter eines Patches |
| `wwww-threejs` | Umläufe und Begegnungen als Bewegung im Raum |
| `wwww-workshop` | die Rechnung selbst als Material zum Ausprobieren |

## Quellen

| Datei | Was darin steht |
|---|---|
| `raw\zahlen\berechnungsgrundlagen.html` | alle 64 Zellen der vier Matrizen mit Formel, Herleitung von 25920, Quervergleich, Steckbriefe |
| `raw\zahlen\matrix_projektiv.html` | Doppelverhältnis, Laguerre-Winkel, Lemniskate, Polstelle bei Saturn |
| `raw\zahlen\matrix_ueberlagert.html` | Teilerverhältnisse von 25920, Lemniskaten-Radius auf der Diagonale, magische Konstanten K |
| `raw\zahlen\matrix_geschwindigkeit_v2.html` | Winkelgeschwindigkeiten, vier Wege für den Atem, gewählt „Atemzüge pro Grad“ |
| `raw\zahlen\matrix_synodisch_v3.html` | Schwebungsperioden, Eigenumlauf, Oktavreduktion des Atems |
| `raw\zahlen\primzahlen-harmonik-hall.html` | Primzahl-Limit, teilerfremde Verzögerungen |
| `raw\---20260815 mathematische Ideen.md` | Vorläufer: Doppelverhältnis, harmonische Spiegelung, Lemniskate |
| `specs\wwww-installation\raw\herz wasserstoff\wasserstoff.md` | Vorläufer: 25920 als Atemzüge, Lebenstage und Weltenjahr |
