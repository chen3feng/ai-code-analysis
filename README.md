# ai-code-analysis

AI-assisted codebase analysis methodology. Turns a complex codebase into a structured, browsable documentation set with clickable source links.

## What This Is

A reusable **skill** and **toolkit** for using AI agents (Claude Code, etc.) to systematically analyze large codebases. Born from the experience of analyzing [vLLM](https://github.com/vllm-project/vllm) — a ~250K line Python/C++/CUDA/Rust project — and producing the [vllm-analysis](https://github.com/chen3feng/vllm-analysis) documentation set.

## Key Ideas

1. **AI explores, human verifies** — AI agents do the heavy research (finding files, reading code, extracting line numbers), but every claim is fact-checked before publishing
2. **Source links that never break** — git submodule pins the analyzed version, all line references are permanent
3. **Local paths for editing, GitHub URLs for browsing** — CI `sed` step converts links automatically
4. **From general to specific** — documents ordered so each builds on the previous

## Files

| File | Purpose |
|------|---------|
| [SKILL.md](SKILL.md) | The full methodology — what AI agents should read |
| [templates/](templates/) | Templates for new analysis projects (README, config, CI) |
| [scripts/](scripts/) | Helper scripts (setup new repo, update submodule) |

## Quick Start

1. Read [SKILL.md](SKILL.md)
2. Copy `templates/` to your new repo
3. Add the target project as a git submodule
4. Start with the architecture overview, then work through each doc
5. Fact-check before publishing

## Example

[vllm-analysis](https://github.com/chen3feng/vllm-analysis) — 8 documents analyzing vLLM internals, from architecture overview to CUDA kernel walkthroughs. Includes GitHub Pages with search and navigation sidebar.

## License

MIT
