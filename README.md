# matlab-repo-cleanup

A Claude Code plugin for cleaning up a whole MATLAB repo in six stages, tracked in one plan document (`docs/repo-cleanup.md`):

1. **Style**: snake_case renames, headers, formatting. Verified automatically: the parse tree must be unchanged once renames are reversed (`tools/check_stage1.m`).
2. **Hygiene**: four whitelisted fixes, verified against a golden-output harness.
3. **Organize**, 4. **Bugs**, 5. **Speed**: tiered findings lists, worked one item at a time.
6. **Closing**: a final repo-wide check.

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
