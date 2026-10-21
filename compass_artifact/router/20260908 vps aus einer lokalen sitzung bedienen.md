---
tags: [smelt, raw]
created: 2026-09-08
topic: Werkzeuge, die eine lokale Claude-Code-Sitzung ueber SSH auf einem VPS arbeiten lassen
---

# VPS aus einer lokalen Sitzung bedienen

## Herkunft

Recherche eines Subagenten aus einer Claude-Code-Sitzung vom 2026-09-08, angestossen mit `/smelt`. Es gibt keinen Share-Link — dieser Text ist das Original.

## Geprüfter Stand

Alle Registry-Daten am 2026-09-08 über die GitHub- und npm-API abgefragt, nicht über Suchergebnisseiten.

| Was | Stand |
|---|---|
| `@modelcontextprotocol/server-filesystem` | npm `2026.8.31`; Repo `modelcontextprotocol/servers` gepusht 2026-09-03 |
| `ssh-mcp` (tufantunc) | npm `2.8.0` (2026-09-04), 703 Sterne |
| `@fangjunjie/ssh-mcp-server` (classfang) | npm `1.9.1` (2026-09-04), 838 Sterne |
| `@hypnosis/ssh-mcp-server` | npm `2.3.3` (2026-08-24), Repo nicht öffentlich auflösbar |
| `@uarlouski/ssh-mcp-server` | npm `1.5.0` (2026-02-12), Repo gepusht 2026-06-10 |
| `@aiondadotcom/mcp-ssh` | npm `1.3.9` (2026-08-10) |
| `mcp-ssh-manager` (bvisible) | npm `3.8.5` (2026-08-28) |
| `mcp-ssh-tmux` (devnullvoid) | Repo gepusht 2026-06-05, 6 Sterne |
| `claude-remote-shell` (torarnv) | Repo gepusht 2026-04-10, 15 Sterne |
| SSHFS-Win | letztes Release `v3.7.21011` vom 2021-02-03, als Prerelease |
| WinFsp | `v2.2B4` (2026-08-03) |
| rclone | `v1.75.1` (2026-09-04) |
| Mutagen | `v0.18.1` (2025-02-24) |
| OpenSSH in Git Bash auf diesem PC | `OpenSSH_10.2p1`, MSYS-Build vom 2026-02-12 |

## Warum zu diesem Spec

Der VPS-Neuaufbau bedient den Server heute aus einer Claude-Code-Sitzung auf dem PC; dieser Fund sagt, ob es zwischen `ssh vps "befehl"` und einem zweiten Claude auf dem Server einen dritten Weg gibt.

## Der Auftrag, im Wortlaut

> **Auftrag:** Welche installierbaren Werkzeuge — MCP-Server, Claude-Code-Plugins, Claude-Code-Skills, oeffentliche Repos — lassen eine auf einem Windows-PC laufende Claude-Code-Sitzung auf einem entfernten Linux-VPS ueber SSH so arbeiten, dass Datei-Lesen, Datei-Aendern, Suchen und laufende Prozesse dort genauso bedienbar sind wie lokal? Und welche davon sind heute gepflegt, belegbar und tatsaechlich installierbar? Antworte als Tabelle: Name, Art (MCP-Server / Plugin / Skill / Repo / Bordmittel), was es konkret ersetzt (Read / Edit / Grep / Glob / laufende Prozesse), Installationsweg, letzter belegter Aktivitaetsstand, und ein Urteil ob es die Luecke schliesst oder nur `ssh <host> "<befehl>"` huebscher verpackt.
>
> **Wozu:** Der Nutzer baut seinen IONOS-VPS (Ubuntu 24.04, Docker, Nginx Proxy Manager, Seafile) gerade neu auf und bedient ihn heute aus einer Claude-Code-Sitzung auf seinem Windows-PC. Er weiss bereits, dass er Claude Code auch direkt auf dem VPS installieren koennte. Der Fund entscheidet, ob es dazwischen einen dritten Weg gibt, der ihm den zweiten Claude auf dem Server erspart — oder ob er belegbar keinen gibt und die Frage damit erledigt ist.
>
> **Kontext:** Claude Codes eingebaute Werkzeuge Read, Edit, Grep und Glob arbeiten immer auf dem Dateisystem der Maschine, auf der der Prozess laeuft; ein entfernter Server ist fuer sie kein Dateisystem, sondern nur ein Bash-Aufruf der Form `ssh vps "befehl"`. Daraus folgen vier bekannte Verluste: kein Diff vor der Freigabe (nur blindes `sed`), kein bleibendes Arbeitsverzeichnis (jeder Aufruf eine neue Verbindung mit voll ausgeschriebenen Pfaden), ein `ssh`-Aufruf pro Datei statt eines Glob plus weniger Reads, und kein Ueberleben laufender Prozesse wie Dev-Server, Watcher oder Test im Wachmodus. Der Client ist Windows 11 mit PowerShell und Git Bash; der Server laeuft mit Schluessel-Anmeldung, ohne root-Login. Bekannte Alternativen, die der Nutzer schon kennt und die deshalb nicht Teil der Antwort sind: Claude Code direkt auf dem VPS unter tmux, VS Code Remote-SSH, code-server, und Anthropics Remote Control.
>
> **Quellen, in dieser Reihenfolge:** (1) `llms.txt` / `llms-full.txt` der jeweiligen Doku-Wurzel, wenn vorhanden. (2) Primaerquellen: die offizielle Claude-Code-Doku unter code.claude.com/docs, das offizielle MCP-Server-Verzeichnis und `modelcontextprotocol/servers` auf GitHub, npm- und PyPI-Paketseiten, Repo-READMEs und Quelltext. (3) GitHub-Suche und die npm-Registry-Suche nach Begriffen wie `mcp ssh`, `mcp remote filesystem`, `mcp sftp`, `claude code ssh plugin`, `remote-ssh mcp`. Blogposts und Tutorials sind Wegweiser zu einer Primaerquelle, nie selbst Beleg.
>
> **Fertig heisst:** Jede Zeile der Tabelle ist gefuellt oder ausdruecklich als *nicht ermittelbar* markiert; jedes genannte Paket ist mit einer geoeffneten Primaerquelle belegt (Repo, npm-, PyPI- oder Doku-Seite mit sichtbarem letztem Stand), nicht nur mit einer Erwaehnung in einer Liste; und fuer jedes Werkzeug steht ausdruecklich da, ob es den Diff-vor-Freigabe-Verlust und den Zustands-Verlust behebt oder nicht. Findest du fuer eine Kategorie belegbar nichts Gepflegtes, ist das ein Ergebnis — sag es mit dem Beleg, statt die Zeile zu fuellen. Die erklaerenden Absaetze so kurz, wie die Sache traegt; die Belegtabelle darf so lang sein, wie sie Zeilen hat.
>
> **Randfrage, hoechstens ein Satz, nicht ausarbeiten:** Ob es gepflegte oeffentliche Skill- oder Plugin-Sammlungen speziell fuer VPS-Betrieb (Server haerten, Docker-Compose-Dienste, Backups) gibt, die man einem auf dem VPS selbst laufenden Claude mitgibt.
>
> **Rahmen:**
> - Vertiefe entlang der Frage, wechsle nie zur Nachbarfrage. Stoesst du auf eine zweite Frage, die sich lohnt, nenne sie in einem Satz und arbeite sie nicht aus.
> - Triff Abwaegungen unterwegs selbst und **nenne jede in der Antwort**. Rueckfragen erreichen niemanden — es hoert hier keiner zu.
> - Schreib keine Datei und aendere nichts. Du gibst zurueck, mehr nicht.
> - Namen, Aufrufe und Behauptungen aus dieser Frage sind **ungeprueft**. Belege oder widerlege sie, bevor du sie uebernimmst.
>
> **Rueckgabe in vier Stuecken, in dieser Reihenfolge:**
> 1. Die Tabelle wie oben.
> 2. Zwei getrennte Listen. *Form:* was dauerhaft gilt — wie Claude Codes Werkzeugmodell mit entfernten Maschinen umgeht, welche Architekturen es fuer entfernten Zugriff ueberhaupt gibt. *Zustand:* was heute gilt — Versionen, Veraltetes, Umbenanntes, Aufgegebenes.
> 3. Die Quellen als volle URLs, eine je nicht-offensichtlicher Behauptung.
> 4. Der Beleg fuer die Schleife: jede Stelle, an der ein zweiter Durchgang etwas geaendert hat, und was er geaendert hat.

## Fehler im Auftrag, gegen den der Fund geprüft wurde

Der Auftrag verlangte Werkzeuge, die vier Verluste beheben, ohne zu sagen, welcher der wichtigste ist. Der Agent hat daraufhin alle vier gleich gewichtet und dadurch Kandidaten in die Tabelle genommen, die nur einen einzigen berühren. Für den nächsten Lauf: den entscheidenden Verlust benennen.

---

# Die Antwort

## Die Tabelle

| Name | Art | Ersetzt konkret | Installationsweg | Letzter belegter Stand | Urteil |
|---|---|---|---|---|---|
| **`@modelcontextprotocol/server-filesystem`, gestartet über SSH-stdio** | MCP-Server (offiziell) | **Read** (`read_text_file`), **Edit** (`edit_file` mit unified Diff und `dryRun`), **Glob** (`search_files`, `directory_tree`) — **nicht Grep** (nur Dateinamen-Muster), **nicht** laufende Prozesse | `claude mcp add --transport stdio vpsfs -- ssh vps npx -y @modelcontextprotocol/server-filesystem /srv/x` | npm `2026.8.31`; Repo gepusht 2026-09-03, 90.140 Sterne | **Schließt die Lücke am weitesten.** Einziger Kandidat mit Diff vor der Änderung (empirisch belegt). Ein Server-Prozess, eine Verbindung, relative Wurzel. Kein Grep, keine Prozesse. |
| **`ssh-mcp` (tufantunc) v2** | MCP-Server | **Laufende Prozesse** (`open-session type=background`, `read-session-output`, `signal-process`), **Zustand** (`type=interactive` hält CWD und Env), SFTP up/down | `npm i -g ssh-mcp`, dann `claude mcp add --transport stdio ssh-mcp -- ssh-mcp`; Config in `%APPDATA%\ssh-mcp\config.toml` | npm `2.8.0` (2026-09-04); 703 Sterne, MIT, CI + OpenSSF Scorecard | **Schließt Zustands- und Prozess-Verlust, nicht den Diff-Verlust.** Einziger gepflegter Server mit echten stateful Sessions. Ergänzt Zeile 1, ersetzt sie nicht. |
| **`@fangjunjie/ssh-mcp-server` (classfang)** | MCP-Server (+ Skill `ssh-mcp-helper` im Repo) | Nur `execute-command`, `upload`, `download`, `list-servers` | `npx -y @fangjunjie/ssh-mcp-server --host … --privateKey …`; liest `~/.ssh/config` | npm `1.9.1` (2026-09-04); 838 Sterne, ISC | **Nur hübscher verpacktes `ssh` + `scp`.** Kein Diff, kein persistenter CWD. Gepflegt, löst aber keinen der vier Verluste. |
| **`@hypnosis/ssh-mcp-server`** | MCP-Server | **Grep/Glob teilweise** (eine Suche über Dateien und Globs statt vier Runden), Dateitransfer, benannte Prozess-Zustände | `npx @hypnosis/ssh-mcp-server` | npm `2.3.3` (2026-08-24) | Reduziert den Ein-Aufruf-pro-Datei-Verlust. Kein Diff-Edit. Repo nicht öffentlich auflösbar — Beleg nur auf der npm-Seite. |
| **`@uarlouski/ssh-mcp-server`** | MCP-Server | SFTP `read`/`write`/`list`/`delete`, Port-Forwarding, Command-Templates | `npx @uarlouski/ssh-mcp-server@latest --configPath=…` | npm `1.5.0` (2026-02-12); Repo gepusht 2026-06-10, Apache-2.0 | SFTP statt blindem `sed`, aber Schreiben ist Ganzdatei-Overwrite ohne Diff. Zustand nicht dokumentiert. Teilverbesserung. |
| **`@aiondadotcom/mcp-ssh`** | MCP-Server (+ `.mcpb`-Bundle) | Kommandos, `scp` up/down, Host-Discovery aus `~/.ssh/config` | `.mcpb` doppelklicken (Claude Desktop) oder `npx @aiondadotcom/mcp-ssh` | npm `1.3.9` (2026-08-10); 98 Sterne, MIT | **Verpackt `ssh`/`scp`.** Kein Diff, kein Zustand. |
| **`mcp-ssh-manager` (bvisible)** | MCP-Server | Kommandos, Deploy, Upload, DB-Dump; `readonly`-Modus | `npx mcp-ssh-manager` | npm `3.8.5` (2026-08-28) | **Verpackt `ssh` — mit Warnung.** Das Changelog nennt drei behobene Command-Injection-Advisories, darunter eine RCE (`GHSA-796j-h5q5-jx6p`), die den `readonly`-Modus aushebelte. Für einen produktiven VPS abzuraten. |
| **`mcp-ssh-tmux` (devnullvoid)** | MCP-Server (PyPI) | **Laufende Prozesse + Zustand** über echtes tmux; SSH überlebt Neustart des MCP-Servers | `pip install mcp-ssh-tmux` | Repo gepusht 2026-06-05, 6 Sterne, MIT | Konzeptionell die sauberste Prozess-Lösung, aber 6 Sterne und ein Autor — zu jung für einen VPS. Kein Diff, kein Read/Edit. |
| **`claude-remote-shell` (torarnv)** | Repo / CLI-Wrapper | **Kehrt das Problem um:** Bash läuft remote, Read/Edit/Grep/Glob bleiben lokal — plus bidirektionaler Mutagen-Sync | `brew install torarnv/claude-remote-shell/claude-remote-shell` | Repo gepusht 2026-04-10, 15 Sterne, MIT | **Auf Windows nicht installierbar** (nur Homebrew). Baut auf `CLAUDE_CODE_SHELL`, das in der offiziellen Env-Var-Referenz **nicht** steht. Hängt zudem an Mutagen, letztes Release 2025-02-24. |
| **SSHFS-Win + WinFsp** | Bordmittel / Repo | **Alles vier vollständig**: Read, Edit (mit echtem Harness-Diff), Grep, Glob arbeiten nativ, weil der VPS ein Laufwerksbuchstabe wird | WinFsp-Installer, dann SSHFS-Win; `\\sshfs\user@host` als Netzlaufwerk | WinFsp `v2.2B4` (2026-08-03); SSHFS-Win letztes Release `v3.7.21011` vom 2021-02-03 als Prerelease, 307 offene Issues | **Schließt Diff- und Zustands-Verlust vollständig — aber die Hälfte des Stapels ist seit 4,5 Jahren ohne Release.** Zweiter Vorbehalt: `rg` über einen FUSE-Netzmount ist um Größenordnungen langsamer als lokal. |
| **`rclone mount` (sftp) + WinFsp** | Bordmittel | Wie oben — **alles vier vollständig** | `winget install winfsp`, `winget install Rclone.Rclone`, `rclone mount vps: S: --vfs-cache-mode full` | rclone `v1.75.1` (2026-09-04), 59.635 Sterne, gepusht 2026-09-07 | **Die gepflegte Fassung der Mount-Idee.** Ersetzt SSHFS-Win eins zu eins bei laufender Wartung. Behebt Diff und Zustand vollständig, laufende Prozesse nicht. Weder rclone noch WinFsp sind auf diesem PC installiert (geprüft). |
| **SSH `ControlMaster`/`ControlPersist` in Git Bash** | Bordmittel | Verbindungsaufbau-Kosten je `ssh`-Aufruf — **nicht** den Arbeitsverzeichnis-Verlust | Vier Zeilen in `~/.ssh/config` | `OpenSSH_10.2p1` (MSYS-Build 2026-02-12) liegt auf diesem PC | **Halber Gewinn, kostenlos, heute.** Der Git-Bash-`ssh` kann multiplexen, das Windows-eigene `ssh.exe` nicht. Da Claude Codes Bash-Werkzeug Git Bash benutzt, greift es. Das CWD bleibt trotzdem bei jedem Aufruf `$HOME`. |
| **Ein MCP-Server, der Read/Edit/Grep/Glob *als solche* umbiegt** | — | — | — | — | **Existiert nicht — das ist ein Ergebnis.** Die offizielle MCP-Registry liefert zu `ssh` sechs Server, keiner mit Diff-erzeugendem Edit. Architektonisch unmöglich: MCP-Server ergänzen Werkzeuge, sie überschreiben keine eingebauten. |
| **Gepflegte Claude-Code-*Plugins* für SSH-Fernzugriff** | Plugin | — | — | `classfang/ssh-plugin`: 1 Stern, gepusht 2026-03-05 | **Belegbar nichts Ernstzunehmendes.** Das einzige gefundene Plugin ist eine dünne Hülle um `@fangjunjie/ssh-mcp-server`. |

## Form — was dauerhaft gilt

- **Claude Codes Werkzeugmodell kennt genau ein Dateisystem: das des Prozesses.** `code.claude.com/docs/en/tools-reference.md` sagt ausdrücklich, dass Read, Edit, Write, Glob, Grep und LSP nur lokal arbeiten und es keine Remote- oder SSH-Unterstützung gibt.
- **Es gibt genau vier Architekturen für Fernzugriff**, unterschieden danach, wo sie die Grenze ziehen:
  1. **Grenze im Werkzeug** — ein MCP-Server bekommt eigene Remote-Werkzeuge (`ssh_execute`, `sftp_write`). Die eingebauten bleiben blind. Das tun rund 90 % der gefundenen Pakete.
  2. **Grenze im Transport** — der MCP-Server selbst läuft drüben, die stdio-Pipe geht durch `ssh`. Die MCP-Werkzeuge sind dann vollwertige Datei-Werkzeuge auf dem Zielsystem. Das ist Zeile 1 und der eigentliche dritte Weg.
  3. **Grenze im Dateisystem** — ein FUSE-Mount macht das Ferne lokal. Dann funktionieren die eingebauten Werkzeuge unverändert, samt Harness-Diff und Berechtigungsregeln. Einziger Weg, der wirklich „genauso bedienbar wie lokal" erreicht.
  4. **Grenze in der Shell** — nur Bash wird umgeleitet, Dateien werden gespiegelt. Kehrt den Verlust um, statt ihn zu beheben.
- **Ein stdio-MCP-Server ist ein beliebiges ausführbares Kommando.** `claude mcp add <name> -- <command> [args]` reicht alles nach `--` unangetastet durch. Dass dieses Kommando `ssh` sein darf, folgt aus der Signatur. Anthropic dokumentiert das Muster nicht, verbietet es aber auch nicht.
- **`roots/list` ist der Stolperstein dieser Architektur — und er trägt.** Claude Code beantwortet `roots/list` mit dem lokalen Startverzeichnis, also einem Windows-Pfad. Der Filesystem-Server ersetzt seine erlaubten Verzeichnisse durch die Roots des Clients (`allowedDirectories = [...validatedRootDirs]`). Dass der Remote-Fall trotzdem funktioniert, liegt an einer Zeile in `roots-utils.ts`: `await fs.realpath(absolutePath)` läuft auf dem Server-Dateisystem, ein Windows-Pfad existiert dort nicht, der Root wird verworfen, und bei null gültigen Roots behält der Server seine Kommandozeilen-Verzeichnisse. Gemessen, nicht vermutet.
- **Ein MCP-Diff ist nicht dasselbe wie ein Harness-Diff.** `edit_file --dryRun` liefert einen echten unified Diff, aber als Werkzeug-Ausgabe. Der Freigabe-Dialog eines MCP-Werkzeugs zeigt weiterhin JSON-Argumente, keinen gerenderten Diff. Der Verlust wird durch Disziplin geschlossen (erst `dryRun`, dann anwenden), nicht durch eine Garantie. Nur der Mount-Weg gibt den echten Harness-Diff zurück.

## Zustand — was heute gilt

- **`ssh-mcp` (tufantunc) ist der De-facto-Standard**: 703 Sterne, 41 npm-Versionen, Version 2 mit Policy-Gates, Rollen-Matrix und Audit-Log. Einziges Paket mit einem Bedrohungsmodell im README.
- **`@fangjunjie/ssh-mcp-server` hat mehr Sterne (838), aber weniger Substanz** — vier Werkzeuge, kein Zustand, kein Diff.
- **SSHFS-Win ist Klassiker und Nachzügler zugleich.** Repo gepflegt (Push 2026-07-12), letztes Release aber von 2021 und als Prerelease markiert, 307 offene Issues. Wer heute mountet, nimmt rclone.
- **Mutagen ist eingeschlafen**: letztes Release `v0.18.1` vom 2025-02-24. Alles darauf Gebaute erbt das.
- **`CLAUDE_CODE_SHELL` ist eine unbelegte Behauptung.** Die offizielle Env-Var-Referenz kennt sie nicht; dort stehen nur `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR`, `BASH_DEFAULT_TIMEOUT_MS`, `BASH_MAX_TIMEOUT_MS`, `BASH_MAX_OUTPUT_LENGTH`.
- **Windows-natives `ssh.exe` kann bis heute nicht multiplexen.** Win32-OpenSSH #1328 und #405; VS Code Remote #96 nennt es „not supported on Windows". Auf diesem PC reproduziert.
- **`mcp-ssh-manager` hat gerade eine Sicherheitsrunde hinter sich** — drei Command-Injection-Advisories, eine davon RCE über `ssh_db_dump`, die `readonly` aushebelte. Behoben, aber die Fehlerklasse sagt etwas über die Reifegrade im Feld.
- **Die offizielle MCP-Registry ist dünn besetzt**: sechs SSH-Einträge, überwiegend read-only-Diagnose. Weder `ssh-mcp` noch `@fangjunjie/ssh-mcp-server` sind dort registriert — die Registry taugt hier nicht als Marktübersicht.

## Quellen

**Claude-Code-Primärdoku**
- https://code.claude.com/docs/llms.txt
- https://code.claude.com/docs/en/tools-reference.md — Werkzeuge nur lokal; Bash ohne persistente Env
- https://code.claude.com/docs/en/mcp.md — `roots/list`-Verhalten, `claude mcp add … -- <command>`, Transporte
- https://code.claude.com/docs/en/env-vars.md — Beleg, dass `CLAUDE_CODE_SHELL` nicht dokumentiert ist

**Filesystem-Server über SSH-stdio**
- https://github.com/modelcontextprotocol/servers/blob/main/src/filesystem/README.md
- https://raw.githubusercontent.com/modelcontextprotocol/servers/main/src/filesystem/index.ts
- https://raw.githubusercontent.com/modelcontextprotocol/servers/main/src/filesystem/roots-utils.ts
- https://www.npmjs.com/package/@modelcontextprotocol/server-filesystem

**Die MCP-Server**
- https://github.com/tufantunc/ssh-mcp · https://www.npmjs.com/package/ssh-mcp
- https://github.com/classfang/ssh-mcp-server · https://www.npmjs.com/package/@fangjunjie/ssh-mcp-server
- https://github.com/uarlouski/ssh-mcp-server · https://www.npmjs.com/package/@uarlouski/ssh-mcp-server
- https://github.com/AiondaDotCom/mcp-ssh · https://www.npmjs.com/package/@aiondadotcom/mcp-ssh
- https://www.npmjs.com/package/@hypnosis/ssh-mcp-server
- https://www.npmjs.com/package/mcp-ssh-manager — Changelog mit `GHSA-796j-h5q5-jx6p`
- https://github.com/devnullvoid/mcp-ssh-tmux · https://pypi.org/project/mcp-ssh-tmux/
- https://registry.modelcontextprotocol.io/v0/servers?search=ssh — die sechs Einträge
- https://github.com/classfang/ssh-plugin — das einzige Claude-Code-Plugin

**Shell-Umleitung und Mount**
- https://github.com/torarnv/claude-remote-shell
- https://github.com/mutagen-io/mutagen/releases
- https://github.com/winfsp/sshfs-win/releases
- https://github.com/winfsp/winfsp/releases
- https://rclone.org/commands/rclone_mount/ · https://github.com/rclone/rclone/releases/latest

**Windows-SSH-Multiplexing**
- https://github.com/PowerShell/Win32-OpenSSH/issues/1328
- https://github.com/PowerShell/Win32-OpenSSH/issues/405
- https://github.com/microsoft/vscode-remote-release/issues/96

**Randfrage**
- https://github.com/hostinger/hostinger-agent-skills · https://binary.ly/skills/ · https://github.com/Binary-ly/claude-skills · https://github.com/GoldenWing-360/claude-security-skills · https://github.com/kyzdes/vps-ninja

**Nachtrag 2026-09-08, nach dem Lauf geprüft:** Der Agent nannte `hostinger/hostinger-agent-skills` als auf diesen Fall zielend. Das stimmt nicht — jeder der sechs Skills dort ruft die Hostinger-API mit einem Bearer-Token aus dem hPanel auf und ist auf einem IONOS-Server wertlos (21 Sterne, MIT). Auf einem beliebigen Ubuntu-Server nutzbar sind stattdessen `GoldenWing-360/claude-security-skills` (17 Sterne, MIT, darin `vps-hardening`, `docker-container-security`, `backup-disaster-recovery`, `postgres-hardening`) und `Binary-ly/claude-skills` (1 Stern, 11 Commits, keine Lizenz angegeben, ein einziger Server-Skill). `kyzdes/vps-ninja` setzt Dokploy voraus.

## Beleg für die Schleife

**a) Die `roots`-Falle: erst als Ausschlusskriterium notiert, dann widerlegt.** Nach dem Lesen von `index.ts` (`allowedDirectories = [...validatedRootDirs]`) sah es so aus, als ersetze der ferne Server sein `/srv` durch den Windows-Pfad — die Architektur der Zeile 1 wäre gefallen. Der zweite Durchgang fand die `fs.realpath`-Prüfung in `roots-utils.ts`. Der erste Test war falsch aufgesetzt (Windows-Pfad an einen auf Windows laufenden Server, der Pfad existierte). Der dritte Durchgang mit korrekt simuliertem Fall gab aus: `No valid root directories provided by client`, und der Server behielt seine Kommandozeilen-Verzeichnisse. Zeile 1 ging damit von „scheitert" auf „stärkster Kandidat".

**b) Der Diff: von „laut README" auf gemessen.** `edit_file` mit `dryRun:true` tatsächlich aufgerufen — echter unified Diff mit Kontextzeilen zurück, Datei unverändert. Dabei fiel die Einschränkung auf: der Diff ist Werkzeug-Ausgabe, nicht Harness-Freigabedialog. Aus „behebt den Diff-Verlust" wurde „behebt ihn durch Disziplin".

**c) `ControlMaster`: von „auf Windows unmöglich" auf „hier möglich".** Der erste Durchgang hätte die Zeile gestrichen. Der zweite fragte, welches `ssh` Claude Codes Bash-Werkzeug benutzt: `/usr/bin/ssh`, laut `ldd` gegen `msys-2.0.dll` gelinkt — ein Cygwin-artiger Build mit AF_UNIX-Emulation. Der Vergleich von `-O check` zeigt zwei verschiedene Fehler: der MSYS-Build führt einen echten Unix-Socket-`connect()` aus und findet nur die Datei nicht, das Windows-Binary scheitert an der Socket-Semantik selbst.

**d) `CLAUDE_CODE_SHELL`: von „starker Hebel" auf „unbelegt".** Ein Drittanbieter-README stellt die Variable als Grundlage dar; die offizielle Referenz kennt sie nicht.

## Abwägungen des Agenten

- Empirisch statt zitiert, wo eine Behauptung die Antwort trägt (roots-Überschreibung, Diff) — Kosten: drei zusätzliche Durchgänge.
- Repos über GitHub- und npm-API abgefragt statt über Webseiten, damit jede Zeile ein Datum hat statt einer Vagheit.
- Release-Datum vom Push-Datum getrennt. Diese Trennung hat rclone an SSHFS-Wins Stelle gebracht.
- Docker-Container für einen echten `ControlMaster`-Test verworfen, weil der Auftrag „ändere nichts" sagte. Der `-O check`-Vergleich beweist nicht, dass eine reale Sitzung über diese Leitung stabil bleibt.
- Sechs weitere SSH-MCP-Pakete geprüft und verworfen (`giuliolibrando`, `idletoaster`, `shaike1/mcp-ssh`, `@mcpcn`, `@zyluo/remote-ssh-mcp`, `ftp-ssh-mcp`) — ohne Aktivität seit 2024/2025 oder ohne Werkzeug, das einen der vier Verluste berührt.
- Latenz, Bandbreite und Kosten nicht gewichtet, außer wo sie ein Urteil kippen (Grep über FUSE-Mount).

## Offene zweite Frage

Ob sich `rclone mount` und `ssh-mcp` sauber kombinieren lassen — Dateien über den Mount mit den eingebauten Werkzeugen samt echtem Harness-Diff, laufende Prozesse über die stateful Sessions — und ob die beiden Sichten auf dasselbe Dateisystem sich beim Cache (`--vfs-cache-mode full`) gegenseitig veralten lassen.
