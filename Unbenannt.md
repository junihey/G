##### graka restart
1. Win + Strg + Umschalt + B. Das startet nur den Grafiktreiber neu. Es piept kurz, und nach ein paar Sekunden ist das Bild oft zurück. Alle Programme laufen weiter.
2. Prüfen, ob der Rechner noch lebt: Num-Lock drücken. Geht die LED an der Tastatur an und aus, läuft Windows, nur die Anzeige fehlt.
3. Blind herunterfahren, wenn der Rechner lebt: Win + R drücken, shutdown /s /t 0 tippen, Enter. Du siehst nichts davon, aber Windows schreibt alles ordentlich zu Ende. Genau das verhindert den Schaden.
4. Erst danach den Einschaltknopf zehn Sekunden halten. Das ist der harte Schnitt, und der hat heute das Dateisystem beschädigt: Windows wurde mitten im Schreiben unterbrochen.
5. Nach jedem harten Ausschalten: chkdsk C: /scan in der Admin-PowerShell. Findet es etwas, danach chkdsk C: /spotfix und ein Neustart.
6. Danach mir Bescheid geben. Ich prüfe git fsck und die Tests in den betroffenen Projekten, so wie heute.


---

# Wege zu bauen

## Welcher Weg?

`/smithy` stellt fünf Fragen. Die erste, die passt, entscheidet.

| #   | Wann                                                | Weg                                                                                                                        | Orchestrator     | Spec friert ein                                                |
| --- | --------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- | ---------------- | -------------------------------------------------------------- |
| 1   | eine Sitzung, Weg klar                              | bauen, Diff lesen                                                                                                          | nein             | keine Spec                                                     |
| 2   | eine Sitzung, Weg unklar                            | `/grill-me`, dann bauen                                                                                                    | nein             | keine Spec                                                     |
| 3   | mehrere Sitzungen, du baust selbst                  | Forge nur für die Spec: `/assay`, `/scope`, bei offener Architektur `/skeleton`. Bauen in Sitzungen in `zaehlen\<projekt>` | nein             | sobald die erste Fassung läuft. Der Bericht meldet Kandidaten. |
| 4   | mehrere Sitzungen, Agenten bauen, Architektur steht | Foundry: `/grill-me` → `/write-a-prd` → `/prd-to-issues` → `/ready-to-implement`                                           | ja, nach dem Tor | keine Forge-Spec. Die PRD-Note ist ein Ticket.                 |
| 5   | mehrere Sitzungen, Agenten bauen, Architektur offen | Forge: `/assay` → `/scope` → … → `/readiness`, dann `/slice-to-issues` → `/ready-to-implement`                             | ja, nach dem Tor | nach dem letzten Slice. `/fold-back` setzt `phase: verify`.    |

## Wer entscheidet was

| Skill                 | Frage                                                               | Antworten                                                                                                                              |
| --------------------- | ------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `/smithy`             | Welcher Weg?                                                        | die Tabelle oben, Wege 1 bis 5                                                                                                         |
| `/foundry`            | Was kostet ein Missverständnis?                                     | direkt bauen · ein Dokument (PRD) · voller Durchgang (Forge zuerst)                                                                    |
| `/forge`              | Braucht es eine Spec, und welcher Forge-Schritt kommt als Nächstes? | nach den Dateien, die schon da sind                                                                                                    |
| `/assay`              | *Nach* der Wahl von Weg 3 oder 5: Verdient das Thema eine Spec?     | Spec · Spec, aber erst den Nebel klären · keine Spec                                                                                   |
| `/fold-back`          | Nach jedem Slice (Weg 5): Was hat der Bau gezeigt?                  | Korrekturen für Ungebautes in den Spec, Gebautes ins Projekt, Entscheidungen als ADR. Nach dem letzten Slice setzt es `phase: verify`. |
| `/ready-to-implement` | Darf ein Agent das bauen?                                           | Du schaltest jedes Issue frei. Ohne das baut der Orchestrator nichts.                                                                  |

Alle smithy-Skills startest du selbst. Keiner startet von allein.

## Die Kopfzeile in `specs\<idee>\README.md`

> **Stand:** aktiv · **Art:** Text · **Teil von:** `wwww-main` · **Gehört zu:** Projekt `zaehlen\…` · Quellen `zaehlen\quellen\…`

- **Stand:** `Idee` · `aktiv` · `gebaut seit JJJJ-MM-TT` · `ruht` · `abgeschlossen` · `archiviert`
- **Art: Text** nur, wenn der Text selbst das Produkt ist. Eine solche Spec ist nie Kandidat zum Einfrieren.
- **Teil von** nur bei einer Unter-Spec. Die spezifischste Spec nennt, was sie nutzt. Die Haupt-Spec nennt nur das Gemeinsame.

## Nach dem Einfrieren (Wege 3 und 5)

- Das Projekt in `zaehlen\` ist die Doku. Eine Entscheidung kommt als ADR nach `zaehlen\<projekt>\docs\adr\`, aber nur mit belegtem Grund.
- Erfüllt sie nur zwei der drei Bedingungen für ein ADR (schwer umkehrbar · überraschend · abgewogen), gehört sie an einen anderen Ort: als Kommentar an die Stelle, als Warnung ins README, oder sie braucht gar nichts.
- **Eine kleine Idee** ist Arbeit am Projekt, direkt oder über Issues. **Eine große zweite Bauphase** bekommt eine neue Spec, die beim Projekt und seinen ADRs beginnt. Die alte bleibt zu.
- Ändert sich eine eingefrorene Spec, melden das der Hook sofort und der Freitagsbericht.

## Ende

- **abgeschlossen:** `node .claude\scheduled\archivieren.mjs <idee>` zeigt den Plan, `--ausfuehren` setzt ihn um: Bundle, Quellen nach `archiv\`, Spec ins Archiv. Gelöscht wird nichts. Eine Haupt-Spec kommt erst ins Archiv, wenn alle ihre Unter-Specs dort sind.

## Wo du nachschaust

| Was                        | Wo                                                                          |
| -------------------------- | --------------------------------------------------------------------------- |
| Alle Ordner, wer sie nennt | `zaehlen\README.md`, Tabelle „Die Ordner“                                   |
| Was diese Woche offen ist  | `reflections\<datum>-ordnung.md`. Öffnet sich bei Neuem selbst in Obsidian. |
| Die Regel                  | `C\CLAUDE.md`, Regel 14                                                     |
| Das Warum                  | `claude-notes\spec-lifetime.md`                                             |
