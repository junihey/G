---
tags: [learning, openwrt]
created: 2026-09-11
topic: Was ein Router tut, was der GL.iNet Slate AX davon kann, und was am 2026-09-11 auf ihm eingerichtet wurde
verification: extern — Standard-Netzwerktechnik und OpenWrt, kein smithy-Bezug; der Teil ab Abschnitt 10 ist der protokollierte Lauf
---

# Was der Router macht

Diese Datei baut von null auf. Abschnitt 1 setzt nichts voraus, jeder folgende
nur die davor. Am Ende verstehst du, was auf dem Slate AX eingerichtet wurde und
warum.

**Was hier nicht steht:** die Befehle zum Nachmachen — die stehen in
`zaehlen\wwww\router.md`. Und nichts über die Anwendung selbst.

---

## 1 · Eine Adresse pro Gerät

Jedes Gerät in einem Netzwerk hat eine Nummer, damit man es ansprechen kann. Sie
heißt **IP-Adresse** und sieht so aus:

```
192.168.8.10
```

Vier Zahlen, durch Punkte getrennt. Die ersten drei sagen, in welchem Netz das
Gerät steckt, die letzte, welches Gerät es ist. Alle Geräte mit `192.168.8.`
vorne sind im selben Netz und können miteinander reden.

Der Zusatz `/24` — geschrieben als `192.168.8.0/24` — heißt genau das: „die
ersten drei Zahlen bilden das Netz". Es gibt in diesem Netz 254 Plätze.

**Adressen, die mit `192.168.` anfangen, gibt es überall.** Sie sind für private
Netze reserviert. Dein Router zu Hause benutzt sie, jedes Büro, jedes Café — und
sie stören sich nicht, weil sie das Internet nie erreichen.

## 2 · Was ein Router tut

Ein **Router** ist das Gerät, an dem ein Netz hängt. Drei Dinge tut er, und sie
sind unabhängig voneinander:

1. Er **spannt das Netz auf** — per Kabel, per WLAN, oder beides.
2. Er **verteilt die Adressen** an alle, die sich anmelden (Abschnitt 3).
3. Er **übersetzt Namen in Adressen** (Abschnitt 4).

Meistens tut er noch ein viertes: Er verbindet dieses Netz mit dem Internet.
**Das muss er aber nicht**, und für unsere Installation soll er es gerade nicht.
Ein Router ohne Internet ist kein kaputter Router — er ist ein Netz für sich.

Der Router selbst hat auch eine Adresse in seinem Netz, üblicherweise die erste:
`192.168.8.1`. Unter dieser Adresse erreichst du ihn.

## 3 · Wer die Adressen vergibt: DHCP

Wenn sich ein Handy in ein WLAN einwählt, hat es noch keine Adresse. Es fragt
ins Netz: „Hat jemand eine für mich?" Der Router antwortet mit einer freien.

Dieses Frage-und-Antwort-Spiel heißt **DHCP**. Es läuft automatisch, niemand
tippt Adressen ein.

Die vergebene Adresse ist eine **Leihgabe** — sie heißt *Lease* und läuft nach
Stunden ab. Danach bekommt dasselbe Gerät vielleicht eine andere.

**Für einen Server ist das schlecht.** Wenn der Rechner, auf dem deine Seite
läuft, heute `192.168.8.204` hat und morgen `192.168.8.77`, zeigt jeder
Verweis ins Leere. Deshalb gibt es die **Reservierung**: Der Router merkt sich
„dieses eine Gerät bekommt immer dieselbe Adresse".

Erkannt wird das Gerät an seiner **MAC-Adresse** — einer Nummer, die fest in der
Netzwerkkarte steckt und sich nicht ändert:

```
60:CF:84:E6:75:38
```

Sechs Zahlenpaare. Jede Netzwerkkarte der Welt hat eine eigene. Kabel und WLAN
desselben Rechners haben verschiedene.

## 4 · Wie aus Namen Adressen werden: DNS

Niemand tippt `192.168.8.10` in einen Browser. Man tippt einen Namen.

Die Übersetzung von Namen in Adressen heißt **DNS**. Im Internet gibt es dafür
ein weltweites Verzeichnis: Wer `julianniklasheynert.xyz` eingibt, fragt einen
DNS-Server, und der antwortet mit `217.154.113.12`.

**Ohne Internet gibt es dieses Verzeichnis nicht.** Genau hier setzt unsere
Installation an: Der Router führt sein eigenes, winziges Verzeichnis. Darin
steht eine Zeile:

```
installation.julianniklasheynert.xyz  →  192.168.8.10
```

Jedes Handy in diesem WLAN fragt den Router, der Router antwortet, und das Handy
landet auf dem Rechner im Raum. Für die Handys sieht das aus wie ganz normales
DNS. Dass die Antwort aus einer selbstgeschriebenen Zeile kommt und nicht aus
dem Internet, merken sie nicht.

**Der Router bringt beides mit**, DHCP und DNS, in einem einzigen Programm
namens `dnsmasq`. Der Name ist die Abkürzung von *DNS masquerade*. Es läuft auf
jedem OpenWrt-Gerät von Haus aus.

Deshalb steht in `claude-notes\drei-orte-einer-anwendung.md`, der DNS gehöre auf
die Router und nicht auf den Rechner: Er ist dort schon.

## 5 · Warum der Name zählt und nicht die Adresse

Ein Browser gibt die Bewegungssensoren eines Handys nur frei, wenn die
Verbindung verschlüsselt ist — HTTPS mit einem Zertifikat, dem er traut.

**Ein Zertifikat wird auf einen Namen ausgestellt, nicht auf eine Adresse.**
Unseres lautet auf `installation.julianniklasheynert.xyz`. Ruft ein Handy
stattdessen `https://192.168.8.10` auf, passt das Zertifikat nicht, der Browser
warnt, und die Sensoren bleiben zu.

Darum die Zeile aus Abschnitt 4. Sie ist nicht Bequemlichkeit, sondern die
Bedingung, unter der die Anwendung überhaupt funktioniert.

## 6 · WLAN: ein Name, ein Passwort — oder mehrere

Ein WLAN hat einen Namen, den dein Handy in der Liste anzeigt. Der Name heißt
**SSID**. Dazu ein Passwort und ein Verschlüsselungsverfahren; das übliche heißt
**WPA2**, in OpenWrt geschrieben als `psk2`.

Der Slate AX hat zwei **Funkmodule**, im System `radio0` und `radio1`:

| Modul | Frequenz | Eigenschaft |
|---|---|---|
| `radio0` | 5 GHz | schneller, geringere Reichweite, kommt schlechter durch Wände |
| `radio1` | 2,4 GHz | langsamer, größere Reichweite |

Deshalb zeigt das Gerät zwei Namen an: `GL-AXT1800-0e4` und
`GL-AXT1800-0e4-5G`. Das ist **ein** Netz über zwei Funkwege, nicht zwei Netze.

**Ein Funkmodul kann mehrere Netze gleichzeitig ausstrahlen.** Jedes mit eigenem
Namen, eigenem Passwort und eigenem Adressbereich. Für ein Handy sehen sie aus
wie getrennte Router.

Im System heißt jedes ausgestrahlte Netz eine `wifi-iface`. Auf dem Slate AX
gibt es vier davon: die zwei Hauptnetze und zwei Gastnetze, die abgeschaltet
sind. Die Hardware erlaubt bis zu **16 pro Funkmodul**.

**Das ist die Antwort auf die Frage nach mehreren Standorten.** Wenn die
Installation mehrere Eintrittspunkte haben soll — Besucher an Standort A starten
an einem anderen Punkt der 3D-Welt als an Standort B —, braucht das nicht
mehrere Router. Drei Namen auf einem Gerät genügen, jeder mit eigenem
Adressbereich.

Wie die Anwendung danach erfährt, aus welchem Netz jemand kam, ist eine eigene
Frage — und der naheliegende Weg über die Absenderadresse trägt nicht. Das steht
in Abschnitt 14, nachdem die Begriffe dafür da sind.

Der einzige Unterschied zu drei Geräten ist die **Reichweite**: Ein Router
strahlt von einem Punkt. Liegen die Standorte in verschiedenen Räumen, kommt das
Signal nicht überall an. Liegen sie im selben Raum, ist ein Gerät besser —
weniger Kabel, weniger Strom, weniger, das ausfallen kann.

## 7 · Der Slate AX ist ein kleiner Computer

Das Gerät heißt vollständig **GL.iNet GL-AXT1800**, Beiname *Slate AX*. Darauf
läuft **OpenWrt** — ein Linux für Router.

Das ist der entscheidende Punkt zum Verständnis: Es ist kein Gerät mit Knöpfen,
sondern ein Computer mit Dateien und Programmen. Du kannst dich darauf anmelden,
Dateien ansehen und Befehle ausführen, genau wie auf einem Server.

GL.iNet liefert OpenWrt mit einer eigenen Oberfläche darüber aus. Deshalb gibt
es **drei Wege** auf dasselbe Gerät:

| Weg | Wie | Wofür |
|---|---|---|
| GL.iNet-Panel | `http://192.168.8.1` im Browser | WLAN-Name, Passwort, die alltäglichen Dinge |
| LuCI | im Panel unter *System → Erweiterte Einstellungen* | die volle OpenWrt-Oberfläche, alles einstellbar |
| SSH | `ssh root@192.168.8.1` im Terminal | dasselbe als Befehle, nachvollziehbar und wiederholbar |

**Alle drei ändern dieselben Dateien.** Was du im Panel klickst, siehst du per
SSH in der Konfiguration wieder.

## 8 · Wie man OpenWrt konfiguriert: `uci`

Die Einstellungen liegen in Textdateien unter `/etc/config/`. Für das Netz ist
`/etc/config/dhcp` zuständig — Name trügt, dort steht auch das DNS-Verzeichnis
aus Abschnitt 4.

Man bearbeitet diese Dateien nicht von Hand, sondern über ein Programm namens
**`uci`** (*Unified Configuration Interface*). Es liest und schreibt sie, und es
weiß, welches Programm danach neu zu starten ist.

Ansehen:

```sh
uci show dhcp
```

Eine Einstellung setzen und behalten:

```sh
uci set dhcp.@domain[0].ip='192.168.8.10'
uci commit dhcp
```

**Ohne `uci commit` ist die Änderung nach einem Neustart weg.** Bis dahin liegt
sie nur in einem Zwischenspeicher.

Und danach muss das betroffene Programm neu lesen:

```sh
/etc/init.d/dnsmasq restart
```

**Warum nicht direkt in `/etc/dnsmasq.conf` schreiben?** Weil OpenWrt diese
Datei bei jedem Start aus der `uci`-Konfiguration neu erzeugt. Eine Änderung
darin wäre beim nächsten Neustart verschwunden.

## 9 · Auf den Router kommen: zwei Stolperstellen

Der Zugang per SSH hat zwei Eigenheiten, die je eine halbe Stunde kosten, wenn
man sie nicht kennt.

**Passwörter nimmt das Gerät über SSH nicht an.** Jedes wird abgelehnt, auch das
richtige. Ein im Panel neu gesetztes Admin-Passwort ändert daran nichts. Der
Zugang läuft über einen **SSH-Schlüssel**: ein Paar aus zwei Dateien auf deinem
PC, von denen die öffentliche auf den Router kommt (über LuCI, *System →
Administration*, Feld *SSH-Keys*) und die private bei dir bleibt.

**SSH bietet von sich aus nur Schlüssel mit Standardnamen an** — `id_rsa`,
`id_ed25519` und ein paar weitere. Heißt deiner anders, wie hier `id_ionos`,
wird er nie angeboten, und die Anmeldung scheitert, obwohl der Schlüssel längst
auf dem Gerät liegt. Man muss ihn bei jedem Aufruf nennen:

```sh
ssh -o "IdentityFile ~/.ssh/id_ionos" -o IdentitiesOnly=yes root@192.168.8.1
```

## 10 · Was am 2026-09-11 eingerichtet wurde

Der Aufbau, mit allem aus den Abschnitten 1 bis 9:

```
Besucher-Handy ---WLAN---> Slate AX (192.168.8.1) ---Kabel---> PC (192.168.8.10)
                            dnsmasq: DHCP + DNS
                            WAN-Port: leer
```

Drei Änderungen am Router, mehr nicht:

| Was | Womit | Wofür |
|---|---|---|
| Der Name zeigt auf den PC | `uci add dhcp domain` | Abschnitt 4 — das eigene DNS-Verzeichnis |
| Der PC bekommt immer `192.168.8.10` | `uci add dhcp host` mit der MAC | Abschnitt 3 — die Reservierung |
| Der SSH-Schlüssel liegt auf dem Gerät | LuCI, Feld *SSH-Keys* | Abschnitt 9 |

**Am WLAN wurde nichts geändert.** Es läuft mit den Namen, die ab Werk
eingestellt waren.

**Der WAN-Port blieb leer.** Das ist die wichtigste Einstellung überhaupt, und
sie besteht darin, ein Kabel *nicht* einzustecken. Der Router hat dadurch kein
Internet — und genau dieser Zustand ist die Installation in der Halle.

## 11 · Was der Router nicht tut

Drei Dinge, die man ihm leicht zuschreibt:

**Er liefert die Seite nicht aus.** Das tut der PC. Der Router sagt den Handys
nur, wo der PC ist.

**Er macht kein HTTPS.** Das Zertifikat liegt auf dem PC, und der verschlüsselt.
Der Router sieht nur Datenpakete, die er weiterreicht.

**Er entscheidet nicht, wer durchkommt.** Auf dem Zielrechner steht eine eigene
Firewall — unter Windows blockiert sie eingehende Verbindungen aus fremden
Netzen, bis eine Regel sie erlaubt. Das ist der häufigste Grund, warum ein Handy
den Rechner nicht erreicht, obwohl am Router alles stimmt.

## 12 · Ein Router ist ein schlechter Test-Client

Beim Einrichten liegt es nahe, vom Router aus zu prüfen, ob der Rechner
erreichbar ist. Das führt in die Irre:

| Test | Was wirklich passiert |
|---|---|
| `nc -z` | Die abgespeckte Programmsammlung auf dem Router kennt diese Option nicht und meldet immer „zu" |
| `wget https://…` | Die Verbindung steht, aber der Router kennt das Zertifikat nicht — sein Vorrat an Wurzelzertifikaten ist Jahre alt |
| `ping` | Prüft ein anderes Protokoll als der Browser; eine Firewall-Regel für Webseiten erlaubt es nicht |

**Für die Frage „kommt ein Besucher durch" taugt nur ein Besucher-Gerät.** Ein
Handy im WLAN, mit dem Browser, den ein Gast auch benutzen würde.

## 13 · Die drei Netze, die am 2026-09-11 entstanden sind

Abschnitt 6 sagt, dass ein Funkmodul mehrere Netze ausstrahlen kann. Hier ist
der Fall dazu. Auf dem 2,4-GHz-Modul laufen jetzt drei zusätzliche Netze:

| WLAN-Name | Adressbereich | Der Router ist darin |
|---|---|---|
| `Metall Hass` | 192.168.11.x | 192.168.11.1 |
| `Scham Kleid` | 192.168.12.x | 192.168.12.1 |
| `Element Geist` | 192.168.13.x | 192.168.13.1 |

Sie sind **offen**, ohne Passwort. Besucher einer Installation sollen sich
einwählen, nicht ein Passwort abtippen.

Jedes Netz brauchte drei Dinge, und jedes davon kennst du schon:

1. **Ein eigenes Netz mit eigener Adresse** für den Router darin — Abschnitt 1.
2. **Einen DHCP-Bereich**, aus dem die Handys ihre Adressen bekommen —
   Abschnitt 3.
3. **Ein ausgestrahltes WLAN**, das an dieses Netz gebunden ist — Abschnitt 6.

Dazu ein vierter Punkt, den man leicht vergisst: Die drei Netze mussten in
dieselbe **Firewall-Zone** wie das Kabelnetz aufgenommen werden. Eine Zone ist
eine Gruppe von Netzen, zwischen denen der Router Verkehr durchlässt. Ohne
diesen Schritt wären die drei Netze zwar da, könnten aber den Rechner nicht
erreichen.

## 14 · Warum der Standort in die Adresszeile gehört und nicht in die IP

Die Installation soll erkennen, aus welchem der drei Netze ein Besucher kommt,
um ihn an einer anderen Stelle der 3D-Welt starten zu lassen.

**Der naheliegende Weg ist die Absenderadresse**, und er ist der falsche. Am
2026-09-11 gemessen: Anfragen aus allen drei Netzen kamen beim Server als
dieselbe Adresse an. Docker Desktop unter Windows schiebt einen eigenen
Vermittler dazwischen, der die ursprüngliche Adresse verliert. Auf einem
Linux-Rechner bliebe sie erhalten — aber eine Lösung, die vom Betriebssystem des
Rechners abhängt, ist keine.

**Der bessere Weg führt über das Captive-Portal-Fenster.** Um ihn zu verstehen,
zuerst: was das überhaupt ist.

### Was ein Captive Portal ist

Du kennst es aus Hotels und Cafés: Du wählst dich ins WLAN ein, und es springt
von selbst ein Fenster auf — „Bitte Bedingungen akzeptieren".

Dahinter steckt eine Prüfung, die jedes Handy nach dem Einwählen automatisch
macht. Es ruft eine feste Adresse im Internet auf und schaut, was zurückkommt:

| System | Ruft auf |
|---|---|
| iOS | `captive.apple.com` |
| Android | `connectivitycheck.gstatic.com` |
| Windows | `msftconnecttest.com` |

Kommt die erwartete Antwort, meldet das Handy „Internet vorhanden". Kommt
stattdessen eine Weiterleitung, schließt es: „Hier sitzt ein Portal davor" — und
öffnet die Seite, auf die weitergeleitet wurde, in einem kleinen Fenster.

### Was daraus folgt

**Der Router kann diese Prüfung abfangen und selbst antworten.** Und er weiß
dabei, aus welchem seiner WLANs die Anfrage kam — die Netze sind getrennt, das
ist Abschnitt 13.

Also kann er für jedes Netz auf eine andere Adresse weiterleiten:

| Aus dem Netz | Weiterleitung auf |
|---|---|
| `Metall Hass` | `https://installation.julianniklasheynert.xyz/?entry=a` |
| `Scham Kleid` | `…/?entry=b` |
| `Element Geist` | `…/?entry=c` |

Der Teil hinter dem Fragezeichen heißt **Query-Parameter**. Er ist Teil der
Adresse und wandert mit, wohin sie auch geht. Die Webseite liest ihn mit einer
Zeile aus:

```js
const eintritt = new URLSearchParams(location.search).get('entry')
```

**Damit muss der Server gar nichts über die Absenderadresse wissen.** Der
Standort steht in der Adresse, die der Besucher aufruft. Es ist egal, wie viele
Vermittler dazwischen liegen und welches Betriebssystem der Rechner hat.

### Warum das Portal ohnehin gebraucht wird

Das Fenster, das da aufspringt, ist **kein vollwertiger Browser**. Auf iOS heißt
es *Captive Network Assistant*, auf Android ist es eine eingeschränkte
Web-Ansicht. Dort gibt es die Freigabe für Bewegungssensoren nicht, und wenn das
Fenster schließt, ist die Sitzung weg.

**Die Anwendung kann dort also gar nicht laufen.** Das Portal darf nur einen Satz
und einen Link zeigen: „Tippe hier". Der Besucher tippt, das Handy öffnet den
richtigen Browser, und dort läuft alles.

Und genau dieser Link trägt den Standort mit. **Die Schwäche des Portals und die
Lösung des Standort-Problems fallen zusammen:** Man braucht ohnehin einen
Wegweiser, und ein Wegweiser kann sagen, wo er steht.

Zwei Dinge sind dabei einzuhalten, beide aus Abschnitt 5: Der Link trägt den
**Namen**, nie die Adresse. Und er beginnt mit `https`, nie mit `http`.

## 15 · Wie das Portal am 2026-09-11 gebaut wurde

Abschnitt 14 erklärt, warum der Standort in die Adresszeile gehört. Hier steht,
aus welchen drei Teilen die Umsetzung besteht — jeder davon ist eine Sache, die
du schon kennst.

**Teil 1: Der Router beantwortet die Prüfadressen selbst.** Für jede der sieben
Adressen aus Abschnitt 14 kam ein Eintrag ins eigene DNS-Verzeichnis von
Abschnitt 4, der auf den Router zeigt. Ein Handy, das `captive.apple.com`
aufruft, landet damit beim Router statt bei Apple.

**Teil 2: Drei Antworten statt einer.** Auf dem Router läuft ein Webserver.
Er bekam drei zusätzliche Zugänge — Port 8011, 8012 und 8013 —, die jeweils mit
einer Weiterleitung antworten:

```
Port 8011  →  https://installation.julianniklasheynert.xyz/?entry=a
Port 8012  →  …?entry=b
Port 8013  →  …?entry=c
```

**Teil 3: Die Firewall sortiert nach Herkunft.** Eine Regel pro Netz leitet
Anfragen an Port 80 des Routers auf den jeweils passenden dieser drei Ports um.
Wer aus `Metall Hass` kommt, landet auf 8011, und bekommt damit `?entry=a`.

Ein **Port** ist dabei nichts weiter als eine Nummer neben der Adresse: Ein
Rechner kann viele Programme gleichzeitig bedienen, und die Portnummer sagt,
welches gemeint ist. Port 80 ist die Voreinstellung für unverschlüsselte
Webseiten, Port 443 für verschlüsselte.

### Was dabei herauskam

Der Lauf ist am 2026-09-11 mit einem iPhone durch alle drei Netze gegangen. Im
Protokoll des Servers stand danach jeweils der richtige Buchstabe — `a` aus
`Metall Hass`, `b` aus `Scham Kleid`, `c` aus `Element Geist`.

**Daneben stand der Beleg für den Umweg.** Die Absenderadresse war bei jeder
einzelnen Anfrage dieselbe: die von Docker, nicht die des Handys. Hätte die
Zuordnung an der Adresse gehangen, wäre kein einziger Standort erkennbar
gewesen.

### Drei Stellen, an denen es hakte

**Der Webserver auf dem Router übernimmt eine geänderte Konfiguration nicht beim
Neuladen.** Der dafür übliche Befehl meldet keinen Fehler und tut nichts; nur
ein vollständiger Neustart wirkt.

**Die Firewall des Zielrechners kennt die neuen Netze nicht.** Die Regel aus
Abschnitt 10 galt nur für das Kabelnetz. Ein Handy aus einem der neuen Netze
wurde abgewiesen, und das iPhone meldete: *keine sichere Verbindung*. Die Regel
musste um die drei Adressbereiche erweitert werden.

**Diese Fehlermeldung ist selbst ein Beleg.** Der Portal-Assistent besteht auf
einer verschlüsselten Verbindung mit gültigem Zertifikat — genauso wie der
Browser bei den Bewegungssensoren, Abschnitt 5. Ein selbstgebautes Zertifikat
oder eine nackte Adresse hätte hier dieselbe Meldung erzeugt.

### Die Wegweiser-Seite

Anfangs führte die Weiterleitung **direkt auf die Anwendung** — und damit in die
Falle aus Abschnitt 14: Im Portal-Fenster laufen die Sensoren nicht.

Seit dem 2026-09-11 liefert der Router stattdessen eine kleine Seite aus, eine
je Standort. Sie zeigt den Namen des Ortes, einen Satz und einen Knopf, der auf
die Anwendung führt — mit dem Buchstaben in der Adresse. Darunter steht dieselbe
Adresse zum Abtippen, falls der Knopf ins Leere führt.

**Sie wird unverschlüsselt ausgeliefert, und das ist richtig so.** Der
Portal-Assistent muss dann keine gesicherte Verbindung aufbauen — genau daran
war der erste Versuch gescheitert. Die Verschlüsselung braucht erst der Schritt
danach, wenn der Besucher im richtigen Browser ist.

### Warum dort kein Knopf steht

Naheliegend wäre ein Knopf, der die Anwendung im richtigen Browser öffnet. **Auf
iOS geht das nicht.**

Am 2026-09-11 geprüft, in dieser Reihenfolge:

| Versuch | Ergebnis |
|---|---|
| gewöhnlicher Link auf `https://…` | Der Portal-Assistent öffnet ihn **in sich selbst** — der Besucher landet wieder dort, wo die Sensoren nicht laufen |
| `x-safari-https://…` | Ein früher übliches Adressschema, das Safari von außen startete. In aktuellen iOS-Versionen wirkungslos. |

Apple hat diesen Weg absichtlich geschlossen. Ein Portal-Fenster soll keine
fremden Programme starten können.

**Deshalb steht auf der Seite eine Anleitung statt eines Knopfes:** Fenster
schließen, Browser öffnen, Adresse eingeben. Die Adresse liegt in einem Feld,
das sich beim Antippen vollständig auswählt — danach bietet iOS *Kopieren* an.
Automatisch in die Zwischenablage schreiben geht ebenfalls nicht: Dafür bräuchte
die Seite einen Secure Context, und sie wird bewusst unverschlüsselt
ausgeliefert.

**Das WLAN bleibt verbunden, auch wenn das Portal-Fenster zugeht.** Das ist die
Eigenschaft, auf der die ganze Anleitung ruht.

### Was das Portal dann überhaupt leistet

Es sieht nach wenig aus, ist aber der Unterschied zwischen einer Installation,
die funktioniert, und einer, die nicht gefunden wird:

- Es **erscheint von selbst**, sobald sich jemand einwählt. Ohne es müsste an
  jedem Standort ein Schild mit einer Adresse hängen.
- Es **nennt den Standort** und gibt die passende Adresse aus — der Buchstabe
  steht schon darin.
- Es **hält das Handy im Netz**. Ohne Portal meldet das Gerät „kein Internet"
  und wechselt oft von selbst auf Mobilfunk zurück.

**Die letzte Handbewegung bleibt beim Besucher.** Wer das nicht will, braucht
einen anderen Weg ins Handy: einen QR-Code an der Wand, den die Kamera-App
öffnet, oder einen NFC-Aufkleber zum Antippen. Beide kosten den Automatismus,
aber keiner von ihnen kämpft gegen das Betriebssystem.

## Verwandt

- `zaehlen\wwww\router.md` — dieselben Schritte als Befehle zum Nachmachen
- `claude-notes\drei-orte-einer-anwendung.md` — warum die Installation ein eigener Ort ist und was dort noch offen ist
- `zaehlen\wwww\ARCHITEKTUR.md` — wo welcher Teil auf welchem Rechner liegt
- `..\https\zertifikate-und-vertrauen.md` — warum der Browser dem Zertifikat traut, das hier ausgeliefert wird
