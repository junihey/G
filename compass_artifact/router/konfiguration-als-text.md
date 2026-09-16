---
tags: [learning, pre-use, betriebssystem]
created: 2026-09-07
topic: 'Warum ein Rechner, dessen Konfiguration als Text vorliegt, für Arbeit mit KI-Agenten der bessere Ort ist -- und wo Linux, macOS und Windows die Grenze ziehen'
verification: 'recherchiert 2026-09-07 gegen Microsoft Learn (WSL, WinGet Configuration, Start-Layout), Apple Deployment Guide (PPPC), docs.brew.sh, manual.raycast.com, nix.dev, tailscale.com/docs; Versionsstände bewusst nicht übernommen'
---

# Konfiguration als Text — und warum ein Agent davon lebt

**Diese Datei erklärt eine Eigenschaft von Betriebssystemen, nicht ein Werkzeug.**
Sie beantwortet, warum ein Rechner, den man als Textdateien hinschreiben kann,
für Arbeit mit KI-Agenten besser taugt als einer, den man klickt. Linux steht
dabei vorn, weil es der Fall ist, der trägt; macOS und Windows kommen danach als
Gegenbeispiele.

**Lies sie von oben nach unten.** Abschnitt 3 stellt einen Begriff auf, den jeder
spätere Abschnitt benutzt.

**Was hier nicht steht:** wie du deinen Server einrichtest — das ist
`zaehlen\vps\` (bis zum 2026-09-08 unter `specs\vps-neuaufbau\`). Wie du an eine laufende Sitzung kommst — das ist
[[remote-session-access]]. Und wie sich *dieser Vault* zwischen Maschinen bewegt
— das ist `PORTABILITY.md`, siehe gleich Abschnitt 1. Preise, Gratiskontingente
und Anbietervergleiche gehören nach `learning\pre-use\README.md` nirgends
hierher.

---

## 1. Zuerst: „portabel" heißt hier etwas anderes

Im Vault hat das Wort schon einen Besitzer. `PORTABILITY.md` beantwortet damit
**wie sich dieser Vault bewegt** — Hooks, kuratierte Notizen, Plugin-Klone,
geplante Aufgaben. Vier Fälle, alle innerhalb eines bestehenden Rechners.

In dieser Datei heißt es etwas Größeres: **wie sich eine ganze Arbeitsmaschine
bewegt.** Nicht ein Ordner, sondern das System, in dem der Ordner liegt — welche
Programme installiert sind, welche Dienste laufen, wie das Netz konfiguriert ist,
welche Tastenkombination welches Fenster öffnet.

Die zwei hängen zusammen, sind aber nicht dasselbe. Ab hier ist immer die zweite
Bedeutung gemeint.

---

## 2. Konfiguration ist nicht Zustand

Zwei Dinge liegen auf jedem Rechner nebeneinander, und nur eines davon ist die
Rede wert.

**Konfiguration** ist, was du entschieden hast. Welche Programme installiert sein
sollen, auf welchem Port ein Dienst lauscht, welchen Editor `git` öffnet. Sie ist
klein, sie ändert sich selten, und sie ist der Grund, warum dein Rechner sich
anfühlt wie deiner.

**Zustand** ist, was daraus geworden ist. Die Datenbank hinter dem Dienst, dein
Browserverlauf, die Logdateien, die Zwischenspeicher, deine eigenen Dateien. Er
ist groß, er ändert sich ständig, und man stellt ihn nicht wieder her — man
sichert ihn.

**Nur Konfiguration lässt sich hinschreiben.** Wer beides in einen Topf wirft,
hält jede Antwort in dieser Datei für zu optimistisch: „mein Rechner ist doch
nicht 40 Zeilen Text" stimmt für den Zustand und ist für die Konfiguration
falsch.

---

## 3. Deklarierbarkeit hat zwei Hälften

**Der Begriff, den die restliche Datei benutzt.** Eine Einstellung ist
**deklarierbar**, wenn du sie hinschreiben und ein Programm sie anwenden kann.
Das sind zwei Bedingungen, nicht eine:

| Hälfte | Frage | Was fehlt, wenn sie fehlt |
|---|---|---|
| **Format** | Liegt die Einstellung als lesbarer, versionierbarer Text vor? | Du kannst sie nicht in git legen und nicht sehen, was sich geändert hat. |
| **Anwendungsweg** | Kann ein Programm sie ohne menschliche Hand zurückschreiben? | Du kannst sie zwar lesen, aber nur ein Mensch mit einer Maus bringt sie auf den neuen Rechner. |

**Fast jede Grenze in dieser Datei liegt in der zweiten Hälfte.** Das ist der
überraschende Teil: das Format ist meist da. Der Weg fehlt.

Ein Beispiel, das beide Hälften auf einmal zeigt, kommt in Abschnitt 8 — der
Programmstarter Raycast unter macOS exportiert einen Teil seiner Einstellungen
als sauberes JSON und lässt ihn trotzdem nur von Hand einlesen.

---

## 4. Warum ein Agent genau darauf angewiesen ist

Ein KI-Agent ist ein Programm, das Text liest, Text schreibt und Kommandozeilen-
Befehle ausführt. Er hat keine Augen für einen Dialog und keine Hand für eine
Maus.

Daraus folgt, was er kann und was nicht:

- **Er kann eine Textdatei ändern und das Ergebnis prüfen.** Er schreibt die
  Zeile, liest sie zurück, sieht den Unterschied. Geht es schief, sieht er es
  sofort.
- **Er kann einen Befehl ausführen und den Rückgabewert lesen.** Ein Dienst
  startet oder startet nicht, und die Antwort steht im Terminal.
- **Er kann einen verschlüsselten Datenblock nicht prüfen.** Er könnte ihn
  überschreiben, aber nicht sagen, ob das Richtige darin steht.
- **Er kann ein Fenster nicht bedienen.** Ein Häkchen in einem Menü ist für ihn
  kein Ort, an den er etwas schreiben kann.

**Die dritte und vierte Zeile scheitern aus verschiedenen Gründen an derselben
Sache: Unprüfbarkeit.** Und das ist der eigentliche Grund, warum ein textbasiertes
System für Agentenarbeit besser ist. Nicht, dass Text schöner wäre. Sondern dass
ein Agent nur dort selbstständig arbeiten darf, wo er seinen eigenen Fehler
bemerkt.

---

## 5. Linux hat beide Hälften — aus Konvention, nicht aus Technik

Auf einem Linux-Server liegt die Konfiguration in `/etc` als Textdateien. Welche
Pakete installiert sind, welche Dienste laufen, wie das Netz eingerichtet ist,
welche Benutzer es gibt, welche Parameter der Kernel bekommt — alles Zeilen, die
man lesen, in git legen und zurückschreiben kann.

**Das ist eine Norm, keine technische Notwendigkeit.** Nichts hindert ein
Linux-Programm daran, seine Einstellungen in einer Binärdatei abzulegen. Die
Desktop-Umgebung GNOME tut genau das: ihre Einstellungen liegen in einer
Binärdatenbank namens **dconf**.

**Und trotzdem bleibt sie deklarierbar** — weil `dconf dump /` sie vollständig
als Text ausgibt und `dconf load /` sie ebenso vollständig zurückschreibt. Das
Format ist binär, der Weg ist offen. Nach der Tabelle aus Abschnitt 3 fehlt damit
nur die erste Hälfte, und die zweite ist die, auf die es ankommt.

Genau das ist die Norm: **auf Linux existiert für fast alles ein Textausweg,
weil man erwartet, dass es einen gibt.**

---

## 6. Was auch auf Linux nicht deklarierbar ist

Die Grenze liegt dort, wo die Sache aufhört, eine Entscheidung zu sein.

- **Zustand** nach Abschnitt 2 — `/var`, `/home`, Datenbanken, Zwischenspeicher,
  Logdateien. Er wird gesichert, nicht hingeschrieben.
- **Geheimnisse.** Ein Passwort in eine versionierte Datei zu schreiben, heißt,
  es in die Historie zu schreiben. Das Nix-Handbuch warnt bei seinem eigenen
  Paketspeicher ausdrücklich davor: er ist für alle Benutzer des Systems lesbar,
  Geheimnisse gehören nicht hinein.
- **Alles unterhalb des Kernels** — die Firmware-Einstellungen des Rechners,
  Secure-Boot-Schlüssel, Bindungen an den Sicherheitschip. Text hilft nicht, wo
  das Betriebssystem noch gar nicht läuft.

---

## 7. Eine Liste ist kein Stand

**Der wichtigste Vorbehalt gegen die ganze Idee**, und er trifft alle drei
Systeme gleich.

Ein Paketmanager, der immer die neueste Version installiert — Homebrew unter
macOS, Arch unter Linux, winget unter Windows —, stellt aus deiner Liste die
**Namen** wieder her, nicht die **Versionen**. Homebrews Handbuch sagt es
wörtlich: es gibt kein Lockfile und wird keines geben.

Die Folge: derselbe Text, zweimal angewendet im Abstand eines Jahres, ergibt zwei
verschiedene Rechner. Für die meiste Arbeit ist das harmlos. Für einen Bau, der
reproduzierbar sein soll, ist es der Punkt, an dem man zu einem System mit
festgeschriebenen Versionen greift — und dafür eine eigene Sprache lernt.

---

## 8. Gegenbeispiel macOS — die Grenze ist ein Zustimmungsmodell

macOS ist erstaunlich weit deklarierbar, und die Vorlage, die diese Datei
ausgelöst hat, unterschätzt es.

**Pakete:** `brew bundle` schreibt aus einer Datei namens **Brewfile** nicht nur
Kommandozeilen-Werkzeuge und grafische Programme zurück, sondern auch
VS-Code-Erweiterungen, npm-, Cargo- und Go-Werkzeuge. Was rausfällt, ist der
Stand — siehe Abschnitt 7 — und Programme aus dem App Store, die dein Konto noch
nie bezogen hat.

**Einstellungen:** `defaults write` schreibt die meisten Programm- und
Systemeinstellungen als Kommandozeile. Konfigurationsprofile sind XML und damit
Text.

**Die Wand steht woanders.** Sie heißt **TCC**, Apples Datenschutzkontrolle. Ob
ein Programm die Bedienungshilfen benutzen, den Bildschirm aufnehmen oder auf die
ganze Festplatte zugreifen darf, liegt in geschützten Datenbanken, an die auch
der Administrator nicht herankommt. Der einzige vorgesehene deklarative Weg ist
ein Profil vom Typ **PPPC** — und Apples eigener Leitfaden sagt dazu, es
erfordere einen Geräteverwaltungsdienst.

**Das ist Absicht, kein Formatproblem.** Alles, was ein Mensch bestätigen soll,
ist per Konstruktion nicht schreibbar. Wäre es schreibbar, wäre die Bestätigung
wertlos. Nach Abschnitt 3 fehlt hier also nicht die erste Hälfte, sondern die
zweite — und zwar bewusst.

**Raycast ist derselbe Befund im Kleinen**, und das versprochene Beispiel aus
Abschnitt 3. Der Programmstarter exportiert Textbausteine und Schnellzugriffe als
unverschlüsseltes JSON mit dokumentiertem Aufbau. Alles Übrige — Tastenkürzel,
Favoriten, Erweiterungseinstellungen — geht nur in eine `.rayconfig`-Datei, die
verschlüsselt ist und eine Passphrase verlangt. Und selbst das saubere JSON kommt
nur über einen Menübefehl zurück ins Programm. Ein Handbuch, das einen Dateipfad
oder ein Kommandozeilen-Werkzeug nennte, gibt es nicht.

Format halb da, Weg gar nicht.

---

## 9. Gegenbeispiel Windows — die Grenze ist eine Editionsgrenze

Auch hier ist der erste Verdacht falsch. **Die Registry ist nicht das
Gegenbeispiel:** sie ist binär, hat aber mit `reg export` und `reg import` einen
verlustfreien Textweg — dieselbe Konstruktion wie dconf in Abschnitt 5.

Und Windows hat einen echten deklarativen Kanal: **WinGet Configuration**
beschreibt Software und Maschinenzustand in einer YAML-Datei und wendet sie mit
`winget configure` an, mehrfach ausführbar ohne Schaden.

**Das Gegenbeispiel ist das Startmenü.** Windows 11 exportiert die angehefteten
Programme mit `Export-StartLayout` als JSON — das Format ist also da. Aber
zurückschreiben lässt sich das nur über einen **Richtlinienkanal**: eine
Geräteverwaltung oder den Gruppenrichtlinien-Editor. Die Binärdatei direkt zu
überschreiben ist nicht vorgesehen. Und der Gruppenrichtlinien-Editor fehlt in
der Home-Edition ganz.

**Das ist eine Frage der Zuständigkeit, nicht des Formats.** Windows trennt „ein
Mensch klickt es sich hin" von „eine Organisation verordnet es" und hat für den
einzelnen, nicht verwalteten Rechner dazwischen nichts. Der Textkanal existiert —
er ist der Verwaltungskanal, und an den kommt ein einzelner Nutzer nicht heran.

---

## 10. Der Sonderfall WSL2 — die Grenze kostet pro Operation

Wer unter Windows eine Linux-Umgebung will, nimmt **WSL2**. Das ist eine echte
Linux-Maschine, und in ihr gilt alles aus Abschnitt 5.

**Die verbreitete Warnung, WSL2 sei für Agentenarbeit zu langsam, ist falsch
begründet.** Langsam ist nicht die virtuelle Maschine. Langsam ist der Weg über
die Grenze zwischen beiden Dateisystemen — der Pfad, der unter `/mnt/c` beginnt.
Microsofts eigene Dokumentation empfiehlt deshalb ausdrücklich, das
Arbeitsverzeichnis im Linux-Dateisystem anzulegen und nicht unter `/mnt/c`. Liegt
es richtig, ist WSL2 schnell.

**Die dauerhafte Regel dahinter:** eine Dateisystemgrenze zwischen zwei
Betriebssystemen kostet **pro Operation, nicht pro Byte.**

Und darum trifft sie einen Agenten härter als einen Menschen. Ein Mensch kopiert
gelegentlich eine große Datei — eine Operation, viele Bytes. Ein Agent fragt
tausende kleine Dateien nach ihren Eigenschaften: ein Suchlauf über das Projekt,
ein `git status`, ein Test, der Dateien einliest. Viele Operationen, wenige Bytes
— genau die Last, die an dieser Grenze teuer wird.

---

## 11. Wo die Maschine steht, und wie du sie erreichst

Aus den Abschnitten 5 bis 10 folgt der Ort: **ein Linux-Rechner ohne grafische
Oberfläche** — ein gemieteter Server im Rechenzentrum oder ein kleiner Rechner
bei dir. Er hat beide Hälften der Deklarierbarkeit, er kennt keine Klick-Menüs,
und er läuft, wenn dein eigener Rechner aus ist.

**Damit entsteht eine neue Frage, die diese Datei nicht beantwortet:** wie du an
eine Sitzung kommst, die dort läuft. Die drei Achsen dazu — wo der Prozess läuft,
was ihn über einen Verbindungsabbruch rettet, womit du ihn bedienst — stehen in
[[remote-session-access]]. Was auf einen solchen Server gehört und was nicht,
steht in `PORTABILITY.md`, Fall D.

**Ein Baustein gehört aber hierher, weil er die Konfiguration selbst verändert:
Tailscale.** Es spannt zwischen deinen Geräten ein privates Netz auf. Jedes Gerät
bekommt eine feste Adresse und einen Namen, unter dem die anderen es erreichen —
unabhängig davon, in welchem Netz es gerade steckt.

Zwei Dinge daran sind für diese Datei wichtig:

- **Es ersetzt den offenen SSH-Port.** Der Dienst nimmt Anmeldungen nur auf der
  privaten Adresse entgegen und prüft sie über den Geräteschlüssel statt über
  hinterlegte SSH-Schlüssel. Die öffentliche Firewall-Regel für Port 22 kann
  danach weg. Was du im Text hinschreibst, wird dadurch kürzer und der Rechner
  von außen kleiner.
- **Der private Schlüssel verlässt ein Gerät nie.** Alles, was zwischen den
  Geräten steht, leitet nur verschlüsselte Pakete weiter und kann sie nicht
  lesen.

**Zwei Dinge, die es nicht tut**, und beide werden gern überschätzt:

- **Es macht deinen Server nicht zum Nachbarn im lokalen Netz.** Jede Verbindung
  beginnt über einen Vermittlungsserver und wird erst danach auf einen direkten
  Weg hochgestuft, wenn einer zustande kommt. Für die Adressierung fühlt es sich
  lokal an. Für den Weg stimmt das nicht.
- **Es schützt nur seinen eigenen Verkehr.** Ein Dienst, der daneben mit einer
  öffentlichen Adresse im Web steht, bleibt genauso offen wie vorher. Wer einen
  Vermittlungsserver für öffentliche Adressen betreibt, braucht ihn weiterhin.

---

## 12. Was am Ende trägt

Drei Sätze, die aus allem Vorherigen folgen.

**Ein Agent darf nur dort selbstständig arbeiten, wo er seinen eigenen Fehler
bemerkt.** Das ist Abschnitt 4, und es ist der Grund für alles Übrige.

**Der Engpass ist selten das Format, fast immer der Anwendungsweg.** Das ist
Abschnitt 3, und die Gegenbeispiele in 8 und 9 scheitern beide an der zweiten
Hälfte, obwohl beide ein sauberes Textformat haben.

**Linux gewinnt nicht durch eine Fähigkeit, sondern durch eine Erwartung.**
Nichts an Linux erzwingt Textkonfiguration — dconf in Abschnitt 5 beweist es. Was
gewinnt, ist die Norm, dass ein Textausweg zu existieren hat. macOS verriegelt
den Weg dort, wo ein Mensch zustimmen soll; Windows dort, wo eine Organisation
verwalten soll. Beide Male ist die Verriegelung gewollt, und beide Male steht ein
Agent davor.
