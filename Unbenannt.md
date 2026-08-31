Warum werden folgende Befehle und Fachbegriffe nicht erwähnt: „runsuite, Runchecks, Tdd“ es gibt sicher noch weitere die mir nicht aufgefallen sind

---

Sind diese offenen und fehlerhaften Stellen in orchestrator-map beschrieben?

Alles hier ist belegt, nichts davon ist Vermutung.

| Loch | Warum es nicht einfach behoben ist |
|---|---|
| **Keine `pipeline.config.json`** | Auf dieser Maschine existiert keine. Alles oben ist gebaut und **nicht angeschlossen** |
| **Keine Guardrails installiert** | Die erste Regel ist gemessen. Ein Linter ist schnell installiert; zu **beweisen**, dass er zuschnappt, ist die Arbeit |
| **Ein Agent kann grün werden, indem er den Test löscht** | Der Prompt bittet darum, es nicht zu tun. Eine Prüfung gibt es nicht, und die naive Regel „ein Test wurde geändert" taugt nicht: eine Umbenennung **muss** jeden Test anfassen, der das Symbol nennt |
| **`REVIEW-STANDARDS.md` ist leer** | Die Mechanik ist bewiesen — mit einem Platzhaltertext. Ein echter Standard existiert nirgends |
| **Kein `awaiting_decision`** | Abschnitt 4 |
| **Ein Merge-Konflikt hat genau eine Verteidigung** | Als *letzte* Linie ist sie richtig. Sie ist derzeit die einzige. Vorbeugen hieße: B rebaset, sobald A merged — das ändert aber, was einem laufenden Agenten zugesagt wurde |
| **Windows-Pfadlänge** | Ein Lauf starb bei **249 Zeichen**. Die Folge ist behandelt (die Notiz scheitert, der Prozess lebt), die Ursache nicht |
| **Eine kaputte Notiz reißt den ganzen Speicher mit** | Siehe unten |

### Der letzte Punkt im Detail (nachgetragen 2026-08-05)

Das Lesen einer Notiz läuft ohne Auffangblock. Ist das YAML im Kopf kaputt, fliegt
der Fehler aus der Auflistung heraus — **beim Start läuft der Orchestrator dann gar
nicht erst an.** Eine einzige handgeschriebene Notiz mit einem Tippfehler legt
alles lahm.

Die zweite Hälfte ist schlimmer. Die Bibliothek merkt sich Ergebnisse. Dieselbe
Notiz wirft also **einmal** und wird danach für die restliche Laufzeit des
Prozesses **still übersprungen.**

Nicht behoben, weil ein Auffangblock ungefragt entscheiden würde, ob eine
unlesbare Notiz übersprungen oder der Lauf angehalten gehört. Und still
überspringen tut der Zwischenspeicher schon jetzt versehentlich.
