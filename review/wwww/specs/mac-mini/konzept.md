---
created: 2026-09-25
revised: 2026-09-25
topic: Mac mini M6 als dauerhaft laufender Arbeitsknoten neben diesem PC — und nebenbei als Ausstellungsrechner für Max/MSP
quelle: drei Chat-Verläufe vom September 2026, dazu Messwerte dieses PCs und PORTABILITY.md Fall D
stand: Konzept, nichts davon gebaut
---

# Mac mini M6 — der zweite Rechner, der nie ausgeht

**Die Antwort zuerst:** Der Mac mini ist nicht der schnellere Rechner. Dieser PC ist es. Der Mac mini ist der Rechner, der **immer an sein darf**. Aus diesem einen Unterschied folgt das ganze Konzept.

- **Dieser PC** bleibt der Arbeitsplatz: Max-Entwicklung, ComfyUI auf der Grafikkarte, Obsidian, interaktive Claude-Sessions im Vault.
- **Eine Linux-VM auf dem Mac mini** ist der Arbeitsknoten: lange und unbeaufsichtigte Claude-Läufe, Docker, Build-Agenten, Dienste, die rund um die Uhr laufen.
- **Der macOS-Host des Mac mini** spielt die Ausstellung ab und ist das Testgerät für Max unter macOS.
- **Der VPS** behält alles, was öffentlich erreichbar sein muss.

## 1. Was der Mac mini wirklich bringt

### Nicht: mehr Rechenleistung

| | Dieser PC | Mac mini M6 |
|---|---|---|
| CPU | Intel Core Ultra 7 265K, 20 Kerne | 12 Kerne |
| RAM | 32 GB | max. 32 GB |
| GPU | RTX 5070 Ti (CUDA) | 12-Core Apple GPU, in einer Linux-VM **nicht nutzbar** |

Bei Arbeit, die auf viele Kerne verteilt läuft (große Builds, parallele Tests, Docker-Stacks), liegt der PC vorn. Bei Arbeit auf einem Kern (ein einzelner `tsc`-Lauf, viele Testrunner) ist der M6 wahrscheinlich gleich schnell oder etwas schneller. ComfyUI und alles mit CUDA bleiben ohnehin auf dem PC.

**Claude selbst rechnet in Anthropics Cloud.** Wie schnell eine Session antwortet, hängt nicht vom Rechner ab. Der Rechner zählt nur für das, was Claude startet: Builds, Tests, Installationen.

### Sondern: diese vier Dinge

1. **Er darf immer an sein.** Schätzung: dieser PC braucht im Leerlauf 60–100 W, der Mac mini 5–10 W. Rund um die Uhr sind das etwa 200 € Strom im Jahr Unterschied (bei 0,35 €/kWh). Deshalb bleibt der PC nachts aus, und der Mac mini arbeitet weiter.
2. **Der PC bleibt frei.** Drei Build-Agenten mit Docker auf dem Mac mini bremsen weder Max noch ComfyUI auf dem PC. Heute konkurrieren beide um dieselben 32 GB.
3. **Linux statt Windows für Server-Arbeit.** Docker läuft in der VM ohne den Umweg über WSL2. Skripte, Pfade und Paketmanager sind dieselben wie auf dem VPS. Die Stolpersteine aus [[shell-und-cli]] fallen dort weg.
4. **Macs Hardware für die Ausstellung.** Ein Patch, der auf Windows läuft, kann auf macOS an Externals, Schriften, Pfaden oder Audiogeräten scheitern. Der Mac mini ist genau das Gerät, auf dem die Ausstellung später läuft.

### Und gegenüber dem VPS

Der VPS ist öffentlich erreichbar, der Mac mini nicht. Der Mac mini hat dafür mehr RAM, eine schnelle lokale SSD und steht im Heimnetz. Der VPS behält Seafile, den Proxy und alles Öffentliche.

**Remote Control läuft auf beiden.** Die Claude-App zeigt dann zwei Gerätekarten. Im Alltag nimmst du die VM auf dem Mac mini, weil dort mehr Leistung bereitsteht. Der VPS bleibt die Rückfallebene: im Urlaub, wenn der Mac mini aus ist, oder wenn er bei einer Ausstellung ohne Internet steht. Beide Anmeldungen laufen nach etwa 28 Tagen ab. Vor einer langen Reise deshalb auf beiden `claude auth status` prüfen.

**Eine Anmeldung ohne Ablaufdatum gibt es mit Remote Control nicht.** `claude setup-token` hält ein Jahr, ein API-Key unbegrenzt, aber beide schließen Remote Control aus. Die 28 Tage stammen aus einem GitHub-Issue und sind nicht selbst geprüft. Ob sie ab der Anmeldung oder ab der letzten Nutzung zählen, zeigt erst der Betrieb.

**Der Notweg, wenn die Anmeldung unterwegs abläuft:** eine SSH-App auf dem Handy (etwa Termius) mit Zugang über Tailscale. Damit per SSH auf den Mac mini, `claude` starten, `/login` tippen und die angezeigte Adresse im Browser des Handys öffnen. Remote Control selbst kann das nicht, es steht mit der abgelaufenen Anmeldung still. Die App vor der Reise einrichten und einmal testen.

### Wie du den Vorteil misst, statt ihn zu schätzen

Nach der Einrichtung einmal denselben Lauf auf beiden Rechnern starten, zum Beispiel `npm ci && npm test` im Orchestrator oder einen Docker-Build. Die Zeit notieren. Dazu einen Tag lang die Leistungsaufnahme beider Rechner mit einer Steckdosen-Messdose ablesen. Erst diese Zahlen sagen, welche Arbeit wohin gehört.

## 2. Die Aufteilung

```
                       Tailscale (alle Geräte, kein offener Port)
   ┌──────────────┐                                       ┌──────────────┐
   │  Dieser PC   │ ── SSH · Editor · Git · OSC · Sync ── │  Mac mini    │
   │  Windows     │                                       │  ┌────────┐  │
   │  Max (Dev)   │                                       │  │ Linux- │  │
   │  ComfyUI     │                                       │  │ VM     │  │
   │  Vault       │                                       │  └────────┘  │
   └──────────────┘                                       │  macOS-Host  │
          │                                               │  Max (Ausst.)│
          └───────────── Handy (Remote Control) ──────────┴──────────────┘
                                   VPS: öffentliche Dienste
```

| Rechner | Läuft dort | Läuft dort nicht |
|---|---|---|
| **Dieser PC** | Max-Editor, ComfyUI, Obsidian, interaktive Sessions in `C\` | Nachtläufe; alles, was den PC wach halten müsste |
| **Mac mini, Linux-VM** | Claude Code mit Remote Control, Build-Agenten mit Docker, Dev-Server der Projekte aus `zaehlen\`, später die geplanten Tasks | Max, alles mit GPU |
| **Mac mini, macOS-Host** | Max (Ausstellung und Test), Tailscale, sonst nichts | Claude Code, Docker, Zugangsdaten |
| **VPS** | Seafile, Proxy, die Sensor-Webseite der Installation, Remote Control als Rückfallebene | Build-Agenten |

## 3. Die Kanäle zwischen PC und Mac mini

Das ist der Kern von „eng verknüpft“. Jeder Kanal hat genau eine Aufgabe.

### Lokal zuerst, Tailscale für die Ferne

**Zwischen den Geräten braucht kein Kanal Internet.** Zu Hause laufen alle über das Heimnetz. Steht der Mac mini bei einer Ausstellung, laufen dieselben Kanäle über Tailscale. Die Befehle bleiben gleich, nur die Adresse wechselt.

**Was trotzdem Internet braucht:** Claude selbst, weil das Modell in Anthropics Cloud rechnet. GitHub nur noch als Sicherung außer Haus. Remote Control vom Handy.

Tailscale allein reicht für „ohne Internet“ nicht. Zu Hause gehen die Daten zwar direkt durchs Heimnetz und kosten kein Datenvolumen. Tailscale braucht aber seinen Koordinationsserver im Internet, um Verbindungen aufzubauen und Schlüssel zu erneuern. Fällt das Internet aus, ist unklar, wie lange Tailscale weiterläuft. Deshalb die feste LAN-Adresse als erster Weg. Sie schützt vor dem Ausfall, nicht vor Datenverbrauch.

**Dafür nötig:**
- Feste IP-Adressen im Router für den Mac-Host und die VM, zum Beispiel `192.168.1.50` und `192.168.1.51`.
- Die VM hängt **gebrückt**° im Netz (`tart run --net-bridged=en0`). Sie bekommt dadurch eine eigene Adresse im LAN und ist vom PC direkt erreichbar. Sie hat ihr eigenes Tailscale.
- **Ein Name für beide Wege.** In `C:\Users\nolte\.ssh\config` wählt SSH selbst: Ist die LAN-Adresse erreichbar, nimmt es sie, sonst den Tailscale-Namen. Alles, was über SSH läuft (Terminal, Editor, Git), heißt dann immer `mini-vm`.

```
Match host mini-vm exec "ping -n 1 -w 300 192.168.1.51 >nul"
  HostName 192.168.1.51
Host mini-vm
  HostName mini-vm        # Tailscale-Name, greift nur ohne LAN
  User claude
```

Ob `Match exec` mit dem OpenSSH von Windows so läuft, wird bei der Einrichtung getestet.

### Die Kanäle

| Kanal | Wofür | Zu Hause | Bei der Ausstellung |
|---|---|---|---|
| **Terminal** | Befehle in der VM | `ssh mini-vm`, dort tmux oder herdr | derselbe Befehl, über Tailscale |
| **Editor** | Dateien in der VM bearbeiten, als lägen sie lokal | VS Code oder Zed mit Remote-SSH auf `mini-vm` | derselbe |
| **Git** | Code und Patches | Die VM hält die Repos als zentrale Ablage im Heimnetz, siehe unten | derselbe, über Tailscale |
| **Syncthing** | Große Dateien ohne Git: Samples, Videos, Texturen für Jitter | Direkt im LAN. Auf dem PC **nur senden**, auf dem Mac-Host **nur empfangen**. | ruht von selbst; die Medien kommen vorher im Heimnetz an |
| **OSC über UDP** | Live-Daten und Fernsteuerung | Max auf dem PC schickt an `192.168.1.50:7400` | an die Tailscale-Adresse des Hosts (`100.x.y.z`) |
| **Browser** | Web-Apps aus der VM testen | `ssh -L 3000:localhost:3000 mini-vm`, dann `http://localhost:3000`. Nur so gelten Kamera und Sensoren im Browser, siehe [[remote-dev-stack]]. | derselbe |
| **Bildschirm** | Die Ausstellung sehen und bedienen | VNC-Viewer (etwa TigerVNC) auf `192.168.1.50` | auf die Tailscale-Adresse |
| **Handy** | Claude-Sessions von unterwegs | Remote Control in der VM, Rückfallebene auf dem VPS | derselbe, braucht Internet am Ausstellungsort |

**Syncthing nur im Heimnetz:** In den Einstellungen die globale Suche und die Relays ausschalten. Als Adresse des Mac mini nur die LAN-Adresse eintragen. Beim Gerät unter „Erlaubte Netzwerke“ das Heimnetz setzen, zum Beispiel `192.168.1.0/24`. Dann verbindet sich Syncthing weder über Relays noch über Tailscale. Steht der Mac mini bei der Ausstellung, ruht der Abgleich von selbst, und kein vergessenes Video frisst das Tagesvolumen.

### Git ohne GitHub dazwischen

**Die VM ist die zentrale Ablage.** Für jedes Repo liegt dort ein Bare-Repo° unter `~/repos/<name>.git`. PC und VM tauschen darüber aus, ohne dass ein Commit das Haus verlässt.

- Auf dem PC bekommt jedes Repo ein zweites Remote: `git remote add mini mini-vm:repos/<name>.git`. Gearbeitet wird mit `git push mini` und `git pull mini`.
- `origin` auf GitHub bleibt die Sicherung außer Haus. Du pushst dorthin, wenn Internet da ist; es muss nicht nach jedem Commit sein.
- Der Mac-Host holt Patches aus derselben Ablage, nur lesend (Abschnitt 4).

Das ändert die Regel aus PORTABILITY.md Fall D für diese Maschine: Das Remote für den Alltag ist `mini`, nicht mehr `origin`.

**Wie eine Session vom PC eine Aufgabe abgibt:** Die Session im Vault schreibt die Aufgabe in ein Repo und pusht nach `mini`. In der VM startest du sie mit `claude --bg "…"` oder über den Orchestrator. Vom PC aus geht das auch direkt: `ssh mini-vm 'cd ~/zaehlen/projekt && claude --bg "…"'`. Das Ergebnis kommt als Branch zurück, du holst es mit `git pull mini`.

### Datenvolumen

**Der Anschluss zu Hause erlaubt 10 GB am Tag.** Alle Rechner zu Hause teilen sich dieses Volumen.

**Zwischen den Geräten fließt wenig, und zu Hause kostet es nichts.** Ein Commit mit einem Patch hat Kilobytes, eine Claude-Session Kilobytes bis wenige Megabyte. Auch mit Tailscale laufen diese Daten direkt durchs Heimnetz. Über das Internet gehen nur Tailscales Steuerdaten. Prüfen mit `tailscale ping mini-vm`: `via 192.168.1.51` heißt direkt, `via DERP` heißt über einen Relay-Server im Internet.

**Volumen kostet, was aus dem Internet heruntergeladen wird.** Grob geschätzt:

| Download | Größe | Wie oft |
|---|---|---|
| Ein Docker-Image, etwa `node:22` | einige hundert MB bis über 1 GB | einmal pro Rechner, danach aus dem Cache |
| `npm install` in einem neuen Projekt | 50–200 MB | einmal, danach aus dem npm-Cache |
| Update von Claude Code | etwa 100 MB | alle paar Tage, auf jedem Rechner einzeln |
| Großes macOS-Update | 5–15 GB | wenige Male im Jahr |
| Bildmodell für ComfyUI (SDXL, Flux) | 7–25 GB | einmal pro Modell |

**Drei Fallen, in denen dieselben Daten mehrfach geladen werden:**
1. **Dasselbe auf zwei Rechnern.** Arbeit auf den Mac mini zu verlagern spart kein Volumen, es verschiebt es nur.
2. **Jeder Build-Agent in einem eigenen Container.** Mit leerem npm-Cache lädt jeder Agent alle Pakete neu. Abhilfe: den npm-Cache der VM in jeden Container einhängen.
3. **Aufräumen löscht den Cache.** `docker system prune` oder eine neu aufgesetzte VM laden danach alles neu. Eine Kopie mit `tart clone` enthält den Cache und ist harmlos.

**Große Downloads nicht auf denselben Tag legen.** Ein einziges Flux-Modell kann das Tagesvolumen allein aufbrauchen.

**Der VPS lädt über sein Rechenzentrum.** Was dort heruntergeladen wird, zählt nicht gegen den Anschluss zu Hause. Nur was du danach nach Hause holst, zählt.

**Bei der Ausstellung** laufen alle Kanäle übers Internet und zählen doppelt: gegen das Volumen zu Hause und gegen das Netz am Ausstellungsort. Git, Terminal und OSC sind unbedenklich. Die Bildschirmfreigabe kostet grob 0,5–2 GB pro Stunde (Schätzung), also nur kurz und mit niedriger Qualität. Syncthing ruht ohnehin.

## 4. Der Weg eines Max-Patches

1. Du baust den Patch auf dem PC im Max-Editor.
2. `git push mini` in die Ablage auf der VM. Medien liegen im Syncthing-Ordner und kommen von allein an.
3. Auf dem Mac-Host: `ssh mini-host ausstellung-update`. Das Skript macht `git pull` aus der Ablage in der VM und lädt Max neu. Der Host hat dafür einen eigenen SSH-Schlüssel, der in der VM nur lesen darf.
4. Über die Bildschirmfreigabe prüfst du Bild und Ton auf der echten Hardware.

**Claude darf Patches bearbeiten.** Die `.maxpat`-Dateien sind JSON. Eine Session auf dem PC oder in der VM ändert sie im Repo. Auf den Host kommt aber nur, was du mit Schritt 3 selbst holst.

**Die VM hat keinen Weg auf den Host.** Sie schreibt nicht in dessen Dateien und startet dort nichts. Sie darf nur OSC an den Port schicken, auf dem Max lauscht. Der Host holt aus der VM, nie umgekehrt.

**Der `maxmsp`-MCP-Server** gibt Claude direkten Zugriff auf ein laufendes Max. Er gehört auf den PC, zum Max-Editor. Auf dem Mac-Host läuft er nie.

## 5. Der macOS-Host: Ausstellung

Einmal einrichten, danach nur noch über `ausstellung-update` anfassen.

- Admin-Konto nur für Verwaltung. Benutzer `ausstellung`: Standardbenutzer, **Auto-Login**, ohne iCloud, ohne Zugangsdaten.
- `sudo pmset -a sleep 0 disksleep 0 displaysleep 0 disablesleep 1`
- `sudo pmset autorestartatconnect 1` und `sudo pmset -a autorestart 1`, dann mit Stecker ziehen testen.
- Bildschirmschoner, Mitteilungen und große Updates aus. Ein macOS-Update kann 5–15 GB haben und das Tagesvolumen allein aufbrauchen.
- Max startet über einen launchd-Agenten mit `KeepAlive`, also nach jedem Absturz neu.
- Audiogerät für die drei Genelec fest in Max eintragen. macOS wechselt nach einem Neustart gern das Standardgerät.

**Standalone oder Max ohne Lizenz?** Ein Standalone muss auf macOS gebaut werden, also auf dem Mac mini selbst. Ohne Lizenz öffnet Max Patches im Runtime-Modus. Das würde den Build-Schritt sparen. Offen ist, ob Jitter und gen~ im Runtime-Modus vollständig laufen. Das wird vor der Entscheidung getestet.

**FileVault ist aus**, weil die Ausstellung Auto-Login braucht. Deshalb liegen auf dem Host keine Geheimnisse, siehe Abschnitt 6.

## 6. Die Linux-VM: Arbeitsknoten

**Werkzeug: Tart** mit einem Ubuntu-Image. `tart clone` legt in Sekunden eine Kopie der VM an, die als Snapshot dient. Die Lizenz vor der Einrichtung prüfen.

**Ressourcen:** Die VM läuft dauerhaft und parallel zur Ausstellung. Deshalb fest **8 von 12 Kernen und 18 von 32 GB**. Max und macOS behalten den Rest. Test vor der ersten Ausstellung: Während Max Ton ausgibt, läuft in der VM ein großer Docker-Build. Knackt der Ton, bekommt die VM weniger Kerne.

**Inhalt:**
- Claude Code (nativer Installer, Kanal `stable`), einmal `/login` mit dem eigenen Abo.
- Remote Control dauerhaft als systemd-Dienst, wie auf dem VPS (`zaehlen\vps\systemd\`). Der Dienst auf dem VPS bleibt bestehen.
- Docker nativ. Der Orchestrator mit seinen Build-Agenten läuft hier. Auf dem PC ist sein Docker-Daemon heute aus.
- Die Bare-Repos als zentrale Ablage (Abschnitt 3) und daneben Arbeitsklone von Vault, smithy und den Projekten aus `zaehlen\`. Alles liegt im Dateisystem der VM.
- Weil die VM die Grenze ist, ist `--dangerously-skip-permissions` hier erlaubt. Auf dem Host nie.

**Zugangsdaten schützen:** Der Mac mini steht bei einer Ausstellung in einem öffentlichen Raum. Deshalb liegen `~/.claude`, die Tokens und die Repos in einem **verschlüsselten Bereich der VM (LUKS)**. Nach einem Stromausfall startet die Ausstellung von allein. Die VM wartet, bis du den Bereich per SSH öffnest. Die Ausstellung hängt nie von dir ab, die Entwicklung schon.

**Vor einem riskanten Lauf:** `tart clone`. Geht etwas schief, VM löschen und die Kopie zurückbenennen.

## 7. Was vom PC umzieht, und wann

Nicht alles auf einmal. Erst läuft ein Schritt von Hand, dann wird er fest eingerichtet.

| Stufe | Was zieht um | Auslöser |
|---|---|---|
| 1 | Remote Control zusätzlich in der VM; der VPS behält seinen Dienst als Rückfallebene | sofort nach der Einrichtung |
| 2 | Build-Agenten des Orchestrators mit Docker | sobald der erste Lauf in der VM von Hand grün war |
| 3 | Lange unbeaufsichtigte Claude-Läufe für Projekte in `zaehlen\` | wenn du einen Lauf über Nacht willst |
| 4 | Die geplanten Tasks aus `.claude\scheduled\` | nur wenn sie ausfallen, weil der PC aus ist. Sie sind heute PowerShell-Skripte und müssen dafür umgeschrieben werden. Die Hooks sind `.mjs` und laufen ohne Änderung. |

**Was nie umzieht:** Max-Entwicklung, ComfyUI, Obsidian. Sie brauchen Windows, die RTX-Grafikkarte oder beides.

## 8. Reihenfolge der Einrichtung

1. Host: Admin-Konto, Benutzer `ausstellung`, Energie-Einstellungen, Stecker-Test.
2. Feste IP-Adressen im Router, Tailscale auf dem Host als Dienst, SSH nur mit Schlüssel, Bildschirmfreigabe vom PC aus testen.
3. Max mit launchd-Agent. Test: Prozess hart beenden, startet Max neu?
4. Tart, Ubuntu-VM gebrückt, eigenes Tailscale, verschlüsselter Bereich, Claude Code, `/login`, Remote Control. Erste Kopie mit `tart clone`.
5. Vom PC: die SSH-Config mit `Match exec`, `ssh mini-vm`, Remote-SSH im Editor, `ssh -L` für eine Web-App. Dann dasselbe noch einmal mit gezogenem Internetkabel am Router.
6. Bare-Repos in der VM, Remote `mini` auf dem PC. Syncthing ohne globale Suche. OSC-Test in beide Richtungen: PC → Mac-Max, VM → Mac-Max.
7. Die Messung aus Abschnitt 1.
8. Das Skript `ausstellung-update`, nachdem der Ablauf zweimal von Hand lief.

## Offen

- ~~Tart-Lizenz und LUKS in einem Tart-Image gegen die aktuelle Doku prüfen.~~ **Beides geklärt am 2026-10-03.** Tart steht unter FSL-1.1-ALv2: interne Nutzung frei, eingeschränkt ist nur, Tart selbst als Konkurrenzprodukt anzubieten — keine Grenze nach Größe oder Umsatz, nach zwei Jahren Apache 2.0. Und LUKS ist keine Frage an Tart: Der Tresor entsteht als Datei in der VM (`fallocate` plus `cryptsetup`), der Hypervisor sieht nur ein Festplatten-Abbild.
- Runtime-Modus ohne Lizenz: laufen Jitter und `gen~` vollständig? **Am 2026-10-03 recherchiert und nicht beantwortet** — die auffindbaren Angaben betreffen Max for Live, nicht den Runtime-Modus. Das klärt nur ein Test auf dem Gerät: Max installieren, einen Patch mit `jit.window` und `gen~` öffnen, laufen lassen.
- Welches Netz gibt es am Ausstellungsort? Ohne ausgehendes Internet fallen Tailscale und damit alle Kanäle aus Abschnitt 3 weg, dann bleibt nur Wartung vor Ort. Die Ausstellung selbst läuft auch ohne Internet weiter.
- Reichen 32 GB, wenn Ausstellung und drei Build-Agenten gleichzeitig laufen? Sonst der M5 Pro mit 48 GB.
- ~~Sensor-Webseite für die Besucher-Handys: VPS oder Cloudflare Tunnel aus der VM?~~ **Beantwortet am 2026-10-03: keins von beidem.** Beide setzen Internet voraus, das es am Ausstellungsort nicht gibt — die Installation läuft ausdrücklich ohne. Die Webseite läuft **in der VM vor Ort**, in Docker, und liefert ein echtes Zertifikat aus, das per DNS-Challenge vorher geholt wurde. Der ganze Ablauf steht in `zaehlen\wwww\installationsrechner.md`.

  Zwei Bedingungen hängen daran, und beide berühren Abschnitt 6:

  - **Die VM muss gebrückt laufen**, mit eigener Adresse im WLAN-Netz. Nur dann erreichen die Besucher-Handys sie, und nur dann sieht sie deren Absenderadressen. Daran hängt mehr als die Erreichbarkeit: In einer echten Linux-VM läuft Docker nativ und reicht die Absenderadresse durch — Docker Desktop auf dem Host täte das nicht. Dadurch erkennt der Server selbst, aus welchem der drei Standort-WLANs ein Besucher kommt, und ein Aufbau aus drei Portal-Seiten und drei QR-Codes fällt auf je einen zusammen.
  - **Die Webseite darf nicht im verschlüsselten Bereich liegen.** Abschnitt 6 lässt die VM nach einem Neustart warten, bis du den Bereich per SSH öffnest. Die Ausstellung darf nie von dir abhängen. Außer dem Zertifikatsschlüssel — 90 Tage gültig, ersetzbar — liegt dort nichts Schützenswertes.
