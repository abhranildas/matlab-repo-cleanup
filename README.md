# matlab-repo-cleanup

A Claude Code plugin for cleaning up a whole MATLAB repo in six stages, tracked in one plan document (`docs/repo-cleanup.md`):

| # | Stage | What changes | How it's verified |
|---|---|---|---|
| 1 | **Style** | snake_case renames, header docs, formatting | Parse tree unchanged once renames are reversed (`tools/check_stage1.m`) |
| 2 | **Hygiene** | Four whitelisted fixes: missing `;`, `find` → logical indexing, preallocation, unused assignments | Pattern check plus a golden-output harness |
| 3 | **Organize** | Signature changes, merging duplicates, reorders | Reviewed one item at a time |
| 4 | **Bugs** | Bug fixes found during stages 1–3 | Reviewed one item at a time |
| 5 | **Speed** | Optimizations | Golden output plus before/after timings |
| 6 | **Closing** | Nothing new: a final repo-wide check | Re-runs the stage 1–2 checks across the whole repo |

Stages 3–5 are findings lists rated 🔴/🟠/🟡. Anything found earlier is written down, not fixed on the spot.

It ships the `matlab-repo-cleanup` skill and five subagents (`matlab-cleanup-lead`, `-mechanical`, `-escalation`, `-stage3`, `-stage3-mechanical`).

## Install

In Claude Code:

```
/plugin marketplace add abhranildas/matlab-repo-cleanup
/plugin install matlab-cleanup@abhranildas
```

Then ask Claude to "clean up this MATLAB repo", or run `/matlab-cleanup:matlab-repo-cleanup`.

## Update

Updates are not automatic for third-party marketplaces unless you turn them on under `/plugin` → Marketplaces. To update by hand:

```
/plugin marketplace update abhranildas
/reload-plugins
```

## Requirements

MATLAB (the checker uses the undocumented `mtree` / `tree2str`; pin the MATLAB version you verify with).

## Note

The skill encodes its author's working conventions: it commits each verified step but never pushes, and it allows a few quick read-only MATLAB checks to run headlessly without asking. Edit `skills/matlab-repo-cleanup/SKILL.md` if yours differ.
