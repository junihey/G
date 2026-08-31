---
tags: [learning, orchestrator]
created: 2026-08-29
topic: Der Orchestrator von Grund auf -- was er ist, wie ein Lauf abläuft, welche Prüfung was beantwortet, und was am 2026-08-03 gebaut, aber nicht angeschlossen war
verification: abgeleitet aus claude-notes/orchestrator-map.md (verified 2026-08-03, Nachtrag 2026-08-05) -- nicht selbst gegen den Code geprüft
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

---

## 1 · Die sechs Wörter, ohne die der Rest nicht trägt

Diese sechs kommen unten dauernd vor. Ohne sie liest sich alles wie Nebel.

**Issue-Note.** Eine Markdown-Datei in Obsidian, eine pro Aufgabe. Oben im Kopf
stehen Felder wie `status:`, `slice:`, `priority:`. Unten steht in Prosa, was
gebaut werden soll. Diese Datei ist gleichzeitig der Auftrag *und* das Protokoll:
der Orchestrator schreibt seinen Fortschritt in dieselbe Datei zurück.

**`main`.** Der eine Hauptstrang des Projekts. Was hier liegt, gilt als gültiger
Stand.

**Branch.** Eine Abzweigung von `main`. Der Agent arbeitet nie direkt auf `main`,
sondern auf einem eigenen Branch namens `issue/<nummer>`.

**Worktree.** Eine zweite, vollständige Kopie des Projektordners auf der
Festplatte, die an einem eigenen Branch hängt. Zwei Agenten in zwei Worktrees
stolpern nicht übereinander — jeder hat seinen eigenen Ordner mit seinen eigenen
Dateien. Sie teilen sich nur die Versionsgeschichte darunter.

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
6. **Der Agent arbeitet.** Er bekommt einen festen ==Vertragstext== plus den Body
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

| #   | Prüfung             | Die Frage                                        | Bei Rot                                                                                    |
| --- | ------------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------ |
| 1   | `git merge --no-ff` | Passt der Text überhaupt auf das heutige `main`? | **Mensch.** Kein neuer Versuch                                                             |
| 2   | `runSuite`          | Läuft es?                                        | ==zurück an den Agenten, mit der Fehlerausgabe== ~~läuft hier der tdd Test~~               |
| 3   | `runChecks`         | Bricht es eine mechanische Regel?                | dasselbe                                                                                   |
| 4   | `review`            | Tut es, was verlangt war?                        | ==**nichts.** Es berichtet nur== ~~gibt es hier einen Loop path und wo berichtet es hin ~~ |

### Warum Prüfung 1 nicht an den Agenten zurückgeht

Ein Textkonflikt heißt: jemand anders hat dieselben Zeilen geändert, während
unser Agent arbeitete. Der Agent sitzt in seinem eigenen Worktree und **sieht die
andere Seite gar nicht.** Ihn das lösen zu lassen wäre, ihn raten zu lassen. Also landet die Arbeit auf dem Branch, der Worktree wird abgeräumt, und du entscheidest. ==~~Zieht hier rebase, was ist die merge queue~~==

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
abschalten wird. Also berichtet es und stoppt nichts.==~~wo berichtet es hin?~~==

### Der Satz, um den es eigentlich geht

Er steht im Kopf von `review.ts`:

> **Bei der Testsuite sollte man unruhig sein.**

Denn geschrieben hat sie derselbe Agent, der den Code schrieb. Hat er die Aufgabe
falsch verstanden, testet er das, was er sich vorgestellt hat — und das ist grün.
Von unten sieht ein falsch verstandenes Issue **exakt aus wie Erfolg.** Das ist
der Grund, warum es Prüfung 4 überhaupt gibt. ==~~Warum kein falscher Test geschrieben~~==

### Und wenn alles durch ist

==Der letzte Schritt heißt `publish` und ist ein `git merge --ff-only` im==
==Haupt-Checkout — **nicht** `git branch -f`. Grund: git weigert sich, einen Branch==
==zwangszubewegen, der irgendwo ausgecheckt ist, und `main` ist immer ausgecheckt.==
==Aufgefallen ist das erst, als ein Test gegen echtes git lief. Die Attrappe im==
==Test hatte `branch -f` fröhlich angenommen==.

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
==Der nebenläufige Fall: zwei Ereignisse zur selben Notiz rasen los, bevor eines==
==fertig ist. Der Anspruch wird deshalb **synchron** gesetzt. Alles, was vorher auf==
==etwas wartet, ist ein Rennen.==

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

**Die Zahl der gleichzeitigen Aufrufe ist gedeckelt, und das ist keine
Geschwindigkeitsfrage.** ==Fünf `claude -p` gehen auf *ein* Rate-Limit-Fenster.==
==Ungedeckelt tauscht man „das Review dauerte länger" gegen „drei Achsen sind==
==gestorben" — und eine tote Achse sagt nichts über einen Diff, den danach niemand==
==mehr ansieht.==

### Was zurückkommt, und der eine Fall, der verweigert wird

Das Kommando bekommt seine Aufgabe über Umgebungsvariablen (welches Issue,
welcher Branch, welche Achse, welcher Diff, welcher Standardtext) und antwortet
mit `{"findings":[…]}` oder `{"skipped":"warum"}`.

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

| Block                | Wann                                | Warum es ihn gibt                                                                                     |
| -------------------- | ----------------------------------- | ----------------------------------------------------------------------------------------------------- |
| ==`CONTRACT`==       | immer                               | Drei Fakten: niemand schaut zu, ein **Commit** ist das einzige Fertig-Signal, frag nicht um Erlaubnis |
| `TDD`                | immer                               | Rot → Grün → Prüfen → Commit                                                                          |
| `PRIOR_WORK`         | wenn der Branch schon Commits trägt | ein Neustart ohne Gedächtnis                                                                          |
| `verifyFailureBlock` | nach roter Integrations-Suite       | die Fehlerausgabe des letzten Versuchs                                                                |

**Warum `CONTRACT`:** der allererste echte Lauf baute die Sache korrekt — und
blieb dann stehen, um einen Menschen um Erlaubnis für den Commit zu fragen. Es
war niemand da.

**Warum `TDD` kein Stilthema ist:** eine grüne Suite beweist „nichts ist kaputt".
Sie beweist nie „das Verlangte wurde gebaut". Ein zuerst geschriebener, einmal rot
gesehener Test ist das billigste Ding, das diese Lücke schließt. Im Block steht
wörtlich *„Schwäche keinen Test ab, um ihn grün zu bekommen."* Das ist eine
**Bitte, keine Prüfung** — siehe Abschnitt 14.

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

## 12 · Guardrails: die Regel, die Bindung, der Beweis

Ein **Guardrail** ist eine mechanische Regel, die der Build durchsetzt. Die Teile
liegen an vier Orten, weil sie **verschieden schnell altern.**

| Stück                       | Datei                       | Altert wodurch                                                                              |
| --------------------------- | --------------------------- | ------------------------------------------------------------------------------------------- |
| **Regel**                   | `forge/GUARDRAILS.md`       | gar nicht — sie nennt kein Werkzeug                                                         |
| **Bindung** an ein Werkzeug | `STACK.md`                  | Werkzeug-Versionen ==~~wie werden die Werkzeuge für jedes einzelne guardrails gefunden?~~== |
| **Beweis**                  | `gates/<regel>/` im Projekt | läuft in der CI bei jedem Commit ~~==wo genau?==~~                                          |
| **Quittung**                | `GUARDRAILS-INSTALLED.md`   | ein Mensch liest sie ==~~die im Projekt genutzt werden?~~==                                 |
| **Auftrag ans Review**      | `REVIEW-STANDARDS.md`       | wird an einen Sub-Agenten gereicht                                                          |

Vier Arten, eine Regel durchzusetzen: eine **Deklaration** (eine Datei nennt
erlaubte Kanten, ein Werkzeug macht Build-Fehler daraus — mit Abstand die
billigste), ein **Typ**, der die Verletzung nicht kompilierbar macht, eine
**Lint-Regel** über den Quelltext, und ein **Ratchet**: ein Zähler plus
gespeicherter Basislinie, der Build fällt, wenn der Zähler steigt.

Drei Klassen von Regeln, und die mittlere ist der ganze Grund für
`REVIEW-STANDARDS.md`: `checked` wird ganz mechanisch geprüft, `partial` nur zur
Hälfte — die andere Hälfte geht ans Review —, `judgment` gar nicht.

**==Der tragende Satz des ganzen Baus:** ein Gate, dessen Regelname umbenannt wurde,==
==**bricht nicht ab.** Es läuft und findet nichts. Und das sieht aus wie ein==
==sauberes Repo. Nur ein Test-Fixture, das durchfallen *muss*, unterscheidet die==
==beiden. Die Prüfung lautet deshalb nie „lässt sauberer Code das Gate passieren",==
==sondern immer **„lässt dreckiger Code es scheitern".**==

**Installiert ist am 2026-08-03: keine.** `orchestrator/` hat strenges `tsc` von
Hand gesetzt, das ist eine Zeile der Typ-Art. Sonst nichts.

---

## 13 · Warum das überhaupt prüfbar ist: die Ports

Ein **Port** ist eine Naht: eine schmale Schnittstelle, hinter der im Betrieb das
Echte steckt und im Test eine Attrappe. Es gibt sechs — für den Issue-Speicher,
git, den Agenten, das Review, eine einzelne Review-Achse und den Reaper.

Der Grund ist immer derselbe: **die Entscheidungen prüfbar machen, ohne einen
echten Claude-Lauf zu bezahlen.**

==Eine Methode ist als einzige **optional**: `runChecks`. Sie zur Pflicht zu machen==
==hätte in acht Testdateien einen Platzhalter erzwungen, die sie gar nicht==
==benutzen — Rauschen, das sich später wie eine echte Guardrail-Änderung liest. Eine==
==fehlende Methode liest sich dagegen als das, was sie ist: eine Installation ohne==
==mechanische Regeln.==

**Stand der Messung am 2026-08-03:** 22 Quelldateien, 33 Testdateien mit 238
Tests, alle grün, dazu 8 Proof-Skripte.

Fast jede Testdatei trägt denselben Kopf: **FALSIFY FIRST.** Also nicht „beweise,
dass es geht", sondern „konstruiere den Fall, in dem es **still** danebengeht".
Fünf ==Testdateien== existieren, weil ein echter Lauf oder eine falsche Vorhersage sie
erzwungen hat — nicht, weil jemand sie sich ausgedacht hat:

- Beim Start lagen drei Notizen bereit, `concurrency: 3` war gesetzt, und trotzdem
  lief nur ein Container.
- Fertige Arbeit lag auf dem Branch, und der Lauf hieß trotzdem `failed`.
- Der Container-Pfad verliert das Transkript.
- Windows meldete `0xC0000142`: das Betriebssystem konnte kurz keinen Prozess
  starten.
- Die Vorhersage zur Paketinstallation im frischen Worktree war schlicht falsch
  (Abschnitt 3).

### Proof-Skripte sind keine Tests

==Ein **Proof** kostet echtes Geld, echtes Docker oder echte Wartezeit. Acht Stück,==
==darunter: zwei Review-Achsen finden je ihren gepflanzten Fehler; der==
==Permission-Prüfer wird beim Durchlassen von `rm -rf` ertappt; das Gateway wird==
==gegen die **echte** `claude`-Binärdatei geprüft statt gegen seine Doku; ein echtes==
==Fünf-Stunden-Fenster wird geparkt und wacht selbst auf; ein Issue läuft von Anfang==
==bis Merge durch.==

Zwei davon waren beim Archivieren beinahe verloren. Sie lebten in der Pipeline, in
der der Orchestrator gebaut wurde, und kamen gerade noch mit. Die Lehre: **Beweise
gehören neben den Code, den sie beurteilen.**

---

## ==14 · Was am 2026-08-03 nicht funktioniert==

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

---

## 15 · Die eine Regel darunter

Sie taucht an mindestens sechs Stellen unabhängig auf, jedes Mal anders formuliert:

> **Eine Abwesenheit muss als Abwesenheit lesbar sein.**

- „Übersprungen" ist etwas anderes als eine leere Befundliste. „Nie geprüft" ist
  nicht „geprüft, nichts gefunden".
- `runChecks` gibt nichts zurück statt „alles in Ordnung" — ein Repo ohne
  Guardrails hat sie nicht *bestanden*, es hat keine.
- Kein Review-Kommando heißt **kein** Review, nicht ein Review, das alles
  durchwinkt.
- Ein fehlender Standardtext darf nie als leerer Text ankommen.
- Eine Achse ohne Standard wird übersprungen, statt eine Meinung im Gewand einer
  Messung zu produzieren.
- Ein Fixture prüft, ob **dreckiger** Code scheitert — nie, ob sauberer durchgeht.

Der Grund ist jedes Mal derselbe: **die andere Wahl sieht von unten aus wie
Erfolg.**

### Und die siebte Stelle bricht sie

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
