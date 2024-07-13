import os
import requests
from prometheus_client import start_http_server, Gauge
import time

# GitHub repository details
GITHUB_REPO = 'Yashground/miniature-enigma'
GITHUB_TOKEN = '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'

# Prometheus metrics
commits_gauge = Gauge('github_commits', 'Number of commits in the repository')
push_events_gauge = Gauge('github_push_events', 'Number of push events in the repository')
pull_requests_gauge = Gauge('github_pull_requests', 'Number of open pull requests')
pr_merged_gauge = Gauge('github_pr_merged', 'Number of merged pull requests')

def get_github_data():
    headers = {'Authorization': f'token {GITHUB_TOKEN}'}

    # Get the number of commits
    commits_url = f'https://api.github.com/repos/{GITHUB_REPO}/commits'
    commits_response = requests.get(commits_url, headers=headers)
    commits = commits_response.json()
    print("Commits Response:", commits)  # Debug
    commits_gauge.set(len(commits))

    # Get the number of push events
    events_url = f'https://api.github.com/repos/{GITHUB_REPO}/events'
    events_response = requests.get(events_url, headers=headers)
    events = events_response.json()
    print("Events Response:", events)  # Debug
    push_events = sum(1 for event in events if event['type'] == 'PushEvent')
    push_events_gauge.set(push_events)

    # Get the number of open pull requests
    pr_url = f'https://api.github.com/repos/{GITHUB_REPO}/pulls?state=open'
    pr_response = requests.get(pr_url, headers=headers)
    pull_requests = pr_response.json()
    print("Open PRs Response:", pull_requests)  # Debug
    pull_requests_gauge.set(len(pull_requests))

    # Get the number of merged pull requests
    pr_merged_url = f'https://api.github.com/repos/{GITHUB_REPO}/pulls?state=closed'
    pr_merged_response = requests.get(pr_merged_url, headers=headers)
    pr_merged = pr_merged_response.json()
    print("Merged PRs Response:", pr_merged)  # Debug
    pr_merged_count = sum(1 for pr in pr_merged if pr['merged_at'] is not None)
    pr_merged_gauge.set(pr_merged_count)

if __name__ == '__main__':
    start_http_server(8000)
    while True:
        get_github_data()
        time.sleep(60)  # Update every minute
