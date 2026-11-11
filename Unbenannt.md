##### graka restart
1. Win + Strg + Umschalt + B. Das startet nur den Grafiktreiber neu. Es piept kurz, und nach ein paar Sekunden ist das Bild oft zurück. Alle Programme laufen weiter.
2. Prüfen, ob der Rechner noch lebt: Num-Lock drücken. Geht die LED an der Tastatur an und aus, läuft Windows, nur die Anzeige fehlt.
3. Blind herunterfahren, wenn der Rechner lebt: Win + R drücken, shutdown /s /t 0 tippen, Enter. Du siehst nichts davon, aber Windows schreibt alles ordentlich zu Ende. Genau das verhindert den Schaden.
4. Erst danach den Einschaltknopf zehn Sekunden halten. Das ist der harte Schnitt, und der hat heute das Dateisystem beschädigt: Windows wurde mitten im Schreiben unterbrochen.
5. Nach jedem harten Ausschalten: chkdsk C: /scan in der Admin-PowerShell. Findet es etwas, danach chkdsk C: /spotfix und ein Neustart.
6. Danach mir Bescheid geben. Ich prüfe git fsck und die Tests in den betroffenen Projekten, so wie heute.