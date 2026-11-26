---
name: matlab-repo-cleanup
description: Procedure for a whole-repo MATLAB cleanup in six named stages, tracked in a single plan document — Style and Hygiene (a mechanically-verified behaviour-preserving readability pass) first, then Organize, then Bugs, then Speed, then a final Closing check. Covers renaming variables, functions, scripts and files to snake_case, harmonizing naming patterns repo-wide, and scanning for optimizations. TRIGGER whenever the user asks to clean up, tidy, refactor for readability, rename/document/reflow, rename files or functions, harmonize naming conventions, speed up or optimize, or "do a readability pass" on a MATLAB repo or a large part of one; also when they ask to write or update a repo-cleanup plan, or to resume one already in progress.
---

# MATLAB repo cleanup

One repo, one plan document (`docs/repo-cleanup.md`), six stages of change. The point of the staging is that the first phase is **behaviour-preserving and mechanically checkable**, so its diff — which will be enormous — does not have to be trusted, only verified. Organizational changes, bug fixes, and optimizations are not forbidden; they are the *later* stages, done after the verified pass, one at a time. The last stage is a single closing gate, not a findings list.

Do not start editing files. Survey first, write the plan, get the user's sign-off on the staging and the tranche plan, then work tranche by tranche.

## The six stages

Each stage has a one-word name; use it in conversation, in commit messages, and in the plan, alongside the number.

| Stage | Name | Change | Canonical diff | Verification |
|---|---|---|---|---|
| **1** | **Style** | Comments, header docs, whitespace, operator and bracket spacing, indentation, reflow, blank-line grouping, file-local renames, **function and file renames** (own repo-wide tranche, step 2a), triaging commented-out code (verdicts only, no deletion) | empty (after reverse rename) | `isequal` on an AST fingerprint — fully automatic, no execution |
| **2** | **Hygiene** | Adding a suppressing `;`, preallocation, `find`→logical indexing, deleting a provably unused assignment | non-empty, must match a whitelisted pattern | pattern check **plus** runtime golden output |
| **3** | **Organize** | Signature changes, `arguments` blocks, merging duplicate functions, reordering statements, changing float accumulation order, anything touching the RNG stream, renaming a config struct field or a frozen `save`/`load` name, acting on the Stage 1 triage of commented-out code — each item carrying a cost/benefit tier | — | not mechanically checkable; reviewed and done individually, after 1/2 |
| **4** | **Bugs** | Bug fixes found anywhere during 1/2/3, each carrying a severity | — | not mechanically checkable; reviewed and fixed individually, after 3 |
| **5** | **Speed** | Optimizations found anywhere during 1/2/3/4, each carrying a risk/benefit tier | — | output equality against the golden harness **plus** a measured before/after timing; done last |
| **6** | **Closing** | No findings of its own — a fixed, four-item gate confirming 1 through 5 actually hold across the whole repo at once, not just per tranche or per item | — | re-runs the existing Stage 1/2 checks repo-wide, confirms every 🔴 item in sections 0.3–0.5 is closed, and re-checks section 2 against current state |

Semicolon insertion is Stage 2 and not Stage 1 because `tree2str` preserves display-vs-suppress: the canonical diff is exactly `X` → `X;`. Trivially whitelisted, but not invisible.

Statement reordering is Stage 3 even when it looks purely cosmetic — not because it's dangerous in principle, but because the check cannot distinguish a safe reorder from an unsafe one.

Speed is its own stage rather than a corner of Organize because the two have different verification: an Organize item is reviewed and reasoned about, while a Speed item is not done until a stopwatch says it worked. It runs **after** Bugs, and that order matters in both directions — optimizing code that is still wrong can freeze the wrong output into the golden reference, and a bug fix sometimes dissolves the optimization outright, because the redundant work *was* the bug. Speed last also makes it the stage that can be dropped without touching anything else.

**When the pass uncovers a bug, an optimization, or an organizational opportunity — and it will — record it in the plan's findings list and do not act on it.** The recording is what survives; the change comes later, as a Stage 3, Stage 4, or Stage 5 item respectively. Organizational cleanups, bugs, and optimizations get three separate lists so that none of them is ever lost inside another. This is the single rule most likely to be violated under pressure, and an "easy" fix or optimization spotted mid-tranche is the most tempting way to violate it.

**All three lists rate their items on the same three-colour scale** — 🔴 highest, 🟠 middle, 🟡 lowest — and encode it in the item's id: `O<tier>.<n>` for Organize (section 0.3), `B<severity>.<n>` for Bugs (section 0.4), `S<tier>.<n>` for Speed (section 0.5). (This is not a stage number — a stage is always spelled out, "Stage 1", never abbreviated "S1".) The number runs 1 (🔴) to 3 (🟡); `n` counts items at that tier in the order found. The emoji leads the item, before the id — an emoji rather than an inline `style` attribute, because GitHub and most previewers strip inline CSS but all of them render emoji, so the colour survives everywhere instead of degrading to plain text on the harder renderer.

Each list is one flat sequence, sorted by tier first and discovery order second — every 1, then every 2, then every 3 — and that is also the order it is worked in. A newly found item takes the next `n` for its tier and is appended to that tier's run; nothing already recorded gets renumbered. If an item's tier turns out to have been misjudged once work starts, re-file it under the correct tier's next `n` — a new id, not a relabel of the old one.

**What the tier means differs by list, because each list rates something different — but in every list it is one overall judgement call, not a formula to plug numbers into:**

**Bugs (0.4) — how bad, if left unfixed:**

| severity | id prefix | marker | meaning |
|---|---|---|---|
| highest | B1 | 🔴 | Silently wrong results on a path that has actually been run — published numbers may be affected. |
| middle | B2 | 🟠 | Reachable, but not silent: it errors out, or it only touches plots, logging, or display. |
| lowest | B3 | 🟡 | Latent — not reachable with the current config or inputs, but would bite a plausible future use. |

**Organize (0.3) — overall cost/benefit, weighed together:**

| tier | id prefix | marker | meaning |
|---|---|---|---|
| highest | O1 | 🔴 | Clear benefit for modest, well-understood effort and low risk of breaking anything — an obvious duplicate to merge, a signature that's plainly wrong. Do first. |
| middle | O2 | 🟠 | Worth doing, but with a real cost: a genuine design decision to make, a large call-site surface, or a benefit that's real but not urgent. |
| lowest | O3 | 🟡 | Marginal benefit, high effort or risk, or a decision better made once more of the repo has settled. A candidate to defer or drop, not an obligation. |

**Speed (0.5) — overall risk/benefit, weighed together, where risk means how much has to be true before the change can be trusted:**

| tier | id prefix | marker | meaning |
|---|---|---|---|
| highest | S1 | 🔴 | A large expected or measured win at low risk — provably output-identical, or a gain big enough that an explicit tolerance decision is a formality. Do first. |
| middle | S2 | 🟠 | Worth doing, but with a real cost: either the gain is only moderate, or it's large but perturbs float accumulation, RNG draw order, or `parfor` reduction order, and needs an explicit tolerance decision from the user before it can be trusted. |
| lowest | S3 | 🟡 | Small, speculative, or unverified — a loop that only *looks* hot, or a real but marginal win that may not be worth the diff. Most items start here, since most optimizations are recorded before anything is measured. |

**Every rating is a joint call, weighing both halves together — not a single-axis lookup.** A large, safe win is a 1. A large, risky win and a small, safe win both land at 2, for different reasons. A small, risky, or entirely unmeasured item is a 3. Say which factor drove the call in the item's write-up — two optimizations with the same measured speedup can land in different tiers if only one is provably safe; two organizational items of the same size can land in different tiers if only one still needs the user's input. Most "easy optimizations" in this ecosystem are guesses about which loop dominates, in image and training loops where guessing wrong costs days of the user's time for no gain — that uncertainty about the benefit is itself enough to keep an item at S3 until it's profiled, however large the potential payoff looks on paper.

## Committing

Every step of every stage ends in its own commit, made as soon as that step is verified — a Stage 1 or Stage 2 tranche, a single Stage 3 item, a single Stage 4 fix, a single Stage 5 optimization, even the tooling setup in step 1. Never batch several steps into one commit, and never leave a finished, verified step sitting uncommitted while work moves on to the next one: the commit history is the second copy of the plan's record, and it should let someone reconstruct what changed and why without re-reading the diff.

The message states what stage and step it is, by number and name, and what changed — for a Stage 1/2 tranche, the checker result and the MATLAB version; for a Stage 3/4 item, the plan item number and a one-line account of the change; for a Stage 5 item, the before and after timings. Match this repo's existing commit-message style if it already has cleanup commits.

**Commit, never push.** Pushing stays the user's call, always — this authorization covers committing a verified step, nothing more.

This binds every subagent dispatched under this skill, not just the orchestrator: finish the step, verify it, tick it in the plan, then commit before reporting back. An agent working solo with no orchestrator follows the same rule.

## Step 0 — survey, and measure everything

Every number in the plan must be measured on the repo as it stands, never estimated. Record the MATLAB version. Collect:

- **Scope.** Which directories are in, which are out (vendored code, ancestral copies, gitignored reference trees). Give file and line counts per directory.
- **Lint.** `checkcode` across all in-scope files; count messages and how many files are clean.
- **Formatting.** Tab-indented files; files with no header comment; files with any line over 100 characters (and the worst offender, with its line number). Also sample how inconsistent the spacing is — `a=[1,2,3]` vs `a = [1, 2, 3]` style — since that sets how much of step 2b each tranche is carrying. `grep -c '[A-Za-z0-9_)\]]=[^=]'` over the tranche gives a rough count of unspaced assignments.
- **Header docs.** How many files have an `Inputs`/`Output` block; how many have a `See also`; whether any `Contents.m` exists.
- **Names, inside files.** Occurrence counts for the repo's heavily-abbreviated identifiers. This is usually the real problem, and the counts tell you which renames are worth doing.
- **Names, of files.** List every `.m` file and judge the name, not just the contents — this is the survey's job and nothing later will do it for you. Flag: camelCase or `TitleCase` filenames; names that don't say what the file does (`test2.m`, `run_it.m`, `local_show_pair.m`); a verb-less name for something that acts, or a verb for something that just returns a value; abbreviations not used anywhere else; a stage or version number baked into the name where the pattern isn't consistent across its siblings (`plot_stage3.m` next to `plot_stage6_pairs.m`); a filename that disagrees with the `function` line inside it. Group them into families and note where each family's pattern breaks — the point is harmonizing a pattern, not renaming one file at a time.
- **Casing census.** Count files and identifiers by casing style, so the split is a number and not an impression: `git ls-files '*.m'` bucketed into snake_case / camelCase / other, and the same for assignment targets (`grep -ohE '^\s*[A-Za-z][A-Za-z0-9_]*\s*=' | grep -c '[a-z][A-Z]'` gives a rough camelCase-variable count). **The target is snake_case everywhere** (step 2), so this number is the size of that job.
- **Convention splits.** e.g. a snake_case repo with one camelCase subdirectory.
- **Builtin shadows.** Parameters or variables named `image`, `diff`, `sum`, …
- **Commented-out code.** Count the lines *and* locate the blocks — file, line range, rough size. This is a rough pass only, to size the work; the real triage, block by block, happens inside Stage 1 (step 2c) when each file is actually being read. Do not delete, and do not judge yet.
- **Argument validation.** Whether `arguments` blocks or `inputParser` appear anywhere.
- **Performance shape.** See below — this is a scan, not a judgement.

### Scanning for optimizations, during the survey

The survey is the only moment the whole repo is read with fresh eyes, so it is where optimization candidates get found. It is **not** where they get judged, and never where they get made. Every hit is recorded as an `S<tier>.<n>` item in section 0.5 and left alone until Stage 5.

Scan for these, and report each as a count with locations — not as a verdict:

- **Work inside a loop that doesn't depend on the loop.** A recomputed constant, a `size`/`numel` of something unchanging, a filter or grid rebuilt every iteration, a struct field looked up repeatedly. The commonest real win, and the commonest one that is provably output-identical.
- **File I/O inside a loop.** `load`, `imread`, `save`, `dir`, or `exist` in a loop body, especially loading the same file each pass. Usually dominates everything else in the loop.
- **`inv`, `pinv`, or `det` where a solve would do.** `inv(A)*b` → `A\b`. Faster *and* better conditioned, so this one is also a numerical-accuracy finding.
- **Growing arrays** beyond what Stage 2 already covers — growth in a nested loop, or of a large array, where preallocation needs a size that isn't known until a pre-pass.
- **Whole-array recomputation** where an incremental update exists, and repeated identical calls to a pure function with the same arguments.
- **Loops that are plainly elementwise** over an array MATLAB would vectorize, and `parfor` candidates — an independent-iteration loop over images or conditions that is still serial.
- **Existing `parfor` loops** that the step-1 check found writing to a reduction variable rather than a sliced output.

Then record two things about the repo as a whole, because they set what any of the above is worth:

- **Is there any timing data at all?** A `tic`/`toc` already in the code, a logged runtime, a note in a README, or the user's own sense of which stage is slow. Usually the answer is no — write that down, because it is why most items start at S3.
- **Where does the wall-clock actually go?** If the user knows, record it. If nobody knows, say so plainly rather than inferring it from loop nesting depth.

A survey that finds no optimization candidates says so explicitly, naming the patterns checked — a documented negative, same as everywhere else in this procedure.

**Find the style target; do not invent one.** Look for the best-documented existing file in this repo or a sibling lab repo (see the `repo-map` skill) and name it in the plan as the exemplar. In this ecosystem that is `vislab-common/+vislab/+lib/watson_otf.m`: summary line, fully-qualified signature, `Inputs`/`Output` with units, `See also`.

Also check that no in-scope file shares a name with something in a sibling repo or an ancestral-code directory — that trap means you might be polishing a file that is already superseded elsewhere.

## Step 1 — build the tooling before touching any file

Copy `tools/canon.m`, `tools/check_stage1.m`, and `tools/assert_rename_bijection.m` from this skill into the repo's `tools/`. They are repo-agnostic. Verify `canon` succeeds on every in-scope file before relying on it — a parse failure on one file means that file needs a different verification route.

`canon` is `tree2str(mtree(file,'-file'))`: MATLAB's own parser, printed back canonically with comments stripped, whitespace and bracket spacing normalised, and missing `end` supplied. It is blind to exactly what Stage 1 may change and sensitive to everything else. Both are undocumented APIs, so pin the MATLAB version in every commit that depends on the check.

`check_stage1(old, new, renames)` reverses the rename map on `canon(new)` and asserts equality with `canon(old)`. The negative lookahead in its regex matters: without it, a short name (`patch`) matches inside a longer one (`patch_size`). `assert_rename_bijection` runs first, because a scope-blind map with a name on both sides (`a→b` and `b→c`) can turn a real change into a false pass.

**Then the golden harness**, for Stage 2. Copy `tools/golden_harness_template.m` and fill in this repo's entry points. Rules that carry over:

- Call entry points **directly**, never through the repo's top-level demo/driver script, which usually seeds with `rng('shuffle')` on some path.
- Seed explicitly with the config's own seed before every entry point.
- Reduce each output to a checksum or a size vector, not the whole array, so the golden `.mat` stays small.
- Reduce with an explicit `'all'`. `sum()` over a cell array from `cellfun` collapses only one dimension and will silently hand you a row vector where you expected a scalar.
- Gate toolbox-dependent entry points on `exist(...)` and warn rather than error.
- Some files will have no callable entry point — a script whose logic lives in local functions. Restructuring it into functions is itself Stage 3, so **decide explicitly** that this file's Stage 2 edits are verified by pattern check only, and write that decision into the plan.

**Check the `parfor` loops** while you're here. If they all write into a sliced output rather than a reduction variable, worker order cannot change a float sum and they are safe to leave alone. Record that finding; an edit that later turns one into a reduction is Stage 3.

## Step 2 — the rename map, in three zones

The rename map is the pass's most valuable artifact and its main divergence risk. Build it first, once, repo-wide, before any tranche.

**snake_case, always.** Every variable, function argument, function, script and filename this repo owns is `lower_snake_case`. Not `camelCase`, not `TitleCase`, not `abbrv`.

snake_case is a rule about *casing*, not about length: it says how to join words that are already there, not to manufacture words. If one word says it, one word is the name — `sigma`, `radius`, `gain`, `contrast`. Never pad a name to make it look like the convention, and never stack qualifiers a reader doesn't need (`image_patch_size_in_pixels` where `patch_size` plus a unit in the header does the job). The shortest name that is unambiguous in its scope wins; expanding an abbreviation is for names that are actually unreadable, not for names that are merely short.

The casing rule is the user's standing preference, so it is not a per-repo judgement call and not a majority vote — a repo that is 90% camelCase still gets converted, and if that's the case, say so in the plan and size it, don't quietly adopt the local style. Three things are **not** ours to rename, and are not exceptions to be argued but hard boundaries:

- Names MATLAB or a toolbox defines: builtins, name-value option strings (`'LineWidth'`, `'FontSize'`), and fields of structs returned by external code (`Screen`, `imfinfo`, `fitrgp`). Leave the casing exactly as the external API spells it.
- Zone-3 frozen names (below): anything in a `save`/`load` string.
- Class names, if the repo has any — MATLAB's own convention is `TitleCase` there, and `classdef` renaming is Stage 3 anyway.

1. **File-local variables — free.** `canon` makes these completely safe. Convert to snake_case, expand the abbreviations, name the loop counters for what they index, and fix the builtin shadows.
2. **Cross-file vocabulary — repo-wide, or not at all.** Three kinds: function and file names (checkable, and therefore Stage 1 — **step 2a**); function arguments named consistently across the repo; and the config struct's field paths (renaming one touches the config file plus every reader, and `check_stage1` can't see it — **deferred to Stage 3**). The middle one is high value because it's everywhere, but a half-done rename is worse than none.
3. **Serialised variable names — frozen.** Any name appearing in a `save`/`load` string, because shipped `.mat` artifacts depend on it. Enumerate these explicitly in the plan. A local variable that *holds* one of these can be renamed; the string literal cannot. Watch for a name that is frozen in one file and free in another.

**Units are the other half of naming.** State them in every header: pixels vs. degrees, mm, nm, "integer divisor, not degrees". A name plus a unit is the whole job.

## Step 2a — function and file names, in one repo-wide tranche

A file rename is a function rename in MATLAB: dispatch is on the filename, so `git mv foo.m bar.m` *is* the rename, and the `function` line inside is cosmetic documentation that must be made to agree with it. Fix the filename and the `function` line together, always.

**This is Stage 1, not Stage 3.** A function name is a bare identifier, so `check_stage1`'s reverse-rename regex covers it at every call site — unlike a config struct field, which the regex deliberately excludes as dot-qualified (`check_stage1.m:30`). That single difference is the whole reason config fields wait for Stage 3 and function names don't. The rename is as mechanically verifiable as renaming a loop counter; it is just verifiable over more files.

**It goes early — its own tranche, immediately after tooling and before the convention-setting tranche.** Every later tranche writes headers, `See also` lines, and `Contents.m` entries that name other files. Rename after those are written and you rewrite them all; rename first and every tranche sees final names. This tranche is also the one exception to the "edit nothing outside your file list" rule: its file list is the whole repo, because call sites are everywhere. Its *permitted edit* is correspondingly narrow — `git mv`, the `function` line, call sites, and references in comments and docs. Nothing else. No reflow, no headers, no spacing; those come later, per tranche.

**Harmonize patterns, don't rename one file at a time.** Decide the family rule, then apply it to every member: one verb vocabulary (`plot_*` or `show_*`, not both), consistent ordering of what-then-qualifier (`plot_stage3` and `plot_stage6_pairs` either both carry the stage first or neither does), and the same noun for the same thing as the code uses internally. Write the rule next to the map in the plan, so the next repo can be judged against it.

**The map.** One table, built once: old filename → new filename → the reason. Before committing to a new name, check it doesn't collide:

```bash
"<matlab>" -batch "disp(which('<new_name>', '-all'))"   # must be empty, or only the file being renamed
```

A name that shadows a builtin or a sibling-repo function is worse than the bad name it replaces.

**Verifying it.** Run `check_stage1(old, new, renames)` over **every file in the repo**, not just the ones whose text changed, with the function-name map as `renames`. A file that legitimately changed nothing passes trivially; the ones that matter are the callers. For a renamed file, the baseline `old` is the pre-`git mv` content, so take a copy of it under the old path before moving — `git show HEAD:<old_path>` if it's clean, a pre-edit backup if not.

**Four things the check cannot see.** Each needs its own sweep, and each gets stated in the tranche's findings-log entry:

1. **Package-qualified call sites.** In `vislab.lib.watson_otf(...)` the final name is preceded by a `.`, so the negative lookbehind at `check_stage1.m:30` refuses to reverse-rename it and the check **fails on a correct edit**. Do not loosen the regex. Either keep packaged functions out of this tranche, or verify those specific files by reading the diff and say in the log that you did.
2. **References outside `.m` files.** READMEs, the plan document itself, `.mlx` live scripts, shell or batch launchers, and any data filename derived from a function name. No AST sees these. Grep the whole repo for each old name, including non-`.m` files, and fix or record every hit.
3. **Dynamic references.** `feval('foo')`, `str2func('foo')`, `exist('foo')`, `which('foo')`, `help foo`. These survive the round-trip as string literals, so the check does pass — but only if you actually updated them. Grep for each old name as a quoted string separately from grepping it as an identifier.
4. **Case-only renames on Windows.** `git mv foo.m Foo.m` is a no-op or an error on a case-insensitive filesystem. Go through a temporary name: `git mv foo.m tmp_foo.m && git mv tmp_foo.m Foo.m`. Since the target is snake_case, this comes up when only capitalisation is wrong.

Use `git mv`, never delete-and-create, so history follows the file.

**What still waits for Stage 3:** renaming a config struct field, renaming a frozen `save`/`load` name, and any rename that also changes a signature — argument order, argument count, or merging two functions into one. A rename tangled up with a signature change is not a rename.

## Step 2b — harmonize the formatting

Renaming is only half of readability; the other half is that the code should *look* written by one person. Do this in the same edit as the renames, in every Stage 1 tranche.

All of it is free. `tree2str` normalizes whitespace and bracket spacing and strips comments, so every rule below is invisible to `canon` — a pure-formatting change comes back byte-identical with an empty rename map. That includes changes that look structural: splitting `a = 1; b = 2;` onto two lines, or expanding `try, web(url); catch, end` into a normal multi-line `try`/`catch`, both round-trip clean.

**Spacing.**

- `=` always spaced. `a = [1, 2, 3]`, never `a=[1,2,3]`.
- Space after a comma, never before. `f(x, y)`, `[1, 2, 3]`, `A(row, col)`.
- Binary operators spaced: `a + b`, `n - 1`, `x == y`, `p && q`.
- Unary minus tight: `-x`, `[-1, 2]`.
- Tight for `^`, `.^`, `:` and transpose, where the operands are simple: `x^2`, `1:n`, `A(2:end, :)`, `A'`. A spaced colon reads as a typo in MATLAB.
- No space just inside a bracket or paren: `[1, 2]` not `[ 1, 2 ]`; `f(x)` not `f( x )`.
- No space between a function name and its `(`.
- No space before `;`. No trailing whitespace on any line. File ends with exactly one newline.

**Indentation.** Four spaces per level, never tabs, including the function body. Continuation lines after `...` get a four-space hanging indent from the statement's own indent — pick that over aligning under the opening delimiter, because alignment breaks every time the line above is renamed.

**Comments.** One space after the `%`: `% comment`, not `%comment`. An inline comment gets two spaces before it: `x = 1;  % why`. Keep whatever section-separator rule the repo already uses (`% ---…`) and make its width consistent.

**Statements.** One per line. The one exception worth preserving is a tightly-paired assignment the repo already writes on one line, separated by two spaces — `itype = 2;  db_name = 'Fabric';` — where the pairing is the point. Apply the same judgement to one-line `if cond, x = a; else, x = b; end`: keep it where it's already used and reads well, but make the choice consistent within a file.

**Blank lines.** One between logical blocks; never two; none immediately after a function signature's header comment block or at the end of a body.

**Two things not to reformat:**

- **Inside a string literal.** `error('a=1 is required')` keeps its spacing. `canon` will catch it if you slip, but don't spend the cycle.
- **`%#ok<...>` pragmas.** Leave the pragma and its position alone; it binds to the line it sits on.

## Step 2c — triage commented-out code, in the same tranche that touches the file

Do this as part of every Stage 1 tranche, for any block the survey located inside that tranche's files — not as a separate pass later. This is triage only: **it writes a verdict, it deletes nothing.** A verdict is prose, so it's invisible to `canon` and doesn't cost the tranche its Stage 1 status; deleting or converting the block is a real change and stays out of scope here, deferred to Stage 3.

Doing this now rather than in Stage 3 closes a real gap: `check_stage1` strips comments before comparing, so it cannot tell "this block is still here" from "Stage 1 silently dropped it." Triaging each block at the moment its file is being read — before any edit to that file happens — means the block is never at risk of disappearing unassessed between the survey and the judgement.

Work out what a block was for **by reading the code around it**: what the live code next to it now does, whether the commented lines compute the same thing a different way, which variables they reference and whether those still exist, whether they are a debug print or a plot, whether they are a complete working alternative or a half-written sketch. Do not lean on `git log` or `git blame` — the history in these repos was not written with this question in mind, and a commit message saying "cleanup" tells you nothing. The code itself is the evidence. Write one verdict per block into the tranche's Stage 1 findings-log entry, with the reasoning:

| verdict | what it looks like | action (deferred to Stage 3) |
|---|---|---|
| **superseded** | the live code beside it does the same job, better; name that live code in the verdict | delete |
| **scaffolding** | a stray `disp`, `figure`, `plot`, `tic`/`toc`, or `keyboard` left from debugging | delete — or promote to a real debug flag if it is genuinely useful |
| **alternative** | a different method, parameter set, dataset, or path that the author switched away from and could switch back to | **keep, but convert**: either promote it to a documented option, or move the idea into the header docs as prose — "an earlier version used X; switched to Y because Z". Not left as dead code, and not silently lost. |
| **unfinished** | a sketch of something never completed | keep, rewritten as a prose TODO rather than as fake code |
| **unknown** | the purpose is not recoverable from the surrounding code | **leave it exactly as it is**, and say so in the verdict. This is the default whenever the evidence runs out. |

**Unknown is the default whenever the evidence runs out.** Say "I can't tell" freely — an honest *unknown* costs a few commented lines, while a wrong *superseded* destroys the only copy of code that was written commented-out and so was never live, meaning it is nowhere in the history to recover from.

If a tranche's files carry no commented-out blocks, its findings-log entry says so explicitly — same as any other documented negative.

## Step 3 — tranche and sequence

Batch by directory, but size the batches by lines, not files — a repo where 18 files are under 30 lines and five files hold a third of the code needs very different budgets per tranche.

Sequencing rules:

- **Tooling first** (tranche 0), because everything else trusts it.
- **The function-and-file rename tranche goes second** (step 2a), before any file is reflowed or documented, and gets the strongest model. It is repo-wide by nature and cannot run in parallel with anything.
- **The tranche that sets in-file naming conventions goes third**, and gets the strongest model. Its decisions bind every later tranche.
- **Clean helpers before their callers.**
- **A one-decision-applied-N-times tranche** (a camelCase subdirectory, say) is cheap regardless of size.
- **The config file and the user-facing driver go late**, and get the strongest model.
- **Large exploratory files with no callers go last.**

Do any housekeeping — filename-conflict copies, files sitting in the wrong directory — in the tooling commit, before the first tranche starts.

**Escalation rule, any tranche:** if the check fails and the cause isn't obvious from the diff, stop. Don't retry with a bigger prompt, and above all don't loosen the check. Hand that one file to `matlab-cleanup-escalation`.

**"Done" checklist for a Stage 1 tranche:**

- [ ] `check_stage1` true for every file in the tranche.
- [ ] Every file has a header matching the exemplar's shape: summary, signature, `Inputs`/`Output` with units, `See also`.
- [ ] Every identifier the repo owns is snake_case — no camelCase variable, argument, or filename left, except the external-API and frozen names listed in step 2.
- [ ] Each file's `function` line agrees with its filename.
- [ ] Formatting harmonized per step 2b: spacing around `=` and binary operators, space after commas, no space inside brackets, 4-space indent, no tabs, no trailing whitespace.
- [ ] No line over 100 characters except documented exceptions — record each one and why. The usual legitimate reason is an unbreakable string literal, since splitting it into a `horzcat` is a real AST change that Stage 1 forbids.
- [ ] No frozen identifier renamed, no `save`/`load` string literal changed.
- [ ] Each package touched has a `Contents.m`.
- [ ] Every commented-out block in the tranche's files has a verdict per step 2c, and nothing was deleted or converted on the strength of it.
- [ ] Bugs found are written down and **not** fixed; optimizations spotted are written down as `S<tier>.<n>` items and **not** made.

Commit per the Committing section above: one commit per tranche, stating the checker result and the MATLAB version.

## Dispatching tranches (orchestrator only)

**This section is for the top-level orchestrator, not for the tranche agents.** If you were spawned as `matlab-cleanup-lead`, `-mechanical`, `-escalation`, `-stage3`, or `-stage3-mechanical`, you are the worker: do the tranche yourself and **never spawn a further subagent**. Skip to step 4.

**Stage 4 (Bugs) and Stage 5 (Speed) are never auto-dispatched.** The user launches each bug fix and each optimization manually, at their own pace — do not spawn any agent against section 0.4 or 0.5 on your own initiative, and do not tag those items with an agent assignment in the plan. Everything below in this section is about Stage 1/2 tranches and Stage 3 items only.

**Orchestrator: do not execute tranches yourself.** Each row of the plan's tranche table names an agent; dispatch that row to that agent with the Agent tool. You stay the orchestrator: you hold the plan, you sequence, you keep the user informed, and you never accumulate 1400 lines of someone else's `pipeline/` in your own context.

**The dispatch call must set `subagent_type` to the exact agent name — never omit it.** Leaving `subagent_type` unset does not error and does not fall back to any row in the table; it silently runs as generic `general-purpose`, which inherits the orchestrator's own model and effort and skips that agent's file entirely. The call still succeeds and the tranche still gets done, just on the wrong, more expensive model with none of the agent-specific instructions — so this failure is easy to miss unless you check. This skill ships as the `matlab-cleanup` plugin, so its agents are registered with the plugin prefix, `matlab-cleanup:<agent>`. If they were instead copied by hand into `~/.claude/agents/`, drop the prefix. Either way, copy the name exactly as it appears in your list of available agent types. Every dispatch in this procedure looks like:

```
Agent({ subagent_type: "matlab-cleanup:matlab-cleanup-mechanical", model: "sonnet", prompt: "..." })
Agent({ subagent_type: "matlab-cleanup:matlab-cleanup-lead", prompt: "..." })
```

| agent | `subagent_type` value | model / effort | pass `model:` in the call? | for |
|---|---|---|---|---|
| `matlab-cleanup-lead` | `"matlab-cleanup:matlab-cleanup-lead"` | opus / medium | **yes — `model: "opus"`** | the function-and-file rename tranche (step 2a), the convention-setting tranche, the config file, the user-facing driver |
| `matlab-cleanup-mechanical` | `"matlab-cleanup:matlab-cleanup-mechanical"` | sonnet / medium | **yes — `model: "sonnet"`** | tranches that are mechanical once the rename map exists |
| `matlab-cleanup-escalation` | `"matlab-cleanup:matlab-cleanup-escalation"` | opus / high | **yes — `model: "opus"`** | one file whose check fails inexplicably |
| `matlab-cleanup-stage3` | `"matlab-cleanup:matlab-cleanup-stage3"` | opus / high | **yes — `model: "opus"`** | one Stage 3 item that needs a design decision, touches irreversible/high-stakes state, or carries per-instance safety judgment |
| `matlab-cleanup-stage3-mechanical` | `"matlab-cleanup:matlab-cleanup-stage3-mechanical"` | sonnet / medium | **yes — `model: "sonnet"`** | one Stage 3 item whose fix is already fully specified — a named repoint target, an enumerated rename list, a documented triage verdict, or another change with one clear correct form |

**Not every Stage 3 item deserves opus.** The Stage 1/2 lead-vs-mechanical split exists because most of that work is mechanical once conventions are set; the same split applies to Stage 3, and it's easy to default every item there to the opus agent just because Stage 3 sounds like "the hard stage." It isn't uniformly hard — "repoint this call to the name already given" and "delete the blocks a Stage 1 triage already marked *superseded*" carry no more judgment than a mechanical Stage 1/2 tranche, while "decide which of two live edge-power definitions is canonical" or "write a migration script that rewrites ~100 GB of collected human data" genuinely need the stronger model. When drafting or updating the plan's Stage 3 list (section 0.3), assign each item individually rather than routing the whole stage through one agent: ask whether the item still has a design decision, a safety judgment, or irreversible-state risk left in it, or whether that call was already made (by the plan text, a Stage 1 triage verdict, or a fully enumerated fix) and all that's left is to execute it correctly.

**Always pass `model:` explicitly, on every dispatch, for every agent in this table — never omit it.** The per-call `model` parameter is the highest-precedence way to set a subagent's model, above the agent file's own frontmatter and above the session's own model — and frontmatter alone has been observed unreliable in both directions (an agent ran on the wrong model despite its file saying otherwise), including once in this repo. Don't reason about what the session's model probably is; state the target model on every call, unconditionally. This is independent of the `subagent_type` requirement above — setting `model` correctly doesn't help if `subagent_type` was never set, since the call still runs as `general-purpose`.

Effort (medium for lead, high for escalation and stage3, medium for mechanical) still comes from the agent file's frontmatter and cannot be set per-call — there is no `effort` parameter on the Agent tool. Passing `model` explicitly does not touch that; it only pins which model the agent runs on.

If the plan's table names a bare model and effort rather than an agent, map it to the nearest row above.

**Sequencing.** Tranches run one at a time in plan order, because each one's naming decisions bind the next. The exception is a set of genuinely independent single files with no shared vocabulary left to settle — those can go in parallel. Never run the convention-setting tranche in parallel with anything.

**Prompt contract.** Every dispatch carries all of this, because the subagent starts with none of it:

1. The path to the plan, and an instruction to read sections 1 (scope), 4.1.1 (the rename map and the three zones), and 4.1.3 (the findings log — *especially the entries from earlier tranches*, which carry binding decisions) **before touching a file**.
2. The explicit file list for this tranche, and the statement that nothing outside it may be edited. For the step-2a rename tranche only, the list is the whole repo — say so, and say that its permitted edit is narrow: `git mv`, `function` lines, call sites, and references in comments and docs, with no reflow, headers, or spacing work.
3. The stage. If Stage 2, the four patterns and the requirement to report a documented negative when none are found.
4. The baseline to verify against, decided by you from `git status`: HEAD for a clean file, a pre-edit backup copy for a file carrying uncommitted work-in-progress or an untracked file. Getting this wrong produces large false diffs, so do not leave it to the subagent to guess.
5. The instruction to write its own findings-log entry into the plan before returning, and to tick its own item in section 0 — and, if the ticked item is in section 0.3 or 0.4 and is the last 🔴 remaining there, to update that section's heading emoji from 🚧 to ☑️ (see "The plan document" below).
6. The standing rules: commit the tranche once it's verified and the plan is updated (see Committing above), never push, don't fix bugs — record them in section 0.4 (Stage 4), each with its `B<severity>.<n>` id and emoji — don't make optimizations, however easy: record them in section 0.5 (Stage 5), each with its `S<tier>.<n>` id and emoji — and don't act on an organizational opportunity either: record it in section 0.3 (Stage 3), each with its `O<tier>.<n>` id and emoji.

**Verification is the subagent's job, and the output is the artifact.** The subagent runs the check itself, headlessly, without asking.

Locate MATLAB once per session rather than assuming a version:

```bash
which matlab || ls -d /c/Program\ Files/MATLAB/R*/bin/matlab | tail -1
```

Then, from the repo root:

```bash
"<matlab>" -batch "addpath('tools'); disp(check_stage1('<old>','<new>',renames))"
"<matlab>" -batch "addpath('tools'); golden_harness('replay','tools/golden_ref.mat')"
```

**Standing authorization, and its exact limits.** The user has granted a narrow, permanent exception to their general rule against self-initiated headless MATLAB runs. It covers **`canon`, `check_stage1`, `assert_rename_bijection`, `checkcode`, and `golden_harness('replay', …)`** — and nothing else. These parse or replay; they do no disk writes and run no pipeline.

Explicitly **not** covered, ask first every time: `golden_harness('capture', …)` (it writes the reference file, so a capture taken after a bad edit silently blesses it), the repo's demo or driver script, training stages, and anything that does real image I/O or overwrites an artifact in `data/`. Long `parfor` runs cost the user real time; that is why the general rule exists.

This authorization travels with this skill and applies in **any** repo, not just the one it was first granted in. No permission entry is needed — `Bash(*)` is already allowed globally.

Require the **verbatim checker output** pasted into the findings log, not a claim that it passed. A subagent reporting "all 21 files passed" is an assertion; the pasted output is evidence. When a tranche returns, spot-check the diff and the log entry before dispatching the next one — a wrong convention propagates silently otherwise.

## Step 4 — Stage 2 (Hygiene), per tranche

For each tranche, check for exactly four patterns and report the result even when it's "none found" — a documented negative is the evidence that the tranche was actually examined:

1. Missing suppressing semicolons. Most apparent hits are a trailing `%` comment after an already-present `;`.
2. `find(...)` that could be logical indexing. Most can't: if the numeric index is used to index a *second* array, printed in a label, or used as a scalar bound, it's not a target.
3. Unpreallocated growth — `x{end+1}` inside a loop, often already flagged `%#ok<AGROW>` by the original author, i.e. known and suppressed rather than fixed. Growth by exactly one element once per *call* is not a target.
4. Unused assignments that `checkcode` flags.

When you do rewrite a growing array: size it from a pre-pass that makes **no RNG draws**, then fill by index in the original loop, so any `rand`/`randperm` calls happen in exactly the same sequence. Verify by capturing the real output before the edit and asserting `isequal` after, then re-run the golden harness in replay mode.

**The four patterns are a closed list, and the boundary is where Stage 5 begins.** Stage 2 takes exactly these four because each one is small, local, and whitelistable. A faster way to write the loop is not on the list however obvious it is — record it as an `S<tier>.<n>` item in section 0.5 and move on. Widening this list is how a verified pass stops being verified.

**A missing semicolon is sometimes deliberate** — a script's only way to print a number when run interactively. Ask before "fixing" one on a line whose variable is never read again; if it's deliberate, add a comment saying so, so a later pass doesn't undo it.

Commit each tranche once the golden-harness replay passes, per the Committing section.

## Step 5 — Stage 3 (Organize)

Only once stages 1 and 2 are complete and committed. **Before working the list, check whether section 2 (scope and measurements) is still current** — if meaningful time has passed since Step 0's survey, or the file set has changed (new files, deletions, renames outside this plan), re-measure it. Organize's tier calls and Stage 5's S3.1 scan both lean on those numbers being live, not on what was true when the plan was written; a stale line count or a since-deleted file silently skews priority. Each item gets individual review; there is no blanket check. Every item carries a cost/benefit tier — 🔴/🟠/🟡, `O<tier>.<n>` — assigned when it's recorded, the same rating scale bugs and optimizations use (see above). Work the list in tier order: every 🔴 O1 first, then every 🟠 O2, then every 🟡 O3.

Dispatch **one item per invocation** — never a batch, since the items share nothing and a single agent doing three of them will blur the boundaries in the work log. Use the item's assigned agent from section 0.3 — `matlab-cleanup-stage3-mechanical` when the fix is already fully specified, `matlab-cleanup-stage3` when it still carries a design decision, a safety judgment, or irreversible-state risk (see "Dispatching tranches" above for the full criterion). **Tier and agent are independent axes:** tier decides priority, the mechanical/design split decides who does it. A 🔴 item can still go to `-mechanical` if its fix is already fully specified; a 🟡 item can still need `-stage3` if what little benefit it has comes wrapped in a real design decision. Tick items as they are actually done and log each in the Stage 3 work log. The list holds organizational cleanups — everything the verified pass deliberately deferred except bugs and optimizations, which get their own stages below.

An Organize item is allowed to make the code faster as a side effect — merging two duplicate functions usually does. That is fine and needs no timing; it is not a Speed item, because the reason for doing it was organizational. What makes something a Speed item is that speed is the *only* reason to do it.

### Commented-out code: acting on the Stage 1 triage

Commented-out code is the one Stage 3 category where the triage already happened, back in Stage 1 (step 2c) — that's where "keeping is the default" is enforced, since triage runs while the file is being read and before anything about it can change. What lands here is only the follow-through: turn each *superseded* or *scaffolding* verdict into a deletion, and each *alternative* or *unfinished* verdict into a conversion (a documented option, or prose in the header docs). Leave every *unknown* exactly alone — that verdict was already the final word.

These become their own Stage 3 items, one per file or block cluster, generated from the Stage 1 triage table (findings log, section 3.1.3). Each cites its verdict row. Nothing is deleted by an agent that did not first see the verdict that licenses it.

Commit each item once it's done and logged, per the Committing section.

### Keeping the golden reference honest, Stage 3 and Stage 4

Run `golden_harness('replay', ...)` after every Stage 3 or Stage 4 item, not only after Stage 1/2 tranches. Two outcomes, and the item's log entry states which:

- **The item was meant to be output-preserving** (most renames, an `arguments` block, most reorders) **and replay still passes.** Nothing to do — that is the expected result, and it is itself evidence the item didn't quietly change behaviour.
- **Replay fails.** Before touching the reference, decide which of two things happened: the item was *expected* to change output (a bug fix, by definition, or a structural change the item already flagged as behaviour-changing), in which case recapture the reference deliberately and record what changed, in which fields, and by roughly how much; or the item was supposed to be output-preserving and something moved that shouldn't have, in which case that is a **new bug** — file it in section 0.4, don't paper over it with a recapture.

Never recapture the reference to make replay pass again without first making that call. A recapture taken on reflex bakes an unexplained drift into the baseline every later tranche and every Stage 5 timing run trusts.

## Step 6 — Stage 4 (Bugs)

Bug fixes, once Stage 3 is settled — a fix that lands before a related structural change is more likely to be clobbered or duplicated by it. **The orchestrator does not dispatch Stage 4 on its own initiative.** The user launches each bug fix manually, in id order — every B1 first, then B2, then B3 — at whatever pace they choose, typically via `matlab-cleanup-stage3` since a bug fix is rarely fully specified in advance. Re-locate each bug by description, not by its recorded file:line, since renames and restructuring since it was found may have moved it. If a bug turns out to already be fixed as a side effect of Stage 3, say so and tick it without a code change. Tick items as they are actually done and log each in the Stage 4 work log.

Commit each fix once it's verified and logged, per the Committing section. If the bug was already fixed as a side effect of Stage 3, ticking it needs no new commit.

## Step 7 — Stage 5 (Speed)

Optimizations, done last, once the code is both structurally settled and correct. Work down section 0.5 in tier order — every 🔴 S1, then every 🟠 S2, then every 🟡 S3 — one item per invocation via `matlab-cleanup-stage3`, since a Speed item always carries a judgement about whether the win is real.

**Every item also carries a verification status, independent of its tier, that decides what "done" requires:**

- **Proven** — provably output-identical (no float or RNG order change): golden-harness bit-equality is the whole bar.
- **Perturbing** — changes float accumulation order, RNG draw order, or `parfor` reduction order: needs an explicit tolerance decision from the user before implementation, and the equality check is against that tolerance instead of bit-exactness.
- **Unprofiled** — the benefit isn't backed by a real measurement yet: **not implementable as recorded, whatever its tier.** Profiling is the item; the profile either promotes it — a number attached, status updated to Proven or Perturbing, tier re-checked against the real number — or closes it as not worth doing.

Most items start Unprofiled, since most optimizations are recorded before anything is measured — that's expected, not a defect in the survey. An Unprofiled item can still be rated 🔴 if the potential payoff looks large: the tier is a priority call made with the information on hand, not a certificate that the work is done.

**Like Stage 4, this stage is never auto-dispatched.** Every item needs timing runs on real inputs, and those cost the user's wall-clock, so the user launches each one.

**Re-triage before implementing anything.** Stages 3 and 4 have rewritten the code since these items were recorded. For each item, check first whether it still exists, whether an organizational change already did it, and whether a bug fix made it moot — the redundant work was sometimes the bug. Close it with a note in that case rather than forcing the optimization through.

**Each item's three obligations**, all three in the work log or the item isn't done:

1. **A before timing**, measured on a real input before any edit, stated with the input size and how many repeats it averages. No before number means no item.
2. **Output equality** by golden-harness replay. A Proven item must be bit-identical; a Perturbing item must fall inside the tolerance agreed when its status was set, quoted in the log.
3. **An after timing**, same input, same repeats. **If the speedup isn't worth the diff, revert the change and record that** — a measured null result is a completed item, and one of the most useful things this stage produces. Keeping a change that made the code harder to read for no measured gain is a failure, not a partial success.

For an item still marked Unprofiled, the profile *is* the item: run it, record where the time actually went, and update its status to Proven or Perturbing with a number attached (re-tier too, if the measurement changes the priority call), or close it. Do not implement anything still Unprofiled.

**Timing and profiling runs are not covered by the standing headless authorization** — they run the real pipeline. Ask before each one, and say what it will cost in wall-clock.

Commit each item once it's measured and logged, per the Committing section. A reverted null result still gets its log entry; whether it needs a commit depends on whether anything is left in the tree.

## Step 8 — Stage 6 (Closing)

Only once Stages 1 and 2 are done and every 🔴 item of Stages 3 through 5 is done (🟠 and 🟡 items may stay open as backlog). Unlike every stage before it, Closing has no findings of its own and no items to tier — it is one fixed four-item gate, run once, confirming the whole repo actually agrees with the plan's record rather than trusting the sum of the per-item checks:

- [ ] **0.6.1.** Re-run `check_stage1` across every in-scope file against current HEAD — not just the files each tranche's own check covered — to catch drift from anything that landed in a later tranche or item.
- [ ] **0.6.2.** `golden_harness('replay', ...)` clean, end to end, no open golden-reference questions left in section 0.4.
- [ ] **0.6.3.** Every 🔴 item in sections 0.3, 0.4, and 0.5 is ticked, or explicitly closed with a reason (dropped, superseded, already fixed as a side effect) rather than left silently open.
- [ ] **0.6.4.** Section 2 read once more against the repo as it now stands. The numbers that opened the plan should still roughly hold; if they don't, that gap is worth a closing line in the plan, not a silent discrepancy for the next reader.

**Never auto-dispatched, same as Stages 4 and 5** — but for a different reason: there is nothing to hand to a subagent. The orchestrator runs all four checks itself, logs the result in the Stage 6 work log, and only then tells the user the plan is complete.

Commit once all four are done and logged, per the Committing section.

## Verification gotchas

**A dirty working tree invalidates the HEAD baseline.** If the repo carries legitimate uncommitted work-in-progress in files you're about to clean, `git diff HEAD` and `check_stage1` against the last commit will produce large false "diffs" that are pre-existing content, not your edits. Take a **pre-edit backup copy of the file's current on-disk content** and diff against that instead. Check `git status` before each tranche and decide per file which baseline applies.

**Untracked files** have no HEAD baseline at all — same backup method.

**Config files get an extra check.** Run the config function before and after with each of its argument combinations and assert `isequal` on the returned structs.

**Package-qualified function names are not covered by the rename regex either**, and for the same reason: `vislab.lib.foo(...)` puts a `.` immediately before `foo`, which the lookbehind at `check_stage1.m:30` excludes. A correct rename of a packaged function therefore makes the check *fail*. Don't loosen the regex to make it pass — that would also un-protect struct fields. Verify those files by reading the diff, and record that you did (step 2a).

**Struct fields are not covered by the rename regex.** `check_stage1` excludes dot-qualified names, so a local variable can be renamed while a struct field of the same original name — especially one that gets saved to a `.mat` — must stay. Note the resulting mismatch in-file.

**Never run the repo's real end-to-end script as a verification step** if it does slow disk I/O or overwrites shipped artifacts. Build an isolated synthetic replica of the loop structure instead, with the same iteration counts and the same RNG calls.

**`check_stage1` is blind to commented-out code disappearing.** `canon` strips comments before comparing, so a tranche that deletes a commented-out block still passes the check — the deletion is invisible to it, the same way it's invisible to everything else Stage 1 is allowed to change. This is exactly why triage (step 2c) happens *inside* the same Stage 1 tranche that touches the file, before any edit to it: the block is judged and its verdict recorded at the one moment nothing has had a chance to make it disappear unassessed. If a later count still disagrees with the recorded inventory and the gap can't be explained any other way, say so rather than guessing.

## The plan document

`references/plan-template.md` is the skeleton: section 0 status with per-stage checklists, section 1 how an agent should execute the plan (the check, and why the stages are split this way), section 2 scope and measurements, section 3 per-stage details and work logs. Section 0 is the live to-do list; section 3 is the append-only record of what was found and decided.

**No stage table anywhere in the plan document, and no changelog of how the plan or the skill changed over time.** The stage table above (section "The six stages") is the skill's own reference, used once, here — it does not get copied into the plan document. Section 1 holds the cross-stage material that doesn't belong to any single stage: the verification mechanics (the check, and Stage 2's extra golden-output requirement) and the rationale for why the boundaries fall where they do — one section, "how an agent should execute this plan," rather than two. If the skill's rules change after a plan was already written, update the plan to match and move on — don't leave a note in the plan explaining that it changed or why; the plan describes the repo's current state, not its own history.

**Each of the six subsections in section 0 (0.1 through 0.6) has the same shape: a status emoji, then Description, optionally Status, then To-do.** The heading is `<emoji> 0.<n> · Stage <n> · <name>` — ✅ done, 🚧 in progress, or ⬜ not started — so the state of all six is visible at a glance without reading prose; section 0 itself is expanded by default, the six subsections collapsed (see markdown-conventions.md). The plan's own top matter states only what the four emoji mean; it does not restate the stage names, the behaviour-preserving distinction, or anything else section 1 or the checklists already cover. Stage 6 (Closing) has no rating legend in its Description — it's a fixed checklist, not a findings list, so there's no tier to explain.

**Stage 3 (Organize) and Stage 4 (Bugs) carry a fourth status, between in-progress and done.** Both lists are tiered (🔴/🟠/🟡), and the 🔴 items are the ones that actually matter for risk — a 🟠 or 🟡 item left unchecked is a backlog, not an open risk. So once every 🔴 item in a section's to-do list is ticked, even while 🟠/🟡 items remain open, that section's heading emoji changes from 🚧 to ☑️ ("provisionally done") rather than staying 🚧 — a faded, hollow checkbox, deliberately not green, so it reads at a glance as "the urgent part is over" without being mistaken for ✅ ("fully done, nothing left"). Recompute this emoji every time a 🔴 item in that section is ticked (it's the only kind of tick that can trigger the 🚧→☑️ transition) and every time a new 🔴 item is filed against an already-☑️ section (which reverts it to 🚧, since a new highest-tier item is exactly the kind of thing ☑️ was promising there wasn't any of). Stages 1, 2, 5, and 6 don't use ☑️ — Stage 5's tiers rate risk/benefit, not open risk the way Bugs and Organize do, and Stages 1, 2, and 6 aren't tiered lists at all.

Below the heading: **Description** is the one-line (or, for Organize/Bugs/Speed, one compact paragraph including the rating legend) statement of what the stage covers. **Status**, when present, is exactly one line and carries only a cross-cutting fact a reader can't already get from the checklist — e.g. "B2.2 blocks Stage 2's golden-output guarantee," or "the scan hasn't run yet." It is not a pointer to the findings log, tranche detail, or work-log section — those sections exist at a fixed, known place (section 3, per stage), so a Status line that only says "see section 3.x" adds nothing a reader doesn't already know from the numbering. Counts, which items are done, which tier is next — all of that is visible in the checklist's checkmarks and emoji, so it does not belong in Status either. **If there is nothing to say beyond what the checklist shows, skip the Status line entirely.** **To-do** is the checklist itself, nothing else. Keep the rating legend in Organize/Bugs/Speed's Description compact — a `🔴 ... · 🟠 ... · 🟡 ...` one-liner plus the id scheme, not a paragraph per tier.

**Section 3's per-stage headings carry no descriptive suffix — just the emoji-free triad, `3.1 · Stage 1 · Style`, matching section 0's heading exactly minus the status emoji.** Don't append "— renaming zones, tranches, and findings log" or similar; the subsections nested inside (3.1.1, 3.1.2, …) already name themselves, and the reader is here to look something up, not to be told what a findings log is.

Write the findings log as you go, not at the end. A per-tranche entry should record naming decisions that bind later tranches, documented line-length exceptions, which baseline was used for verification and why, and anything deliberately left alone.

`references/markdown-conventions.md` covers the collapsible-section formatting and the two rendering traps.
