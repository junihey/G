# Schritt 9 – Bühne aufräumen: Ebenen nach Herkunft, b ziehen, z überall gleich, Zahl am Reiter

Datum 2026-10-17. Form: Werkzeug, Brücke, Quellen, Messung, Aussortiert, Offen.

## Werkzeug

Kein neues Werkzeug. Vier Änderungen an Bühne und Reitern:

| Vorher | Jetzt | Wo |
|---|---|---|
| Ebenen-Liste ohne Ordnung | Gruppen nach Herkunft: „Rechenblatt“, dann je Werkzeug. Der Schalter im Gruppenkopf schaltet alle Ebenen der Gruppe; halb an zeigt er als Strich. | `LAYERS.render` in `src/65-bruecken.js` |
| b in Ax = b nur über Zahlenfelder | In der Spaltensicht ist b ein Griff. Ziehen schreibt die Zeile `b` (auf 0,05 gerundet), die Felder im Werkzeug folgen. | Ebene `m2-axb`, `handles`/`drag` in `src/80-matrix.js` |
| z-Regler in Drehstreckung, Produkt und Potenzen trugen dieselben ids; nur der erste folgte der Zeile `z` | Klassen `kz-a`, `kz-b`; `KZ.showZ` stellt alle Regler, außer dem, an dem gerade gezogen wird | `src/86-komplex.js` |
| Ein Reiter verriet nicht, was im Blatt zu ihm passt | Zahl am Reiter: so viele Zeilen bieten „öffnen in → dieses Werkzeug“ an; der Tooltip nennt sie | `BRIDGE.offers`, `tabCounts` in `src/60-ui.js` |

Klickweg: `binomcdf(20, 0.3, 8)` und `P = normcdf(-inf, 1, 1, 0)` tippen. Der Reiter „Verteilungen“ trägt dann eine 2, sobald er offen ist. Unten links auf der Bühne „Ebenen“ öffnen und den Schalter „Rechenblatt“ ausschalten: Alle Zeilen verschwinden von der Bühne, die Werkzeuge bleiben.

## Brücke

- Die Zahl am Reiter kommt aus derselben Tabelle wie die Knöpfe „öffnen in“ (`BRIDGE.lesarten`). Ein neues Werkzeug mit einer Lesart bekommt die Zahl also ohne Zusatzarbeit.
- b ist dieselbe Zeile wie im Rechenblatt: `b := [3, 4]` und Ziehen ändern sich gegenseitig.

## Quellen

Keine.

## Messung

`node bench/messen.mjs 9`: Tippen bis zum Graphen 42 ms (Median), Reglerbild 16,6 ms, Fläche am Regler 16,6 ms, kein Block über 50 ms. Die Zahl am Reiter rechnet bei jeder Änderung am Blatt neu; im Messlauf ist das nicht zu sehen.

`node bench/ansicht.mjs 9`: Gruppe „Rechenblatt“ aus und wieder an; b per Griff von (3, 4) nach (1,5; 2,5) gezogen, Zeile `b := [1.5, 2.5]`, Lösung x = 0,4, y = 0,7; z-Regler in Drehstreckung gezogen, der Regler in Potenzen folgt; Zeile `z = -0.5 + 2i` gesetzt, beide Regler folgen. Alle 26 Werkzeuge in 2D und 3D ohne Konsolenfehler, keins mit eigener Grafik. Bildschirmfotos angesehen: Ebenen-Gruppen, Rechenblatt aus, b gezogen, Potenzen.

## Aussortiert

Nichts.

## Offen

- ~~Die Zeile `b := [3, 4]` bietet kein „öffnen in → Ax = b“ an.~~ Erledigt am 2026-10-17 (Nachtrag zu Schritt 10): ein Vektor namens `b` bietet es an, der Reiter zählt ihn.
- In der Zeilensicht (zwei Geraden) gibt es keinen Griff; b ist dort kein Punkt der Ebene.

## Nachtrag 2026-10-17: der Griff b war verdeckt

Beim ersten Ausprobieren fand der Nutzer b nicht und konnte es nicht ziehen. b startete bei (2, 1), der ersten Spalte von A = [[2, 1], [1, 3]] aus dem Rundgang: der kleine Ring lag unter der Pfeilspitze von a₁ und unter dem Pfeil der Zeile b. Geprüft war der Griff nur mit einem direkten Aufruf von `STAGE.hit`, nicht mit echten Mausereignissen und nicht mit dieser Matrix. In Schritt 10 behoben (Start bei (3, 4), gefüllter Griff „b ziehen“) und mit echten Mausereignissen geprüft.
