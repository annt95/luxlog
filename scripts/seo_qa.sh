#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-https://luxlog.vercel.app}"
PHOTO_ID="${PHOTO_ID:-}"
USERNAME="${USERNAME:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}PASS${NC} $1"; }
fail() { echo -e "${RED}FAIL${NC} $1"; }
warn() { echo -e "${YELLOW}WARN${NC} $1"; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1"
    exit 1
  fi
}

require_cmd curl
require_cmd grep

check_contains() {
  local content="$1"
  local pattern="$2"
  local label="$3"
  if echo "$content" | grep -Eiq "$pattern"; then
    pass "$label"
  else
    fail "$label"
  fi
}

echo "== Luxlog SEO QA =="
echo "Target: $BASE_URL"

robots="$(curl -fsS "$BASE_URL/robots.txt")"
check_contains "$robots" "Disallow: /upload" "robots.txt disallow upload"
check_contains "$robots" "Disallow: /notifications" "robots.txt disallow notifications"
check_contains "$robots" "Sitemap:" "robots.txt has sitemap"

sitemap="$(curl -fsS "$BASE_URL/sitemap.xml")"
check_contains "$sitemap" "<urlset" "sitemap.xml is valid XML urlset"
check_contains "$sitemap" "<loc>${BASE_URL}/" "sitemap includes home"
check_contains "$sitemap" "<loc>${BASE_URL}/explore" "sitemap includes explore"

home_html="$(curl -fsS "$BASE_URL/")"
check_contains "$home_html" "<meta[^>]+property=\"og:title\"" "home has og:title"
check_contains "$home_html" "<meta[^>]+name=\"twitter:card\"" "home has twitter card"
check_contains "$home_html" "<link[^>]+rel=\"canonical\"" "home has canonical"

if [[ -n "$PHOTO_ID" ]]; then
  photo_url="$BASE_URL/photo/$PHOTO_ID"
  photo_html="$(curl -fsS -A "googlebot" "$photo_url")"
  check_contains "$photo_html" "ImageObject" "photo bot snapshot has ImageObject JSON-LD"
  check_contains "$photo_html" "og:title" "photo bot snapshot has og:title"
  check_contains "$photo_html" "canonical" "photo bot snapshot has canonical"
else
  warn "Skip photo bot snapshot checks (set PHOTO_ID=<id>)"
fi

if [[ -n "$USERNAME" ]]; then
  user_url="$BASE_URL/u/$USERNAME"
  user_html="$(curl -fsS -A "twitterbot" "$user_url")"
  check_contains "$user_html" "ProfilePage" "profile bot snapshot has ProfilePage JSON-LD"
  check_contains "$user_html" "og:type\" content=\"profile\"|og:type' content='profile'" "profile bot snapshot has og:type=profile"
else
  warn "Skip profile bot snapshot checks (set USERNAME=<username>)"
fi

echo
echo "Manual checks still required:"
echo "1) Google Rich Results Test on one /photo/:id URL"
echo "2) Facebook Sharing Debugger and X Card Validator"
echo "3) Search Console sitemap submit + indexing coverage"
