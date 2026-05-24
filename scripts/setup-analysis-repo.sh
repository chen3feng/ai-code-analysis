#!/bin/bash
# Initialize a new codebase analysis repository
set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <analysis-repo-name> <upstream-repo-url> [submodule-dir]"
    echo "Example: $0 vllm-analysis https://github.com/vllm-project/vllm.git vllm"
    exit 1
fi

REPO_NAME="$1"
UPSTREAM_URL="$2"
SUBMODULE_DIR="${3:-$(basename "$UPSTREAM_URL" .git)}"

mkdir "$REPO_NAME" && cd "$REPO_NAME"
git init
git submodule add "$UPSTREAM_URL" "$SUBMODULE_DIR"

mkdir -p docs .github/workflows scripts

# Copy templates
cp "$(dirname "$0")/../templates/README.template.md" README.md
cp "$(dirname "$0")/../templates/pages-workflow.yml" .github/workflows/pages.yml
cp "$(dirname "$0")/../templates/config.yml" docs/_config.yml

echo ""
echo "Analysis repo '$REPO_NAME' initialized."
echo "Next steps:"
echo "  1. Update templates with project-specific values (search for <...> placeholders)"
echo "  2. Create docs/index.md (Pages homepage)"
echo "  3. Start researching: architecture overview first"
echo "  4. Write docs in order from general to specific"
echo "  5. Fact-check all line numbers before publishing"
