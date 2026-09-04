# scratch/

AI-generated reference implementations, experiments, and observation writeups.

Not the source of truth. The learner's implementation in `labs/NN-*/solution/`
is.

## Layout

One directory per lab, named **identically** to the lab directory:

```text
labs/01-pod-lifecycle/          <->   scratch/01-pod-lifecycle/
```

Inside it, one file per solved scenario, plus a directory holding the manifests
actually applied:

```text
scratch/01-pod-lifecycle/
    README.md                       index: what was run, when, outcome
    exercise-1-scenario-a.md        the writeup
    exercise-1-scenario-a/
        pod.yaml
```

Flat names such as `scratch/lab-01-exercise-1.md` are a rule violation.
Checked by `tests/rules/r5-scratch-mirrors-labs.sh`.

## Why this is versioned

The writeups contain real cluster evidence — phases, exit codes, events,
`restartCount`. That evidence is worth keeping and worth diffing against later
runs. Only genuinely disposable artefacts are ignored:
`scratch/**/tmp/`, `*.log`, `*.tmp`.

## Marker

Every file here starts with `<!-- ai-generated -->` (Markdown) or
`# ai-generated` (YAML, shell). That marker is what keeps AI implementations out
of `labs/` — see `tests/rules/r6-no-ai-impl-in-labs.sh`.

## Comparing against your own work

```bash
diff -r labs/01-pod-lifecycle/solution scratch/01-pod-lifecycle/exercise-1-scenario-a
```

The point is not deciding which YAML is correct. It is understanding why they
differ, whether the difference matters, and when the alternative would be the
better choice.
