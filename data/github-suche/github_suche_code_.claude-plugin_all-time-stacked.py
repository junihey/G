import requests
import time
from datetime import datetime, timedelta

GITHUB_TOKEN = "DEIN_TOKEN_HIER"
HEADERS = {
    "Accept": "application/vnd.github.v3+json",
    "Authorization": f"token {GITHUB_TOKEN}"
}

def generate_monthly_chunks(start_year=2024):
    """Erstellt eine Liste von Start- und Enddaten für jeden Monat"""
    chunks = []
    current_date = datetime(start_year, 1, 1)
    end_date = datetime.now()
    
    while current_date < end_date:
        next_month = current_date + timedelta(days=32)
        next_month = datetime(next_month.year, next_month.month, 1)
        
        start_str = current_date.strftime("%Y-%m-%d")
        # Letzter Tag des aktuellen Monats ist ein Tag vor dem 1. des nächsten Monats
        end_str = (next_month - timedelta(days=1)).strftime("%Y-%m-%d")
        
        chunks.append((start_str, end_str))
        current_date = next_month
    return chunks

def get_all_claude_plugins():
    unique_repos = {}
    time_chunks = generate_monthly_chunks(start_year=2024) # Claude-Plugins gibt es erst seit kurzem, 2024 reicht völlig aus
    
    print(f"🌍 Teile Suche in {len(time_chunks)} Zeitfenster auf, um das 1000-Treffer-Limit zu umgehen...")
    
    for start, end in time_chunks:
        print(f"📅 Suche im Zeitraum: {start} bis {end}...")
        
        # Wir fragen für jeden Monat bis zu 10 Seiten ab
        for page in range(1, 11):
            query = f"path:.claude-plugin+filename:marketplace.json+created:{start}..{end}"
            search_url = f"https://api.github.com/search/code?q={query}&per_page=100&page={page}"
            
            response = requests.get(search_url, headers=HEADERS)
            
            if response.status_code == 403:
                wait_time = int(response.headers.get("Retry-After", 30))
                print(f"⚠️ Rate Limit erreicht. Pause für {wait_time} Sek...")
                time.sleep(wait_time)
                response = requests.get(search_url, headers=HEADERS)
                
            if response.status_code != 200:
                break
                
            items = response.json().get("items", [])
            if not items:
                break # Keine weiteren Ergebnisse in diesem Monat
                
            for item in items:
                repo = item["repository"]
                unique_repos[repo["full_name"]] = repo["url"]
                
            # Da wir sehr viele Anfragen senden, lassen wir der API 1 Sekunde Luft pro Seite
            time.sleep(1)

    print(f"\n✅ Fertig! Insgesamt {len(unique_repos)} einzigartige Repositories gefunden.")
    print("⭐ Rufe jetzt die Sterne für alle Repositories ab (das kann ein paar Minuten dauern)...")

    # Sterne abrufen
    results = []
    for count, (name, api_url) in enumerate(unique_repos.items(), 1):
        if count % 100 == 0:
            print(f"  -> {count} von {len(unique_repos)} Repos geladen...")
            
        repo_response = requests.get(api_url, headers=HEADERS)
        if repo_response.status_code == 200:
            data = repo_response.json()
            results.append({
                "name": name, 
                "stars": data.get("stargazers_count", 0), 
                "url": data.get("html_url")
            })
        elif repo_response.status_code == 403:
            time.sleep(5) # Kurze Zwangspause bei Drosselung

    # Sortieren und Ausgeben
    sorted_repos = sorted(results, key=lambda x: x["stars"], reverse=True)
    
    # Speichern in einer Textdatei, weil 13.000 Zeilen das Terminal sprengen
    with open("claude_plugins_top_stars.txt", "w", encoding="utf-8") as f:
        f.write(f"{'Stars':<6} | {'Repository':<50} | URL\n")
        f.write("-" * 100 + "\n")
        for repo in sorted_repos:
            f.write(f"{repo['stars']:<6} | {repo['name']:<50} | {repo['url']}\n")

    print("\n🎉 Fertig! Die Ergebnisse wurden in 'claude_plugins_top_stars.txt' gespeichert.")

if __name__ == "__main__":
    get_all_claude_plugins()