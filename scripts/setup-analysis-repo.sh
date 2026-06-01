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
TEMPLATE_DIR="$(dirname "$0")/../templates"

mkdir "$REPO_NAME" && cd "$REPO_NAME"
git init
git submodule add "$UPSTREAM_URL" "$SUBMODULE_DIR"

mkdir -p docs/_includes .github/workflows scripts

# Copy templates
cp "$TEMPLATE_DIR/README.template.md" README.md
cp "$TEMPLATE_DIR/pages-workflow.yml" .github/workflows/pages.yml
cp "$TEMPLATE_DIR/config.yml" docs/_config.yml
cp "$TEMPLATE_DIR/index.md" docs/index.md
# Visitor counter (GoatCounter), injected into every page by just-the-docs
cp "$TEMPLATE_DIR/head_custom.html" docs/_includes/head_custom.html
cp "$TEMPLATE_DIR/footer_custom.html" docs/_includes/footer_custom.html

echo ""
echo "Analysis repo '$REPO_NAME' initialized."
echo "Next steps:"
echo "  1. Update placeholders (<...>) in README.md, docs/index.md, docs/_config.yml, .github/workflows/pages.yml"
echo "  2. Set your global GoatCounter code (<GOATCOUNTER_CODE>) in docs/_includes/{head,footer}_custom.html"
echo "  3. Start with 01-<project-overview>.md, then 02-<architecture>.md"
echo "  4. Follow the doc numbering convention: 01-, 02-, ... 0N-"
echo "  5. Each doc needs YAML frontmatter: title + nav_order"
echo "  6. Fact-check all line numbers before publishing"
