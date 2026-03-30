#!/bin/bash
# Deploy script for Linda's Cafe
# Usage: GH_TOKEN=your_github_token ./deploy.sh

if [ -z "$GH_TOKEN" ]; then
    echo "Error: GH_TOKEN environment variable not set"
    echo "Please provide your GitHub Personal Access Token"
    echo "Create one at: https://github.com/settings/tokens"
    echo "Required scopes: repo, read:user"
    exit 1
fi

REPO_NAME="sip-klatsch"

# Create repository using GitHub API
curl -s -X POST https://api.github.com/user/repos \
    -H "Authorization: token $GH_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "{\"name\":\"$REPO_NAME\",\"private\":false,\"auto_init\":true}" \
    2>/dev/null | grep -q "id" && echo "Repository created" || echo "Repository may already exist"

# Set remote
git remote add origin "https://$GH_TOKEN@github.com/$(curl -s -H "Authorization: token $GH_TOKEN" https://api.github.com/user | grep -o '"login": "[^"]*"' | cut -d'"' -f4)/$REPO_NAME.git" 2>/dev/null || true

# Push
git branch -M main
git push -u origin main --force 2>/dev/null

# Enable GitHub Pages
curl -s -X POST "https://api.github.com/repos/$(curl -s -H "Authorization: token $GH_TOKEN" https://api.github.com/user | grep -o '"login": "[^"]*"' | cut -d'"' -f4)/$REPO_NAME/pages" \
    -H "Authorization: token $GH_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d '{"source":{"branch":"main","path":"/"}}' \
    2>/dev/null

echo "Deployed! URL will be: https://$(curl -s -H "Authorization: token $GH_TOKEN" https://api.github.com/user | grep -o '"login": "[^"]*"' | cut -d'"' -f4).github.io/$REPO_NAME/"