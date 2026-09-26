import requests
 
 
def search_repositories(
 
query: str,
 
page: int = 1,
 
per_page: int = 25
 
):
 
url = (
"https://api.github.com/search/repositories"
)
 
params = {
"q": query,
"page": page,
"per_page": per_page
}
 
response = requests.get(
url,
params=params,
timeout=30
)
 
response.raise_for_status()
 
return response.json()
 
 
if __name__ == "__main__":
 
result = search_repositories(
"data science"
)
 
print(
result["total_count"]
)
