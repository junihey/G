# Der IONOS-VPS

Dieses Verzeichnis erzeugt den Server unter **217.154.113.12** — Grundausstattung, Dienste, Daten. Es liegt in `zaehlen\`, weil es baut und nicht denkt; das Rohmaterial zum Thema bleibt im Vault unter `specs\vps-neuaufbau\raw\`.

**Der Server wurde am 2026-09-08 aus diesen Dateien neu aufgebaut.** Was dabei geschah und was dabei schiefging, steht in [`aufbau.md`](aufbau.md).

## Was hier liegt

| Datei | Tut was |
|---|---|
| `bootstrap.sh` | Frischen Ubuntu-Server ausstatten: Benutzer, Swap, Docker, Firewall, fail2ban |
| `restore.sh` | Backup einspielen, Datenbank-Benutzer anlegen, Dienste starten, sich selbst prüfen |
| `harden-ssh.sh` | root-Login und Passwort-Anmeldung abschalten — **erst nach geprüftem Schlüssel-Login** |
| `compose/` | Seafile 11.0.13, Proxy Manager 2.14.0; n8n als `.aus` mit Anleitung zum Zurückholen |
| `systemd/` | Die Unit des Remote-Control-Dienstes, der den Handy-Zugang zu Claude Code trägt |
| `werkzeuge.md` | code-server und Claude Code — nachinstallierbar, nicht Teil des Wiederaufbaus |
| `env.beispiel` | Vorlage. Die echte `.env` erzeugt `restore.sh` aus dem Backup. |
| `n8n-workflows/` | Die vier Workflows als lesbares JSON |
| `inventur.md` | Der **alte** Server vor dem Reset — historisch, nicht aktuell |
| `backup.md` | Was gesichert ist und wo es liegt |
| `probelauf.md` · `aufbau.md` | Was der Restore-Probelauf bewies und was der echte Aufbau fand |

## Was der Server heute trägt

| | |
|---|---|
| Ubuntu | 26.04.1 LTS, Docker `docker-ce` |
| Benutzer | `juni` mit Passwort, in `sudo` und `docker`. Kein Dienst läuft als `root`. |
| SSH | nur Schlüssel, kein root-Login, fail2ban aktiv |
| Container | `proxy`, `seafile`, `seafile-db`, `seafile-memcached` |
| Nativ | code-server, Claude Code, der Dienst `claude-rc` für den Handy-Zugang (siehe `werkzeuge.md`) |
| Erreichbar | `seafile.julianniklasheynert.xyz`, `code.julianniklasheynert.xyz` |

## Drei Entscheidungen, die im Aufbau stecken

**Der Dienstbenutzer heißt `juni`.** Änderbar über `ADMIN_USER` in `bootstrap.sh`. Der alte Server lief vollständig als `root`.

**Nur der Proxy hat Host-Ports.** Seafile hängt im Docker-Netz `proxy` und wird über seinen Containernamen erreicht. Damit gibt es keine Ports mehr, die an der Firewall vorbeigehen könnten — Docker schreibt seine Regeln sonst unterhalb von `ufw`.

**Das Docker-Netz hat ein festes Subnetz** (`172.28.0.0/16`). Der Proxy erreicht code-server über die Gateway-Adresse `172.28.0.1`. Vergäbe Docker sie frei, zeigte der Proxy-Host nach einem Neuaufbau ins Leere.

## Wiederherstellung nach einem Ausfall

Der wahrscheinliche Fall. Das Backup liegt in `C:\Users\nolte\vps-backup\<Datum>\` — außerhalb jedes Git-Repositorys, weil es Passwörter im Klartext enthält.

### 1. Frischen Server bereitstellen

Im IONOS-Panel neu installieren, Ubuntu 26.04. Danach hat er **neue Host-Schlüssel**:

```bash
ssh-keygen -R 217.154.113.12
ssh-keyscan -H 217.154.113.12 >> ~/.ssh/known_hosts
```

Falls noch kein Schlüssel existiert, einen erzeugen — ohne Passphrase, damit nicht-interaktive Läufe funktionieren:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ionos -N "" -C "ionos-vps"
```

Den Schlüssel hinterlegen — das braucht ein echtes Terminal, weil es nach dem root-Passwort fragt:

```bash
cat ~/.ssh/id_ionos.pub | ssh root@217.154.113.12 \
  "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

### 2. Repo und Backup hochladen

```bash
scp -r ~/Desktop/zaehlen/vps root@217.154.113.12:/root/
scp ~/vps-backup/<Datum>/*.tar.gz ~/vps-backup/<Datum>/*.sql.gz root@217.154.113.12:/root/backup/
```

Die Image-Archive (`image-*.tar.gz`) braucht es nur, wenn Docker Hub die gepinnten Versionen nicht mehr führt. Dann vorher `docker load -i <archiv>`.

### 3. Aufbauen — als `root`, vor der Härtung

```bash
cd /root/vps
ADMIN_USER=juni SSH_PUBKEY="$(head -1 /root/.ssh/authorized_keys)" ./bootstrap.sh
ARCHIVE=/root/backup ./restore.sh
```

**Diese Reihenfolge ist Absicht.** `bootstrap.sh` legt `juni` ohne Passwort an, also kann er kein `sudo`. Liefe die Härtung vorher, gäbe es weder root noch `sudo` — der Aufbau sperrte sich selbst aus.

`restore.sh` prüft sich am Ende selbst: laufen alle Container, stehen Bibliotheken in der Datenbank, meldet Seafile `Seahub is started`. Schlägt eine der drei Fragen fehl, endet es mit einem Fehler.

### 4. Prüfen, bevor gehärtet wird

- `ssh juni@217.154.113.12` muss ohne Passwort funktionieren.
- Ein Passwort für `juni` setzen: `passwd juni` — sonst kann er später kein `sudo`.
- Seafile öffnen und **eine Datei herunterladen**. Nicht nur die Liste ansehen.

### 5. Härten

```bash
./harden-ssh.sh
```

Danach ist `root` per SSH gesperrt. Der Rückweg bei einem Fehler ist die Web-Konsole im IONOS-Panel — sie funktioniert, geprüft am 2026-09-07.

### 6. Werkzeuge

code-server und Claude Code nach [`werkzeuge.md`](werkzeuge.md).

## Umzug auf einen anderen PC

Der Server bleibt, wo er ist. Was mitwandern muss, ist der **Zugang** und die **Sicherung** — beides liegt außerhalb der Repositorys und wird deshalb von keinem `git clone` mitgebracht.

| Was | Wo | Warum es nicht in git liegt |
|---|---|---|
| `~/.ssh/id_ionos` und `id_ionos.pub` | `C:\Users\nolte\.ssh\` | Der private Schlüssel ist der komplette Serverzugang |
| `~/.ssh/config`, Abschnitt `Host ionos` | daneben | Zwei Zeilen, aber ohne sie heißt jeder Befehl `juni@217.154.113.12` |
| `C:\Users\nolte\vps-backup\` | eigener Ordner | Über ein Gigabyte, mit Passwörtern im Klartext und einem Anmelde-Token |

Der Rest kommt aus git: dieses Repository, und der Vault für die Notizen.

**So sieht der `config`-Abschnitt aus:**

```
Host ionos
    HostName 217.154.113.12
    User juni
    IdentityFile ~/.ssh/id_ionos
```

**Nach dem Umzug drei Dinge prüfen**, in dieser Reihenfolge:

```bash
chmod 600 ~/.ssh/id_ionos        # sonst verweigert ssh den Schlüssel
ssh ionos "hostname"             # muss ohne Passwort durchlaufen
ls ~/vps-backup/                 # die Archive müssen da sein
```

Der erste Schritt fällt oft aus. Windows kopiert Rechte nicht mit, und OpenSSH lehnt einen Schlüssel ab, den auch andere lesen dürfen — die Fehlermeldung nennt „unprotected private key file", nicht die Rechte.

**Der Schlüssel hat keine Passphrase.** Wer die Datei kopiert, ist damit auf dem Server. Beim Umzug ist der Moment, das zu ändern: `ssh-keygen -p -f ~/.ssh/id_ionos` verschlüsselt die Datei, ohne dass auf dem Server etwas angepasst werden muss.

## Einen Dienst hinzufügen

Drei Dinge, dann trägt `restore.sh` ihn mit:

1. Eine compose-Datei unter `compose/<name>/docker-compose.yml`. Ohne Host-Ports, im Netz `proxy`.
2. Sein Datenbestand im Backup.
3. Sein Name in `DIENSTE` am Anfang von `restore.sh`.

Braucht er einen Datenbank-Dump statt einer Dateikopie, ist mehr nötig — der Seafile-Block in `restore.sh` zeigt, was.
