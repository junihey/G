# Prompt

Bitte erstelle mir einen phasenweisen Setup-Ablaufplan, um all diese Themen neu aufzusetzen, den ich immer wieder nutzen kann, er soll minimalistisch und portabel sein:

Youtube-Videos:
1) Claude Code Remote - Immer & Überall! - YouTube
2) Claude Code vom Handy für dich arbeiten lassen (Remote Control) - YouTube
3) So lässt du Claude Code von überall für dich arbeiten (Remote Control) - YouTube
4) Claude Code kostenlos nutzen: Unbegrenzt coden ohne starken PC - YouTube
5) Vollständiges Hermes Agent Setup Tutorial: Schritt-für-Schritt Anleitung
6) Claude überwacht meinen Server - YouTube

SPEC im Anhang als "hybrid-worktree-docker-spec(9).md"

Es ist vorhanden ein VPS von Ionos und ein ClaudePro Account.
Beschränke den Ablaufplan darauf, was ich in Vorbereitung und manuell zum SPEC machen muss. um dann den SPEC möglichst einfach automatisch bauen zu lassen. (Bedenke neben Claude und Hermes Setup, Sandcastle, Herdr und openrouter)

# Answer
---

Hier ist ein fokussierter, portabler Phasenplan, um den Ionos-VPS als „Always-On“-Remote-Maschine vorzubereiten. Das Ziel ist eine minimalistische Basisumgebung, die du von überall (auch mobil) steuern kannst, um danach den Agenten (Slice 1 der Spec) die eigentliche Implementierung der Architektur bauen zu lassen.

### Phase 1: Infrastruktur & Remote-Fundament (Ionos VPS)

Da das System als Remote-Engine läuft, muss der VPS als headless Host vorbereitet werden.

1. **System-Basics:** Logge dich per SSH auf dem VPS ein und installiere die essenziellen Laufzeitumgebungen:
    
    - Node.js (v20+, für Sandcastle, Orchestrator und Claude Code)
        
    - Git (für Sandcastle-Worktrees)
        
    - Docker (für die `container`-Isolationsstufe)
        
2. **Zeitstempel synchronisieren:** Stelle die Zeitzone des Servers auf CEST (Leipzig), damit die Agent-Logs und die automatischen `createdAt`/`updatedAt`-Frontmatter-Einträge der Issues synchron mit deiner lokalen Zeit sind.
    
3. **Remote & Mobile Control:** Um von unterwegs (wie in den Tutorials skizziert) sicher auf den Server zuzugreifen, richte einen Terminal-Multiplexer (`tmux` oder `zellij`) ein. So kannst du SSH-Sessions vom Handy aufbauen, Befehle absetzen, die Verbindung trennen und später nahtlos weiterarbeiten, ohne dass der Agent-Loop unterbrochen wird.
    

### Phase 2: Zugänge & API-Keys (Korrektur & Vorbereitung)

Ein wichtiges Detail vorab: Ein **Claude Pro** Account schaltet nur die Web- und App-Oberfläche frei. Für die Nutzung von Claude Code und automatisierten Agenten im Terminal benötigst du Zugriff auf die **Anthropic API**.

1. **Anthropic API:** Erstelle einen API-Key in der Anthropic Console und lade ein initiales Guthaben (Credits) auf.
    
2. **OpenRouter (Fallback):** Generiere einen OpenRouter API-Key für die Modellwahl-Flexibilität aus der Spec (Abschnitt 8.1).
    
3. **Umgebungsvariablen:** Trage beide Keys in die `.bashrc` oder `.zshrc` deines VPS-Users ein:
    
    Bash
    
    ```
    export ANTHROPIC_API_KEY="sk-ant-..."
    export OPENROUTER_API_KEY="sk-or-..."
    ```
    

### Phase 3: Toolchain Installation (Die manuellen Installationen)

Installiere nun die CLI-Werkzeuge global auf dem VPS. Dies ist die Brücke zwischen der reinen Server-Umgebung und der orchestrierten Agenten-Welt.

1. **Claude Code & Sandcastle:**
    
    Bash
    
    ```
    npm install -g @anthropic-ai/claude-code
    npm install -g @ai-hero/sandcastle
    ```
    
2. **Herdr (Terminal-Sichtbarkeit):**
    
    Installiere die Herdr-CLI für die Workspace-Überwachung (Spec Abschnitt 15). Führe nach der Installation direkt die Integration für Claude aus:
    
    Bash
    
    ```
    herdr integration install claude
    ```
    
3. **Hermes Agent (Optionaler Remote-Layer):** Richte Hermes ein, falls du es als primäres Remote-Interface oder als ergänzendes Monitoring-Tool für den VPS nutzen möchtest, wie es in den Tutorials empfohlen wird.
    
4. **Modell-Gateway (für OpenRouter):**
    
    Richte LiteLLM oder `agentgateway` einmalig lokal auf dem VPS ein (Spec Abschnitt 8.1), um die API-Anfragen von Claude Code auf das OpenAI-Format von OpenRouter zu übersetzen. Starte den Gateway-Prozess im Hintergrund (z. B. via `pm2` oder `systemd`).
    

### Phase 4: Das Seed-Projekt (Der Startschuss)

Jetzt wird das Fundament für Slice 1 der Spec gelegt. Ab hier übernimmt der Agent die Hauptarbeit.

1. **Projektverzeichnis anlegen:**
    
    Erstelle das Hauptverzeichnis für deinen Code auf dem VPS und initialisiere Git.
    
2. **Sandcastle initialisieren:**
    
    Führe den in der Spec definierten Startbefehl aus:
    
    Bash
    
    ```
    sandcastle init --issue-tracker custom
    ```
    
3. **Vault-Struktur anlegen:**
    
    Erstelle den Ordner `./vault/issues/`. Da der VPS keine grafische Oberfläche hat, brauchst du hier keine Obsidian-Installation. Es reicht die reine Ordnerstruktur für die Markdown-Dateien. Du kannst diesen Ordner später per Syncthing mit deinem lokalen Rechner synchronisieren, wenn du die Issues visuell in Obsidian verwalten willst.
    
4. **Den Agenten zünden:**
    
    Lade die komplette `.md`-Spec in den Root-Ordner deines Projekts. Öffne Claude Code (oder Hermes) und gib den ersten großen Bauauftrag:
    
    _„Lies die beigefügte Spec. Wir befinden uns in Slice 1. Baue mir exakt den Code für den ObsidianIssueStore, run-agent.ts mit noSandbox() als Default, und den grundlegenden Chokidar-Watcher, wie in der Spec beschrieben. Nutze das existierende Sandcastle-Setup.“_