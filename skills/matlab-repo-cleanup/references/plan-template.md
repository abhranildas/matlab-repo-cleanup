# Repo-wide cleanup plan

- ✅ done
- ☑️ provisionally done (every 🔴 item done)
- 🚧 in progress
- ⬜ not started

---

<details open>
<summary><h2 style="display:inline; margin:0; font-size:1.15em">0. Status</h2></summary>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em"><!-- ✅/🚧/⬜ --> 0.1 · Stage 1 · Style</h3></summary>

<div style="margin-left:1.5em">

**Description.** Comments, header docs, whitespace, operator and bracket spacing, indentation, reflow, blank-line grouping, renames — file-local identifiers to snake_case, plus function and file names repo-wide in their own tranche — and triaging any commented-out code found in each tranche's files (verdict only, nothing deleted). Checked by `isequal` on a canonical AST fingerprint — no execution needed.

**Status.** <!-- only a cross-cutting fact not already visible in the checklist below — not a pointer to the findings log or any other section. Omit this line entirely if there's nothing to add. -->

**To-do.**

- [ ] **0.1.0.** Tooling: `canon`/`check_stage1`/`assert_rename_bijection`, golden-output harness.
- [ ] **0.1.1.** Function and file renames, repo-wide — the map in section 3.1.1, verified over every file.
- [ ] **0.1.2.** <!-- tranche 1: sets in-file naming conventions -->
- [ ] **0.1.3.** <!-- tranche 2 -->

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em"><!-- ✅/🚧/⬜ --> 0.2 · Stage 2 · Hygiene</h3></summary>

<div style="margin-left:1.5em">

**Description.** Semicolon insertion, preallocation, `find`→logical indexing, deleting a provably unused assignment. Checked by a whitelisted-pattern diff **plus** a runtime golden-output match. A closed list of four: anything bigger is a Speed item (0.5), not a widening of this stage.

**Status.** <!-- only a cross-cutting fact not already visible in the checklist below — not a pointer to the findings log or any other section. Omit this line entirely if there's nothing to add. -->

**To-do.**

- [ ] **0.2.0.** Extend the golden harness to cover every tranche.
- [ ] **0.2.1.** <!-- tranche 1 -->

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em"><!-- ✅/☑️/🚧/⬜ — ☑️ once every 🔴 item below is done --> 0.3 · Stage 3 · Organize</h3></summary>

<div style="margin-left:1.5em">

**Description.** Signature changes, `arguments` blocks, merging duplicate functions, reordering statements, float/RNG-order changes, renaming a config struct field or a frozen `save`/`load` name, acting on the Stage 1 commented-out-code triage — not behaviour-preserving, done after Stage 1/2, and not Bugs (0.4) or Speed (0.5) even if a fix here happens to speed something up. **Rating:** 🔴 clear win, low risk · 🟠 real cost (design decision or wide call-site surface) · 🟡 marginal, defer — a joint call, not a formula, say which factor drove it. Id `O<tier>.<n>`, a flat sequence sorted by tier then discovery order, never renumbered (not a stage number — always spell out "Stage 1"). Two categories recur across repos: zone-2 config-field renames (usually 🟠, call-site surface) and zone-3 frozen-name renames (usually 🟡, risk to shipped artifacts); acting on the Stage 1 triage table (section 3.1.4) is one item per file/block cluster, tier following the verdict — a straight deletion usually 🔴, a judgment-call conversion usually 🟠.

**Status.** <!-- only a cross-cutting fact not already visible in the checklist below (tier and done/open state are — don't repeat them, and don't point to the work log). Omit this line entirely if there's nothing to add. -->

**To-do.**

- [ ] 🔴 **O1.1.** <!-- organizational cleanup: merge duplicate functions, etc. -->
- [ ] 🟠 **O2.1.** <!-- signature changes / `arguments` blocks -->
- [ ] 🟡 **O3.1.** <!-- e.g. reorder statements, even when it looks purely cosmetic -->

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em"><!-- ✅/☑️/🚧/⬜ — ☑️ once every 🔴 item below is done --> 0.4 · Stage 4 · Bugs</h3></summary>

<div style="margin-left:1.5em">

**Description.** Bugs found anywhere during Stage 1/2/3, fixed here after Organize so a later organizational change can't clobber or duplicate a fix. **Rating:** 🔴 severity 1, silently wrong results on a path that has actually been run · 🟠 severity 2, reachable but not silent — errors out, or touches only plots/logging/display · 🟡 severity 3, latent, not reachable with the current config but a hazard for plausible future use. Id `B<severity>.<n>`, a flat sequence sorted by severity then discovery order, never renumbered — the emoji leads the item and is the only severity tag needed.

**Status.** <!-- only a cross-cutting fact not already visible in the checklist below — e.g. an item that blocks something elsewhere. Not a pointer to the work log. Omit this line entirely if there's nothing to add. -->

**To-do.**

- [ ] 🔴 **B1.1.** <!-- file:line (at time of finding) — what's wrong, why it matters, whether it's reachable -->
- [ ] 🟠 **B2.1.** <!-- … -->
- [ ] 🟡 **B3.1.** <!-- … -->

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em"><!-- ✅/🚧/⬜ --> 0.5 · Stage 5 · Speed</h3></summary>

<div style="margin-left:1.5em">

**Description.** Optimization candidates found during the survey (section 1) or anywhere in Stage 1–4, never made at the time — done last, once the code is structurally settled and correct, so a bug fix can't dissolve the optimization out from under it. Every item needs a before timing, golden-output equality, and an after timing; **if the speedup isn't worth the diff, the change is reverted and the null result recorded** — that is a completed item, not a failure. **Rating:** 🔴 large win, low risk (provably output-identical, or a big enough gain that a tolerance decision is a formality) · 🟠 real cost (moderate gain, or a large one that perturbs float/RNG/`parfor`-reduction order and needs a tolerance decision) · 🟡 small, speculative, or unverified — most items start here. Id `S<tier>.<n>`, same non-renumbering rule as 0.4. Separate axis, **verification status** — Proven (bit-identical), Perturbing (needs the agreed tolerance), or Unprofiled (no real measurement yet — **not implementable as recorded, whatever its tier**; the profile either promotes or closes it). Unprofiled doesn't cap the tier: a big-looking unmeasured payoff can still be 🔴.

**Status.** <!-- only a cross-cutting fact not already visible in the checklist below — e.g. whether the scan itself (S3.1) has run. Not a pointer to the work log. Omit this line entirely if there's nothing to add. -->

**To-do.**

- [ ] 🔴 **S1.1.** <!-- file:line (at time of finding) — what the redundant work is, why it's output-identical, verification status -->
- [ ] 🟠 **S2.1.** <!-- … and what it perturbs, and the tolerance the user agreed to -->
- [ ] 🟡 **S3.1.** <!-- … and what would have to be profiled to promote or close it -->

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em"><!-- ✅/🚧/⬜ --> 0.6 · Stage 6 · Closing</h3></summary>

<div style="margin-left:1.5em">

**Description.** A single fixed gate, run once 0.1 and 0.2 are done and every 🔴 item in 0.3 through 0.5 is done — not a findings list, so no rating legend and no items beyond the four below. Confirms the whole repo agrees with the plan's record, rather than trusting the sum of the per-item checks. Never auto-dispatched, for the same reason as Stages 4 and 5 but a different cause: there's nothing to hand to a subagent, so the orchestrator runs all four itself.

**To-do.**

- [ ] **0.6.1.** `check_stage1` re-run across every in-scope file against current HEAD.
- [ ] **0.6.2.** `golden_harness('replay', ...)` clean, end to end.
- [ ] **0.6.3.** Every 🔴 item in 0.3, 0.4, and 0.5 ticked, or explicitly closed with a reason.
- [ ] **0.6.4.** Section 2 re-checked against the repo as it now stands.

</div>

</details>

</details>

---

<details>
<summary><h2 style="display:inline; margin:0; font-size:1.15em">1. How an agent should execute this cleanup plan</h2></summary>

<div style="margin-left:1.5em">

`mtree` parses a `.m` file into MATLAB's own syntax tree, and `tree2str` prints it back in canonical form: comments stripped, whitespace/bracket spacing normalised, missing `end` supplied.

```matlab
canon = @(f) tree2str(mtree(f,'-file'));
```

This gives a fingerprint blind to exactly what stage 1 is allowed to change, sensitive to everything else. Verified: succeeds on all N in-scope files.

Reverse-rename check: clean a file (renames, header, reflow), then undo the rename map on the canonical form of the new file and assert it's identical to the canonical form of the old one:

```matlab
c_new = canon(new_file);
for k = 1:size(renames,1)   % renames = {new_name, old_name}
    c_new = regexprep(c_new, ['(?<![A-Za-z0-9_.])' renames{k,1} '(?![A-Za-z0-9_])'], renames{k,2});
end
isequal(canon(old_file), c_new)   % must be true
```

The lookahead `(?![A-Za-z0-9_])` matters: without it a short name (`patch`) can wrongly match inside a longer one (`patch_size`). The rename map itself must be a bijection with disjoint domain/range — assert this before using it:

```matlab
dom = renames(:,1); ran = renames(:,2);
assert(numel(unique(dom)) == numel(dom));
assert(numel(unique(ran)) == numel(ran));
assert(isempty(intersect(dom, ran)));
```

Caveat: `mtree`/`tree2str` are undocumented MATLAB APIs — pin the MATLAB version in commit messages.

**Stage 2's extra requirement: runtime golden output.** <!-- Does this repo execute? If yes, tools/golden_harness.m captures/replays deterministic outputs under rng(cfg.seed), never through the top-level driver. List what it covers and what it can't. If parts of the repo don't run, say which, and that those tranches are pattern-check-only. --> <!-- parfor finding: sliced output vs. reduction variable -->

Semicolon insertion is stage 2, not stage 1: `tree2str` preserves display-vs-suppress, so the canonical diff is exactly `X` → `X;` — trivially whitelisted, but not invisible.

Speed is its own stage rather than a corner of Organize because the verification differs: an Organize item is reviewed and reasoned about, a Speed item is not done until a stopwatch says it worked. Being last also makes it the one stage that can be dropped entirely without touching anything else.

Stage 3 matters most. The tempting changes are all stage 3 (see section 0.3's list). Every one of them changes output, call sites, or validation behaviour, so none of them belong in the behaviour-preserving pass — keeping them out is what makes that pass's diff skimmable instead of line-by-line. They are the next step of the same overall cleanup, not abandoned.

**All three of Organize, Bugs, and Speed rate their items on the same three-colour scale** — 🔴 highest, 🟠 middle, 🟡 lowest — though what the tier means differs by list: how bad a bug is if left unfixed, versus overall cost/benefit for an organizational item, versus overall risk/benefit for an optimization. See sections 0.3, 0.4, and 0.5 for each list's specific criteria.

When the pass uncovers an *organizational opportunity* — and it will — **record it in 0.3 with its tier emoji and do not make the change**, the same discipline as a bug or an optimization.

When the pass uncovers an *optimization* — and it will — **record it in 0.5 with its tier emoji and do not make it**, however small it looks. The "easy" one spotted mid-tranche is the likeliest way this rule gets broken.

When the pass uncovers a *bug* — and it will — **record it in the findings list first, marked with its severity emoji**, so the recording survives even before the fix happens; the fix itself comes later, as a stage 4 item, kept separate from stage 3 so the bug list never gets buried inside the organizational-cleanup list. Even a 🔴 waits: the severity sets the fix order within stage 4, it does not pull a fix forward or interrupt the tranche that found it.

Statement reordering is kept out of stage 1/2 even though it looks cosmetic, purely because the check cannot distinguish a safe reorder from an unsafe one — it gets the same individual review as the rest of stage 3.

**Before working section 0.3, check whether section 2 is still current.** If meaningful time has passed since it was measured, or the file set has changed, re-measure it — Organize's tiers and Stage 5's S3.1 scan both lean on those numbers being live, not on what was true when the plan was written.

**Golden-reference maintenance, Stage 3 and Stage 4.** Run `golden_harness('replay', ...)` after every Stage 3 or Stage 4 item, not only after Stage 1/2 tranches. If the item was meant to be output-preserving and replay still passes, nothing to do. If replay fails, decide which happened before touching the reference: the item was *expected* to change output (a bug fix, or an organizational change already flagged as behaviour-changing) — recapture deliberately and log what changed and by how much — or it was supposed to be output-preserving and something moved that shouldn't have, which is a new bug for section 0.4, not a reason to recapture.

**Stage 6 (Closing), once Stages 1 and 2 are done and every 🔴 item of Stages 3 through 5 is done:** re-run the full check suite end to end (section 0.6's checklist) rather than trusting the sum of the per-item checks. Nothing before that stage has confirmed the *whole* repo agrees with the plan's record.

</div>

</details>

---

<details>
<summary><h2 style="display:inline; margin:0; font-size:1.15em">2. Scope and measurements</h2></summary>

<div style="margin-left:1.5em">

Every number in this document was measured on the repo as it stands (MATLAB R20XXx), not estimated — state the date measured. Re-measure before trusting any of them after substantial changes, or once real time has passed since this section was last touched (see section 1).

**Scope, precisely.** <!-- what's excluded and why; then: that leaves **N files, M lines** in scope, broken down per directory -->

**What is actually wrong with the files**, measured, not assumed:

- **Lint.** <!-- checkcode message count, how many files clean -->
- **Formatting.** <!-- tabs, missing headers, files with lines >100 chars, worst offender with line number, which files concentrate the problem -->
- **Spacing consistency.** <!-- how much `a=[1,2,3]`-style unspaced code there is vs. `a = [1, 2, 3]`, and whether indentation is uniform. Sets how much formatting work each tranche carries (skill step 2b). -->
- **Header docs.** <!-- how many have Inputs/Output, how many have See also, any Contents.m -->
- **Names, inside files.** <!-- the abbreviation occurrence counts — usually the real problem -->
- **Names, of files.** <!-- every .m filename judged as a name: camelCase/TitleCase filenames, names that don't say what the file does, verb/noun mismatches, one-off abbreviations, inconsistent stage or version numbering across siblings, filenames disagreeing with the `function` line inside. Grouped into families, with the point at which each family's pattern breaks. Feeds the rename map in section 3.1.1. -->
- **Casing census.** <!-- files by casing style (snake_case / camelCase / other) and a rough camelCase-variable count. The target is snake_case everywhere, so this is the size of that job. -->
- **Names diverge across call boundaries.** <!-- concrete example -->
- **Convention splits.** <!-- e.g. snake_case except one camelCase directory -->
- **Builtin shadows.** <!-- which names, which files -->
- **Commented-out code.** <!-- N of M lines, and where the blocks are: file and line range per block, as a rough sizing pass only. The real triage, block by block, happens inside stage 1 (section 3.1.4) when each file is actually read; nothing is judged or removed here. -->
- **Argument validation.** <!-- any `arguments` blocks or `inputParser`? Adding them is stage 3 -->
- **Performance shape.** <!-- The optimization scan (skill step 0), as counts with locations and no verdicts: loop-invariant work recomputed in a loop; file I/O (`load`/`imread`/`save`/`dir`/`exist`) inside a loop; `inv`/`pinv`/`det` where a solve would do; array growth beyond what stage 2 covers; whole-array recomputation where an incremental update exists; plainly-elementwise loops and serial `parfor` candidates; existing `parfor` loops writing to a reduction variable. Every hit becomes an `S<tier>.<n>` item in section 0.5 — none is acted on here. If nothing was found, say so and name the patterns checked. -->
- **Is there any timing data at all?** <!-- an existing tic/toc, a logged runtime, a README note, or the user's own sense of which stage is slow. Usually no — and that is why most 0.5 items start life Unprofiled. Where the wall-clock actually goes, if anyone knows; "nobody knows" if not, rather than an inference from loop nesting. -->

**The style target already exists** — do not invent a new one. <!-- name the exemplar file and its shape, plus the closest in-repo approximations. Note whether any in-scope file shares a name with something in a sibling repo or an ancestral-code tree. -->

</div>

</details>

---

<details>
<summary><h2 style="display:inline; margin:0; font-size:1.15em">3. Stage-by-stage details and work log</h2></summary>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">3.1 · Stage 1 · Style</h3></summary>

<div style="margin-left:1.5em">

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h4 style="display:inline; margin:0; font-size:0.98em">3.1.1 Renaming: the three zones, and the function/file map</h4></summary>

<div style="margin-left:1.5em">

The rename map is the pass's most valuable artifact and its main divergence risk — build it first, once, repo-wide, per tranche.

**Casing: snake_case for everything this repo owns** — variables, arguments, functions, scripts, filenames. Not camelCase, not TitleCase. It is a casing rule only: a one-word name stays one word (`sigma`, `radius`), and nothing is padded or qualified just to look like the convention. Not ours to rename, and not up for debate: MATLAB/toolbox builtins and name-value strings (`'LineWidth'`), fields of structs returned by external code, zone-3 frozen names, and `classdef` names.

1. **File-local variables — free.** <!-- the concrete map: camelCase→snake_case, abbrev→expansion, loop counters, builtin shadows. Because these are file-local, `canon` makes them completely safe. -->
2. **Cross-file vocabulary — repo-wide, or not at all.** Three sub-vocabularies:
   - Function and file names: the map below. Checkable, so **Stage 1**, in its own repo-wide tranche run before every other tranche.
   - Function arguments named consistently across the repo: <!-- list -->. High value because they're everywhere — but a half-done rename is worse than none.
   - The config struct: <!-- N distinct field paths, defined where, read everywhere. Dot-qualified, so `check_stage1` can't see it. **Its own tranche, deferred to Stage 3.** -->
3. **Serialised variable names — forbidden.** <!-- enumerate every name appearing in a save/load string, and which artifacts depend on them. A local variable that *holds* one of these can be renamed; the string in the `save`/`load` call cannot. Flag any name that is frozen in one file and free in another. -->

**Function and file rename map** (skill step 2a). A file rename *is* the function rename — MATLAB dispatches on the filename — so the `function` line is fixed to agree in the same edit. Renames are done with `git mv`, so history follows.

<!-- State the family rules first — one verb vocabulary, consistent what-then-qualifier order, the same noun the code uses internally — then the map. Each new name checked against `which('<new>', '-all')` for a builtin or sibling-repo collision. -->

| old file | new file | why |
|---|---|---|
|  |  |  |

**The four sweeps the check cannot do for you**, each answered explicitly in the tranche's findings-log entry:

- Package-qualified call sites (`pkg.fn(...)`) — excluded by the lookbehind in `check_stage1`, so a *correct* rename fails the check. Verified by diff reading instead: <!-- which files, or "no packaged functions renamed" -->
- Old names referenced outside `.m` files — README, this plan, `.mlx`, launchers, derived data filenames: <!-- hits and fixes -->
- Dynamic references — `feval`/`str2func`/`exist`/`which`/`help` with the name as a string: <!-- hits and fixes -->
- Case-only renames, which need a two-step `git mv` through a temp name on Windows: <!-- which, if any -->

**Units are the other half of naming** — state them in every header: <!-- the repo's unit conventions, field by field -->

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h4 style="display:inline; margin:0; font-size:0.98em">3.1.2 Tranches, sequencing, and model assignment</h4></summary>

<div style="margin-left:1.5em">

<!-- How the work is actually concentrated vs. what file count suggests. Batch the small ones; budget real time for the large ones. -->

The **Agent** column is what the orchestrator dispatches to — see the skill's "Dispatching tranches to subagents" section. Tranches run in order, one at a time.

| # | Tranche | Files / lines | Agent | Why |
|---|---|---|---|---|
| 0 | Rename map + `canon`/checker + golden harness | — | `matlab-cleanup-lead` | Every other step trusts this being right |
| 1 | Function and file renames, repo-wide (section 3.1.1) | all files | `matlab-cleanup-lead` | Must land before any header or `See also` names a file, or they all get rewritten twice. Repo-wide; never parallel with anything |
| 2 |  |  | `matlab-cleanup-lead` | Sets in-file naming conventions for everything downstream |
| 3 |  |  | `matlab-cleanup-mechanical` |  |

**Escalation rule, any tranche:** if `check_stage1` fails and the cause isn't obvious from the diff — stop, don't retry with a bigger prompt, hand that one file to `matlab-cleanup-escalation`. Don't loosen the check instead.

**"Done" checklist for a stage 1 tranche:**

- [ ] `check_stage1(old, new, renames)` true for every file.
- [ ] Every file has a header matching the exemplar's shape: summary, signature, `Inputs`/`Output` with units, `See also`.
- [ ] Every identifier the repo owns is snake_case — no camelCase variable, argument, or filename left except the external-API and frozen names listed in section 3.1.1 — and no name padded out just to fit the convention.
- [ ] Each file's `function` line agrees with its filename.
- [ ] Formatting harmonized (skill step 2b): spacing around `=` and binary operators, space after commas, no space inside brackets, 4-space indent, no tabs, no trailing whitespace.
- [ ] No line exceeds 100 characters except the documented string-literal exceptions (listed per tranche in section 3.1.3) — each would require turning a string literal into a `horzcat` expression, a real AST change forbidden by stage 1.
- [ ] No zone-3 frozen identifier renamed, no `save`/`load` string literal changed.
- [ ] Each package touched has a `Contents.m`.
- [ ] Every commented-out block in the tranche's files has a verdict in section 3.1.4, and nothing was deleted or converted on the strength of it.
- [ ] Bugs found are written down with a severity tag and not fixed (section 0.4, and section 3.1.3 per-tranche).
- [ ] Optimizations spotted are written down with a tier tag and not made (section 0.5).

One commit per tranche, per the skill's Committing section, each stating the checker result.

**Housekeeping done first:** <!-- filename-conflict copies, misplaced files — resolved in the tools commit, before any tranche started -->

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h4 style="display:inline; margin:0; font-size:0.98em">3.1.3 Findings log</h4></summary>

<div style="margin-left:1.5em">

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 0 — tooling</h5></summary>

<div style="margin-left:1.5em">

<!-- What was built, what it was verified against, the MATLAB version, the golden entry points and their checksums, and any subtlety found while building it. -->

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h5 style="display:inline; margin:0; font-size:0.92em">Step 1 — <!-- tranche --></h5></summary>

<div style="margin-left:1.5em">

<!-- Files passed. Naming decisions that bind later tranches, with the reason. Documented line-length exceptions. Which baseline was used for verification (HEAD vs. pre-edit backup) and why. Anything deliberately left alone. -->

</div>

</details>

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h4 style="display:inline; margin:0; font-size:0.98em">3.1.4 Commented-out code — triage verdicts</h4></summary>

<div style="margin-left:1.5em">

One row per block, added as each stage 1 tranche reaches the file it's in — not deferred to a separate pass. Filled in by reading the surrounding code, not the git history. Verdicts: *superseded* (the live code beside it does the same job better — name it) → delete; *scaffolding* (a stray debug print, plot, or timer) → delete or promote to a real debug flag; *alternative* (a method or parameter set the author could switch back to) → keep, but convert it into a documented option or a note in the header docs; *unfinished* (a sketch never completed) → keep, rewritten as a prose TODO; *unknown* (purpose not recoverable) → leave exactly as is. **Unknown is the default whenever the evidence runs out** — an honest unknown costs a few commented lines, while a wrong *superseded* can destroy the only copy of code that was never live and so is nowhere in the history. Acting on a verdict — deleting or converting — is stage 3 (section 0.3), never done here.

| block | file:lines | tranche | what the surrounding code says it was for | verdict |
|---|---|---|---|---|
|  |  |  |  |  |

</div>

</details>

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">3.2 · Stage 2 · Hygiene</h3></summary>

<div style="margin-left:1.5em">

**Coverage gaps found while extending the golden harness, and their resolutions:**

- <!-- e.g. a script whose local functions have no callable entry point: decision is pattern-check only, no runtime golden check -->

**Per-tranche work log:**

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h4 style="display:inline; margin:0; font-size:0.98em">Step 1 — <!-- tranche --></h4></summary>

<div style="margin-left:1.5em">

<!-- Either the fix (what pattern, how rewritten, how verified, golden replay result) or an explicit "no stage 2 edits" that names all four patterns checked and why each has no target here. -->

</div>

</details>

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">3.3 · Stage 3 · Organize</h3></summary>

<div style="margin-left:1.5em">

Fills in as each stage 3 item (section 0.3) is actually done. Commented-out code was already triaged in stage 1 (section 3.1.4) — this log only records what was actually deleted or converted as a result, citing the verdict row it acted on.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">3.4 · Stage 4 · Bugs</h3></summary>

<div style="margin-left:1.5em">

Bugs discovered while doing stage 1/2/3 are recorded in section 0.4 as they're found, each with its `B<severity>.<n>` id and emoji; their fixes, done in that order, get logged here — what was wrong, the fix, and how it was verified (call-site search, not a mechanical check). If the severity turned out to be wrong once the bug was looked at properly, say so here, and re-file it in 0.4 under the correct severity's next `n` — it keeps a new id, the old one is not reused, and nothing else in the list is renumbered.

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">3.5 · Stage 5 · Speed</h3></summary>

<div style="margin-left:1.5em">

One entry per section 0.5 item, filled in as it's measured. Each entry carries all of: the re-triage verdict (does the item still exist after stages 3 and 4, or did an organizational change or bug fix already dissolve it), the **before** timing with input size and repeat count, the golden-output result (bit-identical for a Proven item, inside the agreed tolerance for a Perturbing item, tolerance quoted), and the **after** timing on the same input and repeats.

**A measured null result is a completed item.** If the speedup didn't justify the diff, the change was reverted — log the numbers that said so. That entry is worth as much as a successful one, because it closes the question permanently.

For an item still marked Unprofiled, the profile *is* the item: log where the time actually went, then update its status to Proven or Perturbing with a number attached (re-tiering if the measurement changes the priority call), or close it here.

| item | re-triage | before | after | output check | kept? |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

</div>

</details>

<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">3.6 · Stage 6 · Closing</h3></summary>

<div style="margin-left:1.5em">

One entry, filled in once, when 0.6 is actually run — not per sub-item, since it's one gate, not a findings list. States the result of each of the four checks (0.6.1–0.6.4), verbatim checker output for the two mechanical ones, and any discrepancy found and how it was resolved before the plan was called complete.

</div>

</details>

</details>
