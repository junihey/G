---
tags: [learning, orchestrator]
created: 2026-08-29
updated: 2026-08-31
topic: Der Orchestrator von Grund auf -- was er ist, wie ein Lauf abläuft, welche Prüfung was beantwortet, und was am 2026-08-03 gebaut, aber nicht angeschlossen war
verification: am 2026-08-31 gegen den Code gelesen -- smithy\orchestrator\src\, \test\, \verification\, dazu .claude\guardrails\typescript\ und smithy\forge\skills\baseline\SKILL.md. Vorher nur abgeleitet aus claude-notes/orchestrator-map.md
---

# Wie der Orchestrator arbeitet

Die Langfassung von [[orchestrator-map]]. Dieselben Fakten, nur ausgeschrieben:
die Landkarte setzt die Begriffe voraus, diese Datei baut sie auf.

**Antwort zuerst:** Der Orchestrator ist ein Programm, das dauerhaft läuft und
einen Ordner mit Aufgaben-Notizen beobachtet. Setzt du eine Notiz auf „fertig zum
Bauen", startet er von selbst einen Claude-Agenten, lässt ihn den Code schreiben,
prüft die Arbeit viermal und legt sie in `main` ab. Von deiner Freigabe bis zum
fertigen Merge fasst kein Mensch mehr etwas an.

Er ist am 2026-08-03 fertig gebaut und getestet — und **auf keinem Projekt
angeschlossen.** Die Konfigurationsdatei, die ihn scharf schaltet, existiert auf
dieser Maschine nicht.

Der Code liegt in `smithy\orchestrator\`. Wo unten eine Datei genannt wird, ist
sie relativ zu diesem Ordner gemeint.

---

## 1 · Die sieben Wörter, ohne die der Rest nicht trägt

Diese sieben kommen unten dauernd vor. Ohne sie liest sich alles wie Nebel.

**Issue-Note.** Eine Markdown-Datei in Obsidian, eine pro Aufgabe. Oben im Kopf
stehen Felder wie `status:`, `slice:`, `priority:`. Unten steht in Prosa, was
gebaut werden soll. Diese Datei ist gleichzeitig der Auftrag *und* das Protokoll:
der Orchestrator schreibt seinen Fortschritt in dieselbe Datei zurück.

**`main`.** Der eine Hauptstrang des Projekts. Was hier liegt, gilt als gültiger
Stand.

**Branch.** Eine Abzweigung von `main`. Technisch nur ein Zeiger auf einen
bestimmten Commit. Der Agent arbeitet nie direkt auf `main`, sondern auf einem
eigenen Branch namens `issue/<nummer>`.

**Checkout.** Die Dateien, die tatsächlich auf der Festplatte liegen und die du im
Editor siehst. Ein Branch sagt, *welcher* Stand gemeint ist; ein Checkout ist
dieser Stand, ausgepackt als echte Dateien. Abschnitt 3a erklärt das ausführlich,
weil der letzte Befehl des ganzen Laufs davon abhängt.

**Worktree.** Ein zweiter, vollständiger Checkout desselben Repos an einem anderen
Ort auf der Platte. Zwei Agenten in zwei Worktrees stolpern nicht übereinander —
jeder hat seinen eigenen Ordner mit seinen eigenen Dateien. Sie teilen sich nur
die Versionsgeschichte darunter.

**Agent.** Ein gestarteter Claude-Code-Prozess. Er bekommt einen Prompt, einen
Worktree und keine Aufsicht. Fertig ist er, wenn er einen Commit gemacht hat.

**Slice.** Zwei Arbeitsarten, und sie bestimmen das Gleis (Abschnitt 5):
`vertical` heißt „ein Stück Funktion von oben bis unten", `horizontal` heißt
„dieselbe kleine Änderung an vielen Stellen".

---

## 2 · Ein Lauf von Anfang bis Ende

Der ganze Ablauf einmal als Geschichte. Alles Weitere unten ist Detail dazu.

1. **Du schreibst eine Issue-Note.** Sie steht auf `status: draft`.
2. **Du gibst sie frei.** Der Skill `/ready-to-implement` setzt sie auf
   `ready-to-implement`. Das ist ein **hartes Gate**: nur ein Mensch schiebt eine
   Notiz über diese Schwelle.
3. **Der Orchestrator sieht die Änderung.** Ein Dateiwächter (`chokidar`) meldet
   ihm, dass sich die Datei geändert hat.
4. **Vier Wächter prüfen, ob jetzt wirklich gestartet wird** (Abschnitt 5).
5. **Der Worktree entsteht.** Frischer Ordner, frischer Branch, danach
   `provision()` — die Pakete werden installiert. Die Notiz steht auf
   `provisioning`, dann `running`.
6. **Der Agent arbeitet.** Er bekommt einen festen Vertragstext plus den Body
   deiner Notiz (Abschnitt 8) und schreibt Code, Tests und Commits.
7. **Der Integrations-Worktree entsteht** — ein *dritter* frischer Ordner, auf dem
   aktuellen `main`. Hier laufen die vier Prüfungen (Abschnitt 3).
8. **Ist alles grün, wandert die Arbeit nach `main`.** Die Notiz steht auf
   `merged`, und Issues, die auf sie gewartet haben, werden geweckt.

Geht etwas schief, endet die Notiz auf `conflict` oder `failed`, und dann bist
wieder du dran.

---

## 3 · Die vier Prüfungen zwischen Agent und `main`

Das ist das Herzstück. Vier Prüfungen, feste Reihenfolge, alle im selben frischen
Integrations-Worktree. **Keine kann für eine andere einspringen** — jede
beantwortet eine andere Frage.

| # | Prüfung | Die Frage | Bei Rot |
|---|---|---|---|
| 1 | `git merge --no-ff` | Passt der Text überhaupt auf das heutige `main`? | **Mensch.** Kein neuer Versuch |
| 2 | `runSuite` | Läuft es? | zurück an den Agenten, mit der Fehlerausgabe |
| 3 | `runChecks` | Bricht es eine mechanische Regel? | dasselbe |
| 4 | `review` | Tut es, was verlangt war? | **nichts.** Es berichtet nur |

Prüfung 2 startet den `testCommand` aus der Konfiguration, Voreinstellung
`npm test` — die Tests des Projekts. Prüfung 3 startet den `checkCommand` — die
Guardrails, Abschnitt 12. Ist `checkCommand` leer, wird Prüfung 3
**übersprungen**, nicht bestanden.

### Warum Prüfung 1 nicht an den Agenten zurückgeht

Ein Textkonflikt heißt: jemand anders hat dieselben Zeilen geändert, während
unser Agent arbeitete. Der Agent sitzt in seinem eigenen Worktree und **sieht die
andere Seite gar nicht.** Ihn das lösen zu lassen wäre, ihn raten zu lassen. Also
landet die Arbeit auf dem Branch, der Worktree wird abgeräumt, und du entscheidest.

### Warum es einen dritten, frischen Worktree braucht

Ein Merge kann textuell sauber sein und die Tests trotzdem brechen. Beispiel:
`main` hat eine Funktion umbenannt, dein Agent hat eine neue Stelle geschrieben,
die den alten Namen ruft. Zwei verschiedene Zeilen, kein Textkonflikt, kaputtes
Programm. Der Integrations-Worktree fängt genau das. Ohne ihn wäre die Zusage
„läuft ohne menschlichen Schritt bis `main`" eine Drohung.

**In jedem frischen Worktree läuft `provision()`, also die Paketinstallation.**
Worktrees teilen die Versionsgeschichte, aber **nicht** den `node_modules`-Ordner.
Erwartet wurde, dass ohne Installation die Tests rot werden. Was ein echter Lauf
tatsächlich produzierte, war schlimmer: sie wurden **grün.** Node sucht Pakete
auch in den übergeordneten Ordnern, und dort lag zufällig ein fremdes
`node_modules`. Die Tests liefen gegen Pakete aus einem völlig anderen Projekt.

### Warum Prüfung 4 nie blockiert

Prüfung 2 und 3 sind mechanisch: ein Testname, eine Regel, eine Datei. Der Agent
kann damit etwas anfangen. Prüfung 4 ist ein Urteil eines anderen Modells. Ein
Urteil, das einen sauberen Lauf stoppen kann, ist ein Urteil, das man bald
abschalten wird. Also berichtet es und stoppt nichts.

### Wohin Prüfung 4 berichtet

**In dieselbe Issue-Note.** Nicht in ein eigenes Dokument, nicht in einen
Kommentar irgendwo, nicht in eine Datenbank.

Der Weg im Code: `Integrator.reviewBeforePublish()` ruft
`this.store.appendLog(issue.id, describeReview(outcome))`. `appendLog`
(`src/issue-store.ts:112`) hängt eine Aufzählungszeile mit Zeitstempel unter die
Überschrift `## Log` in der Markdown-Datei an — und legt die Überschrift an, falls
sie noch fehlt.

Das JSON aus dem Review-Kommando landet dort nie wörtlich. `describeReview`
übersetzt es vorher in Zeilen:

```
reviewed before merge — 2 finding(s) across 2 of 3 axis/axes:
  [spec] Das Abbruchkriterium „leere Eingabe liefert eine leere Liste" ist nicht abgedeckt.
  [correctness] reviewed, no findings
  [design] DID NOT RUN — kein Standardtext für diese Achse
```

`{"findings":[…]}` wird zu je einer Zeile pro Befund. `{"skipped":"warum"}` wird
zur `DID NOT RUN`-Zeile. Die Datei, die der Auftrag war, ist auch das Protokoll.

### Der Satz, um den es eigentlich geht

Er steht im Kopf von `review.ts`:

> **Bei der Testsuite sollte man unruhig sein.**

Denn geschrieben hat sie derselbe Agent, der den Code schrieb. Hat er die Aufgabe
falsch verstanden, testet er das, was er sich vorgestellt hat — und das ist grün.
Von unten sieht ein falsch verstandenes Issue **exakt aus wie Erfolg.** Das ist
der Grund, warum es Prüfung 4 überhaupt gibt.

**Und der rote Test hilft dagegen nicht.** Der Prompt verlangt ihn ausdrücklich
(Abschnitt 8). Aber selbst wenn der Agent sich daran hält, beweist Rot nur:
dieser Test prüft *etwas Neues*. Er beweist nicht: dieser Test prüft *das
Richtige*. Bei einem falsch verstandenen Issue ist der Test zuerst rot für das
vorgestellte Verhalten und danach grün für das vorgestellte Verhalten. Beide
Farben stimmen, und beide sind an der Aufgabe vorbei. Prüfung 4 misst gegen den
Issue-Body — den einzigen Text im ganzen Lauf, den der Agent nicht selbst
geschrieben hat.

==~~Warum wird der Test dann nicht erst nach Prüfung 4 geschrieben?~~==

Wo der TDD-Test überhaupt läuft: im Worktree des Agenten, gestartet vom Agenten
selbst. `runSuite` ist etwas anderes und später — der Orchestrator im
Integrations-Worktree, nach dem Merge. Dieselbe Suite, zwei verschiedene Läufe an
zwei Orten. Aus dem Worktree des Agenten verlässt nur eines den Ordner: der Commit.

---

## 3a · Was „ausgecheckt" heißt, und warum `main` es immer ist

Dieser Abschnitt erklärt die letzte Zeile des Merge-Pfades. Er steht eigenständig,
weil das Wort *Checkout* unten dreimal trägt.

### Ein Repo hat zwei Hälften

Ein git-Repo besteht aus zwei Dingen, die man leicht für eines hält:

1. **Die Versionsgeschichte.** Alle Commits, alle Branches, komprimiert im
   versteckten Ordner `.git`. Ein Commit ist ein vollständiger Schnappschuss.
   Nichts davon siehst du im Editor.
2. **Das Arbeitsverzeichnis.** Die Dateien, die wirklich als Dateien auf der
   Platte liegen. Das ist, was dein Editor öffnet und was `npm test` liest.

**Ein Checkout ist der Vorgang, der aus 1 die 2 macht:** „nimm den Stand von
Branch X und leg ihn als echte Dateien in diesen Ordner." Und *ein* Checkout ist
auch das Ergebnis davon — ein Ordner voller Dateien, der weiß, von welchem Branch
er kommt.

Ein Branch ist **ausgecheckt**, wenn irgendein Arbeitsverzeichnis gerade seinen
Stand zeigt.

### Warum `main` immer ausgecheckt ist

Der Projektordner selbst ist ein Checkout. Klonst du ein Repo, bekommst du genau
das: die Geschichte in `.git`, und daneben die Dateien des Hauptbranches,
ausgepackt. Dieser Ordner heißt hier **Haupt-Checkout**, und er steht auf `main`.

Es gibt keinen normalen Zustand, in dem er das nicht tut. `main` ist also immer
ausgecheckt — nicht als Regel, sondern weil der Ordner existiert.

Ein **Worktree** ist ein *zweites* Arbeitsverzeichnis am selben Repo, angelegt mit
`git worktree add`. Die Geschichte bleibt eine, die Dateien sind zwei Sätze an
zwei Orten. git merkt sich, welcher Worktree welchen Branch ausgecheckt hat — und
lässt denselben Branch nie zweimal ausgecheckt sein.

In einem Lauf gibt es drei Arbeitsverzeichnisse:

| Ordner | Steht auf | Wer arbeitet darin |
|---|---|---|
| Haupt-Checkout | `main` | niemand; er ist das Ziel |
| Worktree des Agenten | `issue/<nummer>` | der Agent |
| Integrations-Worktree | **keinem Branch** | die vier Prüfungen |

Der dritte ist der interessante. Er wird mit `git worktree add --detach` angelegt
(`src/git.ts:225`) — *losgelöst*, also direkt auf einen Commit gesetzt statt auf
einen Branch. Hätte er `main` ausgecheckt, wäre `main` zweimal ausgecheckt, und
das verbietet git. Losgelöst kollidiert er mit nichts.

### Und deshalb `merge --ff-only` statt `branch -f`

Der letzte Schritt heißt `publish` und sind zwei Befehle (`src/git.ts:317`):

```
git rev-parse HEAD          # im Integrations-Worktree: welche SHA ist das Ergebnis?
git merge --ff-only <sha>   # im Haupt-Checkout: spul main genau dorthin vor
```

Die naheliegende Abkürzung wäre `git branch -f main <sha>` — „setz den Zeiger
`main` einfach auf diesen Commit". Sie funktioniert nicht, aus zwei Gründen.

**Der erste Grund ist eine Weigerung von git.** Wörtlich:

> fatal: cannot force update the branch 'master' used by worktree at …

Ein Branch, der irgendwo ausgecheckt ist, lässt sich nicht zwangsbewegen. Und
`main` ist immer ausgecheckt, siehe oben. Die Abkürzung scheitert also immer,
nicht manchmal.

**Der zweite Grund ist, warum git sich weigert.** `branch -f` bewegt nur den
Zeiger, nicht die Dateien. Danach behauptet git: „du bist auf `main`, und `main`
ist Commit Z" — aber im Ordner liegen die Dateien von Commit Y. Jede Datei, die
sich zwischen Y und Z unterscheidet, erschiene ab sofort als eine Änderung, die
*du* gemacht hast. Ein `git status` voller Änderungen, die niemand geschrieben hat.

| Befehl | bewegt den Zeiger | bewegt die Dateien | bei fremden Änderungen im Ordner |
|---|---|---|---|
| `git branch -f main <sha>` | ja | **nein** | verweigert, weil ausgecheckt |
| `git merge --ff-only <sha>` | ja | **ja** | bricht ab, überschreibt nichts |

`--ff-only` heißt „nur vorspulen": tu es nur, wenn der Zielcommit ein direkter
Nachfahre des jetzigen ist. Ist er das nicht — weil jemand anders `main`
inzwischen bewegt hat —, bricht der Befehl ab, statt einen Merge-Commit zu
erfinden. Das ist gleichzeitig die einzige Verteidigung gegen zwei gleichzeitige
Läufe, unten in 3b.

### Warum es erst der echte Lauf fand

Die Unit-Tests arbeiten gegen eine **Attrappe** von git: ein Objekt, das dieselben
Methoden hat und nur festhält, dass es gerufen wurde. Eine Attrappe kann nicht
nein sagen. `branch -f` war für sie ein Methodenaufruf wie jeder andere.

Erst `test/real-git.test.ts` legt ein echtes Repo in einem Wegwerf-Ordner an und
ruft echte git-Befehle. Der Kommentar im Code sagt es ohne Umschweife:
*„Proven by real-git.test.ts; the fake accepted it happily, which is exactly why
the gate required real commands."*

---

## 3b · ==Es gibt keine Merge-Warteschlange und kein Rebase==

Beides fehlt. Das Wort `rebase` kommt in keiner Quell- und in keiner Testdatei des
Orchestrators vor.

Was es stattdessen gibt, ist `RunGate` — ein Einlass **am Anfang**, nicht am
Merge. Es zählt freie Plätze (`concurrency`, Voreinstellung 1) und ordnet
Wartende nach einer Rangzahl. Es reiht **Starts** ein, keine Merges.

Der Merge wird nur als Folge davon seriell: `integrate()` läuft innerhalb des
Laufs, der den Platz hält. Bei Kapazität 1 kann nichts überlappen.

Bei Kapazität größer 1 kann es überlappen, und dann greift keine Warteschlange,
sondern ein Scheitern:

1. Lauf A und Lauf B legen je einen Integrations-Worktree an, beide auf dem `main`,
   der in diesem Moment gilt.
2. A ist zuerst fertig und publiziert. `main` bewegt sich.
3. B ist fertig. Sein Ergebnis ist kein direkter Nachfahre des neuen `main` mehr.
4. `git merge --ff-only` bricht ab und wirft. Der `catch` in `integrate()` macht
   daraus `conflict`.

Der Zweite verliert also und wird ein Fall für dich. Das ist die eine Verteidigung,
die Abschnitt 14 als „genau eine" nennt. Als *letzte* Linie ist sie richtig; sie
ist nur derzeit auch die *einzige*. Vorbeugen hieße: B rebaset, sobald A gemergt
hat — und das ändert, was einem laufenden Agenten zugesagt wurde.

---

## 4 · Die Zustände einer Notiz

Eine Issue-Note wandert durch acht Zustände. **Nur die ersten beiden schreibt ein
Mensch, alle anderen die Maschine.**

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

Setzt du eine `failed`-Notiz von Hand zurück auf `ready-to-implement`, bekommt sie
einen wirklich frischen Start. Das Feld `routedVia` — es merkt sich, über welchen
Weg der letzte Versuch lief — wird auf jedem Endzustand gelöscht. Sonst bliebe die
Notiz still an eine Straße geheftet, die niemand mehr gewählt hat.

**Ein Zustand fehlt, und das ist bekannt:** `awaiting_decision`. Eine Notiz kann
auf eine **Uhr** warten und wacht selbst wieder auf — zweimal gegen echte
Fünf-Stunden-Fenster gemessen. Auf einen **Menschen** warten kann sie nicht. Jede
Entscheidung, die die Pipeline hätte aufschieben können, wird deshalb ein Stopp.
Steht als `O19` in smithys `OPEN.md`.

---

## 5 · Zwei Gleise und vier Wächter

Es gibt zwei Dispatcher, also zwei getrennte Wege in die Ausführung. Welchen eine
Notiz nimmt, entscheidet ihr Feld `slice:`.

| Gleis | Für | Wie viele gleichzeitig | Wie es startet |
|---|---|---|---|
| `verticalDispatcher` | `slice: vertical` (und fehlendes Feld) | so viele, wie `concurrency` erlaubt | wenn eine Datei sich ändert |
| `ralphDispatcher` | `slice: horizontal` | **genau eine**, fest verdrahtet | fragt regelmäßig nach |

Bevor auf dem vertikalen Gleis wirklich ein Agent startet, kommen **vier
Wächter.** Jeder fängt etwas, das die anderen nicht sehen können.

**1 · Hat sich der Status wirklich bewegt?** (`prev !== next`)
Obsidian speichert eine Notiz mehrfach pro Bearbeitung. Ohne diesen Wächter würde
jeder Tastendruck als Ereignis durchgehen.

**2 · Sind die Abhängigkeiten erfüllt?**
Eine Notiz darf auf eine andere zeigen. **`merged` ist der einzige Zustand, der so
eine Kante löst.** `running` ist nicht fertig; auf `failed` weiterzubauen heißt,
einem kaputten Fundament ein zweites Stockwerk zu geben. Eine Kante, die auf
nichts zeigt, ist ein Planungsfehler und nie ein grünes Licht.

Warum das *hier* geprüft wird und nicht schon beim menschlichen Gate: die Antwort
ändert sich, nachdem du freigegeben hast. Ob eine Abhängigkeit gemergt ist, ist
eine Frage der Reihenfolge — keine Frage der Freigabe.

**3 · Läuft dieses Issue schon?**
Der **Anspruch** ist `this.inFlight`, eine Menge von Issue-IDs in
`src/dispatcher.ts`. Der ganze Mechanismus sind zwei Zeilen:

```ts
if (this.inFlight.has(issue.id)) return;
this.inFlight.add(issue.id);
```

**Synchron heißt: zwischen diesen beiden Zeilen steht kein `await`.** JavaScript
läuft in einem einzigen Faden. Solange nichts dazwischen wartet, sind die zwei
Zeilen eine ununterbrechbare Einheit — kein zweites Ereignis kommt dazwischen.

Der konkrete Fall, gegen den das gebaut ist: Obsidian speichert zweimal, chokidar
feuert zweimal, und `main.ts:159` reicht das mit `void onIssue(issue)` weiter,
also **ohne** auf den vorigen Aufruf zu warten. Beide Aufrufe sind wirklich
gleichzeitig unterwegs.

Stünde ein `await` vor dem Anspruch — etwa weil der Abhängigkeits-Check von der
Platte lesen müsste —, liefe es so: Aufruf A prüft, findet nichts, wartet. Aufruf
B prüft, findet immer noch nichts, wartet. Beide setzen den Anspruch. Zwei Agenten
auf einem Worktree. Deshalb ist `dependenciesSatisfied()` bewusst eine synchrone
Funktion: sie darf vor dem Anspruch stehen, weil sie nicht wartet.

Der Anspruch wird auch über das Warten an `RunGate` hinweg gehalten. Ein doppeltes
Ereignis auf eine Notiz, die schon in der Schlange steht, wird verworfen — nicht
dahinter aufgetürmt.

**4 · Ist ein Platz frei?** (`RunGate`)
Den Fall sieht keiner der ersten drei: zwei Ereignisse auf **zwei verschiedenen**
Issues. `RunGate` zählt die Plätze und ordnet die Wartenden nach einer nackten
Rangzahl, niedriger zuerst. Bei Gleichstand gewinnt strikt der frühere:
**Priorität bricht Gleichstände, sie mischt Gleiche nicht neu.** Bei Kapazität 1
ergibt das automatisch die alte Reihenfolge des Eintreffens.

### Warum es `recheck()` gibt

Landet Issue A in `main`, schreibt **niemand** in Issue B, das auf A wartete. Die
Datei von B ändert sich nicht, der Dateiwächter feuert nicht, B säße für immer auf
`ready-to-implement`. `recheck()` läuft deshalb nach jedem Merge einmal die
Wartenden durch. Es gibt das nur auf dem ereignisgetriebenen Gleis — das andere
fragt ohnehin regelmäßig nach.

### Die vier Felder im Kopf einer Notiz

| Feld | Werte | Wer liest es |
|---|---|---|
| `slice` | `horizontal` \| `vertical` | die Weiche: welches Gleis |
| `priority` | `urgent` \| `normal` \| `low` | `RunGate` — die **einzige** Ordnungsachse |
| `kind` | `feature` \| `bugfix` \| `refactor` \| `infra` \| `docs` | **niemand.** Nur Doku für Menschen |
| `phase` | Freitext | ein Mensch. Nie ein Ersatz für `status` |

`kind: refactor` wird gelesen und **bewirkt nichts.**

---

## 6 · Die sechs Grenzen, die man dauernd verwechselt

Drei Paare davon sehen auf den ersten Blick gleich aus. Sie sind es nicht.

| Grenze | Zählt was | Default |
|---|---|---|
| `maxIterations` | Sandcastles **eigene** Wiederholschleife | **1**, festgenagelt |
| `maxVerifyAttempts` | rote Integrations-Suite | 3 |
| `maxRetries` | Versuche **ohne jeden Fortschritt** | 3 |
| `idleTimeoutSeconds` | Agent sagt nichts mehr | 300 |
| `maxRunSeconds` | Wanduhr, egal wie gesprächig | 3600 |
| `maxResumeDelaySeconds` | wie weit ein Park in die Zukunft darf | 6 h |

**Die erste gegen die zweite.** Sandcastle — die Bibliothek, die den Agenten
startet — hat eine eigene Schleife. Sie sucht in der **Prosa** des Agenten nach
einer Zeichenfolge. Kein Test, keine git-Abfrage. Ein Agent schrieb einmal „ich
drucke `SMOKE-DONE` absichtlich NICHT" — und die Schleife feuerte trotzdem, weil
die Zeichenfolge im Satz stand. Deshalb steht sie auf 1. Die *informierte*
Schleife ist `maxVerifyAttempts`: jeder neue Versuch bekommt die Fehlerausgabe
des letzten in den Prompt.

**Die dritte gegen die zweite.** Ein Lauf, der ins Rate-Limit lief und geparkt
wurde, hat nichts falsch gemacht. Er darf nicht das Budget aufessen, das ein
echter fehlschlagender Test braucht. Also zwei getrennte Zähler.

**Die vierte gegen die fünfte.** `idleTimeoutSeconds` tötet einen **stummen**
Agenten. Einen geschwätzigen, der endlos im Kreis redet, begrenzt sie nicht —
dafür ist die Wanduhr da. Läuft die ab, bleibt der Worktree stehen.

**Die sechste.** Ein `allowed_warning`-Ereignis trug einmal ein
**Sieben-Tage**-Fenster. Als Wartezeit gelesen hätte das einen völlig gesunden
Lauf tagelang geparkt.

---

## 7 · Das Review — mehrere Achsen, je ein eigener Prozess

Prüfung 4 ist nicht *ein* Review, sondern mehrere parallele. **Eine Achse ist ein
Name plus eine Quelle für Standards.** Beides gehört dem Projekt, nicht dem
Orchestrator.

| Achse | Woher der Maßstab kommt | Stand 2026-08-03 |
|---|---|---|
| `spec` | der Body deiner Issue-Note | **reserviert**, druckt immer zuerst |
| `correctness` | 12 bekannte Code-Smells, im Skript eingebaut | läuft, bewiesen |
| `design` | `REVIEW-STANDARDS.md` | Datei benannt, **inhaltlich leer** |
| `security` | offen | ungetestet |
| `performance`, `accessibility` | — | nichts |

Jede Achse ist ein eigener `claude -p`-Aufruf, also **eine frische Session ohne
geerbten Kontext.** Genau das könnte ein Skill nicht leisten: der läuft in
derselben Session, die ihn aufrief.

### Der Deckel auf den gleichzeitigen Aufrufen

Der Deckel heißt `reviewConcurrency`, steht in `src/config.ts` auf **2** und geht
an `FanOutReviewer` (`src/review.ts`). Der startet so viele Arbeiter, die sich die
Achsen der Reihe nach abholen:

```ts
const workers = Math.max(1, Math.min(this.concurrency, briefs.length));
```

Zwei Dinge stehen in dieser Zeile. Nie mehr Arbeiter als Achsen — bei drei Achsen
und Deckel 5 laufen drei. Und nie weniger als einer, auch bei einer 0 in der
Konfiguration.

**Bei `reviewConcurrency: 1` ist es also wirklich seriell.** Ein Arbeiter holt
sich Achse 1, wartet sie ab, holt sich Achse 2, wartet sie ab. Dasselbe Ergebnis,
dieselbe Reihenfolge im Protokoll, nur langsamer.

**Warum der Deckel keine Geschwindigkeitsfrage ist.** Jeder `claude -p`-Aufruf
zieht am selben Rate-Limit-Fenster desselben Kontos. Fünf gleichzeitig sind fünf
gegen ein Budget. Und was über das Limit läuft, wird nicht eingereiht — es
scheitert.

Die Rechnung ist deshalb schief:

- **Gedeckelt:** das Review dauert länger. Es sitzt in einem Pfad, der schon einen
  Merge, eine volle Suite und die Guardrails hinter sich hat. Ein paar Minuten
  mehr fallen dort nicht auf.
- **Ungedeckelt:** drei von fünf Achsen sterben. Und dieses Review ist der
  **einzige** Blick auf diesen Diff. Danach wandert er nach `main` und niemand
  sieht ihn wieder an.

Der Kommentar im Code zieht die Konsequenz noch schärfer: ungedeckelt ist
schlechter als *seriell*. Seriell dauert am längsten, liefert aber jede Achse.

### Was passiert, wenn das Rate-Limit vor den Reviews zuschlägt

**Sie werden nicht nachgeholt.** Nicht nach dem Reset, nicht später, gar nicht.

Die Kette:

1. Das Review-Kommando ist ein `claude -p`. Trifft es ein Limit, bricht es ab oder
   druckt kein brauchbares JSON.
2. `parseFindings` macht daraus `{skipped: "…"}` mit dem Grund — nie einen Befund,
   nie einen Absturz.
3. `describeReview` schreibt eine `DID NOT RUN`-Zeile in die Issue-Note.
4. `publish` läuft trotzdem. Prüfung 4 blockiert nie, auch nicht dafür.

Die ganze Park-Mechanik — Status `rate_limited`, Feld `resumeAt`, der Timer, der
selbst wieder aufweckt — sitzt ausschließlich in `src/runner.ts` und umgibt den
**Bau**-Agenten. Der Review-Pfad kennt sie nicht. `rate_limited` taucht in
`review.ts` und `integrator.ts` kein einziges Mal auf.

==Warum das so gebaut ist: parken heißt warten, und ein wartender Merge ist ein==
==Merge, der nicht stattfindet. Eine geparkte Notiz blockiert dabei einen Platz und==
==einen ganzen Worktree. Das Review nachzuholen hieße, den fertigen, grün geprüften==
==Code stundenlang liegen zu lassen — für einen Bericht, der ohnehin nichts==
==aufhält.==

Der Preis steht in Abschnitt 14 als eigene Zeile: ein Rate-Limit zur Review-Zeit
lässt den Diff ungeprüft nach `main`. Die Notiz sagt es ehrlich, aber sie sagt es
niemandem laut.

### Was zurückkommt, und der eine Fall, der verweigert wird

Das Kommando bekommt seine Aufgabe über Umgebungsvariablen (`REVIEW_ISSUE_ID`,
`REVIEW_BRANCH`, `REVIEW_SPEC`, `REVIEW_AXIS`, `REVIEW_DIFF_BASE`, bei Bedarf
`REVIEW_STANDARDS`) und antwortet mit `{"findings":[…]}` oder `{"skipped":"warum"}`.

Der **Exit-Code wird absichtlich ignoriert.** Etwas zu finden ist kein Fehlschlag,
und eine CLI beendet sich aus allerlei Gründen ungleich Null.

**Alles, was nicht sauber parst, wird `skipped` — nie ein Befund, nie ein
Abbruch.** Ein kaputtes Review ist *Nichtwissen*. Es als „nichts gefunden" zu
melden wäre das eine Ergebnis, das dieser Teil verweigert: es ist von einem
wirklich sauberen Diff nicht zu unterscheiden.

Deshalb ist `skipped` auch **pro Achse** und nicht ein einzelnes Flag für das
ganze Review: vier gesunde Achsen würden eine tote sonst unsichtbar machen. Die
Logzeile zählt darum, wie viele geantwortet haben — `2 finding(s) across 2 of 3
axis/axes`.

### Warum die Aufteilung im TypeScript sitzt und nicht im Skript

Das Skript ist ein Claude-Aufruf. Was darin passiert, kann man nur beweisen,
indem man Geld ausgibt. Die Aufteilung, die Reihenfolge, der Deckel und die Regel
„eine tote Achse ist keine bestandene" sind aber **Entscheidungen** — und die
gehören auf die Seite der Grenze, die ein normaler Test erreicht.

Ein Reviewer, der abstürzt, kippt keinen guten Lauf: der Auffangblock sitzt tief
genug, dass ein Absturz nicht als `conflict` endet. Sonst würde ein abgestürztes
Review Arbeit als nicht mergebar ablegen, die einen sauberen Merge und eine grüne
Suite hatte.

---

## 8 · Der Prompt, den jeder Agent bekommt

Vor deinem Issue-Text stehen vier feste Blöcke. **Dein Text steht zuletzt**, damit
die eigentliche Aufgabe die frischeste Information im Prompt ist.

| Block | Wann | Warum es ihn gibt |
|---|---|---|
| `CONTRACT` | immer | Drei Fakten: niemand schaut zu, ein **Commit** ist das einzige Fertig-Signal, frag nicht um Erlaubnis |
| `TDD` | immer | Rot → Grün → Prüfen → Commit |
| `PRIOR_WORK` | wenn der Branch schon Commits trägt | ein Neustart ohne Gedächtnis |
| `verifyFailureBlock` | nach roter Integrations-Suite | die Fehlerausgabe des letzten Versuchs |

Alle vier stehen als Konstanten in `src/operating-contract.ts` — im Code, nicht in
der Konfiguration, weil sie beschreiben, wie *dieser* Orchestrator arbeitet, und
nicht, was ein Projekt will.

**Warum `CONTRACT`:** der allererste echte Lauf baute die Sache korrekt — und
blieb dann stehen, um einen Menschen um Erlaubnis für den Commit zu fragen. Es
war niemand da.

**Warum `TDD` kein Stilthema ist:** eine grüne Suite beweist „nichts ist kaputt".
Sie beweist nie „das Verlangte wurde gebaut". Ein zuerst geschriebener, einmal rot
gesehener Test ist das billigste Ding, das diese Lücke schließt. Der Block gibt
vier Schritte vor: Test schreiben und laufen lassen (*„Er MUSS fehlschlagen"*),
minimalen Code schreiben, neuen Test **und** volle Suite laufen lassen, committen.
Im Block steht wörtlich *„Schwäche keinen Test ab, um ihn grün zu bekommen."*

Das ist eine **Bitte, keine Prüfung** — siehe Abschnitt 14. Die vier Schritte
laufen im Worktree des Agenten, und niemand sieht sie. Ob vorher etwas rot war,
steht nirgends; aus dem Ordner verlässt nur der Commit.

**Warum `PRIOR_WORK`:** im Container ist das real. Ein echtes Rate-Limit schlägt
zu, Sandcastle kopiert das Transkript nie aus dem Container heraus. Code und
Commits überleben — die Erinnerung nicht.

Ein Block wurde wieder **entfernt**: die Bitte, `<promise>COMPLETE</promise>` zu
drucken. Sie steuerte Sandcastles eigene Schleife, und die steht auf 1. **Eine
Anweisung, die einen abgeschalteten Mechanismus steuert, ist reine Kosten auf
jedem einzelnen Prompt.**

---

## 9 · Wo der Agent läuft: Host oder Container

Zwei Möglichkeiten. Auf dem **Host** heißt: direkt auf deinem Rechner, mit Zugriff
auf deine Festplatte. Im **Container** heißt: in einer abgeschotteten Docker-Kiste.

Entschieden wird in dieser Reihenfolge:

1. **Steht `isolation:` im Kopf der Notiz?** Dann gilt das. Steht dort ein Wert,
   den es nicht gibt — etwa `isolation: docker` —, **bricht der Lauf ab.** Wer
   sich beim Wort für Isolation vertippt, will Isolation. Als Schweigen gelesen
   liefe er auf dem Host, also genau falsch herum.
2. **Ist der Lauf geroutet?** Also: läuft er über ein fremdes Modell statt direkt
   über Anthropic? Dann **immer** Container. Steht in der Notiz gleichzeitig
   `isolation: host`, bricht es ab — beide Lesarten sind vertretbar, also wird
   keine still gewählt.
3. **Steht etwas Gefährliches in der Prosa?** Reguläre Ausdrücke suchen nach
   Signalen wie „braucht einen Dienst", „plattformabhängig", „zerstörerisch".
4. **Sonst: Host.** Das ist der Default.

Fällt die Entscheidung auf Container und es fehlt ein Zugangstoken, **bricht es
ab. Kein Rückfall auf den Host.**

**Die ehrliche Schwäche steht im Kopf der Datei selbst:** Schritt 3 sucht in Text,
den ein Mensch zufällig so formuliert hat. Das ist ein Auffangnetz, keine
Garantie. Wer das als „die Pipeline erkennt gefährliche Arbeit" liest, hat es
falsch gelesen — genau deshalb wird `isolation:` **zuerst** geprüft.

### Warum ein gerouteter Lauf zwingend in den Container muss

Claude Code fragt vor jedem Shell-Befehl ein zweites Modell, ob der Befehl sicher
ist. Läuft alles über ein Gateway, antwortet darauf irgendein fremdes Modell. Am
2026-07-31 maß `proof:doorman` ein kostenloses Modell in dieser Rolle: es lehnte
`chmod -R 777` korrekt ab und ließ `rm -rf` durch.

Auf dem Host ist dieser Prüfer **das Einzige** zwischen Agent und Festplatte. Und
die Richtungen kosten nicht gleich viel: etwas Harmloses zu blockieren kostet
einen Lauf, etwas Zerstörerisches durchzulassen kostet die Maschine.

**Was der Container nicht kauft:** er schützt deinen Rechner, nicht das Projekt.
Der Agent schreibt weiter in seinen Worktree und committet. Die Schranke vor
`main` bleibt die grüne Suite aus Abschnitt 3.

### Wunsch und Tatsache stehen nie im selben Feld

Dieselbe Lehre an drei Stellen:

| Wunsch (Mensch) | Tatsache (Maschine) |
|---|---|
| `isolation` | `mode` |
| `model` | `respondingModel` |
| `useGateway` | `routedVia` |

Gäbe es nur ein Feld, käme `mode: host` eines abgeschlossenen Laufs beim nächsten
Lesen als menschlicher Override zurück — und würde die Entscheidung für immer
einfrieren.

---

## 10 · Modell-Routing

Claude Code spricht die Anthropic-API und sonst nichts, bedingungslos. Ein
gefälschtes Gateway hat das gezeigt: das volle Werkzeug-Schema und acht spezielle
Header gehen bei jeder Anfrage raus, und keine Einstellung bewegt daran ein Feld.
Ein fremdes Modell kann so eine Anfrage nicht roh entgegennehmen. Also muss ein
**Gateway** dazwischen übersetzen.

Wo diese Naht sitzt, war keine Geschmacksfrage: die tatsächlichen Optionen von
Sandcastle — in der installierten Typdatei nachgesehen, nicht angenommen — haben
kein Feld für eine Adresse. Sie haben `env`. Also läuft die Umleitung über
Umgebungsvariablen.

**Der Schalter ist mit Absicht manuell.** Ein automatischer Wechsel bei
Rate-Limit brächte nichts: die geparkte Session liegt bei Anthropic, und
fortsetzen lässt sie sich nur dort. **Anbieterwechsel ist ein Neustart, kein
Fortsetzen.**

---

## 11 · Der Reaper — was aufgeräumt wird

Ein Aufräumer, der regelmäßig Reste einsammelt.

| Was | Regel |
|---|---|
| Worktrees | **Nie** einen, dessen Issue `provisioning`, `running` oder `rate_limited` ist |
| Branches | `issue/*`, verwaist, nach **7 Tagen** — Beweismaterial bekommt eine Woche |
| Container | erkannt am **Mount-Pfad**, weil der Name keine Issue-Nummer trägt |
| `safe.directory`-Einträge | **global**, nicht im Repo — dort leckt Sandcastle sie, eine pro Worktree, nie entfernt |

Die letzte Zeile ist keine Theorie: nach zwei Tagen Bauen waren 43 von 55
Einträgen tot.

**`hygieneDryRun` steht standardmäßig auf `true`** — der Reaper sagt beim ersten
Lauf nur, was er löschen *würde*. Ein Aufräumer, der ungefragt sofort löscht, ist
genau der übereifrige Aufräumer, vor dem gewarnt wird. Einen Zyklus zuschauen,
dann scharf schalten.

Ist ein Container-Mount unlesbar, gilt er als „unbewiesen" und wird in Ruhe
gelassen.

Der Job ist kleiner, als er aussieht, weil der Fehlerpfad das Beweismaterial
schon vom Worktree auf den **Branch** verschoben hat: Kilobytes statt eines
kompletten `node_modules`, und der Branch überlebt den Worktree. **Eine Ausnahme,
und sie ist das ganze Sicherheitsargument:** lässt sich die Arbeit nicht sichern,
bleibt der Worktree stehen. Die Arbeit eines Agenten zu verlieren ist schlimmer
als eine volle Festplatte.

---

## 12 · Guardrails, von vorn

Ein **Guardrail** ist eine Regel über den Code, die eine Maschine bei jedem Commit
entscheidet, ohne dass jemand zusieht. Ein Beispiel, das es wirklich gibt:
*„im Domänen-Ordner steht kein `throw`."*

Dieser Abschnitt beantwortet vier Fragen in dieser Reihenfolge: welche Regeln
gelten, womit sie durchgesetzt werden, wo das Werkzeug herkommt, und wann was
geprüft wird.

### 12.1 · Wann wird bestimmt, welche Regeln gelten?

**Einmal pro Projekt.** Nicht pro Issue, nicht pro Lauf, nicht bei jedem Merge.

Der Ort ist `/baseline` Step 3a — ein Schritt in smithys Einrichtungs-Skill,
`smithy\forge\skills\baseline\SKILL.md`. Er geht die Speisekarte in
`smithy\forge\GUARDRAILS.md` durch: 25 Zeilen, jede eine Regel, und **keine
einzige nennt ein Werkzeug.**

Warum die Speisekarte kein Werkzeug nennt: sie liegt im Plugin und wird beim
nächsten Update komplett ersetzt. Ein Werkzeugname mit Version wäre darin sofort
veraltet. Eine Zeile sagt deshalb, *was entschieden werden muss* — nie, *was es
entscheidet*.

Pro Zeile drei Handgriffe:

1. **Ein Werkzeug finden.** Über die Stufen in `LEGWORK.md`: Stufe 1 die
   `llms.txt` der Werkzeug-Doku, Stufe 2 der Research-Skill, Stufe 3 Papersuche,
   Stufe 4 Video, Stufe 5 den Quelltext des Pakets lesen. Man arbeitet sich hoch,
   bis eine Antwort trägt. Das Ergebnis gilt als **Annahme**.
2. **In `STACK.md` festnageln**, mit der Version, die das Projekt wirklich fährt.
3. **Mit einer kaputten Datei beweisen.** Die kleinste Datei schreiben, die die
   Regel *bricht*, das Werkzeug darüber laufen lassen, und darauf bestehen, dass
   es meckert.

Erst Schritt 3 macht aus der Annahme eine Tatsache. **Eine Zeile, die Schritt 3
nicht besteht, wird nicht installiert.**

Danach existieren vier Dinge, die vorher nicht existierten — und sie liegen an
vier Orten, weil sie **verschieden schnell altern:**

| Stück | Datei | Altert wodurch |
|---|---|---|
| **Regel** | `smithy\forge\GUARDRAILS.md` | gar nicht — sie nennt kein Werkzeug |
| **Bindung** an ein Werkzeug | `STACK.md` | Werkzeug-Versionen |
| **Beweis** | `gates/<regel>/` im Projekt | läuft in der CI bei jedem Commit |
| **Quittung** | `GUARDRAILS-INSTALLED.md` im Projekt | ein Mensch liest sie |
| **Auftrag ans Review** | `REVIEW-STANDARDS.md` | wird an einen Sub-Agenten gereicht |

Die letzte Zeile ist für alles da, was **keine** Maschine entscheidet. Der Katalog
sortiert seine Zeilen in drei Klassen: `checked` wird ganz mechanisch geprüft,
`partial` nur zur Hälfte — die andere Hälfte geht ans Review —, `judgment` gar
nicht. Die ungeprüften Hälften und die `judgment`-Zeilen landen in
`REVIEW-STANDARDS.md`, ausformuliert als Anweisung an einen Leser.

### 12.2 · Wo liegt das gefundene Werkzeug?

Drei Antworten, weil hier drei verschiedene Dinge gemeint sein können.

**Das Werkzeug selbst** — eslint, tsc, dependency-cruiser — liegt **im Projekt**,
in dessen `node_modules`, installiert über dessen `package.json`. Es wandert
nirgendwohin. Jedes Projekt hat sein eigenes.

**Die Erkenntnis, welches Werkzeug es ist**, steht in `STACK.md` im
pipeline-weiten Root — eine Ebene über den einzelnen Specs. Das ist der Ort, an
dem eine zweite Idee im selben Projekt nicht noch einmal sucht.

**Die fertige Konfiguration** liegt in `.claude\guardrails\<stack>\` **im Vault**.
Das ist der Ort, an dem ein *anderes* Projekt nicht noch einmal sucht.

Was dort heute wirklich liegt, für TypeScript:

```
.claude/guardrails/typescript/
  .dependency-cruiser.cjs      Struktur-Regeln (Domänen, Zyklen, I/O am Rand)
  eslint.config.js             Lint-Regeln über dem Quelltext
  tsconfig.json                die strengste Typprüfung
  .nvmrc                       die Node-Version
  .github/workflows/gates.yml  was die CI startet
  gates/
    run.mjs                    der Beweislauf
    erzeuge-fixtures.mjs       legt die kaputten Dateien an
    skripte/                   drei Ratchet-Skripte plus ihre Basislinien
```

Kopiert wird das von `node .claude/scripts/init-project.mjs <ziel> --stack=typescript`,
1:1 in die Projekt-Root, und **nie überschreibend**: existiert eine Datei im Ziel
schon, wird sie übersprungen und gezählt.

Zwei Dinge daran sind wichtig:

**Die kaputten Dateien werden nicht mitkopiert.** Sie entstehen erst im Ziel, aus
`gates/erzeuge-fixtures.mjs`. Eine kopierte kaputte Datei würde stillschweigend
veralten, sobald ein Werkzeug seinen Fehlercode ändert — der Generator trägt die
erwarteten Meldungen an einer einzigen Stelle.

**Kopiert heißt nicht bewiesen.** Nach dem Kopieren einmal `node gates/run.mjs`,
und das muss `18/18 Regeln bewiesen` melden. Erst dann darf ein Datum in die
Quittung.

Der Preis dieser Ablage steht in [[guardrails-into-projects]]: die Vorlage liegt
im Vault, nicht im Plugin. Sie wandert **nicht** mit, wenn jemand anders smithy
installiert.

### 12.3 · Wann wird geprüft — und von wem?

Hier werden drei Befehle verwechselt. Sie laufen an verschiedenen Orten und
beantworten verschiedene Fragen.

| Befehl im Projekt | Läuft über | Beantwortet | Wo im Lauf |
|---|---|---|---|
| `npm test` | den echten Code | **Läuft es?** | Prüfung 2, `runSuite` |
| `npm run lint`, `typecheck`, `struktur` | den echten Code | **Bricht es eine Regel?** | Prüfung 3, `runChecks` |
| `node gates/run.mjs` | die absichtlich kaputten Dateien | **Sind die Regeln überhaupt noch scharf?** | **gar nicht im Lauf** — nur in der CI |

Der Reihe nach.

**`runSuite` startet den `testCommand`** aus `pipeline.config.json`, Voreinstellung
`npm test`. Das sind die Tests, die das Projekt für sich selbst geschrieben hat. ==~~Sind das die tdd Tests?~~==
Mit Guardrails hat das nichts zu tun.

**`runChecks` startet den `checkCommand`.** Das *sind* die Guardrails, angewandt
auf den echten Code. Bei der TypeScript-Vorlage ist das die Gruppe
`npm run typecheck`, `npm run lint`, `npm run struktur` plus die drei
Ratchet-Skripte. Ist `checkCommand` leer, gibt `runChecks` `undefined` zurück —
also „übersprungen", nie „bestanden".

Beide laufen im **Integrations-Worktree**, nacheinander, Suite zuerst. Der
Kommentar in `src/config.ts` nennt den Grund für die Reihenfolge: ein Repo, dessen
Tests nicht durchlaufen, hat ein größeres Problem als seinen Lint, und beides
gleichzeitig zu starten begrübe den ersten Fehler unter dem zweiten.

Und der Grund, warum die Guardrails überhaupt hier laufen und nicht bloß in der
CI: **die CI läuft nach dem Push.** Eine Verletzung, die dort auffällt, liegt
schon auf `main` und wird hinterher gemeldet. Ein Guardrail ist per Definition
eine Regel, die hält, wenn niemand zusieht — also muss sie entscheiden, *bevor*
`main` sich bewegt. Die CI im Zielrepo bleibt trotzdem nützlich, als zweites Netz
für Menschen, die von Hand pushen.

**`node gates/run.mjs` ist der dritte, und er ist nicht Teil des Merge-Pfades.**
Er läuft in der CI des Projekts, bei jedem Push. Er prüft nicht den Code — er
prüft die Prüfer.

Der Workflow zeigt beide Blöcke nebeneinander
(`.claude/guardrails/typescript/.github/workflows/gates.yml`):

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

Zwei Blöcke, zwei Fragen. Der erste fragt den Code. Der zweite fragt die Regeln.

### 12.4 · Warum es die kaputten Dateien braucht

Das ist der tragende Satz des ganzen Baus, und er lohnt eine Geschichte.

Du hast eine Regel: *im Domänen-Ordner steht kein `throw`.* Sie ist eine Zeile in
`eslint.config.js` und nennt dort einen Regelnamen beim Namen.

Eslint 11 kommt heraus. Der Regelname heißt jetzt anders. Du aktualisierst.
`npm run lint` läuft, findet nichts, beendet sich mit 0. Grün.

Und dein Code *ist* sauber — du hast ja nie ein `throw` in die Domäne geschrieben.

Jetzt die Frage: **läuft deine Regel noch?**

An dieser Ausgabe kannst du es nicht sehen. „Grün" bedeutet hier zwei völlig
verschiedene Dinge, und beide sehen gleich aus:

| | Regel lebt | Regel ist tot |
|---|---|---|
| **sauberer Code** | geht durch | geht durch |
| **dreckiger Code** | fällt durch | geht durch |

Die obere Zeile ist in beiden Spalten gleich. Eine Beobachtung, die in beiden
Welten dasselbe Ergebnis hat, trennt sie nicht — sie trägt **null Information.**

Die untere Zeile unterscheidet sich. Sie ist die einzige, die das tut. Deshalb
lautet die Prüfung nie „lässt sauberer Code das Gate passieren", sondern immer
**„lässt dreckiger Code es scheitern".**

**Eine Regel stirbt ohne Vorwarnung**, und auf mehr Wegen als dem einen oben. Der
Linter benennt sie um. Ein Selektor zeigt auf eine Syntax, die es nicht mehr gibt.
Eine Konfigurationszeile landet im falschen Block und wird stillschweigend
ignoriert. Oder — der Fall, der hier schon passiert ist — du kopierst die Vorlage
in ein Projekt mit anderen Ordnernamen und vergisst, die Liste `DOMAENEN` in
`.dependency-cruiser.cjs` und `eslint.config.js` anzupassen. Dann greifen die
Regeln über einen Ordner, den es nicht gibt. Sie laufen, finden nichts, melden
Erfolg.

In keinem dieser Fälle bricht etwas ab.

### 12.5 · Wie ein Beweis-Ordner aussieht

Ein Ordner **pro Regel**, im Projekt, unter `gates/`:

```
gates/<slug>/
  erwartung.json     welches Werkzeug, welche Katalogzeile, welcher Text muss in der Ausgabe stehen
  fixture.ts         die kaputte Datei          (bei tsc)
  src/<domäne>/…     die kaputte Datei im Baum  (bei eslint und dependency-cruiser)
  tsconfig.json      eigenes Projekt            (bei tsc und eslint)
```

Ein echtes Beispiel aus `gates/erzeuge-fixtures.mjs` — der Slug
`kein-throw-im-kern`, gebunden an eslint, Katalogzeile *„no throw inside the
domain"*, Klasse `checked`. Die kaputte Datei ist genau das:

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

Gestartet wird mit `node gates/run.mjs` (alle Regeln) oder
`node gates/run.mjs <slug>` (eine).

**`erwartung.json` prüft zwei Dinge getrennt:** dass das Werkzeug überhaupt
meckert (Exit ungleich 0), und dass es **aus dem richtigen Grund** meckert. Die
zweite Hälfte ist nötig, weil eine kaputte Datei auch durchfällt, wenn sie an
einem Tippfehler scheitert — und das sähe ohne die Textprüfung genauso aus wie ein
Erfolg.

Deshalb unterscheidet `run.mjs` zwei Fehlermeldungen, und sie bedeuten
Gegensätzliches:

| Meldung | Was passiert ist | Was zu tun ist |
|---|---|---|
| *„das Werkzeug war zufrieden"* | Die Regel ist weg | Konfiguration reparieren |
| *„Fehlschlag ja, aber ohne `<text>`"* | Die Regel greift, meldet nur anders | `erwartung.json` nachziehen |

Zwei Fallen, in die dieser Ordner schon getreten ist. **`exclude` wird vererbt:**
die Wurzel-`tsconfig.json` schließt `gates` aus, damit die kaputten Dateien den
normalen Bau nicht dauerhaft rot färben — ein Fixture-Projekt, das `extends`
benutzt und `exclude` nicht überschreibt, schließt sich damit selbst aus, und
`tsc` meldet `TS18003: No inputs were found` statt des echten Fehlers. **Und die
Domänen-Globs in `eslint.config.js` brauchen ein führendes `**/`:** ohne das
greift die Regel in `src/`, aber nicht in `gates/<slug>/src/`, und das Fixture
bewiese eine andere Regel als die, die im Bau läuft.

Ein Namensunterschied, der auffällt: diese Notiz und die Vault-Vorlage sagen
`gates/<regel>/`, smithys `/baseline` sagt „speichere es als Proof-Skript in
`verification/` neben dem Spec". Dieselbe Sache, zwei Orte. Gelaufen ist die
Vault-Variante.

### 12.6 · Wo stehen die Guardrails, die für ein Projekt gelten?

An zwei Orten, und sie sagen Verschiedenes.

**Was wirklich läuft**, steht in der `package.json` des Projekts und in
`.github/workflows/gates.yml`. Das ist die Wahrheit: was die CI und der
`checkCommand` starten, ist was gilt.

**Was davon bewiesen ist**, steht in `GUARDRAILS-INSTALLED.md` in der Projekt-Root.
Sechs Spalten:

```
| Guardrail | Machine | Class | Bindung | Fixture | Bewiesen am |
```

Der Kopf der Datei sagt selbst, worauf es ankommt: *„Eine Zeile ohne Fixture ist
keine geltende Regel."* Die Spalte **Bewiesen am** ist die einzige, die zählt.

Die Regel-*Liste* steht dort ausdrücklich nicht. Sie steht in
`smithy\forge\GUARDRAILS.md`. `GUARDRAILS-INSTALLED.md` wählt daraus aus und
schreibt auf, womit gebunden wurde.

Und `REVIEW-STANDARDS.md` ist wieder etwas anderes, obwohl beide aus demselben
Katalog gespeist werden:

| Datei | Was sie ist | Wer liest sie |
|---|---|---|
| `GUARDRAILS-INSTALLED.md` | eine **Quittung**: was eine Maschine entscheidet, womit, seit wann bewiesen | ein Mensch |
| `REVIEW-STANDARDS.md` | ein **Auftrag**: der Text, den der Review-Fächer einer Achse als Maßstab reicht | eine Maschine, die ihn weitergibt |

Zwei Leser, zwei Lebensdauern, zwei Dateien. Bis zum 2026-08-03 waren sie ein
Dokument mit zwei Abschnitten; jetzt zeigt der eine nur noch auf den anderen.

`init-project.mjs` legt `GUARDRAILS-INSTALLED.md` **leer** an. Absichtlich: was in
einem Projekt bewiesen wurde, gilt im nächsten nicht. Leer ist für ein neues
Projekt der korrekte Zustand, kein fehlender.

### 12.7 · Vier Arten, eine Regel durchzusetzen

Der Katalog ordnet jede Zeile einer von vier Maschinen zu. Welche, entscheidet die
Kosten.

- **Deklaration** — eine Datei nennt die erlaubten Kanten zwischen Ordnern, ein
  Werkzeug macht Build-Fehler daraus. Mit Abstand die billigste: alle
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

### 12.8 · Stand

**Im Orchestrator selbst ist keine installiert.** `orchestrator/` hat strenges
`tsc` von Hand gesetzt, das ist eine Zeile der Compiler-Art. Sonst nichts.

**Die TypeScript-Vorlage dagegen existiert und ist bewiesen** — am 2026-08-15 in
`zaehlen\wiki-api-retriever`, gegen `smithy/forge/GUARDRAILS.md`. Achtzehn der 25
Katalogzeilen sind dort gebunden; die übrigen sieben brauchen etwas, das eine
Vorlage nicht mitbringen kann (einen zweiten Kontext, git-Historie,
`IDIOLEKT.md`). Die Versionen, gegen die bewiesen wurde: typescript 6.0.3,
eslint 10.8.1, typescript-eslint 8.67.0, dependency-cruiser 18.2.0,
type-coverage 2.30.1, zod 4.4.3, node 24.15.0.

Steigt eine dieser Versionen, ist `node gates/run.mjs` der Test, ob die Bindung
noch trägt.

---

## 13 · Warum das überhaupt prüfbar ist: die Ports

Ein **Port** ist eine Naht: eine schmale Schnittstelle, hinter der im Betrieb das
Echte steckt und im Test eine Attrappe. Es gibt sechs — für den Issue-Speicher,
git, den Agenten, das Review, eine einzelne Review-Achse und den Reaper.

Der Grund ist immer derselbe: **die Entscheidungen prüfbar machen, ohne einen
echten Claude-Lauf zu bezahlen.**

**Stand der Messung am 2026-08-03:** 22 Quelldateien, 33 Testdateien mit 238
Tests, alle grün, dazu 8 Proof-Skripte.

### 13.1 · Warum `runChecks` als einzige optional ist

Die Schnittstelle `GitPort` (`src/git.ts:21`) listet auf, was der Orchestrator von
git braucht: einen Integrations-Worktree anlegen, mergen, einen Merge abbrechen,
die Suite laufen lassen, die Guardrails laufen lassen, veröffentlichen, fragen ob
ein Branch noch ungemergte Commits trägt.

Im Betrieb steckt dahinter der echte `GitAdapter`, der wirklich git-Befehle
startet. Im Test steckt eine Attrappe: ein von Hand gebautes Objekt mit denselben
Methoden, die nur festhalten, dass sie gerufen wurden.

**TypeScript verlangt: eine Attrappe muss jede Methode der Liste haben.** Fehlt
eine, kompiliert die Testdatei nicht. `runChecks` trägt als einzige ein `?` — sie
darf fehlen.

Zwei Gründe, und der zweite ist der wichtigere.

**Erstens: der Platzhalter wäre Lärm, der wie ein Signal aussieht.** Ohne das `?`
müsste in jeder Attrappe eine Zeile wie diese stehen:

```ts
runChecks: async () => undefined,
```

Heute bauen **sieben** Testdateien eine git-Attrappe — `conflict`, `provisioning`,
`resume-existing-commits`, `review-gate`, `session-lost`, `verify-retry`,
`wip-preservation` — und nur `review-gate.test.ts` prüft überhaupt Guardrails.
Sechsmal reines Beiwerk. Und dieses Beiwerk erschiene im Diff des Commits, der es
einführt, und in jedem späteren `git log -p` dieser Dateien: als hätte jemand an
den Guardrails etwas geändert.

*(Der Kommentar im Code spricht von acht Dateien. Gezählt sind heute sieben. Die
Zahl hat sich bewegt, das Argument nicht.)*

**Zweitens: eine fehlende Methode sagt etwas Wahres.** Sie liest sich als das, was
sie ist — eine Installation ohne mechanische Regeln. Ein Platzhalter, der
`{ ok: true }` zurückgäbe, sagt dagegen „die Regeln sind bestanden", und das ist
gelogen, wenn es keine gibt.

Der Aufruf im Integrator ist entsprechend gebaut:

```ts
const checks = await this.git.runChecks?.(integration.path);
if (checks && !checks.ok) { … }
```

Das `?.` heißt: gibt es die Methode nicht, ruf sie nicht, ergib `undefined`. Und
die Bedingung behandelt `undefined` als „übersprungen", nie als „bestanden".
Dasselbe eine Ebene tiefer: der echte `GitAdapter.runChecks` gibt `undefined`
zurück, wenn `checkCommand` leer ist — nicht `{ ok: true }`.

Das ist Abschnitt 15, angewandt.

### 13.2 · FALSIFY FIRST, und die fünf Dateien aus echten Läufen

Fast jede Testdatei trägt denselben Kopf: **FALSIFY FIRST.** Also nicht „beweise,
dass es geht", sondern „konstruiere den Fall, in dem es **still** danebengeht".

Fünf Testdateien existieren, weil ein echter Lauf oder eine falsche Vorhersage sie
erzwungen hat — nicht, weil jemand sie sich ausgedacht hat:

| Datei | Was passiert war |
|---|---|
| `test/startup-scan-concurrency.test.ts` | 2026-07-25: `concurrency: 3`, drei fertige Notizen beim Start, und trotzdem lief nur **ein** Container. Ursache: die `for…of`-Schleife im Startup-Scan wartet mit `await` auf den *ganzen* Lauf, bevor sie weiterzählt — der Ereignis-Pfad tut das nicht |
| `test/resume-existing-commits.test.ts` | `iss-2026-001` committete `2e14772` (fertig, getestet) und lief dann ins Fünf-Stunden-Fenster. Der Wiederaufnahme-Lauf meldete `commits: []` — es war nichts mehr zu tun — und `settle()` nannte den Lauf `failed`, obwohl die Arbeit fertig auf dem Branch lag |
| `test/session-lost.test.ts` | 2026-07-25, 11:42: echtes Rate-Limit nach 16 Sekunden im Container. Alles griff, die Notiz parkte korrekt. Das Aufwachen um 12:07 starb an einer fehlenden Sitzungsdatei — Sandcastles `captureToHost` steht **nach** `invokeAgent`, ohne `finally`, und ein echtes Limit *wirft* |
| `test/wake-failure.test.ts` | 2026-07-14: geparkt 12:01, geweckt 16:10:00.496 — unbeaufsichtigt, vier Stunden später, eine halbe Sekunde zu spät. Dann starb `git config --global --add safe.directory` mit Exit 3221225794, also Windows `0xC0000142`: das Betriebssystem konnte kurz keinen Prozess starten. Sekunden später lief derselbe Befehl fehlerfrei |
| `test/provisioning.test.ts` | Die Vorhersage lautete: frischer Worktree ohne `node_modules` → rote Suite. Sie wurde **grün**, gegen ein fremdes `node_modules` aus einem übergeordneten Ordner (Abschnitt 3) |

### 13.3 · Proof-Skripte sind keine Tests

Der Unterschied ist der Preis, und daraus folgt alles andere.

**Ein Test kostet nichts.** Attrappen, Wegwerf-Ordner, Sekunden. `npm test` startet
alle 33 Dateien auf einmal, bei jeder Änderung, und muss immer grün sein.

**Ein Proof kostet etwas Echtes:** einen bezahlten Claude-Aufruf, einen laufenden
Docker-Daemon, oder vier Stunden Warten. So etwas kann nicht in einer Suite
stehen, die bei jedem Commit durchlaufen muss.

Also: eigener Ordner `verification/`, ein eigener Befehl je Datei, gestartet von
Hand. Acht Stück:

| Befehl | Datei | Was er beweist | Was er kostet |
|---|---|---|---|
| `proof:review` | `review-e2e.ts` | zwei Review-Achsen finden je ihren gepflanzten Fehler | Geld |
| `proof:doorman` | `doorman-judgment.ts` | der Permission-Prüfer wird beim Durchlassen von `rm -rf` ertappt | Geld |
| `proof:gateway-translation` | `gateway-translation-proof.ts` | das Gateway gegen die **echte** `claude`-Binärdatei statt gegen ihre Doku | Geld |
| `proof:resume` | `rate-limit-resume-e2e.ts` | ein echtes Fünf-Stunden-Fenster wird geparkt und wacht selbst auf | Wartezeit |
| `proof:one-issue` | `run-one-issue.ts` | ein Issue läuft von Anfang bis Merge durch | Geld |
| `proof:container` / `proof:host` | `container-e2e.ts` | beide Befehle zeigen auf dieselbe Datei | Docker |
| `proof:provisioning` | `provisioning-e2e.ts` | die Paketinstallation im frischen Worktree | Docker |
| `proof:reaper-docker` | `reaper-real-docker.ts` | der Aufräumer gegen echtes Docker | Docker |

**Und warum es sie trotzdem geben muss:** jeder von ihnen deckt genau die Stelle
ab, an der eine Attrappe nichts beweist. Die Attrappe von git nahm `branch -f`
fröhlich an. Die Doku von `claude` sagte etwas anderes als die Binärdatei. Ein
selbstgebautes Rate-Limit-Ereignis hat die Form, die man ihm gibt — das echte
hatte eine andere, und deshalb ging `settle()` beim ersten Mal am Problem vorbei.

Zwei davon waren beim Archivieren beinahe verloren. Sie lebten in der Pipeline, in
der der Orchestrator gebaut wurde, und kamen gerade noch mit. Die Lehre: **Beweise
gehören neben den Code, den sie beurteilen.**

---

## 14 · Was am 2026-08-03 nicht funktioniert

Alles hier ist belegt, nichts davon ist Vermutung.

| Loch | Warum es nicht einfach behoben ist |
|---|---|
| **Keine `pipeline.config.json`** | Auf dieser Maschine existiert keine. Alles oben ist gebaut und **nicht angeschlossen** |
| **Keine Guardrails im Orchestrator installiert** | Die TypeScript-Vorlage ist seit 2026-08-15 gebunden und bewiesen (Abschnitt 12.8) — aber in einem anderen Projekt. Hier liegt nur strenges `tsc` |
| **Ein Agent kann grün werden, indem er den Test löscht** | Der Prompt bittet darum, es nicht zu tun. Eine Prüfung gibt es nicht, und die naive Regel „ein Test wurde geändert" taugt nicht: eine Umbenennung **muss** jeden Test anfassen, der das Symbol nennt |
| **Ein roter Test wird verlangt, aber nie gesehen** | Die vier TDD-Schritte laufen im Worktree des Agenten. Aus dem Ordner verlässt nur der Commit. Ob je etwas rot war, steht nirgends |
| **`REVIEW-STANDARDS.md` ist leer** | Die Mechanik ist bewiesen — mit einem Platzhaltertext. Ein echter Standard existiert nirgends |
| **Ein Rate-Limit zur Review-Zeit lässt den Diff ungeprüft durch** | Die Park-Mechanik umgibt nur den Bau-Agenten. Der Review-Pfad kennt sie nicht: die Achse wird `skipped`, `publish` läuft, niemand holt sie nach (Abschnitt 7) |
| **Kein `awaiting_decision`** | Abschnitt 4 |
| **Ein Merge-Konflikt hat genau eine Verteidigung** | Als *letzte* Linie ist sie richtig. Sie ist derzeit die einzige. Vorbeugen hieße: B rebaset, sobald A merged — das ändert aber, was einem laufenden Agenten zugesagt wurde (Abschnitt 3b) |
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

---

## 15 · Die eine Regel darunter

Sie taucht an mindestens sieben Stellen unabhängig auf, jedes Mal anders formuliert:

> **Eine Abwesenheit muss als Abwesenheit lesbar sein.**

- „Übersprungen" ist etwas anderes als eine leere Befundliste. „Nie geprüft" ist
  nicht „geprüft, nichts gefunden".
- `runChecks` gibt nichts zurück statt „alles in Ordnung" — ein Repo ohne
  Guardrails hat sie nicht *bestanden*, es hat keine.
- Eine fehlende Methode auf dem Port sagt „keine mechanischen Regeln", ein
  Platzhalter würde „bestanden" sagen (Abschnitt 13.1).
- Kein Review-Kommando heißt **kein** Review, nicht ein Review, das alles
  durchwinkt.
- Ein fehlender Standardtext darf nie als leerer Text ankommen.
- Eine Achse ohne Standard wird übersprungen, statt eine Meinung im Gewand einer
  Messung zu produzieren.
- Ein Fixture prüft, ob **dreckiger** Code scheitert — nie, ob sauberer durchgeht
  (Abschnitt 12.4).

Der Grund ist jedes Mal derselbe: **die andere Wahl sieht von unten aus wie
Erfolg.**

### Und die achte Stelle bricht sie

Im selben Programm. Das Review weigert sich ausdrücklich, etwas Unparsbares als
„nichts gefunden" zu melden — es wird übersprungen, weil ein kaputtes Review
Nichtwissen ist.

Der Issue-Speicher steht vor exakt derselben Lage — eine Notiz, die nicht parst —
und tut das Gegenteil: er wirft, und danach überspringt der Zwischenspeicher
dieselbe Notiz still. Ein Verzeichnis, das leise eine Notiz weniger meldet, als es
hält, **ist** wörtlich die Abwesenheit, die nicht als Abwesenheit lesbar ist.

Zwei Nähte, dieselbe Frage, entgegengesetzte Antworten, ein Programm. Das ist der
Grund, warum diese Regel aufgeschrieben gehört und nicht bloß befolgt wird: **wo
sie nur Gewohnheit ist, gilt sie da, wo jemand gerade daran dachte.**

Gefunden hat das übrigens kein Mensch, sondern ein Agent, der die echte Klasse
gegen Wegwerf-Verzeichnisse laufen ließ, statt den Code zu lesen.

---

## Verwandt

[[orchestrator-map]] — die Kurzfassung mit den Diagrammen und den Dateinamen.
Wenn du sie danach liest, ist sie eine Erinnerungsstütze statt einer Einführung.

[[isolation-levels]] — Host, Container, und was welcher schützt.

[[system-strengths]] — warum in diesem Vault direkt auf `main` committet wird, im
Agenten-Repo aber jeder Agent einen eigenen Branch bekommt.

[[guardrails-into-projects]] — was es kostet, dass die Stack-Vorlagen im Vault
liegen und nicht im Plugin.
