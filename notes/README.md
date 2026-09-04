# notes/

Durable knowledge extracted from the labs.

A note answers one question: **what did I learn that will be useful again?**

Do not write a note because documentation exists. Write it because something was
learned — usually something that surprised you.

## Categories

```text
concepts/          how something works
troubleshooting/   symptom -> diagnosis -> fix
patterns/          reusable approaches
```

Do not add categories without a strong reason.

## Structure

```markdown
# Title

## What
## Why
## Example
## Gotchas
## Used in
```

`Used in` points at real files in this repository — the lab where it came up,
the scratch writeup that shows the evidence.

## Inline markers

Use when a note is not finished:

```markdown
> TODO: behavior not verified yet
> QUESTION: does this also hold for OnFailure?
> OBSERVATION: restartCount kept increasing after the pod went Ready
```

Do not retro-fit markers to existing notes.
