---
tags: [learning, orchestrator]
created: 2026-08-29
updated: 2026-08-31
topic: 'Der Orchestrator von Grund auf -- ein Lehrtext, der bei null anfängt: die Begriffe, die Bauteile, ein Lauf, die vier Prüfungen, die Regeln über den Code, und wie das Ganze geprüft ist'
verification: 'am 2026-08-31 gegen den Code gelesen -- smithy\orchestrator\src\, \test\, \verification\, dazu .claude\guardrails\typescript\ und smithy\forge\skills\baseline\SKILL.md'
---

# Wie der Orchestrator arbeitet

**Was das hier ist.** Ein Lehrtext über ein Programm, das dauerhaft läuft, einen
Ordner mit Aufgaben-Notizen beobachtet und jede freigegebene Aufgabe von selbst
bauen, prüfen und veröffentlichen lässt. Von deiner Freigabe bis zum fertigen
Ergebnis fasst kein Mensch mehr etwas an.

**Wie er zu lesen ist.** Die acht Teile bauen aufeinander auf. Jeder Begriff wird
erklärt, bevor er benutzt wird, und jede Datei wird benannt, bevor auf sie
verwiesen wird. Teil I setzt nichts voraus. Wer git schon kennt, liest ihn
trotzdem kurz an — die Abschnitte 3, 4 und 6 klären Unterscheidungen, an denen
später ganze Absätze hängen.

**Was hier nicht steht.** Diese Datei beschreibt die Maschine, wie sie
funktioniert. Was daran offen, kaputt oder noch nicht angeschlossen ist, steht in
[[orchestrator-map]] — dort ist es maschinell überwacht und wird nachgezogen,
sobald sich der Code bewegt. Ändert sich dort etwas, wird diese Datei
nachgehoben. Auch die vollständigen Verzeichnisse gehören dorthin: alle
Testdateien, alle Konfigurationsschlüssel, die Diagramme.

Der Code liegt in `smithy\orchestrator\`. Wo unten eine Datei genannt wird, ist
sie relativ zu diesem Ordner gemeint.

---
---

# Teil I — Die Begriffe, auf denen alles steht

Neun Begriffe. Ohne sie liest sich der Rest wie Nebel, und mit ihnen liest er
sich fast von selbst.

## 1 · Ein Repository hat zwei Hälften

Ein **Repository** — kurz Repo — ist ein Projektordner, der seine eigene
Geschichte mitführt. Er besteht aus zwei Dingen, die man leicht für eines hält:

**Die Versionsgeschichte.** Jeder je gespeicherte Stand, komprimiert im
versteckten Unterordner `.git`. Das ist ein Archiv. Du öffnest es nie im Editor,
und du kannst es nicht sinnvoll von Hand lesen.

**Das Arbeitsverzeichnis.** Die Dateien, die wirklich als Dateien auf der Platte
liegen. Das ist, was dein Editor öffnet, was ein Programm ausführt und was ein
Testlauf liest.

Alles, was git tut, bewegt sich zwischen diesen beiden Hälften: etwas aus dem
Arbeitsverzeichnis ins Archiv legen, oder etwas aus dem Archiv ins
Arbeitsverzeichnis holen.

## 2 · Commit, Branch, Checkout

**Ein Commit** ist ein vollständiger Schnappschuss des Projekts, im Archiv
abgelegt und mit einer eindeutigen Nummer versehen — der **SHA**, eine lange
Folge aus Ziffern und Buchstaben wie `2e14772`. Ein Commit ist unveränderlich.
Was einmal drin ist, bleibt drin.

**Ein Branch** ist ein Zeiger auf einen Commit, mit einem Namen. Mehr nicht. Der
Branch `main` ist der Zeiger, der auf den jeweils gültigen Stand des Projekts
zeigt. Machst du einen neuen Commit, während `main` ausgecheckt ist, rückt der
Zeiger einen weiter.

Weil ein Branch nur ein Zeiger ist, kostet ein neuer Branch nichts. Er ist ein
zweiter Name auf denselben Commit, und ab da können sich die beiden Zeiger
auseinanderbewegen.

**Ein Checkout** ist der Vorgang, der aus der ersten Hälfte die zweite macht:
*„nimm den Stand, auf den Branch X zeigt, und leg ihn als echte Dateien in diesen
Ordner."* Und *ein* Checkout ist auch das Ergebnis davon — ein Ordner voller
Dateien, der weiß, von welchem Branch er kommt.

Ein Branch heißt **ausgecheckt**, wenn irgendein Arbeitsverzeichnis gerade seinen
Stand zeigt.

Der Projektordner selbst ist ein Checkout. Klonst du ein Repo, bekommst du genau
das: das Archiv in `.git`, und daneben die Dateien des Hauptbranches, ausgepackt.
Dieser Ordner heißt in dieser Datei durchgehend **Haupt-Checkout**, und er steht
auf `main`.

**Daraus folgt ein Satz, der später eine ganze Entscheidung trägt: `main` ist
immer ausgecheckt.** Nicht als Regel, die jemand aufgestellt hat, sondern weil der
Ordner existiert.

## 3 · Worktree: mehrere Arbeitsverzeichnisse an einer Geschichte

Ein **Worktree** ist ein zweites Arbeitsverzeichnis am selben Repo, an einem
anderen Ort auf der Platte. Angelegt wird er mit `git worktree add`.

Was geteilt wird und was nicht:

| | geteilt |
|---|---|
| die Versionsgeschichte (`.git`) | **ja** — es gibt nur eine |
| die Dateien im Ordner | nein — jeder Worktree hat seinen eigenen Satz |
| der ausgecheckte Branch | nein — jeder hängt an einem eigenen |
| installierte Pakete (`node_modules`) | **nein** — und das ist eine Falle, siehe Abschnitt 20 |

Zwei Agenten in zwei Worktrees stolpern also nicht übereinander. Jeder hat seinen
eigenen Ordner mit seinen eigenen Dateien, und beide legen ihre Commits in
dasselbe Archiv.

**git lässt denselben Branch nie zweimal ausgecheckt sein.** Das ist eine harte
Regel, keine Warnung. Sie ist der Grund, warum der Integrations-Worktree in
Abschnitt 20 an gar keinem Branch hängt.

## 4 · Merge — und die zwei Arten, die man verwechselt

**Mergen** heißt: zwei auseinandergelaufene Stände wieder zusammenführen. git
vergleicht dazu beide Seiten mit ihrem letzten gemeinsamen Stand und baut daraus
einen neuen.

Es gibt zwei Arten, und in dieser Datei kommen beide vor. Sie sehen im Text
gleich aus und tun völlig Verschiedenes.

**`git merge --no-ff <branch>`** — der echte Zusammenführungs-Merge. Er nimmt die
Änderungen des Branches und legt sie über den aktuellen Stand. Das Ergebnis ist
ein neuer Commit mit zwei Vorfahren, ein **Merge-Commit**. `--no-ff` erzwingt
diesen Merge-Commit auch dann, wenn ein Vorspulen möglich wäre — damit im Archiv
sichtbar bleibt, dass hier etwas zusammengeführt wurde.

Haben beide Seiten dieselben Zeilen geändert, kann git nicht entscheiden, welche
gilt. Dann meldet es einen **Konflikt** und tut nichts.

**`git merge --ff-only <sha>`** — nur vorspulen. *Fast-forward* heißt: der
Zielcommit ist ein direkter Nachfahre des jetzigen, es gibt also gar nichts
zusammenzuführen, man muss den Zeiger nur weiterschieben. `--ff-only` sagt: tu es
**nur**, wenn das der Fall ist. Ist es das nicht, brich ab.

| | `merge --no-ff` | `merge --ff-only` |
|---|---|---|
| Was es tut | führt zwei Stände zusammen | schiebt den Zeiger weiter |
| Neuer Commit | ja, ein Merge-Commit | nein |
| Wenn es nicht geht | Konflikt | Abbruch |
| Wo im Lauf | Prüfung 1, im Wegwerf-Ordner | `publish`, im Haupt-Checkout |

Die letzte Zeile ist die wichtigste. **Der Merge-Pfad enthält zwei Befehle mit dem
Wort `merge`, und nur der zweite bewegt `main`.**

## 5 · Test, Suite, rot und grün

**Ein Test** ist ein kleines Programm, das ein anderes Programm aufruft und
behauptet, was herauskommen soll. Stimmt es, ist der Test **grün**. Stimmt es
nicht, ist er **rot** und sagt, was er stattdessen bekam.

**Eine Suite** ist die Gesamtheit aller Tests eines Projekts. „Die Suite ist grün"
heißt: jeder einzelne Test war grün. Ein einziger roter macht die ganze Suite rot.

Gestartet wird eine Suite über einen Befehl, den das Projekt festlegt — in einem
Node-Projekt üblicherweise `npm test`.

**Was eine grüne Suite beweist, und was nicht.** Sie beweist: nichts von dem, was
geprüft wird, ist kaputt. Sie beweist **nie**: das Verlangte wurde gebaut. Ein
Projekt ohne einen einzigen Test hat eine grüne Suite. Dieser Unterschied ist der
Grund für Prüfung 4 in Abschnitt 23, und er ist der wichtigste Satz in Teil I.

## 6 · Drei Sorten Datei, die alle nach „Test" klingen

Diese drei liegen in verschiedenen Ordnern, oft sogar in verschiedenen Repos, und
werden ständig verwechselt. Ab hier heißen sie in dieser Datei immer bei ihrem
eigenen Namen.

| Name | Wo | Was es ist | Wer schreibt es |
|---|---|---|---|
| **Projekt-Test** | im Zielprojekt, neben dessen Code | ein normaler Test über den Code, den ein Agent gebaut hat | der Agent |
| **Fixture** | `gates/<regel>/` im Zielprojekt | eine absichtlich **kaputte** Datei, eine pro Regel, die durchfallen *muss* | ein Generator, siehe Abschnitt 34 |
| **Orchestrator-Test** | `smithy\orchestrator\test\` | ein Test über den Orchestrator selbst | wer den Orchestrator baut |

**Der Satz, der alles ordnet: hier stehen zwei völlig getrennte Programme
nebeneinander.**

| | Der Code, den **Agenten schreiben** | Der Code des **Orchestrators** |
|---|---|---|
| Wo | im Zielprojekt | `smithy\orchestrator\src\` |
| Wer schreibt ihn | ein Claude-Agent, unbeaufsichtigt | ein Mensch mit einem Agenten |
| Geprüft durch | Projekt-Tests, Guardrails, Fixtures | Orchestrator-Tests, Proofs |
| Steht in | Teil IV und VI | Teil VII |

Wer die beiden zusammenwirft, versteht weder Teil VI noch Teil VII. Sie handeln
von verschiedenen Programmen.

## 7 · Agent, Session, Prompt — und `claude -p`

**Claude Code** ist das Programm, das du benutzt, wenn du in einem Terminal mit
Claude arbeitest. Es kann Dateien lesen und schreiben, Befehle ausführen und
git bedienen.

**Ein Prompt** ist der Text, den ein Modell zu lesen bekommt, bevor es antwortet.

**Eine Session** ist ein laufendes Gespräch mit allem, was darin bisher gesagt
wurde — dem **Kontext**. Zwei Sessions teilen keinen Kontext. Was die eine weiß,
weiß die andere nicht.

**Ein Agent** ist in dieser Datei immer: ein gestarteter Claude-Code-Prozess, der
einen Prompt und einen Worktree bekommt und dann ohne Aufsicht arbeitet. Niemand
liest mit, niemand beantwortet Rückfragen. Fertig ist er, wenn er einen Commit
gemacht hat — das ist das einzige Signal, das der Orchestrator als „erledigt"
akzeptiert.

**`claude -p "<text>"`** startet Claude Code einmalig, nicht-interaktiv: ein
Prompt rein, eine Antwort raus, Prozess beendet. Jeder solche Aufruf ist eine
**frische Session ohne geerbten Kontext**. Das ist der Grund, warum das Review in
Abschnitt 23 so gebaut ist, wie es gebaut ist.

**Sandcastle** ist die Bibliothek, die den Agenten tatsächlich startet und
überwacht. Sie kümmert sich um Worktree, Container, Sitzungsverwaltung und meldet
am Ende zurück, was passiert ist.

**Ein Rate-Limit** ist eine Obergrenze des Anbieters: so und so viel Arbeit pro
Zeitfenster. Ist das Fenster leer, geht nichts mehr, bis es sich zu einem
bekannten Zeitpunkt wieder öffnet. Der Orchestrator kann einen Lauf bis dahin
**parken** und weckt ihn selbst wieder auf.

## 8 · Die Issue-Note

**Eine Issue-Note** ist eine Markdown-Datei in Obsidian, eine pro Aufgabe. Sie hat
zwei Hälften.

Oben, zwischen zwei Zeilen aus drei Bindestrichen, steht der **Frontmatter** —
Felder in der Form `name: wert`:

```yaml
---
status: ready-to-implement
slice: vertical
priority: normal
kind: feature
---
```

Unten steht in normaler Prosa, was gebaut werden soll. Das ist der **Body**.

**Diese eine Datei ist gleichzeitig der Auftrag und das Protokoll.** Der
Orchestrator liest den Body als Aufgabenbeschreibung, und er schreibt seinen
Fortschritt in dieselbe Datei zurück — den Status oben in den Frontmatter,
Ereignisse unten als Aufzählungszeilen unter einer Überschrift `## Log`.

Es gibt kein zweites Register. Der Ordner mit den Notizen *ist* die Datenbank.

Vier Felder im Frontmatter steuern etwas, und eines davon steuert nichts:

| Feld | Werte | Wer liest es |
|---|---|---|
| `status` | acht Werte, Abschnitt 14 | alles |
| `slice` | `vertical` \| `horizontal` | die Weiche: welches Gleis, Abschnitt 15 |
| `priority` | `urgent` \| `normal` \| `low` | die Warteschlange — die einzige Ordnungsachse |
| `kind` | `feature` \| `bugfix` \| `refactor` \| `infra` \| `docs` | **niemand.** Nur Doku für Menschen |

`kind: refactor` wird gelesen und bewirkt nichts. Das ist Absicht: es beschreibt
die Arbeit für einen menschlichen Leser und darf nie zu einer zweiten
Steuerungsachse werden, die niemand mitliest.

## 9 · Slice: vertikal und horizontal

**Ein Slice** ist die Art der Arbeit, und das Feld `slice:` entscheidet, welchen
Weg eine Notiz durch den Orchestrator nimmt.

**`vertical`** heißt: ein Stück Funktion von oben bis unten. Eine neue Fähigkeit,
die durch alle Schichten geht — Eingabe, Logik, Ausgabe, Test. Solche Aufgaben
sind voneinander unabhängig, also dürfen mehrere gleichzeitig laufen.

**`horizontal`** heißt: dieselbe kleine Änderung an vielen Stellen. Ein Symbol
umbenennen, überall einen Parameter ergänzen. Solche Aufgaben fassen dieselben
Dateien an, also läuft immer nur eine.

Fehlt das Feld, gilt `vertical`.

---
---

# Teil II — Die Bauteile

Bevor irgendein Ablauf beschrieben wird: was liegt eigentlich in dem Ordner, um
den es geht.

## 10 · Der Ordner `smithy\orchestrator\`

```
smithy/orchestrator/
  src/            23 Quelldateien — das Programm selbst
  test/           33 Orchestrator-Tests
  verification/   8 Proof-Skripte (Teil VII)
  package.json    welche Befehle es gibt, welche Pakete es braucht
  start.ps1       der Start
  GATEWAY.md      wie ein fremdes Modell angebunden wird
```

Alles ist TypeScript. Nichts darin nennt einen absoluten Pfad: derselbe
Orchestrator läuft gegen ein zweites Zielprojekt, indem man **nur seine
Konfiguration** austauscht.

Die Konfiguration heißt `pipeline.config.json` und sagt ihm vier Dinge: wo die
Issue-Notes liegen, welches Repo bearbeitet wird, wie die Tests dieses Projekts
gestartet werden, und wie seine mechanischen Regeln gestartet werden.

## 11 · Die Quelldateien, jede in einem Satz

Damit später jeder Verweis auf einen Namen zeigt, den du schon gelesen hast.

**Der Kern des Ablaufs**

| Datei | Was sie tut |
|---|---|
| `main.ts` | startet alles, hört auf Dateiänderungen, hält die Zeitgeber |
| `dispatcher.ts` | entscheidet, ob eine geänderte Notiz jetzt wirklich einen Agenten startet |
| `run-gate.ts` | zählt die freien Plätze und lässt Wartende in der richtigen Reihenfolge durch |
| `runner.ts` | führt einen einzelnen Lauf: Agent starten, Ergebnis einordnen, bei Bedarf parken |
| `integrator.ts` | die vier Prüfungen und die Veröffentlichung |
| `startup-scan.ts` | beim Programmstart einmal alle Notizen durchsehen |
| `shutdown.ts` | beim Beenden keine Notiz zurücklassen, die behauptet zu laufen |

**Die Außenwelt**

| Datei | Was sie tut |
|---|---|
| `issue-store.ts` | liest und schreibt die Issue-Notes |
| `git.ts` | alle git-Befehle |
| `agent.ts` | die Naht zu Sandcastle |
| `sandcastle-agent.ts` | Sandcastle wirklich aufrufen und seine Ausgabe deuten |
| `docker.ts` | Container auflisten und abräumen |
| `provision.ts` | Pakete in einem frischen Worktree installieren |

**Die Entscheidungen, jede für sich prüfbar gehalten**

| Datei                   | Was sie tut                                                 |
| ----------------------- | ----------------------------------------------------------- |
| `isolation.ts`          | Host oder Container?                                        |
| `model-provider.ts`     | welches Modell, und über welchen Weg?                       |
| `dependencies.ts`       | ist eine Notiz durch eine andere blockiert?                 |
| `domain.ts`             | die Datenform einer Issue-Note, ohne jedes Projektwissen    |
| `config.ts`             | die Konfiguration lesen und prüfen                          |
| `operating-contract.ts` | die festen Textblöcke, die vor jedem Issue im Prompt stehen |

**Das Review**

| Datei | Was sie tut |
|---|---|
| `review.ts` | **die zentrale Datei des Reviews:** was ein Befund ist, wie das Ergebnis eines Review-Kommandos gelesen wird, wie mehrere Achsen parallel laufen |
| `review-wiring.ts` | verbindet die Konfiguration mit `review.ts` |
| `review-once.ts` | dasselbe Review von Hand auf einen beliebigen Diff loslassen |

**Das Aufräumen**

| Datei | Was sie tut |
|---|---|
| `reaper.ts` | entscheidet, welche Reste weg dürfen |

`review.ts` ist die Datei, auf die in Abschnitt 23 mehrfach verwiesen wird. Ihr
Kopfkommentar enthält den Satz, um den es dort geht.

## 12 · Ports: die Nähte, an denen man Attrappen einsetzen kann

**Ein Port ist eine schmale Schnittstelle: eine Liste von Methoden, ohne den Code,
der sie ausführt.** Im Betrieb steckt dahinter das Echte. In einem
Orchestrator-Test steckt dahinter eine **Attrappe** — ein von Hand gebautes
Objekt mit denselben Methoden, das nur festhält, dass es gerufen wurde, und
antwortet, was der Test ihm vorgibt.

Ein Beispiel macht es sofort klar. Der Port für git verlangt unter anderem eine
Methode `merge`. Der Test schreibt:

```ts
const git = { merge: async () => false, /* … */ };   // „der Merge scheitert"
```

Und prüft dann: landet die Notiz jetzt wirklich auf `conflict`, bleibt `main`
unangetastet, wird die Arbeit auf dem Branch gesichert? Kein echtes git, keine
echte Datei, Millisekunden.

Es gibt sechs Ports:

| Port | Dahinter steckt im Betrieb |
|---|---|
| `IssueStore` | der Ordner mit den Issue-Notes |
| `GitPort` | echte git-Befehle im Merge-Pfad |
| `GitHygiene` | echte git-Befehle beim Aufräumen |
| `AgentPort` | Sandcastle, das einen Agenten startet |
| `ReviewPort` | ein ganzes Review über mehrere Achsen |
| `AxisReviewPort` | eine einzelne Review-Achse |

Der Grund ist bei allen sechs derselbe: **die Entscheidungen des Orchestrators
prüfbar machen, ohne einen echten Claude-Lauf zu bezahlen.**

Und die Grenze dieses Verfahrens steht in Teil VII: eine Attrappe antwortet, was
man ihr aufschreibt. Ob die Wirklichkeit dasselbe antwortet, kann sie nicht sagen.

---
---

# Teil III — Ein Lauf von Anfang bis Ende

## 13 · Die Geschichte in acht Schritten

1. **Du schreibst eine Issue-Note.** Sie steht auf `status: draft`.
2. **Du gibst sie frei.** Der Skill `/ready-to-implement` setzt sie auf
   `ready-to-implement`. Das ist ein **hartes Gate**: nur ein Mensch schiebt eine
   Notiz über diese Schwelle.
3. **Der Orchestrator sieht die Änderung.** Ein Dateiwächter — die Bibliothek
   `chokidar` — meldet, dass sich die Datei geändert hat.
4. **Vier Wächter prüfen, ob jetzt wirklich gestartet wird** (Abschnitt 16).
5. **Der Worktree entsteht.** Frischer Ordner, frischer Branch `issue/<nummer>`,
   danach Paketinstallation. Die Notiz steht auf `provisioning`, dann `running`.
6. **Der Agent arbeitet.** Er bekommt feste Vertragstexte plus den Body deiner
   Notiz (Abschnitt 25) und schreibt Code, Projekt-Tests und Commits.
7. **Der Integrations-Worktree entsteht** — ein dritter frischer Ordner, auf dem
   aktuellen `main`. Dort laufen die vier Prüfungen (Teil IV).
8. **Ist alles grün, wandert die Arbeit nach `main`.** Die Notiz steht auf
   `merged`, und Notizen, die auf sie gewartet haben, werden geweckt.

## 14 · Die acht Zustände einer Notiz

**Nur die ersten beiden schreibt ein Mensch. Alle anderen gehören der Maschine.**

| Zustand | Bedeutung | Wer setzt ihn |
|---|---|---|
| `draft` | Aufgabe formuliert, noch nicht freigegeben | Mensch |
| `ready-to-implement` | freigegeben, wartet auf einen Platz | **Mensch** (das harte Gate) |
| `provisioning` | Worktree wird gebaut, Pakete installiert | Maschine |
| `running` | Agent arbeitet | Maschine |
| `rate_limited` | Limit erreicht, Lauf ist geparkt | Maschine |
| `merged` | in `main` | Maschine |
| `conflict` | Textkonflikt, Arbeit liegt auf dem Branch | Maschine |
| `failed` | kein Fortschritt, keine Commits | Maschine |

Setzt du eine Notiz von Hand von `failed` zurück auf `ready-to-implement`, bekommt
sie einen wirklich frischen Start. Alle Felder, die der letzte Versuch
hinterlassen hat, sind auf jedem Endzustand gelöscht — auch `routedVia`, das sich
merkt, über welchen Weg der Versuch lief. Sonst bliebe die Notiz still an eine
Straße geheftet, die niemand mehr gewählt hat.

## 15 · Zwei Gleise

Es gibt zwei getrennte Wege in die Ausführung, und das Feld `slice:` entscheidet.

| Gleis | Für | Wie viele gleichzeitig | Wie es startet |
|---|---|---|---|
| das vertikale | `slice: vertical` und fehlendes Feld | so viele, wie `concurrency` erlaubt | wenn eine Datei sich ändert |
| das horizontale | `slice: horizontal` | **genau eine**, fest verdrahtet | fragt regelmäßig nach |

Der Unterschied im Startverhalten hat einen Grund. Das vertikale Gleis reagiert
auf Ereignisse, weil eine unabhängige Aufgabe sofort loslaufen darf. Das
horizontale fragt in festen Abständen nach, weil ohnehin nur eine gleichzeitig
laufen kann — ein Ereignis mehr oder weniger ändert daran nichts.

Nur das vertikale Gleis braucht die vier Wächter des nächsten Abschnitts.

## 16 · Die vier Wächter vor dem Start

Vier Prüfungen, bevor wirklich ein Agent startet. **Jede fängt etwas, das die
anderen drei nicht sehen können.**

### Wächter 1 — Hat sich der Status wirklich bewegt?

Obsidian schreibt eine Notiz bei einer einzigen Bearbeitung mehrfach auf die
Platte. Der Dateiwächter meldet jeden dieser Schreibvorgänge.

Der Wächter vergleicht deshalb den vorigen Status mit dem jetzigen und lässt nur
durch, was sich wirklich verändert hat. Ohne ihn würde jeder Tastendruck als
Ereignis durchgehen.

### Wächter 2 — Sind die Abhängigkeiten erfüllt?

Eine Notiz darf auf eine andere zeigen: *diese Aufgabe braucht zuerst jene.*

**`merged` ist der einzige Zustand, der so eine Kante löst.** `running` ist nicht
fertig. Auf `failed` weiterzubauen hieße, einem kaputten Fundament ein zweites
Stockwerk zu geben. Und eine Kante, die auf eine Notiz zeigt, die es gar nicht
gibt, ist ein Planungsfehler — nie ein grünes Licht.

Warum das hier geprüft wird und nicht schon beim menschlichen Gate: **die Antwort
ändert sich, nachdem du freigegeben hast.** Ob eine Abhängigkeit gemergt ist, ist
eine Frage der Reihenfolge, keine Frage der Freigabe.

Eine blockierte Notiz bleibt auf `ready-to-implement` und **wartet**. Sie bekommt
einmal eine Zeile ins Log, damit Stillstand nicht wie ein Fehler aussieht.

### Wächter 3 — Läuft diese Notiz schon?

Der **Anspruch** ist eine Menge von Notiz-Nummern, die gerade in Arbeit sind. Der
ganze Mechanismus sind zwei Zeilen:

```ts
if (this.inFlight.has(issue.id)) return;
this.inFlight.add(issue.id);
```

**„Synchron gesetzt" heißt: zwischen diesen beiden Zeilen steht kein `await`.**

Das braucht eine Erklärung. JavaScript läuft in einem einzigen Faden. Ein `await`
bedeutet: *hier gebe ich die Kontrolle ab und mache später weiter* — und in der
Zwischenzeit darf anderer Code laufen. Solange zwischen Prüfen und Setzen kein
`await` steht, sind die zwei Zeilen eine ununterbrechbare Einheit.

Der Fall, gegen den das gebaut ist: Obsidian speichert zweimal, der Dateiwächter
feuert zweimal, und `main.ts` reicht beide Ereignisse weiter, **ohne** auf das
erste zu warten. Beide sind wirklich gleichzeitig unterwegs.

Stünde ein `await` vor dem Anspruch, liefe es so: Aufruf A prüft, findet nichts,
wartet. Aufruf B prüft, findet immer noch nichts, wartet. Beide setzen den
Anspruch. Zwei Agenten auf einem Worktree.

Deshalb ist auch der Abhängigkeits-Check aus Wächter 2 bewusst eine synchrone
Funktion: er darf vor dem Anspruch stehen, weil er nicht wartet.

Der Anspruch wird über das Warten in der Schlange hinweg gehalten. Ein doppeltes
Ereignis auf eine Notiz, die schon wartet, wird verworfen — nicht dahinter
aufgetürmt.

### Wächter 4 — Ist ein Platz frei?

Den Fall sieht keiner der ersten drei: zwei Ereignisse auf **zwei verschiedenen**
Notizen.

Die Schlange zählt die Plätze und ordnet die Wartenden nach einer nackten
Rangzahl, niedriger zuerst. Diese Zahl kommt aus `priority`. Bei Gleichstand
gewinnt strikt der frühere:

> **Priorität bricht Gleichstände. Sie mischt Gleiche nicht neu.**

Bei einem einzigen Platz ergibt das automatisch die Reihenfolge des Eintreffens.

### Und der fünfte Weg hinein: die Nachprüfung

Landet Notiz A in `main`, schreibt **niemand** in Notiz B, die auf A gewartet hat.
Ihre Datei ändert sich nicht, der Dateiwächter feuert nicht, B säße für immer auf
`ready-to-implement`.

Nach jedem Merge läuft deshalb einmal eine Nachprüfung über alle Wartenden. Es
gibt sie nur auf dem vertikalen Gleis — das horizontale fragt ohnehin regelmäßig
nach.

## 17 · Die sechs Grenzen

Sechs Zahlen begrenzen einen Lauf, und drei Paare davon sehen auf den ersten
Blick gleich aus.

| Grenze | Zählt was | Default |
|---|---|---|
| `maxIterations` | Sandcastles **eigene** Wiederholschleife | **1** |
| `maxVerifyAttempts` | rote Integrations-Suite | 3 |
| `maxRetries` | Versuche **ohne jeden Fortschritt** | 3 |
| `idleTimeoutSeconds` | Agent sagt nichts mehr | 300 |
| `maxRunSeconds` | Wanduhr, egal wie gesprächig | 3600 |
| `maxResumeDelaySeconds` | wie weit ein Park in die Zukunft reichen darf | 6 h |

**Die erste gegen die zweite.** Sandcastle hat eine eigene Wiederholschleife. Sie
entscheidet, ob ein Agent noch einmal loslegt, indem sie in seiner **Prosa** nach
einer Zeichenfolge sucht. Kein Test, keine git-Abfrage — sie liest einen Satz.
Deshalb steht sie auf 1: sie läuft genau einmal und entscheidet nichts.

Die *informierte* Wiederholung ist `maxVerifyAttempts`. Sie fragt eine echte Suite
auf dem aktuellen `main`, und jeder neue Versuch bekommt die Fehlerausgabe des
letzten in seinen Prompt. Das ist der Unterschied zwischen „noch mal probieren"
und „noch mal probieren, und diesmal weißt du warum".

**Die dritte gegen die zweite.** Ein Lauf, der ins Rate-Limit lief und geparkt
wurde, hat nichts falsch gemacht. Er darf nicht das Budget aufessen, das ein
echter fehlschlagender Test braucht. Also zwei getrennte Zähler.

**Die vierte gegen die fünfte.** `idleTimeoutSeconds` tötet einen **stummen**
Agenten — einen, der seit fünf Minuten nichts mehr sagt. Einen geschwätzigen, der
endlos im Kreis redet, begrenzt sie nicht. Dafür ist die Wanduhr da.

---
---

# Teil IV — Die vier Prüfungen zwischen Agent und `main`

Das ist das Herzstück.

## 18 · Der Überblick

Vier Prüfungen, feste Reihenfolge, alle im selben frischen Ordner. **Keine kann
für eine andere einspringen** — jede beantwortet eine andere Frage.

| # | Prüfung | Die Frage | Bei Rot |
|---|---|---|---|
| 1 | `git merge --no-ff` | Passt der Text überhaupt auf das heutige `main`? | **Mensch.** Kein neuer Versuch |
| 2 | die Suite | Läuft es? | zurück an den Agenten, mit der Fehlerausgabe |
| 3 | die Guardrails | Bricht es eine mechanische Regel? | dasselbe |
| 4 | das Review | Tut es, was verlangt war? | **nichts.** Es berichtet nur |

Danach, und nur danach, kommt `publish` — der einzige Schritt, der `main` bewegt.

Merk dir die Reihenfolge, weil sie oft falsch erinnert wird:

```
merge  →  Suite  →  Guardrails  →  Review  →  publish
```

Der Merge steht **vorn**. Prüfung 2 und 3 prüfen ein Ergebnis, das schon
zusammengeführt ist — aber noch nirgends liegt.

## 19 · Prüfung 1 — passt es textuell?

Der Branch des Agenten wird mit `git merge --no-ff` in den Integrations-Worktree
gemergt. Gibt es einen Konflikt, wird der Merge abgebrochen und die Notiz landet
auf `conflict`.

**Warum das als einziges nicht an den Agenten zurückgeht.** Ein Textkonflikt
heißt: jemand anders hat dieselben Zeilen geändert, während unser Agent
arbeitete. Der Agent sitzt in seinem eigenen Worktree und **sieht die andere Seite
gar nicht.** Ihn das lösen zu lassen wäre, ihn raten zu lassen.

Also: die Arbeit wird auf dem Branch gesichert, der Worktree abgeräumt, `main`
nicht angefasst, und du entscheidest.

Die Sicherung ist wörtlich gemeint. Alles, was noch nicht committet war, wird als
Commit mit dem Präfix `wip:` auf den Branch gelegt. Danach ist der Worktree sauber
und darf verschwinden — der Branch trägt alles, und `git log <branch>` ist das
Beweismaterial. Kilobytes statt eines kompletten Paketordners.

**Eine Ausnahme, und sie ist das ganze Sicherheitsargument:** lässt sich die
Arbeit nicht auf den Branch sichern, bleibt der Worktree stehen. Er ist dann die
einzige Kopie. Die Arbeit eines Agenten zu verlieren ist schlimmer als eine volle
Festplatte.

## 20 · Warum es einen dritten, frischen Worktree braucht

Der Integrations-Worktree ist der dritte Ordner im Spiel:

| Ordner | Steht auf | Wer arbeitet darin |
|---|---|---|
| Haupt-Checkout | `main` | niemand; er ist das Ziel |
| Worktree des Agenten | `issue/<nummer>` | der Agent |
| Integrations-Worktree | **keinem Branch** | die vier Prüfungen |

**Warum an keinem Branch.** Er wird mit `git worktree add --detach` angelegt —
*losgelöst*, also direkt auf einen Commit gesetzt statt auf einen Branch. Hätte er
`main` ausgecheckt, wäre `main` zweimal ausgecheckt, und das verbietet git
(Abschnitt 3). Losgelöst kollidiert er mit nichts.

**Warum es ihn überhaupt gibt.** Ein Merge kann textuell sauber sein und das
Programm trotzdem kaputtmachen. Beispiel: `main` hat eine Funktion umbenannt, dein
Agent hat eine neue Stelle geschrieben, die den alten Namen ruft. Zwei
verschiedene Zeilen, kein Textkonflikt, kaputtes Programm.

Genau das fängt dieser Ordner. Ohne ihn wäre die Zusage *„läuft ohne menschlichen
Schritt bis `main`"* eine Drohung.

**Und warum darin die Pakete installiert werden.** Worktrees teilen die
Versionsgeschichte, aber nicht den Ordner `node_modules` (Abschnitt 3). In jedem
frischen Worktree läuft deshalb erst eine Paketinstallation.

Ohne sie wird die Suite nicht etwa rot, sondern **grün** — und das ist der
schlimmere Fall. Node sucht Pakete auch in den übergeordneten Ordnern. Liegt dort
ein fremdes `node_modules`, laufen die Tests gegen Pakete aus einem völlig anderen
Projekt und melden Erfolg. Die Suite, die `main` bewachen soll, wäre dann keine
Aussage mehr über das Projekt.

## 21 · Prüfung 2 — läuft es?

Im Integrations-Worktree wird der Testbefehl des Projekts gestartet, in der
Konfiguration `testCommand`, Voreinstellung `npm test`.

**Welche Tests laufen da?** Alle Projekt-Tests. Die, die der Agent gerade
geschrieben hat, und jeder einzelne aus allen früheren Aufgaben. Das ist der
Punkt: die neuen prüfen die neue Funktion, die alten fangen, was die neue
kaputtgemacht hat.

Der Agent hat dieselbe Suite in seinem eigenen Worktree schon laufen lassen. Das
hier ist der zweite Lauf, an einem anderen Ort und auf einem anderen Stand —
nämlich nach dem Merge mit dem heutigen `main`. Genau dort tauchen die Fehler auf,
die im Worktree des Agenten gar nicht existieren konnten.

**Bei Rot geht die Arbeit zurück an den Agenten.** Anders als beim Textkonflikt
kann er damit etwas anfangen: er hat die Namen der gescheiterten Tests und deren
Ausgabe, und der Code, der sie erzeugt, ist sein eigener. Die Arbeit wird auf dem
Branch gesichert, die Fehlerausgabe wandert in den nächsten Prompt, und der
nächste Versuch baut darauf auf statt neu anzufangen. Gedeckelt durch
`maxVerifyAttempts`.

## 22 · Prüfung 3 — bricht es eine mechanische Regel?

Danach, auf demselben Ergebnis, laufen die **Guardrails** — mechanische Regeln
über den Code. Was das genau ist und woher sie kommen, steht in Teil VI; hier
zählt nur ihre Stellung im Ablauf.

Gestartet werden sie über `checkCommand` aus der Konfiguration. Ist der leer, wird
diese Prüfung **übersprungen** — nicht bestanden. Ein Projekt ohne Guardrails hat
sie nicht *bestanden*, es hat keine.

**Warum die Suite zuerst läuft.** Ein Projekt, dessen Tests nicht durchlaufen, hat
ein größeres Problem als seinen Lint. Liefe beides gleichzeitig, begrübe der
zweite Fehler den ersten.

**Warum die Guardrails hier laufen und nicht in der CI.** Die CI — die Prüfung,
die ein Server nach dem Hochladen fährt — läuft **nach** dem Push. Eine Verletzung,
die dort auffällt, liegt schon auf `main` und wird hinterher gemeldet. Ein
Guardrail ist aber definiert als eine Regel, die hält, wenn niemand zusieht. Also
muss sie entscheiden, **bevor** `main` sich bewegt.

Die CI im Zielprojekt bleibt trotzdem nützlich, als zweites Netz für Menschen, die
von Hand pushen.

Eine gebrochene Regel wird behandelt wie eine rote Suite: zurück an den Agenten,
mit der Ausgabe. Er bekommt die Regel und die Datei genannt, und das ist etwas,
womit er arbeiten kann.

## 23 · Prüfung 4 — tut es, was verlangt war?

### Warum es diese Prüfung gibt

Der Kopfkommentar von `src/review.ts` — der Datei, die das Review steuert
(Abschnitt 11) — enthält den Satz, um den es hier geht. Sinngemäß:

> **Von den drei Prüfungen davor ist die Suite die, bei der man unruhig sein
> sollte.**

Der Grund: **die Projekt-Tests hat derselbe Agent geschrieben, der den Code
geschrieben hat.**

Stell dir vor, der Agent hat die Aufgabe falsch verstanden. Er baut, was er sich
vorgestellt hat. Dann schreibt er Tests — und die prüfen natürlich das, was er
sich vorgestellt hat. Sie sind grün. Der Merge ist sauber, die Guardrails greifen
nicht, weil der Code sauber geschrieben ist.

**Von unten sieht ein falsch verstandenes Issue exakt aus wie Erfolg.**

Prüfung 1 kann das nicht sehen: sie prüft Text. Prüfung 2 kann es nicht sehen:
sie fragt Tests, die aus derselben Quelle stammen wie der Fehler. Prüfung 3 kann
es nicht sehen: sie prüft die Form des Codes, nicht seinen Zweck.

Deshalb gibt es eine vierte, und sie misst gegen den **Body der Issue-Note** — den
einzigen Text im ganzen Lauf, den der Agent nicht selbst geschrieben hat.

### Warum ein zuerst roter Test das nicht löst

Der Prompt verlangt vom Agenten, den Test **zuerst** zu schreiben und ihn einmal
rot zu sehen (Abschnitt 25). Das ist richtig und hilft — aber gegen diesen
speziellen Fehler hilft es nicht.

Ein roter Test beweist: *dieser Test prüft etwas, das es noch nicht gibt.* Er
beweist nicht: *dieser Test prüft das Richtige.*

Bei einem falsch verstandenen Issue ist der Test zuerst rot für das vorgestellte
Verhalten und danach grün für das vorgestellte Verhalten. Beide Farben stimmen.
Beide sind an der Aufgabe vorbei.

### Wie das Review gebaut ist

Prüfung 4 ist nicht *ein* Review, sondern mehrere gleichzeitige.

**Eine Achse ist ein Name plus eine Quelle für Standards.** Der Name sagt, worauf
geschaut wird. Die Quelle sagt, wogegen gemessen wird. Beide Hälften gehören dem
Projekt, nicht dem Orchestrator: welche Achsen gefahren werden, steht in der
Konfiguration — genau wie der Testbefehl. Der Orchestrator kennt keine feste
Liste.

Sechs Namen sind vorgesehen. Sie stehen hier vollständig, auch die, für die es
noch keinen Maßstab gibt — sonst versteht man nicht, was eine Achse überhaupt
ist:

| Achse | Woher der Maßstab kommt |
|---|---|
| `spec` | **der Body der Issue-Note.** Reserviert: der Orchestrator liefert die Quelle selbst, und die Achse wird immer zuerst gedruckt |
| `correctness` | eine Liste bekannter Code-Schwächen, im Review-Skript eingebaut |
| `design` | `REVIEW-STANDARDS.md` — die Datei aus Abschnitt 31 |
| `security` | **vorgesehen**, Maßstab noch offen |
| `performance` | **vorgesehen**, Maßstab noch offen |
| `accessibility` | **vorgesehen**, Maßstab noch offen |

Die letzten drei sind keine vergessenen Zeilen, sondern leere Plätze. Eine Achse
ohne Maßstab wird übersprungen und meldet das — sie erfindet keine Meinung im
Gewand einer Messung. Welche der sechs heute wirklich etwas findet, steht in
[[orchestrator-map]].

`spec` ist die einzige Achse, der `review.ts` eine eigene Bedeutung gibt. Der
Grund steht oben in diesem Abschnitt: sie ist die, die nichts anderes in dieser
Maschine abdeckt.

**Jede Achse ist ein eigener `claude -p`-Aufruf**, also eine frische Session ohne
geerbten Kontext (Abschnitt 7). Das ist der Kern der Konstruktion: eine Achse kann
nicht von der anderen verdrängt werden, weil sie sich keinen Kontext teilen. Ein
Skill könnte das nicht leisten — der läuft in derselben Session, die ihn aufrief.

### Der Deckel auf den gleichzeitigen Aufrufen

Die Zahl der gleichzeitigen Aufrufe ist gedeckelt, in der Konfiguration
`reviewConcurrency`, Voreinstellung 2. Der Code startet so viele Arbeiter, die
sich die Achsen der Reihe nach abholen:

```ts
const workers = Math.max(1, Math.min(this.concurrency, briefs.length));
```

Zwei Dinge stehen in dieser Zeile: nie mehr Arbeiter als Achsen, und nie weniger
als einer. **Bei `reviewConcurrency: 1` ist es also wirklich seriell** — eine
Achse nach der anderen, dasselbe Ergebnis, nur langsamer.

**Der Deckel ist keine Geschwindigkeitsfrage.** Jeder `claude -p`-Aufruf zieht am
selben Rate-Limit-Fenster desselben Kontos. Fünf gleichzeitig sind fünf gegen ein
Budget. Und was über das Limit läuft, wird nicht eingereiht — es scheitert.

Die Rechnung ist deshalb schief:

- **Gedeckelt:** das Review dauert länger. Es sitzt in einem Pfad, der schon einen
  Merge, eine volle Suite und die Guardrails hinter sich hat. Ein paar Minuten
  fallen dort nicht auf.
- **Ungedeckelt:** einige Achsen sterben. Und dieses Review ist der **einzige**
  Blick auf diesen Diff — danach wandert er nach `main` und niemand sieht ihn
  wieder an.

Ungedeckelt ist damit schlechter als seriell. Seriell dauert am längsten, liefert
aber jede Achse.

### Was ein Review-Kommando bekommt und zurückgibt

Das Kommando ist ein gewöhnliches Skript. Der Orchestrator weiß nicht, dass
dahinter Claude steckt — er startet es so, wie er auch den Testbefehl startet.
Die Aufgabe kommt über Umgebungsvariablen:

| Variable | Inhalt |
|---|---|
| `REVIEW_ISSUE_ID` | welche Notiz |
| `REVIEW_BRANCH` | welcher Branch |
| `REVIEW_AXIS` | welche Achse |
| `REVIEW_SPEC` | der Body der Notiz |
| `REVIEW_DIFF_BASE` | wogegen zu vergleichen ist |
| `REVIEW_STANDARDS` | der Standardtext, falls die Achse einen hat |

Zurück kommt JSON auf der Standardausgabe, in einer von zwei Formen:

```json
{"findings":[{"text":"…"}]}
{"skipped":"warum diese Achse nicht geprüft werden konnte"}
```

**Der Exit-Code wird absichtlich ignoriert.** Etwas zu finden ist kein Fehlschlag,
und ein Kommandozeilenprogramm beendet sich aus allerlei Gründen ungleich Null.
Die Ausgabe ist der Vertrag.

**Alles, was nicht sauber gelesen werden kann, wird `skipped`** — nie ein Befund,
nie ein Absturz. Das ist die eine Stelle, an der sich diese Datei etwas
verweigert: ein kaputtes Review ist *Nichtwissen*, und es als „nichts gefunden" zu
melden wäre von einem wirklich sauberen Diff nicht zu unterscheiden.

Und `skipped` gilt **pro Achse**, nicht für das ganze Review. Vier gesunde Achsen
würden eine tote sonst unsichtbar machen.

### Wohin das Ergebnis geht

**In dieselbe Issue-Note.** Nicht in ein eigenes Dokument, nicht in einen
Kommentar irgendwo, nicht in eine Datenbank.

Das Ergebnis wird vorher in Zeilen übersetzt und als Aufzählung unter die
Überschrift `## Log` gehängt:

```
reviewed before merge — 2 finding(s) across 2 of 3 axis/axes:
  [spec] Das Abbruchkriterium „leere Eingabe liefert eine leere Liste" ist nicht abgedeckt.
  [correctness] reviewed, no findings
  [design] DID NOT RUN — kein Standardtext für diese Achse
```

Die Kopfzeile zählt, wie viele Achsen **geantwortet** haben — `2 of 3`. Genau
deshalb steht die Zahl da: damit eine tote Achse sichtbar bleibt.

### Warum es nichts blockiert

Prüfung 2 und 3 sind mechanisch: ein Testname, eine Regel, eine Datei. Prüfung 4
ist ein **Urteil** eines anderen Modells.

Ein Urteil, das einen sauberen Lauf stoppen kann, ist ein Urteil, das man bald
abschalten wird — beim ersten Mal, wo es danebenlag und eine fertige Arbeit
liegenblieb. Also berichtet es und stoppt nichts.

Aus demselben Grund sitzt der Auffangblock für einen abstürzenden Reviewer tief:
ein abgestürztes Review darf keine Arbeit als nicht mergebar ablegen, die einen
sauberen Merge und eine grüne Suite hatte.

## 24 · `publish` — der einzige Schritt, der `main` bewegt

Alles davor spielte sich in Wegwerf-Ordnern ab. Erst hier bewegt sich etwas
Bleibendes.

Zwei Befehle:

```
git rev-parse HEAD          # im Integrations-Worktree: welche SHA ist das Ergebnis?
git merge --ff-only <sha>   # im Haupt-Checkout: spul main genau dorthin vor
```

Der erste fragt: welchen Commit hat der Integrations-Worktree jetzt? Das ist der
Merge-Commit aus Prüfung 1, geprüft von Prüfung 2 bis 4. Der zweite spult `main`
genau dorthin vor.

**Warum nicht die naheliegende Abkürzung `git branch -f main <sha>`**, also „setz
den Zeiger einfach dorthin"? Zwei Gründe.

**Der erste ist eine Weigerung von git:**

> fatal: cannot force update the branch 'master' used by worktree at …

Ein Branch, der irgendwo ausgecheckt ist, lässt sich nicht zwangsbewegen. Und
`main` ist immer ausgecheckt (Abschnitt 2). Die Abkürzung scheitert also immer,
nicht manchmal.

**Der zweite ist, warum git sich weigert.** `branch -f` bewegt nur den Zeiger,
nicht die Dateien. Danach behauptet git „du bist auf `main`, und `main` ist Commit
Z" — aber im Ordner liegen die Dateien von Commit Y. Jede Datei, die sich zwischen
Y und Z unterscheidet, erschiene ab sofort als eine Änderung, die *du* gemacht
hast.

| Befehl | bewegt den Zeiger | bewegt die Dateien | bei fremden Änderungen im Ordner |
|---|---|---|---|
| `git branch -f main <sha>` | ja | **nein** | verweigert, weil ausgecheckt |
| `git merge --ff-only <sha>` | ja | **ja** | bricht ab, überschreibt nichts |

Die letzte Spalte ist ein zusätzlicher Gewinn: hat ein Mensch im Haupt-Checkout
ungesicherte Änderungen liegen, bricht `--ff-only` ab, statt sie zu überschreiben.

### Was danach passiert

Die Notiz geht auf `merged`. Alle Felder, die den Lauf beschrieben — der
Worktree-Pfad, die letzte Fehlerausgabe, der Zähler der Versuche, der Weg über
den das Modell erreicht wurde — werden **gelöscht**, nicht bloß liegengelassen.
Eine gemergte Notiz, die noch „diese Tests sind gescheitert" trägt, schickt den
nächsten Leser hinter einem Fehler her, der längst behoben ist.

Der Worktree des Agenten wird abgeräumt. Und die Nachprüfung aus Abschnitt 16
läuft einmal über alle Wartenden.

### Warum das Ganze seriell bleibt

Es gibt **keine Merge-Warteschlange** und **kein Rebase** — das Wort kommt in
keiner Quelldatei vor.

Was es gibt, ist die Schlange aus Wächter 4, und die reiht **Starts** ein, keine
Merges. Der Merge wird nur als Folge davon seriell: die Prüfungen laufen innerhalb
des Laufs, der den Platz hält. Bei einem Platz kann nichts überlappen.

Bei mehreren Plätzen kann es überlappen, und dann greift keine Warteschlange,
sondern `--ff-only`: Lauf A publiziert zuerst, `main` bewegt sich, das Ergebnis von
Lauf B ist kein direkter Nachfahre mehr, der Befehl bricht ab und die Notiz landet
auf `conflict`. Der Zweite wird ein Fall für dich.

---
---

# Teil V — Was der Agent bekommt und wo er läuft

## 25 · Der Prompt

Vor dem Body deiner Notiz stehen feste Textblöcke. **Dein Text steht zuletzt**,
damit die eigentliche Aufgabe die frischeste Information im Prompt ist.

Sie stehen als Konstanten in `src/operating-contract.ts` — im Code, nicht in der
Konfiguration, weil sie beschreiben, wie *dieser* Orchestrator arbeitet, und nicht,
was ein Projekt will.

| Block | Wann | Was er sagt |
|---|---|---|
| Vertrag | immer | drei Fakten, siehe unten |
| Arbeitsweise | immer | Rot → Grün → Prüfen → Commit |
| Vorarbeit | wenn der Branch schon Commits trägt | „hier liegt schon etwas, bau darauf auf" |
| Fehlerausgabe | nach roter Suite oder gebrochener Regel | die Ausgabe des letzten Versuchs |

**Der Vertrag** enthält drei Sätze, weil drei Dinge fehlten:

1. Du arbeitest unbeaufsichtigt. Niemand liest mit, niemand beantwortet
   Rückfragen — entscheide selbst.
2. Diese Pipeline erkennt „fertig" an genau **einem** Signal: einem git-Commit.
   Ohne Commit gilt der Lauf als gescheitert, auch wenn der Code im Worktree
   korrekt ist.
3. Bitte niemanden um Erlaubnis zum Committen. Es ist niemand da, der sie geben
   könnte.

**Die Arbeitsweise** verlangt vier Schritte:

1. **ROT.** Schreibe zuerst den Test, der das geforderte Verhalten beschreibt, und
   führe ihn aus. Er *muss* fehlschlagen — der Code existiert ja noch nicht. Läuft
   er sofort grün, prüft er nicht, was er prüfen soll.
2. **GRÜN.** Dann der minimal nötige Code, damit genau dieser Test besteht.
3. **PRÜFEN.** Der neue Test **und** die volle Suite — letztere fängt
   Regressionen, die der neue Test nicht sieht.
4. Erst wenn beides grün ist: committen.

Dazu der Satz *„Schwäche keinen Test ab, um ihn grün zu bekommen."*

Warum das kein Stilthema ist: eine grüne Suite beweist „nichts ist kaputt", nie
„das Verlangte wurde gebaut" (Abschnitt 5). Ein zuerst geschriebener, einmal rot
gesehener Test ist das billigste Ding, das diese Lücke schließt — der rote Lauf
ist der Beweis, dass der Test das neue Verhalten überhaupt anfasst.

Diese vier Schritte laufen im Worktree des Agenten. Aus dem Ordner verlässt nur
der Commit.

**Die Vorarbeit** ist für den Fall gedacht, dass ein Lauf ohne sein Gedächtnis neu
startet. Das ist im Container real: ein Rate-Limit schlägt zu, und das Protokoll
der Sitzung verlässt den Container nicht. Code und Commits überleben — die
Erinnerung daran nicht. Ohne diesen Block könnte der neu gestartete Agent einen
halbfertigen Branch nicht von einem leeren unterscheiden.

## 26 · Host oder Container

Zwei Möglichkeiten, wo ein Agent laufen kann.

**Auf dem Host** heißt: direkt auf deinem Rechner, mit Zugriff auf deine
Festplatte.

**Im Container** heißt: in einer abgeschotteten Docker-Kiste. Der Agent sieht nur
seinen Worktree, der als Ordner hineingereicht wird.

Entschieden wird in dieser Reihenfolge:

1. **Steht `isolation:` im Kopf der Notiz?** Dann gilt das. Steht dort ein Wert,
   den es nicht gibt, **bricht der Lauf ab.** Wer sich beim Wort für Isolation
   vertippt, will Isolation. Als Schweigen gelesen liefe er auf dem Host, also
   genau falsch herum.
2. **Ist der Lauf geroutet?** Läuft er also über ein fremdes Modell statt direkt
   über Anthropic? Dann **immer** Container. Steht in der Notiz gleichzeitig
   `isolation: host`, bricht es ab — beide Lesarten sind vertretbar, also wird
   keine still gewählt.
3. **Steht etwas Gefährliches in der Prosa?** Suchmuster erkennen Signale wie
   „braucht einen Dienst", „plattformabhängig", „zerstörerisch".
4. **Sonst: Host.**

Fällt die Entscheidung auf Container und es fehlt ein Zugangstoken, bricht es ab.
Kein Rückfall auf den Host.

**Die Grenze von Schritt 3 steht in der Datei selbst:** er sucht in Text, den ein
Mensch zufällig so formuliert hat. Das ist ein Auffangnetz, keine Garantie. Genau
deshalb wird `isolation:` **zuerst** geprüft — wer Isolation braucht, schreibt sie
hin.

### Warum ein gerouteter Lauf zwingend in den Container muss

Claude Code fragt vor jedem Shell-Befehl ein zweites Modell, ob der Befehl sicher
ist. Läuft alles über ein Gateway, antwortet darauf irgendein fremdes Modell.

Auf dem Host ist dieser Prüfer **das Einzige** zwischen Agent und Festplatte. Und
die beiden Fehlerrichtungen kosten nicht gleich viel: etwas Harmloses zu blockieren
kostet einen Lauf. Etwas Zerstörerisches durchzulassen kostet die Maschine.

**Was der Container nicht kauft:** er schützt deinen Rechner, nicht das Projekt.
Der Agent schreibt weiter in seinen Worktree und committet. Die Schranke vor `main`
bleibt die aus Teil IV.

### Wunsch und Tatsache stehen nie im selben Feld

Dieselbe Konstruktion an drei Stellen:

| Wunsch (schreibt ein Mensch) | Tatsache (schreibt die Maschine) |
|---|---|
| `isolation` | `mode` |
| `model` | `respondingModel` |
| `useGateway` | `routedVia` |

Gäbe es nur ein Feld, käme `mode: host` eines abgeschlossenen Laufs beim nächsten
Lesen als menschliche Vorgabe zurück — und würde die Entscheidung für immer
einfrieren.

## 27 · Modell-Routing

Claude Code spricht die Anthropic-Schnittstelle und sonst nichts. Das volle
Werkzeug-Schema und mehrere spezielle Kopfzeilen gehen bei jeder Anfrage raus, und
keine Einstellung bewegt daran ein Feld.

Ein fremdes Modell kann so eine Anfrage nicht roh entgegennehmen. Also muss ein
**Gateway** dazwischen übersetzen — ein Vermittler, der die Anfrage in die Sprache
des anderen Anbieters übersetzt und die Antwort zurück.

Wo diese Naht sitzt, war keine Geschmacksfrage: die Optionen, die Sandcastle
anbietet, haben kein Feld für eine Adresse. Sie haben `env`. Also läuft die
Umleitung über Umgebungsvariablen.

**Der Schalter ist mit Absicht manuell.** Ein automatischer Wechsel bei Rate-Limit
brächte nichts: die geparkte Sitzung liegt bei Anthropic, und fortsetzen lässt sie
sich nur dort. **Anbieterwechsel ist ein Neustart, kein Fortsetzen.**

## 28 · Der Reaper

Ein Aufräumer, der regelmäßig Reste einsammelt.

| Was | Regel |
|---|---|
| Worktrees | **nie** einen, dessen Notiz `provisioning`, `running` oder `rate_limited` ist |
| Branches | `issue/*`, verwaist, nach **7 Tagen** — Beweismaterial bekommt eine Woche |
| Container | erkannt am **Mount-Pfad**, weil der Name keine Notiz-Nummer trägt |
| `safe.directory`-Einträge | **global**, nicht im Repo — dort sammeln sie sich an, einer pro Worktree |

Der Job ist kleiner, als er aussieht, weil der Fehlerpfad das Beweismaterial schon
vom Worktree auf den Branch verschoben hat (Abschnitt 19).

**Er beginnt im Trockenlauf.** Beim ersten Lauf sagt er nur, was er löschen
*würde*. Ein Aufräumer, der ungefragt sofort löscht, ist genau der übereifrige
Aufräumer, vor dem zu warnen wäre. Einen Zyklus zuschauen, dann scharf schalten.

Und alles, was er nicht als Müll **beweisen** kann, lässt er stehen. Ist ein
Container-Mount unlesbar, gilt er als unbewiesen und bleibt.

---
---

# Teil VI — Die Regeln über den Code, den Agenten schreiben

Dieser Teil handelt vom **Zielprojekt**, nicht vom Orchestrator (Abschnitt 6).

## 29 · Was ein Guardrail ist

**Ein Guardrail ist eine Regel über den Code, die eine Maschine bei jedem Commit
entscheidet, ohne dass jemand zusieht.**

Ein Beispiel, das es wirklich gibt: *im Domänen-Ordner steht kein `throw`.*

Der Unterschied zu allem, was sonst „Regel" heißt: ein Guardrail wartet auf
niemanden. Eine Regel, die ein Mensch auslegen muss, ist kein Guardrail — sie
gehört in den Text, den das Review gereicht bekommt (Abschnitt 23).

Genau das macht Guardrails für eine unbeaufsichtigte Pipeline wichtig: sie ist per
Definition die Lage, in der niemand zusieht.

## 30 · Wann entschieden wird, welche gelten

**Einmal pro Projekt.** Nicht pro Aufgabe, nicht pro Lauf.

Der Ort ist ein Schritt in smithys Einrichtungs-Skill, `/baseline` Step 3a. Er geht
eine Speisekarte durch: `smithy\forge\GUARDRAILS.md`, 25 Zeilen, jede eine Regel.

**Keine dieser 25 Zeilen nennt ein Werkzeug.** Das ist Absicht. Die Datei liegt im
Plugin und wird beim nächsten Update komplett ersetzt; ein Werkzeugname mit
Version wäre darin sofort veraltet. Eine Zeile sagt deshalb, *was entschieden
werden muss* — nie, *was es entscheidet*.

Pro Zeile drei Handgriffe:

1. **Ein Werkzeug finden.** Über die Stufen in `LEGWORK.md`: Stufe 1 die
   `llms.txt` der Werkzeug-Doku, Stufe 2 ein Recherche-Skill, Stufe 3
   Papersuche, Stufe 4 Video, Stufe 5 den Quelltext des Pakets lesen. Man arbeitet
   sich hoch, bis eine Antwort trägt. Das Ergebnis gilt als **Annahme**.
2. **In `STACK.md` festnageln**, mit der Version, die das Projekt wirklich fährt.
3. **Mit einer kaputten Datei beweisen.** Die kleinste Datei schreiben, die die
   Regel *bricht*, das Werkzeug darüber laufen lassen, und darauf bestehen, dass es
   meckert.

Erst Schritt 3 macht aus der Annahme eine Tatsache. **Eine Zeile, die Schritt 3
nicht besteht, wird nicht installiert.**

Der Katalog sortiert seine Zeilen außerdem in drei Klassen:

- **`checked`** — ganz mechanisch entscheidbar.
- **`partial`** — nur zur Hälfte. Die andere Hälfte wird ausformuliert und wandert
  in `REVIEW-STANDARDS.md`, wo das Review sie als Maßstab bekommt.
- **`judgment`** — gar nicht mechanisch. Landet vollständig in
  `REVIEW-STANDARDS.md`.

Eine `partial`-Zeile, die nicht sagt, welche Hälfte ungeprüft ist, wäre schlimmer
als eine fehlende Zeile — sie liest sich als erledigt. Jede benennt deshalb ihre
eigene Lücke.

## 31 · Wo welches Stück liegt

Fünf Stücke an fünf Orten, weil sie **verschieden schnell altern**.

| Stück | Datei | Ebene | Altert wodurch |
|---|---|---|---|
| **Regel** | `smithy\forge\GUARDRAILS.md` | im Plugin | gar nicht — sie nennt kein Werkzeug |
| **Bindung** | `STACK.md` | pipeline-weit | Werkzeug-Versionen |
| **Beweis** | `gates/<regel>/` | im Zielprojekt | läuft in der CI bei jedem Commit |
| **Quittung** | `GUARDRAILS-INSTALLED.md` | im Zielprojekt | ein Mensch liest sie |
| **Auftrag** | `REVIEW-STANDARDS.md` | pipeline-weit | eine Maschine reicht ihn weiter |

Die letzten beiden verwechselt man leicht, obwohl beide aus demselben Katalog
gespeist werden:

| | `GUARDRAILS-INSTALLED.md` | `REVIEW-STANDARDS.md` |
|---|---|---|
| Was es ist | eine **Quittung** | ein **Auftrag** |
| Inhalt | was eine Maschine entscheidet, womit, seit wann bewiesen | der Text, den eine Review-Achse als Maßstab bekommt |
| Wer liest es | ein Mensch | eine Maschine, die ihn weitergibt |

Die Quittung hat sechs Spalten:

```
| Guardrail | Machine | Class | Bindung | Fixture | Bewiesen am |
```

Ihr eigener Kopf sagt, worauf es ankommt: *„Eine Zeile ohne Fixture ist keine
geltende Regel."* **Die Spalte „Bewiesen am" ist die einzige, die zählt.**

### Wo das Werkzeug selbst liegt

Drei verschiedene Dinge, die man hier zusammenwirft:

**Das Werkzeug** — eslint, tsc, dependency-cruiser — liegt im Zielprojekt, in
dessen `node_modules`, installiert über dessen `package.json`. Es wandert
nirgendwohin.

**Die Erkenntnis, welches Werkzeug es ist**, steht in `STACK.md`. Das ist der Ort,
an dem eine zweite Aufgabe im selben Projekt nicht noch einmal sucht.

**Die fertige Konfiguration** liegt in `.claude\guardrails\<stack>\` im Vault. Das
ist der Ort, an dem ein *anderes* Projekt nicht noch einmal sucht.

Was dort für TypeScript liegt:

```
.claude/guardrails/typescript/
  .dependency-cruiser.cjs      Struktur-Regeln: Domänen, Zyklen, I/O nur am Rand
  eslint.config.js             Lint-Regeln über dem Quelltext
  tsconfig.json                die strengste Typprüfung
  .nvmrc                       die Node-Version
  .github/workflows/gates.yml  was die CI startet
  gates/
    run.mjs                    der Beweislauf
    erzeuge-fixtures.mjs       legt die kaputten Dateien an
    skripte/                   die Ratchet-Skripte plus ihre Basislinien
```

Diese Vorlage ist gegen ein echtes Projekt gebunden und bewiesen: 18 der 25
Katalogzeilen, gegen typescript 6.0.3, eslint 10.8.1, typescript-eslint 8.67.0,
dependency-cruiser 18.2.0, type-coverage 2.30.1. Die übrigen sieben brauchen
etwas, das eine Vorlage nicht mitbringen kann — einen zweiten Kontext,
git-Historie, das Vokabular des Projekts.

Eingesetzt wird sie in zwei Schritten, und die tun **verschiedene** Dinge:

```bash
node <Vault>/.claude/scripts/init-project.mjs <zielordner> --stack=typescript
cd <zielordner>
npm install --save-dev typescript eslint @eslint/js typescript-eslint dependency-cruiser type-coverage
node gates/erzeuge-fixtures.mjs      # legt die 18 kaputten Dateien an
node gates/run.mjs                   # muss 18/18 melden
```

Zeile 1 kopiert die **Konfiguration** in die Projekt-Root, 1:1 und nie
überschreibend. Zeile 3 holt die **Programme** aus dem Netz nach `node_modules`.
Ohne Zeile 3 liegt eine `eslint.config.js` im Ordner, und es gibt kein eslint, das
sie liest.

**Kopiert heißt nicht bewiesen.** Deshalb Zeile 4 und 5. Die kaputten Dateien sind
mit Absicht nicht Teil der Vorlage: eine kopierte kaputte Datei würde
stillschweigend veralten, sobald ein Werkzeug seinen Fehlercode ändert. Der
Generator trägt die erwarteten Meldungen an einer einzigen Stelle.

## 32 · Die drei Befehle, die man verwechselt

Drei Befehle laufen im Zielprojekt, an verschiedenen Orten, mit verschiedenen
Fragen.

| Befehl | Läuft über | Beantwortet | Wo |
|---|---|---|---|
| `npm test` | den echten Code | **Läuft es?** | Prüfung 2, im Integrations-Worktree |
| `npm run lint`, `typecheck`, `struktur` | den echten Code | **Bricht es eine Regel?** | Prüfung 3, im Integrations-Worktree |
| `node gates/run.mjs` | die absichtlich **kaputten** Dateien | **Sind die Regeln überhaupt noch scharf?** | **nur in der CI** |

Der erste ist der `testCommand`. Der zweite ist der `checkCommand`. Der dritte
kommt im Merge-Pfad gar nicht vor.

Der CI-Workflow zeigt die Trennung wörtlich:

```yaml
# Die Regeln über dem echten Code.
- run: npm run typecheck
- run: npm run lint
- run: npm run struktur
- run: node gates/skripte/reproduzierbar-aus-frischem-klon.mjs
- run: node gates/skripte/ausnahmen-vermehren-sich-nicht.mjs
- run: node gates/skripte/typanteil-faellt-nicht.mjs

# Und der Beweis, dass die Regeln überhaupt noch scharf sind.
# Ohne diesen Schritt sieht eine stillgelegte Regel aus wie ein sauberes Repo.
- run: node gates/run.mjs
```

**Zwei Blöcke, zwei Fragen. Der erste fragt den Code. Der zweite fragt die
Regeln.**

## 33 · Warum nur eine kaputte Datei etwas beweist

Das ist der tragende Satz des ganzen Guardrail-Baus, und er lohnt eine Geschichte.

Du hast eine Regel: *im Domänen-Ordner steht kein `throw`.* Sie ist eine Zeile in
`eslint.config.js` und nennt dort einen Regelnamen beim Namen.

Eslint 11 kommt heraus. Der Regelname heißt jetzt anders. Du aktualisierst.
`npm run lint` läuft, findet nichts, beendet sich mit 0. Grün.

Und dein Code *ist* sauber — du hast ja nie ein `throw` in die Domäne geschrieben.

**Jetzt die Frage: läuft deine Regel noch?**

An dieser Ausgabe kannst du es nicht sehen. „Grün" bedeutet hier zwei völlig
verschiedene Dinge, und beide sehen gleich aus:

| | Regel lebt | Regel ist tot |
|---|---|---|
| **sauberer Code** | geht durch | geht durch |
| **dreckiger Code** | fällt durch | geht durch |

Die obere Zeile ist in beiden Spalten gleich. **Eine Beobachtung, die in beiden
Welten dasselbe Ergebnis hat, trennt sie nicht — sie trägt null Information.**

Die untere Zeile unterscheidet sich. Sie ist die einzige, die das tut. Deshalb
lautet die Prüfung nie *„lässt sauberer Code das Gate passieren"*, sondern immer
**„lässt dreckiger Code es scheitern"**.

**Eine Regel stirbt ohne Vorwarnung**, und auf mehr Wegen als dem einen oben:

- Der Linter benennt sie um.
- Ein Suchmuster zeigt auf eine Syntax, die es nicht mehr gibt.
- Eine Konfigurationszeile landet im falschen Block und wird ignoriert.
- Du setzt die Vorlage in ein Projekt mit anderen Ordnernamen ein und passt die
  Domänenliste nicht an. Dann greifen die Regeln über einen Ordner, den es nicht
  gibt.

In keinem dieser Fälle bricht etwas ab. In jedem läuft das Werkzeug, findet nichts
und meldet Erfolg.

## 34 · Wie ein Beweis-Ordner aussieht

Ein Ordner **pro Regel**, im Zielprojekt, unter `gates/`:

```
gates/<slug>/
  erwartung.json     welches Werkzeug, welche Katalogzeile, welcher Text muss in der Ausgabe stehen
  fixture.ts         die kaputte Datei          (bei tsc)
  src/<domäne>/…     die kaputte Datei im Baum  (bei eslint und dependency-cruiser)
  tsconfig.json      eigenes Projekt            (bei tsc und eslint)
```

Ein echtes Beispiel: der Ordner `kein-throw-im-kern`, gebunden an eslint,
Katalogzeile *„no throw inside the domain"*, Klasse `checked`. Die kaputte Datei
ist genau das:

```ts
// src/protokoll/fixture.ts
export function transaktionLesen(zeile: string): string {
  if (!zeile.includes("Txn")) {
    throw new Error("keine Transaktion gefunden");
  }
  return zeile;
}
```

Erwartet wird der Text `Kein throw im Kern` in der Ausgabe von eslint.

Gestartet wird mit `node gates/run.mjs` für alle oder `node gates/run.mjs <slug>`
für eine.

**`erwartung.json` prüft zwei Dinge getrennt:** dass das Werkzeug überhaupt
meckert (Exit ungleich 0), und dass es **aus dem richtigen Grund** meckert. Die
zweite Hälfte ist nötig, weil eine kaputte Datei auch durchfällt, wenn sie an
einem Tippfehler scheitert — und das sähe ohne Textprüfung genauso aus wie ein
Erfolg.

Entsprechend unterscheidet der Beweislauf zwei Fehlermeldungen, und sie bedeuten
Gegensätzliches:

| Meldung | Was passiert ist | Was zu tun ist |
|---|---|---|
| *„das Werkzeug war zufrieden"* | Die Regel ist weg | Konfiguration reparieren |
| *„Fehlschlag ja, aber ohne `<text>`"* | Die Regel greift, meldet nur anders | `erwartung.json` nachziehen |

Die zweite Meldung kommt typischerweise nach einem Versionssprung: der Fehlercode
hat sich geändert, die Regel nicht. Dann zieht man die Erwartung nach — nie die
Regel.

## 35 · Vier Arten, eine Regel durchzusetzen

Der Katalog ordnet jede Zeile einer von vier Maschinen zu. Welche, entscheidet die
Kosten.

- **Deklaration** — eine Datei nennt die erlaubten Verbindungen zwischen Ordnern,
  ein Werkzeug macht Build-Fehler daraus. Mit Abstand die billigste: alle
  Struktur-Regeln fallen aus dieser einen Datei heraus.
- **Compiler** — ein Typ macht die Verletzung nicht kompilierbar. Die stärkste,
  weil man sie nicht pro Zeile abschalten kann, ohne eine sichtbare Markierung zu
  hinterlassen.
- **Lint-Regel** — eine Regel über den Quelltext. Nötig da, wo kein Typ die
  Eigenschaft tragen kann.
- **Ratchet** — ein Zähler plus gespeicherter Basislinie; der Build fällt, wenn
  der Zähler steigt. So bekommt eine Ermessensfrage eine mechanische Hälfte:
  niemand entscheidet, ob das Design gut ist, und alle merken, wenn es schlechter
  wurde.

---
---

# Teil VII — Wie der Orchestrator selbst geprüft ist

Ab hier geht es wieder um das andere Programm: den Orchestrator (Abschnitt 6).

## 36 · Test und Attrappe

Ein Orchestrator-Test funktioniert so: du baust eine Attrappe (Abschnitt 12),
sagst ihr, was sie antworten soll, und prüfst, ob der Code richtig darauf
reagiert.

```ts
const git = { merge: async () => false, /* … */ };   // „der Merge scheitert"
// prüfe: landet die Notiz jetzt auf conflict, bleibt main unangetastet?
```

**Das prüft deine Logik.** Es prüft nicht, ob echtes git jemals `false` sagt — das
hast du gerade selbst hingeschrieben.

Ein solcher Test kostet nichts: Attrappen, Wegwerf-Ordner, Millisekunden.
`npm test` startet alle 33 Dateien auf einmal, bei jeder Änderung, und muss immer
grün sein.

## 37 · Proof: die Messung an der Wirklichkeit

Und genau da, wo die Attrappe aufhört, fängt die zweite Sorte Prüfung an.

**Ein Proof prüft nicht Code. Er misst, wie sich die Wirklichkeit verhält.**

Der Unterschied in einem Satz:

> Ein Test fragt: **reagiert mein Code richtig auf X?**
> Ein Proof fragt: **passiert X überhaupt so?**

Drei Beispiele machen das konkret.

**Der Permission-Prüfer.** Der Orchestrator entscheidet: ein gerouteter Lauf muss
in den Container (Abschnitt 26). Die Begründung dahinter ist eine Vermutung über
die Welt — *ein kostenloses Modell urteilt in dieser Rolle nicht gut genug.*

Eine Attrappe kann das nicht beantworten; sie sagt, was man ihr aufschreibt. Also
gibt der Proof echtes Geld aus und legt dem echten kostenlosen Modell echte
Befehle vor. Das Ergebnis: `chmod -R 777` korrekt abgelehnt, `rm -rf`
durchgelassen. Diese Messung ist der Grund für die Regel im Programm.

**Das Gateway.** Die Dokumentation von `claude` sagt eine Sache darüber, welche
Kopfzeilen es sendet. Die Binärdatei tut eine andere. Ein Test, der gegen die
Dokumentation gebaut ist, ist grün und falsch. Also wird gegen die echte
Binärdatei geprüft.

**Echtes git.** Die Attrappe nahm `git branch -f` fröhlich an — sie kann nicht nein
sagen. Echtes git weigert sich (Abschnitt 24). Solange nur Attrappen antworteten,
war der Fehler unsichtbar.

**Warum das einen eigenen Ordner braucht.** Ein Proof kostet einen bezahlten
Claude-Aufruf, einen laufenden Docker-Daemon oder Stunden Wartezeit. So etwas kann
nicht in einer Suite stehen, die bei jedem Commit durchlaufen muss.

Also: eigener Ordner `verification/`, ein eigener Befehl je Datei, von Hand
gestartet. Acht Stück:

| Befehl | Was er misst | Was er kostet |
|---|---|---|
| `proof:review` | zwei Review-Achsen finden je ihren gepflanzten Fehler | Geld |
| `proof:doorman` | wie der Permission-Prüfer wirklich urteilt | Geld |
| `proof:gateway-translation` | das Gateway gegen die echte `claude`-Binärdatei | Geld |
| `proof:resume` | ein echtes Fünf-Stunden-Fenster, geparkt und selbst aufgewacht | Wartezeit |
| `proof:one-issue` | eine Notiz von Anfang bis Merge | Geld |
| `proof:container` / `proof:host` | der Lauf in der Kiste bzw. auf dem Rechner | Docker |
| `proof:provisioning` | die Paketinstallation im frischen Worktree | Docker |
| `proof:reaper-docker` | der Aufräumer gegen echtes Docker | Docker |

**Und die Regel, die daraus folgt:** Beweise gehören neben den Code, den sie
beurteilen. Ein Proof, der in einem anderen Repo liegt, wird beim Archivieren
vergessen — und dann steht eine Behauptung im Code, für die es keinen Beleg mehr
gibt.

## 38 · FALSIFY FIRST

Fast jede Orchestrator-Testdatei trägt denselben Kopf: **FALSIFY FIRST.**

Also nicht *„beweise, dass es geht"*, sondern *„konstruiere den Fall, in dem es
**still** danebengeht"*.

Das Wort *still* trägt die ganze Regel. Ein lauter Fehler meldet sich selbst — ein
Absturz, eine Fehlermeldung, ein roter Test. Ein stiller Fehler sieht aus wie
Erfolg, und deshalb ist er der einzige, den man aktiv suchen muss.

Zwei Beispiele aus diesem Ordner:

- Eine grüne Suite, die gegen fremde Pakete lief (Abschnitt 20). Laut Vorhersage
  hätte sie rot sein müssen. Sie war grün, und das war schlimmer.
- Ein Testlauf, der sich als Unterlauf eines anderen ausgibt und deshalb mit 0
  endet, obwohl er rot war. Eine rote Suite, gemeldet als grün, hätte einen
  kaputten Merge veröffentlicht.

Beide sehen von unten aus wie Erfolg. Das ist kein Zufall — es ist dasselbe Muster
wie in Abschnitt 33 und Abschnitt 23, und es hat einen eigenen Namen. Er steht in
Teil VIII.

---
---

# Teil VIII — Die eine Regel darunter

## 39 · Eine Abwesenheit muss als Abwesenheit lesbar sein

Diese Regel taucht an mindestens sieben Stellen unabhängig auf, jedes Mal anders
formuliert, und jedes Mal in einem anderen Teil des Programms:

| Wo | Wie sie dort aussieht |
|---|---|
| Die Guardrails (Abschnitt 22) | Ein leerer `checkCommand` ergibt „übersprungen", nie „bestanden" |
| Der Port (Abschnitt 12) | Eine fehlende Methode sagt „keine mechanischen Regeln"; ein Platzhalter würde „bestanden" sagen |
| Das Review (Abschnitt 23) | Kein Review-Kommando heißt **kein** Review, nicht ein Review, das alles durchwinkt |
| Die Achsen (Abschnitt 23) | Eine Achse ohne Standard wird übersprungen, statt eine Meinung im Gewand einer Messung zu produzieren |
| Das Ergebnis (Abschnitt 23) | Unlesbares wird `skipped`, nie „nichts gefunden" |
| Der Standardtext (Abschnitt 31) | Ein fehlender Text darf nie als leerer Text ankommen |
| Das Fixture (Abschnitt 33) | Geprüft wird, ob dreckiger Code scheitert — nie, ob sauberer durchgeht |

**Der Grund ist jedes Mal derselbe: die andere Wahl sieht von unten aus wie
Erfolg.**

Und das ist auch der Grund, warum diese Regel aufgeschrieben gehört und nicht bloß
befolgt wird. Wo sie nur Gewohnheit ist, gilt sie an den Stellen, an denen jemand
gerade daran dachte — und an keiner anderen.

---

## Verwandt

[[orchestrator-map]] — die geprüfte Fassung. Sie trägt die vollständigen
Verzeichnisse, die Diagramme, die Konfigurationsschlüssel und alles, was offen
oder kaputt ist. Im Zweifel gilt sie; diese Datei hier wird nachgezogen, wenn sich
dort etwas ändert.

[[isolation-levels]] — Host, Container, und was welcher schützt.

[[system-strengths]] — warum in diesem Vault direkt auf `main` committet wird, im
Agenten-Repo aber jeder Agent einen eigenen Branch bekommt.

[[guardrails-into-projects]] — was es kostet, dass die Stack-Vorlagen im Vault
liegen und nicht im Plugin.
