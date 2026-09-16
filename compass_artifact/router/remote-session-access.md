---
tags: [claude-note, curated]
created: 2026-08-09
topic: Wo ein Claude-Code-Prozess läuft, was ihn am Leben hält, und womit du ihn von unterwegs bedienst
verification: extern — Claude-Code-Verhalten und Fremd-Tools (herdr, tmux, systemd), kein smithy-Bezug, per Hand
---

# Eine Session erreichen, wenn du nicht davor sitzt

**Drei Fragen, nicht eine.** Wo läuft der Prozess, was hält ihn am Leben, womit bedienst du ihn. Die drei sind frei kombinierbar. Fast jede Verwirrung zu diesem Thema kommt daher, dass zwei davon zusammengeworfen werden.

| Achse | Auswahl |
|---|---|
| **Ort** — wo rechnet Claude, wo liegen die Dateien | dein PC · dein VPS · Anthropics Cloud |
| **Lebensdauer** — was passiert, wenn die Verbindung abreißt | nichts (stirbt) · tmux/screen · herdr · systemd-Dienst |
| **Bedienung** — womit du tippst | SSH-Terminal · VS Code Remote-SSH · code-server im Browser · Remote Control (Handy-App / claude.ai/code) |

Der Ort entscheidet, ob dein PC an sein muss. Die Lebensdauer entscheidet, ob du dich trennen darfst. Die Bedienung entscheidet nur, wie es aussieht.

**Diese drei Achsen betreffen den Claude-Prozess, nicht die gebaute Anwendung.** Wer die App im Browser testen will — besonders vom Handy —, braucht zwei weitere Achsen, die hier fehlen: HTTPS-Zugriff und Datei-Bearbeitung. Die stehen in [[remote-dev-stack]]. Ohne sie sperrt der Browser Kamera, Standort und Service Worker, sobald die Adresse nicht mehr `localhost` heißt.

## Der Denkfehler, der hier zuerst aufzulösen ist

**VS Code Remote-SSH heißt: der Prozess läuft auf dem VPS.** Die Oberfläche läuft auf deinem PC, aber alles, was du im integrierten Terminal startest, startet auf dem Server. Wer dort `claude` tippt, hat eine VPS-Session, keine PC-Session — auch wenn er sie vom PC aus gestartet hat.

Daraus folgt: **„PC anlassen, damit ich vom Handy an die VPS-Session komme" ist unnötig.** Der PC hat mit dieser Session nichts zu tun, sobald sie läuft. Er wird nur gebraucht, solange er das einzige Fenster ist.

Was der PC dagegen sehr wohl tun muss: **laufen, wenn der Prozess auf ihm läuft.** Das ist Weg 1 unten, und dort ist es kein Fehler, sondern die Bedingung.

## Vom PC aus per SSH — was geht und was fehlt

**Einen VPS einrichten kannst du vom PC-Claude aus. Auf ihm entwickeln nicht.** Der Unterschied liegt bei den Werkzeugen, nicht bei SSH.

Läuft Claude Code auf deinem PC, arbeiten Read, Edit, Grep und Glob auf **deinem** Dateisystem. Der VPS ist dann kein Dateisystem, sondern ein Befehl — erreichbar nur durch Bash:

```bash
ssh vps "cat ~/projekt/server.js"           # statt Read
ssh vps "sed -i 's/3000/4000/' ~/projekt/…" # statt Edit
ssh vps "grep -rn 'TODO' ~/projekt"         # statt Grep
```

Das läuft. Was dabei fehlt:

| | Claude auf dem VPS | Claude auf dem PC, `ssh vps "…"` |
|---|---|---|
| Änderung | Edit zeigt den Diff vor der Freigabe | ein `sed`-Befehl; ob er die richtige Stelle trifft, siehst du danach |
| Zustand | ein Arbeitsverzeichnis, das bleibt | jeder Aufruf eine neue Verbindung, jeder Pfad voll ausgeschrieben |
| Überblick | ein Glob und ein paar Reads | ein `ssh`-Aufruf pro Datei |
| Laufendes | Dev-Server, Watcher, Test im Wachmodus | ein einzelner Befehl endet, der Prozess mit ihm |

**Die Grenze ist der Bootstrap.** Pakete installieren, einen Benutzer anlegen, Node aufsetzen, Claude Code selbst installieren — einzelne Befehle mit je einem Ergebnis, genau wofür `ssh vps "befehl"` gebaut ist. Danach hört es auf, der richtige Weg zu sein: entwickelt wird dort, wo der Code liegt.

## Ort A — auf deinem PC

Claude rechnet lokal, greift auf lokale Dateien zu, benutzt deine MCP-Server und deine Plugin-Installation. Alles, was in diesem Vault steht, gilt hier.

**Was ihn am Leben hält:** herdr. Es ist ein Multiplexer für Agenten-Sessions und kann **detachen** — Fenster zu, Session läuft weiter, du dockst später wieder an. Details in [[tool-basis-usage]].

**Grenze:** der PC muss an bleiben. Schlaf ist laut Doku unkritisch, die Verbindung baut sich beim Aufwachen neu auf. Aus ist aus.

## Ort B — auf dem VPS

Claude rechnet auf dem Server, greift auf die Dateien dort zu. Dein PC ist komplett aus dem Spiel. Was auf einen VPS gehört und was nicht, steht in `PORTABILITY.md` Fall D — dieser Abschnitt beantwortet nur, wie du an die laufende Session kommst.

**Vier Wege, ihn am Leben zu halten:**

| Weg | Überlebt SSH-Trennung | Überlebt Reboot | Preis |
|---|---|---|---|
| nackte SSH-Sitzung | nein | nein | keiner — aber die Session stirbt mit der Verbindung |
| `tmux` / `screen` | ja | nein | ein Befehl beim Start, einer beim Andocken |
| herdr | ja | nein | Install-Script, Server muss laufen; dafür mehrere Agenten nebeneinander |
| systemd-Dienst | ja | ja | Unit-Datei, eigener Dienst-User, Logdatei, und das Login-Problem unten |

**Die Reihenfolge ist eine Empfehlung, keine Rangliste.** Fang mit tmux an. Ein systemd-Dienst kauft genau eine Eigenschaft dazu — Überleben eines Reboots — und die brauchst du erst, wenn dich ein Neustart tatsächlich einmal geärgert hat.

**Nie als `root`.** Leg einen eigenen, unprivilegierten Benutzer an und gib ihm Zugriff nur auf das Projektverzeichnis. Der Grund ist nicht Theorie: Claude führt Befehle aus, und du gibst sie aus der Ferne frei, oft flüchtig. Ein Fehlgriff als `root` trifft das ganze System.

## Ort C — in Anthropics Cloud

Kein PC, kein VPS, keine Installation. Die Session läuft auf Anthropics Infrastruktur und sieht deine lokalen Dateien **nicht**.

| Einstieg | Befehl / Ort |
|---|---|
| Neue Cloud-Session anlegen | `claude --cloud "Beschreibung"` oder claude.ai/code |
| Eine Cloud-Session ins lokale Terminal holen | `claude --teleport [session]` |
| Aus einem Team-Chat heraus | Slack-App (`@Claude`) |

**Für diesen Vault ist Ort C fast immer der falsche.** Spec-Arbeit liest `TENETS.md`, `STACK.md` und die Notizen hier — die liegen in deinem Klon, nicht in der Cloud. Ort C lohnt für ein fremdes Repo, das du gar nicht ausgecheckt hast.

## Bedienung: die vier Fenster

| Fenster | Braucht auf dem Handy | Zeigt |
|---|---|---|
| SSH-Terminal | einen SSH-Client (Termius o.ä.) | alles, aber als Terminal |
| VS Code Remote-SSH | einen PC | volle IDE |
| code-server | nur einen Browser | volle IDE, aber du betreibst sie selbst |
| Remote Control | die Claude-App oder claude.ai/code | die Unterhaltung, nicht den Dateibaum |

**Remote Control ist das einzige Fenster ohne SSH.** Die Session meldet sich bei Anthropic an und fragt dort nach Arbeit; es wird **kein eingehender Port** geöffnet. Genau deshalb funktioniert es hinter jedem Router und auf jedem Handy ohne Vorbereitung.

**code-server ist der teuerste Weg und braucht Absicherung.** VS Code im Browser, auf deinem VPS gehostet. Ohne Passwort und ohne HTTPS-Proxy davor steht deine Entwicklungsumgebung offen im Netz. Nimm ihn nur, wenn du unterwegs wirklich Dateien bearbeiten willst — für „kurz nachsehen und antworten" reicht Remote Control.

### Das SSH-Terminal auf einem Telefon

**tmux und Claude Code sind keine Alternativen.** tmux ist der Behälter, Claude Code das Programm darin. Die Wahl steht nicht zwischen beiden, sondern zwischen zwei Wegen an dieselbe laufende Sitzung: Remote Control für die Unterhaltung, SSH für alles daneben — Logs ansehen, Container neu starten, in die Datenbank schauen.

Eine Zeile deckt beide Fälle ab, anhängen und erzeugen:

```bash
ssh juni@ionos -t 'tmux new -A -s cc'
```

**Clients:** Termius auf beiden Plattformen, Blink Shell auf iOS. Termius bringt eine Zusatzleiste mit Esc, Ctrl, Tab und Pfeilen; Blink lässt Tasten frei belegen und ist dafür das bessere Werkzeug, kostet aber.

**Drei Dinge sind auf dem Telefon anders:**

| Was | Warum | Womit |
|---|---|---|
| Die Fenstergröße | tmux richtet eine Sitzung nach dem **kleinsten** angehängten Client aus — hängt der PC noch dran, schrumpft dessen Fenster auf Handygröße | eine eigene Sitzung, die dieselben Fenster teilt: `tmux new-session -t cc -s handy`, am Ende `tmux kill-session -t handy` |
| Der Prefix | `Ctrl+b` mit Softkeys ist mühsam, aber `Ctrl+a` und `Ctrl+b` springen in Claude Codes Eingabezeile an den Zeilenanfang und ein Zeichen zurück | etwas, das sonst niemand benutzt: `set -g prefix C-Space`, dazu `unbind C-b` und `bind C-Space send-prefix` |
| Esc | die wichtigste Taste in Claude Code, und auf keiner Softtastatur | `Ctrl+[` tut dasselbe und geht überall, wo es eine Ctrl-Taste gibt |

Dazu zwei Kleinigkeiten: **Splits vermeiden** — nebeneinanderliegende Panes sind auf einem Telefon unlesbar, nimm Fenster (`Prefix c`, `Prefix n`). Und `set -g default-terminal "tmux-256color"` in `~/.tmux.conf`, sonst sind die Farben falsch.

## Remote Control: was gemessen ist

Geprüft am 2026-08-09 gegen `claude --help` (Binary v2.1.226 auf dieser Maschine) und die offizielle Doku unter `code.claude.com/docs/en/remote-control`.

**Drei Arten, es zu starten — sie tun Verschiedenes:**

| Aufruf | Was du bekommst |
|---|---|
| `claude remote-control` | **Server-Modus.** Kein Chat im Terminal, nur ein Server, der auf Verbindungen wartet. Zeigt eine Session-URL; Leertaste blendet einen QR-Code ein. |
| `claude --remote-control` (kurz `--rc`) | **Normale interaktive Session**, zusätzlich vom Handy steuerbar. Du kannst lokal weitertippen. |
| `/remote-control` (kurz `/rc`) in einer laufenden Session | Schaltet die **aktuelle** Unterhaltung frei, mit Verlauf. **Seit 2.1.263 ist das die Voreinstellung** — die Statuszeile zeigt `/rc active`, und derselbe Befehl schaltet es wieder *ab*. |

Ein `claude rc` als Unterkommando gibt es nicht — `--rc` ist ein Flag, `/rc` ein Slash-Befehl.

**Voraussetzungen, jede davon kann es lautlos verhindern:**

- **Abo**: Pro, Max, Team oder Enterprise. API-Schlüssel gehen nicht.
- **Anmeldung**: `claude auth login` (voller Umfang). Ein Token aus `claude setup-token` oder `CLAUDE_CODE_OAUTH_TOKEN` reicht **nicht** — es darf nur Modell-Anfragen stellen. Fehlermeldung: *„Remote Control requires a full-scope login token"*.
- **Endpunkt**: `ANTHROPIC_BASE_URL` muss auf `api.anthropic.com` zeigen. Ein Proxy davor schaltet Remote Control ab.
- **Telemetrie-Schalter**: `DISABLE_TELEMETRY`, `DO_NOT_TRACK`, `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` und `DISABLE_GROWTHBOOK` schalten die Prüfung ab, von der die Verfügbarkeit abhängt. Jede einzelne davon genügt.
- **Workspace-Trust**: einmal `claude` im Projektordner starten und den Trust-Dialog bestätigen. Im Home-Verzeichnis wird Trust nie gespeichert — starte Remote Control also aus einem Projektordner.

**Zwei Kollisionen, die in diesem Vault schon angelegt sind:**

Die `setup-token`-Regel trifft den Orchestrator. `smithy/orchestrator/README.md` verlangt genau so ein Token in `.env.local`. Beides auf einer Maschine geht, aber es sind zwei verschiedene Anmeldungen, und die Orchestrator-Anmeldung trägt Remote Control nicht.

Die `ANTHROPIC_BASE_URL`-Regel trifft [[codex-subscription-via-cliproxyapi]]. Wer Claude Code auf den lokalen Proxy zeigen lässt, verliert Remote Control in derselben Session. Beides gleichzeitig ist unmöglich, nicht nur ungetestet.

**Grenzen:**

- **Der lokale Prozess muss laufen.** Terminal zu, VS Code beendet, Prozess tot — Session weg. Die Doku empfiehlt für SSH ausdrücklich `tmux` oder `screen`.
- **Netzausfall über etwa 10 Minuten** beendet die Session, wenn die Maschine wach ist und das Netz nicht erreicht. Danach neu starten.
- **Eine Remote-Session pro interaktivem Prozess.** Nicht pro Maschine — das ist die verbreitete Falschangabe. Mehrere Instanzen bekommen je eine eigene Session, und der Server-Modus bedient bis zu 32 gleichzeitig (`--capacity`, Vorgabe 32).
- **Manche Befehle bleiben lokal**, `/plugin` und `/resume` etwa. `/model`, `/effort` und `/rename` gehen vom Handy, aber nur mit Argument (`/model sonnet`).

**Push aufs Handy** schaltest du mit `/config` ein: *Push when Claude decides* und *Push when actions required*. Ohne das bekommst du nichts gemeldet, wenn ein langer Lauf fertig ist oder eine Freigabe hängt.

## Zwei Wege, die sich nicht ausschließen

Das ist die Auswahl, die für diesen Vault sinnvoll ist. Die beiden decken zusammen alles ab; die übrigen Kombinationen aus der Tabelle oben sind Varianten davon.

### Weg 1 — PC bleibt an

Claude in einer herdr-Pane starten, dann `/rc`. Vom Handy in der Claude-App weiterarbeiten.

**Herdr und Remote Control machen zwei verschiedene Dinge, und du brauchst beide.** Herdr hält den Prozess über eine getrennte Verbindung hinweg am Leben. Remote Control gibt dir das Fenster ohne SSH-Client. Herdr allein hieße: Handy-Terminal per SSH. Remote Control allein hieße: das Terminal muss offen bleiben.

Wann dieser Weg der richtige ist: die Arbeit liegt ohnehin auf dem PC, und du willst nur unterwegs nachsehen oder eine Freigabe erteilen.

### Weg 2 — PC ist aus, VPS trägt die Arbeit

**Seit dem 2026-09-09 aufgebaut.** Auf dem IONOS-VPS laufen zwei tmux-Sitzungen nebeneinander, und sie tun Verschiedenes:

| tmux-Sitzung | Was darin läuft | Wofür |
|---|---|---|
| `claude` | eine normale interaktive Sitzung | das Fenster am PC — ein herdr-Space hängt sich daran |
| `rc` | `claude remote-control --name vps` | der Server fürs Handy: **neue** Sitzungen auf Zuruf, Kapazität 32 |

**Der Unterschied entscheidet, ob du ohne PC anfangen kannst.** Eine interaktive Sitzung mit `/rc` teilt eine Unterhaltung, die es schon gibt — jemand muss sie gestartet haben. Der Server-Modus legt eine neue an, wenn du vom Handy eine aufmachst. Nur das zweite trägt „PC war die ganze Zeit aus".

Von Hand aufgesetzt wird der Server so:

```bash
cd ~/projekt && tmux new -d -s rc "~/.local/bin/claude remote-control --name vps"
tmux attach -t rc          # er fragt einmal: Enable Remote Control? (y/n)
```

Trennen mit `Strg-b d`. Der Prozess läuft weiter, das Handy behält sein Fenster.

**Das Fenster am PC macht ein Script.** `.claude/scripts/open-vps-space.ps1` legt den herdr-Space an und hängt ihn an die Sitzung `claude`. Es ist idempotent: ein zweiter Lauf fokussiert den vorhandenen Space, statt einen zweiten anzulegen. Schließen des Spaces beendet nichts — dafür braucht es `tmux kill-session`.

**Wer nicht weiß, was gerade läuft, tippt `/tongs`.** Der Skill stellt beide Bestände nebeneinander — die Panes auf dem PC und die tmux-Sitzungen auf dem VPS — und bietet dann nur an, was der Zustand hergibt: starten, Fenster öffnen oder schließen, beenden, Handy-Zugang an und aus. Er ruft dabei dasselbe Script auf.

**Der offene Punkt ist beantwortet.** Am 2026-09-09 auf dem IONOS-VPS gemessen: die Anmeldung von `juni` steht, sie erneuert sich aus dem gespeicherten Refresh-Token und hat keinen Browser verlangt. Die Scopes umfassen `user:profile` und `user:sessions:claude_code` — also eine volle Anmeldung, kein `setup-token`. Weg 2 trägt damit.

**systemd erst danach.** Wenn tmux sich bewährt und dich nur der Reboot stört, wird daraus eine Unit-Datei mit eigenem Dienst-User. Vorher nicht: ein Dienst, der wegen fehlender Anmeldung nichts tut, startet trotzdem sauber und meldet Erfolg.

**Und davor steht noch eine Sperre: `Linger=no`.** Ohne Linger beendet systemd die Dienste eines Benutzers, sobald dessen letzte Sitzung endet — die Unit startete also erst beim nächsten Login und wäre genau dann nutzlos, wenn sie gebraucht wird. Freigeschaltet wird das mit `sudo loginctl enable-linger juni`, und dieser Befehl verlangt zwingend eine Passwort-Eingabe. Aus der Ferne skriptbar ist er deshalb nicht.

## Was in einem fremden Blogpost stand und hier nicht stimmt

Die Vorlage zu diesem Thema kam aus einem Affiliate-Beitrag mit Hosting-Rabattcode. Drei Angaben daraus sind gegen die Doku geprüft und falsch:

| Behauptung | Tatsächlich |
|---|---|
| `claude rc` startet Remote Control | Gibt es nicht. `claude remote-control`, `--rc` oder `/rc`. |
| Eine Session pro Maschine | Eine pro interaktivem Prozess; Server-Modus bedient bis zu 32. |
| Dienst als `root` betreiben | Technisch möglich, aber unnötiges Risiko. Eigener Benutzer. |

Die technische Substanz des Beitrags — systemd-Unit, Persistenz über tmux — deckt sich sonst mit der Doku. Behandle ihn als Erfahrungsbericht, nicht als Referenz.

## Verwandt

- [[remote-dev-stack]] — die andere Hälfte: Tailscale, Mosh, Caddy und Zed, und warum die App ohne HTTPS die halbe Web-Plattform verliert. Mosh gehört auf die Achse *Bedienung* und ersetzt `tmux` an keiner Stelle.
- `PORTABILITY.md` Fall D — was auf den VPS gehört, was nicht, und wie die Dateien synchron bleiben (git, keine zweite Schicht darüber).
- [[tool-basis-usage]] — herdr im Detail, inklusive der Grenze zur kopflosen Orchestrator-Pipeline.
- [[codex-subscription-via-cliproxyapi]] — der Proxy, der Remote Control ausschließt.
