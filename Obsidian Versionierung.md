# Versionierung
## Quartz
- nach jeder Bearbeitung mit Github und Sourcetree
## Obsidian
## Makro
- Frontmatter mit Properties 
	- wird in Archiv-Ordner verschoben, wenn status: "deprecated" (Archiv-Ordner in Quartz ausschließen)
	- Plugin **Auto Note Mover** für automatisches Verschieben bei Status-Änderung
```yaml
--- 
status: "deprecated" # oder "active", "planned" 
introduced_in: "v1.0.0" 
deprecated_in: "v2.1.0" 
replaced_by: "[[Feature - Passkey Authentication]]" 
last_updated: 2026-06-01
changes:
- "v1.7.0: Überschrift 'Auth' zu 'OAuth2 Flow' geändert; Deprecated-Hinweis für Legacy-API hinzugefügt." 
- "v1.5.0: Initiale Dokumentation des Authentifizierungs-Features."
---
```
- neue Notiz mit "replaces" property als Gegenrichtung zur alten Notiz im Gegensatz zu "replaced_by" (neue Notiz)
- Verbesserung: property "changes" lieber am Ende der Notiz als Changelog
## Mikro
- auf status: "deprecated" setzen, wenn zu viele Changes stattgefunden haben
- im Fließtext mit Tags der Version #v1/5/0
- Überschriften mit Callouts, Beispiel:
---
%%Vor Deprecation%%
### Authentifizierung %%Dummy Überschrift%%
> [!attention] Veraltet (Deprecated)
> Dieses Feature wurde ab v1.7.0 durch OAuth2 ersetzt. Aktuelle Dokumentation siehe: [[#OAuth2 Authentifizierung]].
> *(Optional: Der alte Text kann hier im einklappbaren Callout oder darunter stehen bleiben)*
### OAuth2 Authentifizierung
Hier steht der neue, aktuelle Inhalt...

---
%%Nach Deprecation, im Archiv%%

> [!attention] Veraltet (Deprecated)
> Diese Dokumentation ist veraltet. Das Feature wurde ab v1.7.0 durch OAuth2 ersetzt.
> 🚀 Zur aktuellen Version: [[OAuth2#OAuth2 Authentifizierung]]

### Authentifizierung
Hier steht der alte Text für den historischen Kontext...

---
- Alternative: ID-basierte Blockreferenzen 
	- [[test#^d01218|test2]]
	- ![[test#^d01218]]
		- nimmt bei Preview nur die aktuelle Zeile
		- eher bei absolut kritischen API Specs auf Datenfelder
		- Vergleich:
	- [[test#test2 d01218]]
	- ![[test#test2 d01218]]
- Alternative: Rechtsklick auf Überschrift + "Rename this heading..." aktualisiert alle Links
	- "Updated X file" Meldung beachten
# Plugins
- Persistent Links
	- Verschieben von Überschriften
- Block Reference Count / Strange New Worlds
	- mit kleiner Anzeige bei jeder Überschrift, wie häufig diese verlinkt ist

> [!NOTE]- # Reset Procedure
> Der Zeitpunkt für den "harten Schnitt" – also das Archivieren der alten Datei und den Neustart mit einer frischen Notiz – ist erreicht, wenn die Übersichtlichkeit der aktuellen Dokumentation unter der historischen Last zusammenbricht.
> 
> Da du dich entschieden hast, Versionierung auf Mikro-Ebene (mit Callouts und Dummy-Überschriften) zuzulassen, brauchst du klare Regeln, wann dieses Mikro-Management zu viel wird. Hier sind die drei klaren Indikatoren, wann der Zeitpunkt für das Archiv gekommen ist:
> 
> ### 1. Der "Schiff des Theseus"-Moment (Struktureller Umbau)
> 
> Wenn sich das Feature technisch oder konzeptionell so stark verändert, dass die alte Dokumentation für das Verständnis des neuen Systems keine Relevanz mehr hat oder sogar in die Irre führt.
> 
> * **Die Faustregel:** Wenn du mehr als 50 % des Inhalts der Notiz (Überschriften, Logik-Beschreibungen, Endpunkte) umschreiben oder mit *Deprecated-Callouts* verstecken müsstest.
> * **Beispiel:** Der Wechsel von einer simplen REST-API zu GraphQL oder von einer lokalen Passwort-Datenbank zu einem externen Identity Provider (SSO). Der grundlegende Zweck bleibt gleich, aber die Mechanik ist komplett neu.
> 
> ### 2. Kognitive Überlastung (Das Changelog-Müllhalden-Problem)
> 
> Wenn die Notiz mehr aus Änderungsverlauf und Warnhinweisen besteht als aus aktueller Dokumentation.
> 
> * **Zu viele Callouts:** Sobald du in einer Notiz mehr als zwei veraltete Dummy-Überschriften mit Archiv-Callouts hast. Das stört den Lesefluss für jeden Entwickler, der einfach nur wissen will, wie das Feature *jetzt* funktioniert.
> * **Changelog-Länge:** Wenn das Changelog am Ende der Notiz so lang wird, dass es den eigentlichen Inhalt dominiert, und die ältesten Einträge auf Versionen verweisen, die in der Produktion längst nicht mehr unterstützt werden.
> 
> ### 3. Das Feature ist im Code "End of Life"
> 
> Dies ist der offensichtlichste Trigger.
> 
> * Wenn ein Feature in der Codebase offiziell als `@deprecated` markiert wird und in einem der kommenden Release-Zyklen entfernt werden soll. Die Notiz wandert ins Archiv und dient nur noch als historische Referenz. Falls es keinen direkten Nachfolger gibt, wird natürlich auch keine neue Notiz angelegt.
> 
> ---
> 
> ### Der Ablauf: So funktioniert der Reset in der Praxis
> 
> Wenn einer dieser Punkte zutrifft, machst du keine halben Sachen mehr im Text, sondern nutzt den sauberen Makro-Schnitt:
> 
> 1. **Einfrieren (Freeze):** Du setzt die aktuelle Datei auf `status: "deprecated"`. Füge ganz oben das Warn-Callout mit dem Verweis auf die geplante neue Datei ein. Das Changelog dieser alten Datei wird ab jetzt nie wieder angefasst. Das Plugin *Auto Note Mover* schiebt sie ins Archiv.
> 2. **Tabula Rasa:** Du erstellst eine komplett neue Notiz für das überarbeitete Feature. Diese enthält keine alten Dummy-Überschriften und keine Altlasten.
> 3. **Changelog Reset:** In der neuen Datei startest du mit einem völlig leeren Changelog. Der erste und einzige Eintrag lautet dann zum Beispiel:
> * *- v2.0.0: Initiale Dokumentation des neuen OAuth2-Systems (ersetzt Legacy-Auth).*
> 
> 
> 1. **Verknüpfung:** Im Frontmatter der neuen Notiz nutzt du `replaces: "[[Legacy Auth_v1]]"`, um die Brücke zur Vergangenheit zu schlagen.
> 
> Welche Art von Features dokumentierst du aktuell am meisten in deinem Second Brain – sind es eher abstrakte Architekturkonzepte oder sehr spezifische API-Endpunkte und Code-Snippets?