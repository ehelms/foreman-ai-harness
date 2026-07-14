#!/bin/bash
# Foreman PR review: convention checks + diff output
# Designed for compact output to stay under inline display limits.

set -euo pipefail

# --- Project type ---
if [ -f app/registries/foreman/plugin.rb ]; then
  PROJECT_TYPE="core"
elif ls foreman_*.gemspec &>/dev/null && grep -rl 'Foreman::Plugin.register' lib/ &>/dev/null; then
  PROJECT_TYPE="plugin"
elif ls smart_proxy*.gemspec &>/dev/null; then
  PROJECT_TYPE="smart_proxy"
else
  PROJECT_TYPE="unknown"
fi

# --- Diff range ---
BASE_BRANCH=$(git symbolic-ref --short refs/remotes/upstream/HEAD 2>/dev/null || git symbolic-ref --short refs/remotes/origin/HEAD)
MERGE_BASE=$(git merge-base "$BASE_BRANCH" HEAD)

echo "PROJECT_TYPE=$PROJECT_TYPE BASE=$BASE_BRANCH MERGE_BASE=$MERGE_BASE"
echo ""
echo "=== COMMITS ==="
git log --oneline --no-color "$MERGE_BASE"..HEAD
echo ""
echo "=== STAT ==="
git diff --stat "$MERGE_BASE"..HEAD

# --- Convention checks (only print failures) ---
echo ""
echo "=== CONVENTION CHECKS ==="
CHECKS_PASSED=true

BAD_COMMITS=$(git log --oneline --no-color "$MERGE_BASE"..HEAD | grep -v -E '^[a-f0-9]+ (Fixes|Refs) #[0-9]+' || true)
if [ -n "$BAD_COMMITS" ]; then
  echo "FAIL 1 commit-format: $BAD_COMMITS"
  CHECKS_PASSED=false
fi

BAD_VIEWS=$(git diff --no-color --diff-filter=A "$MERGE_BASE"..HEAD --name-only -- 'app/views/**/*.erb' | grep -v '\.html\.erb$' || true)
if [ -n "$BAD_VIEWS" ]; then
  echo "FAIL 2 view-extension: $BAD_VIEWS"
  CHECKS_PASSED=false
fi

BAD_EXCEPTIONS=$(git diff --no-color "$MERGE_BASE"..HEAD | grep -E '^\+.*class.*Exception.*<' | grep -v 'Foreman::Exception' || true)
if [ -n "$BAD_EXCEPTIONS" ]; then
  echo "FAIL 3 exception-type: $BAD_EXCEPTIONS"
  CHECKS_PASSED=false
fi

BAD_LOGGER=$(git diff --no-color "$MERGE_BASE"..HEAD | grep -E '^\+.*logger\.(debug|info).*#\{' || true)
if [ -n "$BAD_LOGGER" ]; then
  echo "FAIL 4 logger-block: $BAD_LOGGER"
  CHECKS_PASSED=false
fi

BAD_CLASSEVAL=$(git diff --no-color "$MERGE_BASE"..HEAD | grep -E '^\+.*class_eval' || true)
if [ -n "$BAD_CLASSEVAL" ]; then
  echo "FAIL 5 concern-pattern: $BAD_CLASSEVAL"
  CHECKS_PASSED=false
fi

BAD_LIB=$(git diff --no-color --diff-filter=A "$MERGE_BASE"..HEAD --name-only -- 'lib/**/*.rb' | grep -E '(service|model)' | grep -v -E '(engine|tasks|generators)' || true)
if [ -n "$BAD_LIB" ]; then
  echo "FAIL 6 app-vs-lib: $BAD_LIB"
  CHECKS_PASSED=false
fi

BAD_REFLECT=$(git diff --no-color "$MERGE_BASE"..HEAD | grep -E '^\+.*params.*\.(to_sym|send)\(' || true)
if [ -n "$BAD_REFLECT" ]; then
  echo "FAIL 7 unsafe-reflection: $BAD_REFLECT"
  CHECKS_PASSED=false
fi

BAD_SEARCH=$(git diff --no-color "$MERGE_BASE"..HEAD | grep -E '^\+.*scoped_search.*:ext_method' | grep -v ':only_explicit.*=>.*true' || true)
if [ -n "$BAD_SEARCH" ]; then
  echo "FAIL 8 scoped-search: $BAD_SEARCH"
  CHECKS_PASSED=false
fi

BAD_DEPRECATION=$(git diff --no-color "$MERGE_BASE"..HEAD | grep -E '^\+.*ActiveSupport::Deprecation' || true)
if [ -n "$BAD_DEPRECATION" ]; then
  echo "FAIL 9 deprecation: $BAD_DEPRECATION"
  CHECKS_PASSED=false
fi

if [ "$CHECKS_PASSED" = true ]; then
  echo "ALL PASS (1-9)"
fi
echo "10 i18n: contextual (AI assessment)"

# --- Diff ---
SHORTSTAT=$(git diff --shortstat "$MERGE_BASE"..HEAD)
INSERTIONS=$(echo "$SHORTSTAT" | grep -oP '\d+(?= insertion)' || echo 0)
DELETIONS=$(echo "$SHORTSTAT" | grep -oP '\d+(?= deletion)' || echo 0)
TOTAL=$((INSERTIONS + DELETIONS))

echo ""
if [ "$TOTAL" -le 1000 ]; then
  echo "=== DIFF ($TOTAL lines) ==="
  git diff --no-color "$MERGE_BASE"..HEAD
else
  echo "=== LARGE PR ($TOTAL lines) — use stat triage ==="
fi
