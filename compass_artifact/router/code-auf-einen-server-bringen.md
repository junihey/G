---
tags: [learning, git]
created: 2026-09-11
topic: Wie Code von diesem Rechner auf einen Server kommt — über GitHub mit Deploy Key, oder ohne Netz als git bundle
verification: extern — Standard-git und GitHub; der Ablauf ist am 2026-09-10 und 2026-09-11 für zaehlen\wwww\ gelaufen
---

# Code auf einen Server bringen

Diese Datei setzt voraus, dass du `git commit` kennst. Alles andere baut von
hier auf.

**Was hier nicht steht:** wie man in der Historie zurückgeht — das steht in
`restore-vs-reset.md` daneben.

---

## 1 · Das Problem: eine Wahrheit, mehrere Kopien

Der Code liegt auf deinem Rechner. Er soll auch auf dem VPS liegen, und später
auf einem Rechner in einer Halle.

Die naheliegende Lösung — Ordner kopieren — erzeugt ein stilles Problem: Danach
gibt es drei Fassungen, und niemand weiß mehr, welche die richtige ist. Ändert
jemand etwas auf dem Server, ist es nirgends festgehalten.

**Die Regel, die das verhindert: Auf dem Server wird keine Datei bearbeitet.**
Wer es doch tut, hat einen vierten Ort statt drei.

## 2 · Das Remote ist die zweite Kopie

Ein **Remote** ist ein Repository, das woanders liegt und einen Namen hat. Der
übliche Name ist `origin`.

```bash
git remote -v
```

Zeigt das nichts, gibt es keine zweite Kopie — der Code existiert genau einmal,
auf dieser Platte. `git push` antwortet dann: *No configured push destination.*

Ein Remote anlegen:

```bash
git remote add origin https://github.com/junihey/wwww.git
git push -u origin main
```

`-u` merkt sich die Zuordnung, danach genügt `git push`.

## 3 · Der Server holt sich den Code

Auf dem Server einmalig:

```bash
git clone git@github.com:junihey/wwww.git
```

Danach bei jeder Änderung:

```bash
git pull
```

**`git pull` holt nur, was sich geändert hat** — nicht alles noch einmal.

## 4 · Bei einem privaten Repository fehlt der Zugang

Ein öffentliches Repository kann jeder klonen. Ein privates verlangt einen
Nachweis, und der Server hat keinen Browser, in dem sich jemand anmelden könnte.

Der erste Versuch scheitert dann so:

```
fatal: could not read Username for 'https://github.com': No such device or address
```

Git fragt nach einem Benutzernamen, und niemand ist da, der antwortet.

## 5 · Der Deploy Key

Ein **Deploy Key** ist ein SSH-Schlüsselpaar, das für **ein einziges
Repository** gilt.

Ein Schlüsselpaar besteht aus zwei Dateien: Der **private Schlüssel** bleibt auf
dem Server und wird nie weitergegeben. Der **öffentliche** ist zum Weitergeben
gedacht — er wird bei GitHub hinterlegt.

Auf dem Server erzeugen:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/github_wwww -N ""
cat ~/.ssh/github_wwww.pub
```

Den ausgegebenen Text bei GitHub eintragen: *Repository → Settings → Deploy
keys → Add deploy key*. **Schreibzugriff nicht erlauben** — der Server soll nur
lesen.

Damit SSH den Schlüssel auch anbietet, kommt er in `~/.ssh/config`:

```
Host github.com
  IdentityFile ~/.ssh/github_wwww
  IdentitiesOnly yes
```

Und die Adresse des Remotes muss die SSH-Form haben, nicht die HTTPS-Form:

```
git@github.com:junihey/wwww.git
```

**Warum nicht ein Zugriffstoken?** Ein Token gilt für dein ganzes Konto. Ein
Deploy Key gilt für ein Repository und nur zum Lesen. Wird der Server
kompromittiert, ist der Schaden begrenzt.

## 6 · Die Falle mit den Schlüsselnamen

**SSH bietet von sich aus nur Schlüssel mit Standardnamen an** — `id_rsa`,
`id_ecdsa`, `id_ed25519` und ein paar weitere. Heißt deiner anders, wird er nie
angeboten, und die Anmeldung scheitert mit *Permission denied*, obwohl der
Schlüssel längst am Ziel liegt.

Das ist die häufigste Ursache für eine Anmeldung, die „ohne Grund" fehlschlägt.
Zwei Auswege: der Eintrag in `~/.ssh/config` aus Abschnitt 5, oder bei jedem
Aufruf:

```bash
ssh -o "IdentityFile ~/.ssh/mein_schluessel" -o IdentitiesOnly=yes benutzer@host
```

Was tatsächlich angeboten wird, zeigt `ssh -v` in den Zeilen mit *Trying private
key*.

## 7 · Ohne Netz: das `git bundle`

Ein Rechner in einer Halle hat kein Internet. `git clone` von GitHub fällt aus.

Ein **Bundle** ist ein Repository in einer einzigen Datei — mit vollständiger
Historie, allen Zweigen, allem:

```bash
git bundle create wwww-repo.bundle --all
```

Diese Datei kopierst du auf einen Stick. Am Ziel:

```bash
git clone wwww-repo.bundle wwww
```

Danach liegt dort ein vollwertiges Repository. `git log` funktioniert, `git
diff` funktioniert.

Prüfen, ob eine Bundle-Datei heil ist:

```bash
git bundle verify wwww-repo.bundle
```

Die Antwort *The bundle records a complete history* heißt: vollständig.

**Für `zaehlen\wwww\` sind das 280 Kilobyte** — neben zweimal 22 Megabyte für
die Docker-Images fällt es nicht ins Gewicht.

## 8 · Was nicht über git geht

Zwei Dinge gehören nie ins Repository und müssen deshalb anders reisen:

| Was | Warum nicht | Wie stattdessen |
|---|---|---|
| die `.env` | enthält ortsabhängige Werte und später Passwörter | von Hand hinterlegen; `.env.example` im Repo ist die Checkliste |
| `certs/` | enthält den privaten Schlüssel | separat kopieren, ins Backup |

Beide stehen in `.gitignore`. **Prüfen, bevor du das erste Mal pushst** — was
einmal in der Historie steht, bekommt man nur mit Mühe wieder heraus:

```bash
git ls-files
```

Die Ausgabe ist genau das, was beim Push übertragen wird.

## 9 · Der Ablauf im Zusammenhang

```
dein PC  --git push-->  GitHub (privat)  --git pull-->  VPS
   |                                                    (Deploy Key, nur lesen)
   |
   +--git bundle-->  Stick  --git clone-->  Rechner in der Halle
```

Auf dem VPS ändert sich danach nichts von Hand — nur `git pull` und ein
Neustart der Container.

## 10 · Eine Nebenwirkung, die überrascht

Hängt dein Rechner am Netzwerk des Routers für die Installation, hat er **kein
Internet mehr**: Windows nimmt die Kabelverbindung als bevorzugten Weg, und der
Router hat keinen Uplink.

Dann scheitert `git push` mit einer Zeitüberschreitung, obwohl WLAN daneben
verbunden ist. Der Commit ist gemacht, nur nicht übertragen. Kabel ziehen löst
es.

## Verwandt

- `restore-vs-reset.md` — zurückgehen in der Historie
- `show-vs-diff.md` — ansehen, was sich geändert hat
- `..\docker\wie-wwww-aufgebaut-ist.md` — was neben dem Code noch transportiert werden muss
- `zaehlen\wwww\README.md` — die Befehle für Prod und für das Bündel
