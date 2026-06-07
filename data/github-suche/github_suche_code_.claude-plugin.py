import requests
import time

# Dein GitHub Personal Access Token
GITHUB_TOKEN = "HIER EINTRAGEn"
HEADERS = {
    "Accept": "application/vnd.github.v3+json",
    "Authorization": f"token {GITHUB_TOKEN}"
}

def get_top_claude_plugins(max_pages=3):
    unique_repos = {}
    
    print(f"🚀 Starte Turbo-Suche...")
    
    for page in range(1, max_pages + 1):
        search_url = f"https://api.github.com/search/code?q=path:.claude-plugin+filename:marketplace.json&per_page=100&page={page}"
        
        response = requests.get(search_url, headers=HEADERS)
        
        # Falls wir doch zu schnell sind (Rate Limit)
        if response.status_code == 403:
            wait_time = int(response.headers.get("Retry-After", 10))
            print(f"⚠️ Rate Limit erreicht. Pause für {wait_time} Sek...")
            time.sleep(wait_time)
            response = requests.get(search_url, headers=HEADERS)

        if response.status_code != 200:
            break

        items = response.json().get("items", [])
        if not items: break
            
        for item in items:
            repo = item["repository"]
            unique_repos[repo["full_name"]] = repo["url"]

    print(f"✅ {len(unique_repos)} Repos gefunden. Rufe Sterne ab...")

    # Sterne ohne künstliche Pause abrufen
    results = []
    for name, api_url in unique_repos.items():
        repo_response = requests.get(api_url, headers=HEADERS)
        if repo_response.status_code == 200:
            data = repo_response.json()
            results.append({
                "name": name, 
                "stars": data.get("stargazers_count", 0), 
                "url": data.get("html_url")
            })
        elif repo_response.status_code == 403: # Falls wir bei den Details gedrosselt werden
            time.sleep(1) 

    # Sortieren und Ausgeben
    sorted_repos = sorted(results, key=lambda x: x["stars"], reverse=True)
    print(f"\n{'Stars':<6} | {'Repository':<40} | URL")
    print("-" * 80)
    for repo in sorted_repos:
        print(f"{repo['stars']:<6} | {repo['name']:<40} | {repo['url']}")

if __name__ == "__main__":
    get_top_claude_plugins(max_pages=5) # Hier kannst du jetzt locker auch 5 oder 10 Seiten abfragen