import urllib.request
import json
import time
import sys

def get_latest_run():
    url = "https://api.github.com/repos/VityaIG/Cort1so1/actions/runs?per_page=3"
    req = urllib.request.Request(url, headers={"Accept": "application/vnd.github.v3+json"})
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode())
    return data["workflow_runs"]

print("Waiting for GitHub action for commit 6b2b84d to complete...")
while True:
    runs = get_latest_run()
    run = next((r for r in runs if r["head_sha"].startswith("6b2b84d")), None)
    if run is None:
        print("Run not found yet. Waiting 5 seconds...")
        time.sleep(5)
        continue
    status = run["status"]
    if status == "completed":
        conclusion = run["conclusion"]
        print(f"Action completed with conclusion: {conclusion}")
        break
    else:
        print(f"Current status: {status}. Waiting 5 seconds...")
        time.sleep(5)
