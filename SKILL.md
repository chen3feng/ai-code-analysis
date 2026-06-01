---
name: codebase-analysis
description: Systematically analyze a complex codebase and produce deep-dive documentation with clickable source links, pinned by git submodule.
---

# Codebase Analysis Skill

## Purpose

Analyze large, complex codebases and produce a structured **documentation set** that makes the internals accessible. The output is a GitHub Pages-hosted site with:
- Multiple docs organized from overview to deep details
- Every code reference is a clickable link to the exact source line
- Source pinned via git submodule so line numbers never go stale

## When to Use

- You need to understand a large open-source project's internals
- You want to onboard new team members to a complex codebase
- You're evaluating architectural decisions in a dependency

## Core Principles

### 1. Start from the reader, not the code

Each document answers one question:
- "What is this project, why does it exist, and where is it used?" → Project overview & background
- "What are the layers and how do they connect?" → Architecture overview
- "How is the code organized?" → Code structure
- "What happens during startup?" → Initialization flow
- "What happens when processing a request?" → Runtime flow
- "How does the key innovation work at the code level?" → Deep dive

**Always lead with a project overview / background doc.** Before any architecture or code, doc 01 should orient a newcomer: what the project is, the problem it solves, why it exists, who uses it, how it compares to alternatives, and the core ideas the rest of the docs will unpack. This is prose-heavy and light on source links — its job is to build the mental model and motivation that makes the deep-dive chapters land. Do not fold "what is this project" into the architecture doc; give background its own chapter.

### 2. From general to specific

Order documents so each builds on the previous. A reader starting from doc 1 should never encounter unexplained concepts.

### 3. Every claim links to source

No hand-waving. Every class name, function reference, and design claim should have a clickable link to the exact source line.

### 4. Pinned version via git submodule

The analyzed project is included as a git submodule at a specific commit. This guarantees all line numbers remain valid forever.

### 5. Fact-check before publishing

After writing, verify every line-number reference by reading the actual source file at that line. AI-assisted analysis can hallucinate function names, line numbers, and even entire APIs.

## Workflow

### Phase 1: Setup

```bash
# Create the analysis repo
mkdir <project>-analysis && cd <project>-analysis
git init
git submodule add <upstream-repo-url> <submodule-dir>
mkdir docs scripts .github/workflows

# Initialize git identity
git config user.name "..." && git config user.email "..."
```

**Document naming convention**:

```
docs/
├── index.md                      # Pages homepage (nav_order: 1)
├── _config.yml                   # Jekyll config (just-the-docs theme)
├── 01-<project-overview>.md      # nav_order: 2 — what it is, why it exists, where it's used
├── 02-<architecture>.md          # nav_order: 3 — broadest technical view
├── 03-<code-structure>.md        # nav_order: 4
├── 04-<initialization>.md        # nav_order: 5
├── 05-<model-loading>.md         # nav_order: 6
├── 06-<runtime-flow>.md          # nav_order: 7
├── 07-<op-registration>.md       # nav_order: 8
├── 08-<key-algorithm-1>.md       # nav_order: 9
└── 09-<key-algorithm-2>.md       # nav_order: 10
```

Rules:
- `NN-<slug>.md`  — numeric prefix ensures file system order. Jekyll sidebar uses `nav_order` frontmatter.
- **Doc 01 is always a project overview / background chapter** (see Core Principle 1). Architecture and code structure follow it, not lead.
- `index.md` always has `nav_order: 1` and serves as the Pages landing page. **This file is mandatory** — without it, Jekyll cannot generate `index.html` and the site will return 404 at the root URL.
- Each doc must have Jekyll frontmatter:
  ```yaml
  ---
  title: <Short Title>
  nav_order: <N>
  ---
  ```
- Order must be from general to specific — each doc builds on concepts from previous ones.

### Phase 2: Research

For each planned document, use AI agents to explore:

```
Agent prompt pattern:
"I need to understand <specific aspect> in <project>. Explore the codebase at <path>.
Focus on: <key questions>. This is research only - do NOT write code.
Provide exact file paths and line numbers for all classes/methods/definitions."
```

Key research angles:

| Document | Research Question | Key Files to Explore |
|----------|------------------|---------------------|
| Project overview & background | What is this project? Why does it exist? Who uses it? How does it compare to alternatives? What are its core ideas? | README, project homepage, intro/design docs, comparable projects |
| Architecture overview | What are the layers? How do they connect? | Entry points, engine core, main classes |
| Code structure | How is the code organized? Build system? | Top-level directories, CMake/setup.py, C++/Rust code |
| Initialization flow | What happens from entry to ready? | Engine __init__, worker creation, config parsing |
| Runtime flow | One request's full path? | Scheduler, executor, model runner, sampler |
| Model loading | How are weights loaded? | Model loader classes, weight iterators, registry |
| Op registration | Python↔C++ bridge? | TORCH_LIBRARY, torch.library, @triton.jit |
| Key algorithm (e.g. PagedAttention) | How does the core innovation work? | Core kernel files, memory management, CUDA code |

### Phase 3: Writing

For each document, follow this structure:

1. **Overview** — what problem does this solve? Why does it matter?
2. **Architecture / Flow** — the big picture before diving into details
3. **Detailed walkthrough** — step by step through the code, with links
4. **Key file index** — table of all referenced files with line numbers

**Link format**: Use relative paths from docs/ to the submodule. On GitHub Pages, a CI `sed` step converts them to GitHub blob URLs.

```
# Local (works in VS Code):
[name](../vllm/vllm/path/to/file.py#L123)

# CI converts to for Pages:
[name](https://github.com/upstream/repo/blob/<commit>/vllm/path/to/file.py#L123)
```

> The sed pattern must match your document's link format. If `docs/` is at repo root (sibling to the submodule), links look like `](submodule/...` rather than `](../submodule/...`. The sed expression needs to match whatever prefix your docs use.

### Phase 4: Infrastructure

**GitHub Pages workflow** (`.github/workflows/pages.yml`):

```yaml
# Key step: sed rewrite before Jekyll build
- name: Rewrite source links for Pages
  run: |
    COMMIT=$(git ls-tree HEAD vllm | awk '{print $3}')
    BASE="https://github.com/<upstream>/blob/${COMMIT}"
    cd docs
    for f in 0*.md; do
      sed -i \
        -e "s|](../vllm/vllm/|](${BASE}/vllm/|g" \
        -e "s|](../csrc/|](${BASE}/csrc/|g" \
        -e "s|](../setup\.py|](${BASE}/setup.py|g" \
        "$f"
    done

- uses: actions/jekyll-build-pages@v1
  with:
    source: docs
```

> **Note on sed glob**: Use `[0-9]*.md` not `0*.md` — if you have 10+ documents, `0*.md` won't match `10-*.md` etc. The wider pattern `[0-9]*.md` catches all numbered docs.

**Jekyll config** (`docs/_config.yml`):

```yaml
title: <Project> Source Analysis
remote_theme: just-the-docs/just-the-docs
nav_sort: case_sensitive
```

Each doc needs frontmatter for sidebar ordering:

```yaml
---
title: Architecture Overview
nav_order: 2
---
```

### Phase 4b: Troubleshooting Infrastructure

**First-time Pages deployment may fail**. If the Pages site has never been deployed before, `actions/configure-pages@v5` can fail with:

```
Error: Get Pages site failed. Not Found
```

This happens because the Pages site metadata doesn't exist yet. Solution: after the workflow fails, manually re-run it — the second attempt will succeed because the initial failure still registered the site configuration. You can also pre-enable Pages via API:

```bash
gh api repos/<owner>/<repo>/pages -X POST -f "build_type=workflow"
```

**Custom git hooks can interfere**. If your global `.gitconfig` has `core.hookspath` pointing to custom hooks, commands like `git rev-parse --show-toplevel` may return the wrong repository. Symptoms: `git log` shows commits from a different repo, `git remote -v` shows the wrong origin. Fix: use explicit env vars for all git operations:

```bash
export GIT_DIR=/path/to/.git GIT_WORK_TREE=/path/to/repo
```

### Phase 5: Fact-Checking

This is the most important phase. AI-written docs contain errors.

```
For each document:
  1. Extract all <file>:<line> references
  2. Read each source file at that line
  3. Verify the claimed class/function/variable exists there
  4. Flag CRITICAL (fabricated API, wrong line > 50 lines off)
     vs MINOR (off by 1-5 lines, oversimplified pseudocode)
```

**Common error patterns to catch:**
- Functions that don't exist (AI invents convenient API names)
- Line numbers off by 50+ lines (pointing to wrong class entirely)
- Code snippets that differ from actual source (wrong parameters, types)
- Enum values that don't exist in the codebase
- Wrong file paths (e.g. `worker/gpu_worker.py` vs `v1/worker/gpu_worker.py`)

### Phase 6: Publishing

Write a blog post or announcement explaining:
- What you analyzed and why
- What the docs cover
- How they were generated (AI-assisted + fact-checked)

## Quality Standards

### Good signs
- Reader can navigate from high-level to deep detail without gaps
- Every code reference is clickable and verified
- Architecture diagrams (ASCII) show data flow, not just file names
- Tables summarize key decisions with "why" columns

### Bad signs
- Long prose describing what code does without linking to the code
- Duplicating content already in official docs
- Copy-pasting from the original project's README
- No fact-checking pass before publishing

## Traps to Avoid

1. **Don't start writing immediately** — spend significant time exploring first. Understanding the architecture prevents restructuring later.

2. **Don't cover official docs** — if the upstream already explains a concept well, link to it. Focus on implementation details.

3. **Don't trust AI line numbers** — always verify. AI models see approximate line numbers and often hallucinate exact ones.

4. **Don't make docs dependent on external links** — all key content should be self-contained. External links supplement, not replace.

5. **Don't skip the overview** — a good architecture diagram saves hours of confusion. Spend time on it.

6. **One doc, one question** — if a doc tries to answer too many questions, split it. Each doc should have a clear thesis.

## Reference

See [chen3feng/vllm-analysis](https://github.com/chen3feng/vllm-analysis) for a complete example using this methodology.
