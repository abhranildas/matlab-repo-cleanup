# Formatting conventions for the plan document

## Collapsible sections

The plan is long and mostly reference material, so every section is a `<details>` block whose `<summary>` is the heading. Nest them to four levels (h2 → h5).

Pattern for a section, with the indent and font-size that go with its level:

```html
<details style="margin:0.7em 0 0.7em 1.5em">
<summary><h3 style="display:inline; margin:0; font-size:1.05em">3.1 · Stage 1 · Style</h3></summary>

<div style="margin-left:1.5em">

…body…

</div>

</details>
```

Font sizes by level: h2 `1.15em`, h3 `1.05em`, h4 `0.98em`, h5 `0.92em`. Every nested `<details>` takes `style="margin:0.7em 0 0.7em 1.5em"`. Bodies go in a `<div style="margin-left:1.5em">`.

**Section 0 (Status) is the one exception: `<details open>`, expanded by default**, since it's the live to-do list — the five stage subsections nested inside it stay plain `<details>`, collapsed. Every other top-level section, and every nested subsection anywhere, is plain `<details>`.

**A heading that names a stage — id, "Stage N", and the stage's one-word name — separates the three with middots and carries no descriptive suffix**: `0.1 · Stage 1 · Style`, `3.1 · Stage 1 · Style`. The subsections nested inside a section-3 stage (3.1.1, 3.1.2, …) name themselves; the stage heading itself doesn't need an em-dash summary of what's below it.

Blank lines around the body are required — without them the markdown inside the `<div>` is not parsed.

Check that `<details>` and `</details>` counts match after any structural edit.

## Two rendering traps

**GitHub strips inline `style` attributes.** The indentation and heading sizes only render in a local markdown previewer (VS Code, Antigravity). On GitHub the sections still collapse, but everything sits flush left. Fine — but don't rely on indentation to carry meaning.

**The previewer hard-breaks on every source newline.** So do **not** soft-wrap prose to a column. Each paragraph and each list item must be **one single long source line**, however long, and the renderer wraps it. Manual wrapping at 80 or 100 characters renders as ragged lines broken mid-sentence.

Never join across: fenced code blocks, table rows (`|`), HTML tags, headings, `---`, blank lines, or the start of a list item.

If you ever need to unwrap a document that was written wrapped, be careful of inline code spans that got split across two source lines — joining with a space inserts a spurious space inside the backticks. Audit for `` `…/ …` `` afterward; hits that span a table cell boundary are false positives.

## Voice

Findings-log entries are prose, not bullet fragments. State what was done, what was decided, and what was deliberately not done, with file and line references. A tranche that found nothing still gets an entry saying what was checked — that's the evidence it was examined.
