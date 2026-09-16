---
tags: [learning, pre-use, betriebssystem]
created: 2026-09-08
topic: 'Was root von einem normalen Benutzer unterscheidet, was ein eigener Dienstbenutzer praktisch einbringt -- und warum die Gruppe docker den Gewinn wieder halbiert'
verification: 'aus dem Neuaufbau des IONOS-VPS am 2026-09-08 heraus geschrieben; die Aussagen zu sudo, Gruppenrechten und der docker-Gruppe sind Linux-Grundlagen und nicht gegen Herstellerdokumentation nachgezogen'
---

# `root` und der eigene Benutzer

**Diese Datei erklärt eine Eigenschaft von Unix-Systemen, kein Werkzeug.** Sie beantwortet, warum fast jede Anleitung sagt „nicht als `root` arbeiten", was der Rat praktisch einbringt — und an welcher Stelle er weniger einbringt, als er verspricht.

**Lies sie von oben nach unten.** Der letzte Abschnitt nimmt zurück, was die ersten aufbauen, und das ist der Punkt.

## 1 — Zwei Sorten Benutzer, nicht mehr

`root` ist der Systemverwalter. Er darf alles: jede Datei ändern, jeden Prozess beenden, jeden Dienst starten. **Es gibt keine Rückfrage**, weil es niemanden gibt, der zurückfragen könnte — `root` ist die Instanz, die sonst fragen würde.

Jeder andere Benutzer besitzt sein Heimatverzeichnis und das, was ihm ausdrücklich gehört. Alles Übrige liest er höchstens.

Dazwischen steht **`sudo`**: ein Programm, das einen Befehl als `root` ausführt, wenn der Aufrufer dazu berechtigt ist. Die Berechtigung kommt meist aus der Gruppe `sudo`, und `sudo` verlangt zur Bestätigung **das Passwort des Aufrufers** — nicht das von `root`.

Daraus folgt eine Falle, die beim ersten eigenen Server zuverlässig zuschlägt: Ein Benutzer, der mit `adduser --disabled-password` angelegt wurde, hat kein Passwort. Er ist in der Gruppe `sudo`, und `sudo` funktioniert trotzdem nicht — es fragt nach einem Passwort, das nicht existiert. Beim Aufbau des IONOS-VPS am 2026-09-08 fiel das erst auf, als der Restore es brauchte.

## 2 — Was der Unterschied praktisch ändert

Am Beispiel eines Servers, auf dem Dienste in Docker laufen:

| Handlung | als `root` | als eigener Benutzer |
|---|---|---|
| Container starten, stoppen, Logs lesen | geht | geht — wenn er in der Gruppe `docker` ist |
| Dateien in einem Dienstverzeichnis ändern | geht | teils; sonst `sudo` |
| Paket installieren, Firewall ändern | geht | `sudo` und Passwort |
| Versehentlich das System löschen | sofort | erst nach einer Passworteingabe |

**Der Alltag kostet nichts.** Was täglich vorkommt — nachsehen, neu starten, ein Log lesen — läuft ohne Hürde. Nur Eingriffe ins System kosten einen Tippvorgang. Genau darin liegt der Nutzen: Die Hürde steht dort, wo Fehler teuer werden, und nirgends sonst.

## 3 — Der Hauptgewinn heißt Versehen, nicht Angreifer

Ein falscher Pfad in einem Löschbefehl trifft als normaler Benutzer sein Heimatverzeichnis. Als `root` trifft er alles.

Das wiegt schwerer, seit Befehle nicht mehr nur von Hand entstehen. Wer einen Agenten aus der Ferne Befehle ausführen lässt und Freigaben flüchtig erteilt, verschiebt genau diese Wahrscheinlichkeit nach oben — und `root` verwandelt jeden solchen Fehlgriff in einen Systemschaden.

Zweiter Gewinn: Läuft ein exponierter Dienst unter einem eigenen Benutzer, sitzt ein Einbrecher dort nicht sofort als Systemverwalter.

## 4 — Und wo der Gewinn kleiner ist, als er aussieht

**Die Gruppe `docker` ist faktisch gleichwertig mit `root`.** Wer Container starten darf, startet einen mit eingehängtem Wurzelverzeichnis und ändert darüber jede Datei des Systems — ohne `sudo`, ohne Passwort. Das ist keine Lücke einer bestimmten Installation, sondern gilt überall, wo Docker ohne `sudo` benutzbar ist.

Derselbe Mechanismus ist im Betrieb nützlich: Er erlaubt es, Daten zu sichern, die `root` gehören, ohne ein Passwort zu kennen. Nützlich und gefährlich sind hier dasselbe Werkzeug.

Ehrlich zusammengefasst: **Gegen jemanden, der bereits Zugang zum Benutzerkonto hat, ist der Gewinn gering. Gegen einen Tippfehler ist er groß.** Wer mehr will, muss woanders ansetzen — beim Zugang selbst, etwa mit einer Passphrase auf dem SSH-Schlüssel.

## Wo das hier angewendet ist

`zaehlen\vps\` baut den IONOS-Server genau nach diesem Muster: ein Benutzer `juni` mit Passwort, in den Gruppen `sudo` und `docker`, kein Dienst als `root`. Die Reihenfolge, in der das aufgesetzt werden muss, steht dort im README — sie ist nicht beliebig, weil ein Benutzer ohne Passwort und ein abgeschalteter root-Login zusammen jeden Zugang versperren.
