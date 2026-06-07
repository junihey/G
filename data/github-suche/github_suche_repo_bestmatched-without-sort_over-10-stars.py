import requests
from datetime import datetime

# WICHTIG: Setze hier deinen GANZ NEUEN Token ein!
GITHUB_TOKEN = "HIER EINTRAGEn"
HEADERS = {
    "Accept": "application/vnd.github.v3+json",
    "Authorization": f"token {GITHUB_TOKEN}"
}

def get_high_quality_plugins():
    results = []
    
    print("⏳ Rufe die neuesten Repositories ab (Filter: 'claude', Mindestens 10 Sterne)...")
    
    for page in range(1, 6): # 5 Seiten à 100 Ergebnisse = Top 500 Projekte
        # FEHLER BEHOBEN: sort=indexed wurde zu sort=updated geändert!
        search_url = f"https://api.github.com/search/repositories?q=claude+stars:>10&order=desc&per_page=100&page={page}"
        
        response = requests.get(search_url, headers=HEADERS)
        
        if response.status_code != 200:
            print(f"Fehler bei Seite {page}: {response.status_code} - {response.text}")
            break

        items = response.json().get("items", [])
        if not items:
            break
            
        for item in items:
            # Erstellungsdatum auslesen und konvertieren
            created_at_str = item.get("created_at")
            created_at_dt = datetime.strptime(created_at_str, "%Y-%m-%dT%H:%M:%SZ") if created_at_str else None
            
            results.append({
                "name": item["full_name"],
                "stars": item["stargazers_count"],
                "url": item["html_url"],
                "created_at_dt": created_at_dt,
                "created_at_formatted": created_at_dt.strftime("%d.%m.%Y") if created_at_dt else "Unbekannt"
            })

    if not results:
        print("❌ Keine Repositories gefunden.")
        return

    print(f"✅ {len(results)} Repositories gefunden. Analysiere Daten und sortiere nach Sternen...")

    # Ältestes Datum ermitteln
    valid_dates = [r["created_at_dt"] for r in results if r["created_at_dt"]]
    if valid_dates:
        oldest_date = min(valid_dates)
        # Finde das passende Repo zum ältesten Datum
        oldest_repo = next(r for r in results if r["created_at_dt"] == oldest_date)
        oldest_info = f"{oldest_date.strftime('%d.%m.%Y')} (Repository: {oldest_repo['name']})"
    else:
        oldest_info = "Unbekannt"

    # Lokal nach Sternen sortieren (absteigend)
    sorted_results = sorted(results, key=lambda x: x["stars"], reverse=True)

    # In Datei schreiben
    with open("claude_plugins_echte_top_stars.txt", "w", encoding="utf-8") as f:
        # Kopfbereich mit dem ältesten Datum am Anfang der Datei
        f.write("=" * 115 + "\n")
        f.write("ZUSAMMENFASSUNG DER SUCHE\n")
        f.write(f"Anzahl gefundener Repositories: {len(results)}\n")
        f.write(f"Ältestes Erstellungsdatum in dieser Liste: {oldest_info}\n")
        f.write("=" * 115 + "\n\n")
        
        # Tabellen-Header
        f.write(f"{'Stars':<6} | {'Erstellt am':<12} | {'Repository':<50} | URL\n")
        f.write("-" * 115 + "\n")
        
        # Datenzeilen
        for repo in sorted_results:
            f.write(f"{repo['stars']:<6} | {repo['created_at_formatted']:<12} | {repo['name']:<50} | {repo['url']}\n")

    print("\n🎉 Fertig! Die Datei wurde erfolgreich erstellt.")

if __name__ == "__main__":
    get_high_quality_plugins()