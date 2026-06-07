import requests
import time
from datetime import datetime

GITHUB_TOKEN = "HIER EINTRAGEn"
HEADERS = {
    "Accept": "application/vnd.github.v3+json",
    "Authorization": f"token {GITHUB_TOKEN}"
}

def get_latest_1000_plugins():
    unique_repos = {}
    
    print("⏳ Rufe die neuesten Repositories ab (sortiert nach Erstelldatum)...")
    
    for page in range(1, 11):
        search_url = f"https://api.github.com/search/code?q=path:.claude-plugin+filename:marketplace.json&sort=indexed&per_page=100&page={page}"
        
        response = requests.get(search_url, headers=HEADERS)
        
        if response.status_code in [403, 422]:
            print(f"ℹ️ GitHub Limit erreicht. Lese bis Seite {page-1} ein.")
            break

        if response.status_code != 200:
            print(f"Fehler bei Seite {page}: {response.status_code}")
            break

        items = response.json().get("items", [])
        if not items:
            break
            
        for item in items:
            repo = item["repository"]
            unique_repos[repo["full_name"]] = repo["url"]
            
        time.sleep(0.5)

    print(f"✅ {len(unique_repos)} einzigartige Repositories gefunden. Rufe Details und Sterne ab...")

    results = []
    oldest_date = None
    oldest_repo_name = ""

    for count, (name, api_url) in enumerate(unique_repos.items(), 1):
        if count % 100 == 0:
            print(f"  -> {count} von {len(unique_repos)} Repos geladen...")
            
        repo_response = requests.get(api_url, headers=HEADERS)
        if repo_response.status_code == 200:
            data = repo_response.json()
            
            # Erstelldatum des Repositories auslesen (Format: 2026-05-20T12:34:56Z)
            created_at_str = data.get("created_at")
            created_at_dt = datetime.strptime(created_at_str, "%Y-%m-%dT%H:%M:%SZ") if created_at_str else None
            
            # Prüfen, ob dies das älteste bisher gefundene Repo ist
            if created_at_dt:
                if oldest_date is None or created_at_dt < oldest_date:
                    oldest_date = created_at_dt
                    oldest_repo_name = name

            results.append({
                "name": name, 
                "stars": data.get("stargazers_count", 0), 
                "url": data.get("html_url"),
                "created_at": created_at_dt.strftime("%d.%m.%Y") if created_at_dt else "Unbekannt"
            })
        elif repo_response.status_code == 403:
            time.sleep(5)

    # Nach Sternen sortieren
    sorted_repos = sorted(results, key=lambda x: x["stars"], reverse=True)
    
    # Datum für die Anzeige formatieren
    oldest_date_formatted = oldest_date.strftime("%d.%m.%Y um %H:%M Uhr") if oldest_date else "Unbekannt"
    
    # Zusammenfassung im Terminal
    print("\n" + "="*60)
    print(f"📊 ANALYSE-ERGEBNIS:")
    print(f"Insgesamt abgefragte Repos: {len(unique_repos)}")
    print(f"Ältestes Repo in dieser Auswahl: '{oldest_repo_name}'")
    print(f"Erstellt am: {oldest_date_formatted}")
    print("="*60 + "\n")

    # In Datei schreiben
    with open("claude_plugins_neueste_top_stars.txt", "w", encoding="utf-8") as f:
        f.write(f"ZUSAMMENFASSUNG:\n")
        f.write(f"Abgefragte Repositories: {len(unique_repos)}\n")
        f.write(f"Zeitraum: Von {oldest_date.strftime('%d.%m.%Y') if oldest_date else 'Anfang'} bis heute (Neueste zuerst gesucht)\n")
        f.write(f"Ältestes Repo in dieser Liste: {oldest_repo_name} ({oldest_date_formatted})\n")
        f.write("-" * 110 + "\n\n")
        
        f.write(f"{'Stars':<6} | {'Erstellt am':<12} | {'Repository':<45} | URL\n")
        f.write("-" * 110 + "\n")
        for repo in sorted_repos:
            f.write(f"{repo['stars']:<6} | {repo['created_at']:<12} | {repo['name']:<45} | {repo['url']}\n")

    print("🎉 Fertig! Die Liste wurde inklusive Erstellungsdatum in 'claude_plugins_neueste_top_stars.txt' gespeichert.")

if __name__ == "__main__":
    get_latest_1000_plugins()