#!/usr/bin/env bash
set -e

# Ensure check-plugins.sh is executable
chmod +x ../scripts/check-plugins.sh

# Create dummy github_repos.txt
cat <<EOF >github_repos.txt
jose-elias-alvarez/null-ls.nvim
test-user/this-repo-does-not-exist-12345
glepnir/lspsaga.nvim
jose-elias-alvarez/typescript.nvim
folke/lazy.nvim
EOF

# Setup environment
export IGNORE_PLUGINS="jose-elias-alvarez/typescript.nvim"

echo "Running check-plugins.sh with dummy data..."
# Run the script (expecting exit code 1 due to issues found)
../scripts/check-plugins.sh "github_repos.txt" "results.json" || true

# Verify outputs
echo "Verifying results..."

get_output() {
  jq -r ".$1" results.json
}

ARCHIVED=$(jq -c '."archived_plugins"' results.json)
DELETED=$(jq -c '."deleted_plugins"' results.json)
MOVED=$(jq -c '."moved_plugins"' results.json)
HAS_ISSUES=$(get_output "has_issues")

echo "Archived Output: $ARCHIVED"
echo "Deleted Output: $DELETED"
echo "Moved Output: $MOVED"

FAILED=0

# Check Archived (null-ls should be there)
if echo "$ARCHIVED" | grep -q "jose-elias-alvarez/null-ls.nvim"; then
  echo "✅ null-ls.nvim detected as archived"
else
  echo "❌ FAIL: null-ls.nvim NOT detected as archived"
  FAILED=1
fi

# Check Ignored (typescript.nvim should NOT be there)
if echo "$ARCHIVED" | grep -q "jose-elias-alvarez/typescript.nvim"; then
  echo "❌ FAIL: typescript.nvim should be ignored but was detected"
  FAILED=1
else
  echo "✅ typescript.nvim correctly ignored"
fi

# Check Deleted
if echo "$DELETED" | grep -q "test-user/this-repo-does-not-exist-12345"; then
  echo "✅ Non-existent repo detected as deleted"
else
  echo "❌ FAIL: Non-existent repo NOT detected as deleted"
  FAILED=1
fi

# Check Moved (glepnir/lspsaga.nvim -> nvimdev/lspsaga.nvim)
if echo "$MOVED" | grep -q "glepnir/lspsaga.nvim"; then
  echo "✅ lspsaga.nvim detected as moved"
else
  echo "❌ FAIL: lspsaga.nvim NOT detected as moved"
  FAILED=1
fi

# Check Has Issues
if [ "$HAS_ISSUES" == "true" ]; then
  echo "✅ has-issues is true"
else
  echo "❌ FAIL: has-issues is not true"
  FAILED=1
fi

rm "github_repos.txt" "results.json"

if [ $FAILED -eq 0 ]; then
  echo "🎉 ALL TESTS PASSED"
  exit 0
else
  echo "💥 SOME TESTS FAILED"
  exit 1
fi
