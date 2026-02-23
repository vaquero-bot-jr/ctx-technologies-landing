#!/usr/bin/env bash
# review.sh – monitor live site and trigger redeploy if needed
set -u

PAGE_URL="https://vaquero-bot-jr.github.io/ctx-technologies-landing/"
REPO_DIR="$(git rev-parse --show-toplevel)"
LOG_FILE="/tmp/ctx_tech_review.log"

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$PAGE_URL")
    echo "$TIMESTAMP – status code: $STATUS" >> "$LOG_FILE"
    if [ "$STATUS" -ne 200 ]; then
        echo "$TIMESTAMP – page not reachable (status $STATUS). Triggering redeploy." | tee -a "$LOG_FILE"
        cd "$REPO_DIR"
        # Ensure we have latest changes
        git fetch origin main
        git reset --hard origin/main
        # Re‑push to trigger Pages build
        git push origin main
    else
        # Check for key elements
        if ! curl -s "$PAGE_URL" | grep -q 'id="case-study"'; then
            echo "$TIMESTAMP – case study section missing. Triggering redeploy." | tee -a "$LOG_FILE"
            cd "$REPO_DIR"
            git fetch origin main
            git reset --hard origin/main
            git push origin main
        else
            echo "$TIMESTAMP – all good." | tee -a "$LOG_FILE"
        fi
    fi
    sleep 600
done
