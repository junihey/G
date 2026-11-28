---
tags: [spec, wwww-main, motive]
created: 2026-10-30
topic: 'Die zehn Motive, die sich durch die ganze Arbeit ziehen -- ihr Wortlaut und wo sie in Specs und Prototypen anklingen'
verification: 'Wortlaut vom Nutzer am 2026-10-30 eingefuegt, aus specs\wwww-main\raw\20260808 context infos.md. Die Spalte "ausdruecklich" am selben Tag in den Specs und READMEs nachgesehen. Die Spalte "klingt an" ist eine Lesart von Claude vom selben Tag; der Nutzer hat sie als Lesart angenommen, nicht als Festlegung. Die Spalte "ueber den Doppelgaenger" ist eine Lesart von Claude vom 2026-11-04, vom Nutzer in die Tabelle uebernommen. Die Orte in welt vom Nutzer am 2026-11-10 bestaetigt.'
---

# Motive — was sich durch die ganze Arbeit zieht

Stand 2026-11-10. **Die Motive sind gesetzt, wo sie anklingen, ist zum Teil eine Lesart.**

> [!abstract] Zehn Motive ziehen sich durch die ganze Arbeit
> Zwei sind Regeln für jede Entscheidung, eines ist der Rahmen aus 12 Kräften und 7 Bewegungen, sieben sind Themen. Ausdrücklich arbeitet bisher nur `modelle.md` mit ihnen. Wo sie sonst anklingen, steht als „klingt an“: eine Lesart, nicht festgelegt.
>
> ```mermaid
> flowchart TD
>   subgraph RE[Regeln]
>     K1["Keine Entscheidung<br/>darf Kraft kosten"]
>     K2["Nur konkret<br/>umrissene Ideen"]
>   end
>   subgraph RA[Rahmen]
>     R12["12 Kraftzentren"] --- R7["7 Bewegungen"]
>   end
>   subgraph TH[Themen]
>     T1["3 in 1 in 3"]
>     T2[Minerale]
>     T3[Vokale]
>     T4["Polaritäten,<br/>Zwilling"]
>     T5[Verwandlung]
>     T6[Feedback]
>     T7["Kugel?"]
>     T1 ~~~ T4
>     T2 ~~~ T5
>     T3 ~~~ T6
>     T5 ~~~ T7
>   end
>   RE --> RA --> TH
> ```

^blick

**Was hier steht:** die Motive im Wortlaut und wo sie in Specs und Prototypen anklingen.

**Was hier nicht steht:** wie ein Motiv klingt. Das steht für die Modelle in `specs\wwww-installation\modelle.md` unter „Motive → Modelle“.

**Verwandt:** `specs\wwww-main\raw\20260808 context infos.md` (die Quelle, mit weiteren Notizen zu Symmetrie und Mineral), `specs\wwww-threejs\steuerung.md` (der Motiv-Rahmen für die 12 Punkte, offen), `specs\wwww-main\review\review.canvas` (der Kasten „Motive“).

Die Motive stehen hier ausgeschrieben, weil `raw\` nicht in git liegt.

---

## Wo sie anklingen

**Ausdrücklich** heißt: Die Spec oder README dieser Karte nennt das Motiv selbst. **Klingt an** ist eine Lesart, vom Nutzer als Lesart angenommen am 2026-10-30. Die Namen sind die Karten im Review-Canvas, `canvas.mjs` liest diese Tabelle. **Über den Doppelgänger** fragt, was das Motiv über die Arbeitshypothese aus `konzept.md` sagt. Das ist eine Lesart von Claude vom 2026-11-04.

| Motiv                                      | in einem Satz                                                                                                         | ausdrücklich                      | klingt an                                                                                                            | über den Doppelgänger (Lesart) |
| ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------- | --------------------------------- | -------------------------------------------------------------------------------------------------------------------- |---|
| Keine Entscheidung darf Kraft kosten       | Entscheidungen sind einfach und notwendig, sonst braucht es einen anderen Weg.                                        | modelle                           | –                                                                                                                    | – |
| Nur konkret umrissene Ideen                | Dargestellt wird nur, was umrissen ist.                                                                               | –                                 | –                                                                                                                    | Prüfstein: Auch die Hypothese braucht einen konkreten Ort. Am Zwilling hat sie ihn. |
| 12 Kraftzentren, 7 Bewegungen              | Zwölf stille Kräfte als Orte, sieben Bewegungen als Qualitäten.                                                       | steuerung, modelle, kommunikation | zahlen, magenta-rt2                                                                                                  | Der Zwilling ist eine der zwölf Kräfte, der Doppelgänger hat im Rahmen also seinen Platz. |
| 3 in 1 in 3                                | Zwei, denen sich ein Drittes vereinigt, wie im Jahreskreislauf.                                                       | modelle                           | verraeumlichung, wwww-threejs-schichten, zahlen, kette-entwurf, Heft 25920, granit-projektion (die Raumecke)         | Er ist die Zweiheit, der sich das Dritte vereinigen muss: das Ich, das die Taube zur Erde trägt, das inkarniert und zugleich die Welt durchdringender Geist ist. |
| Minerale                                   | Mathematische Ideen als Bewegung, ausgeglichenes Gleichgewicht, zersplitterte Form.                                   | –                                 | granit-atlas, granit-projektion, zahlen (Laguerre), threejs-wegkurven-funken                                         | „Auflösen Lust, Materialisieren Schmerz“ sind seine Pole. Die zersplitterte Form gibt dem Zersplittern einen Stoff. |
| Vokale                                     | Die Sprache verliert das Substantiv und geht ins Werdende.                                                            | modelle                           | Heft 25920, typo-katalog                                                                                             | Das Ich lässt sich nicht als Ding festhalten, es setzt sich immer neu. |
| Polaritäten, Dopplung, Symmetrie, Zwilling | Sonne und Mond, Analyse und Synthese, zwei Seiten, die sich ausgleichen. Der Zwilling aus den 12 Kräften gehört dazu. | modelle                           | kette-entwurf, kommunikation, artefakte, Klang des Handys, steuerung (der Zwilling V4), max-bausteine/vektorfiguren, welt (Teilung der Ebene und Farbsaum)  | Es benennt ihn direkt: Luzifer und Ahriman sind seine Pole. |
| Verwandlung, Metamorphose, Kaleidoskop     | Übergänge zwischen Ideen, ein Klang nimmt die Gestalt eines anderen an.                                               | modelle                           | granit-projektion, max-bausteine/vektorfiguren, threejs-wegkurven-funken, typo-katalog, sa3-medium, Klang des Handys, welt (ferne Arbeiten als Blüten) | Die Verwandlung ist der Übergang, mit dem er immanent verbunden ist. Das Kaleidoskop ist zugleich das Zersplittern der Asuras: Wie in der Nigredo wird alles zu Asche, und aus dem schwarzen Boden entsteht Neues. |
| Feedback, Kopplung                         | Die Ausgabe wird wieder Eingabe.                                                                                      | modelle                           | kommunikation, fdn, teppich, artefakte, magenta-rt2                                                                  | So begegnet man sich selbst als etwas Fremdem. |
| Kugel als Absolutum?                       | Die platonischen Körper nähern sich der lebendigen Kugel.                                                             | modelle                           | steuerung (Felder als Kugeln), threejs-wegkurven-funken, welt (Schnatz)                                                              | Sie ist das Gegenbild: das Ganze, dem man sich nur annähert. |

^orte

**Noch ohne Ort:** „Nur konkret umrissene Ideen“, und aus „Polaritäten, Dopplung, Symmetrie, Zwilling“ die zwei Webseiten, bei denen die Bewegung auf die andere springt, wenn die Durchdringung auf der einen bricht.

## Die Motive im Wortlaut

Vom Nutzer, aus `raw\20260808 context infos.md`, eingefügt am 2026-10-30.

- Keine Entscheidung darf Kraft kosten. Entscheidungen sind einfach und notwendig. Wenn sie Kraft kostet, müssen anderer Weg gegangen werden.
- nur konkret umrissene Ideen darstellen
- 12 Motive (Edelsteine des Neuen Jerusalem), 7 Bewegungen (Planeten) als Rahmen
    - 12 als Kräfte (die Zeichen des Tierkreises als äußerlich stille Kraftzentren)
        - Zwilling's Symmetrie in der Kunst ist Urerlebnis der gestaltenden kosmischen Kräfte vor dem Einströmen der Vielheit der Seelenkräfte und der Einmaligkeit der Ich-Kräfte. (körperliches Erlebnis der Dopplung, Sinnesorgane)
            - in Altpersien als Spaltung und polare Teilung des Kosmos erlebt, in Altindien noch ein einheitlicher Äther
            - Es ist dieses symmetrische Wesen mit seiner Sonnen- und Mond-Seite in uns, durch das wir unser Ich entwickeln können. (Augen sind im Geist eins)
            - (Judith von Halle „Das Wort…“ Band III - Aus Kapitel 177) Wenn aber diese seelisch-geistige Saturn-Natur der Schöpfung ins Sinnlich-Materielle hinunter sklerotisiert, erscheint sie in ihr Gegenteil verkehrt. Aus seelischer Wärme, welche man als teilnahmsvolle Zuwendung, freilassendes Wohlwollen oder Opfergesinnung beschreiben könnte, werden an der materiellen Oberfläche eines ent-geisteten planetarischen Körpers rein physikalische, also entseelte Phänomene.
            - (Richard Karutz - Aber von dem Baum der Erkenntnis...") [Symmetrie als Realsymbol:] sie entstamme einem eingeborenen „Gefühl für Symmetrie“ oder einem „Trieb nach Gleichgewicht“. Aber Gefühl und Trieb müssen wiederum irgendwoher kommen, sie müssen in geistigen Wirklichkeiten wurzeln, sonst bleiben sie Worte einer willkürlichen historischen Betrachtung. Nicht das Ziel, ein Trieb nach Gleichgewicht, führt die Hand des Künstlers, sondern der Ursprung, eine Kraft tut es. Das innere Erleben des Gleichgewichts tut es. Das Phänomen entsteht also da, wo erstmalig der symmetrisch mathematisierende Wille der körperlichen Aufbaukräfte erlebt wird; wo der Gleichgewichtssinn des Menschen sich, wenn auch noch nicht im Bewußtsein erfaßt, so doch im Unterbewußtsein vor der Außenwelt empfindet, in allen Handlungen nach außen drängt und in der künstlerischen Tat sich ausdrückt. ... kann also in der menschlichen Bewußtseinsgeschichte erst da erscheinen, wo die menschlichen äußeren Sinne für die Umwelt erwachen und die inneren Sinne sich mit der Umwelt auseinandersetzen können. Das ist in der altpersischen Kultur der Fall.
        - [[20260808 context infos#weiteres zu Symmetrie/Zwillinge]]
        - (marjorie spock - durchkraftete stille und bewegung) [[Pasted image 20260907192705.png]]
    - 7 als Qualitäten, Menschliche Wesenmonaden, Bewusstseinszustände
        - [[IMG_0141.jpg]]
        - (Neuer Jupiter anthrowiki, GA 88, S. 197) Das Wesenhafte muß erst durch die Weisheit (Mond) hindurchgegangen sein, dann durch die Liebe (Erde), und endlich muß es im Feuer (Jupiter) aufgehen. Das ist das Ziel, welches der Urgeist, der den Kosmos durchströmt, anstrebt.
        - Wesen
            - (HEIDEGGER ÜBER SPRACHE UND INFORMATION) Phänomene auf ihre offenen Dimensionen des Möglichen hin auslegen, sie in ihrem "Wesen",  d.h. in ihren Bedingungen und Grenzen erkennen und somit das erwünschte freie Verhältnis ermöglichen.
    - (GA 145, S. 109ff) Neues Jerusalem, Neuer Jupiter, Würfel, Gral in der Dreigliedrigkeit des Schädels, Sinneseindrücke und mineralische Extrakte
- 3 in 1 in 3
    - Ebenso wie wir aus Gott geboren sind, sterben wir im Sinne der esoterischen Weisheit in Christo: I. C. M. Und weil überall da, wo sich etwas offenbart, sich eine Zweiheit zeigt, der sich das Dritte vereinigen muß, wird der Mensch, wenn er den Tod überwunden hat, sich selbst identifizieren mit dem die Welt durchdringenden Geiste (die Taube). Er wird auferstehen und wieder leben im Geiste: P. S. S. R.
        - (Judith von Halle „Das Wort…“ Band III - Aus Kapitel 177) alles, was zur Sinnessphäre geworden ist, zum lebendigen Geist erheb
    - Ausgleich der Polaritäten, Dopplung und Symmetrie
    - Jahreskreislauf (3 in 1 in 3) [[223a DER JAHRESKREISLAUF ALS ATMUNGSVORGANG DER ERDE 7. APRIL 1923.pdf]]
    - Würfel3d/Pixel2d/GaussianSplat1d - Strahl
        - Scan-Methoden
    - räumliche Ecken
- Minerale
    - mathematische Ideen als metamorphotische Bewegungen und Potenzierung durch Pflanzen
    - thermodynamisches Gleichgewicht, was sie ausgleichen
    - Auflösen Lust, Materialisieren Schmerz
    - nicht erwachtes Bewusstsein höherer Hierarchien, Sinnesorgane, einstiges Leben, Ort der Freiheit
    - Kyriotetes Weisheit Urphänomen Geist Mineral Verhältnis-Zahl
        - Pflanze formt den Raum um, und kehrt zu höherer Form zurück, Potenzierung
        - Excusiai Form Urform Physis/Phantom Laguerre Raum
            - So haben wir hier die Begegnung von Kräften der normalen Geister der Form und von Kräften der abnormen Geister der Form. Die prallen aufeinander. Es entsteht in Wahrheit eine Einstülpung, und damit zugleich an dieser Stelle ein Zerbrechen der Form, aber eben nur der Form. Die Form zerbricht, und es entsteht diese Einbohrung. Und zerbrochene Form, zersplitterte Form, das ist in Wahrheit Materie. Materie im physischen Sinne gibt es nur da, wo Formen zersplittert werden. So sind auch die Planeten draußen zersplitterte Formen.
            - (Judith von Halle „Das Wort…“ Band III - Aus Kapitel 177) Erst dadurch, dass Christus dem einzelnen Menschen das Ich erweckt hat, kann nun das bereits seit der alten Saturn-Zeit herangebildete Urbild (Phantomleib bei R.Steiner genannt) seines physischen Leibes eigentlich von einem „allgemeinen“ menschlichen Besitz zu einem „persönlichen“ Eigentum des einzelnen Ichs werden.
                - Der physische Leib muss eines Tages ebenso individuell werden wie das Ich. (Astralleib teilt sich Sympathien, Antipathien, Triebe; Ätherleib nur unterschiedlich in den vier Temperamenten)
    - [[20260808 context infos#weiteres zu Mineral (Pflanze)]]
- Vokale https://superpang.bandcamp.com/album/phantom-acid
    - (Das Geheimnis der Trinität, GA 214, 150 ff.) Nach dem Tod verliert der Mensch, immer mehr den Bezug zum Substantivischen in der Sprache. Er orientiert sich am Werdenden, dadurch hält ervnoch eine Zeit lang die Verbindung zuvden Verbalformen, die sich aber oft alsc Interjektionen oder Empfindungswörter zeigen. So geht es aus dem Physischen durch das Umformen der Sprache ins Geistige hinein.
- Polaritäten, Dopplung und Symmetrie
    - Regenbogen und Wolke
    - Säulen des Tempels (Neues Jerusalem, Schlange, Baum der Erkenntnis und des Lebens)
    - Luzifer Ahriman
    - Sonne ☉□ , ‿ ∞ mond
    - Analyse Synthese: okkultistisches Entkleiden der menschlichen Gestalt in Gliedrigkeit und Wesenheiten (Analyse ruft Wesenheiten hervor)
    - FFT Bandpass
    - 2 Webseiten, sobald die Durchdringung der Ebenen auf einer Webseite bricht, verschiebt sich die Bewegung auf die andere Webseite in polarer Art und Weise (z.b. Würfel, Pixel und Splats liegen nicht mehr übereinander, auf der anderen Webseite erscheinen vom Umkreis Elemente die Äther verlassen und aufeinander zurücken und verdichten)
    - Auf- und Absteigendes (Bruckner)
- Verwandlung, Metamorphose und Kaleidoskop
    - Übergänge zwischen Ideen
    - fft [[img359.jpg]]
    - Timbre Transfer
    - Metamorphose Pflanzenwachstum https://robertschwarz.bandcamp.com/album/stridulations-1-14
    - Dynamis Bewegung Urprinzip Seele Pflanze Metamorphose
- Feedback, Kopplung
- Kugel als Absolutum?
    - Platonische Körper als Konstruktion der lebendigen, dynamischen Kugel mit maximaler Symmetrie und Vollkommenheit; können Kugel umschreiben oder eingeschrieben werden - Ecken auf Kugeloberfläche und sind dadurch eine diskrete Annäherung an die Kontinuität der Kugel
