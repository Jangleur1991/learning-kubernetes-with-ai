# Kubernetes Learning Guide

How labs in this repository are designed and taught.

This file owns pedagogy. `CLAUDE.md` owns operations — file placement, cluster
safety, research procedure. `RULES.md` owns the machine-checked invariants.
Nothing here is repeated there.

---

## The point

Build Kubernetes skill that can be explained and defended, not a collection of
YAML snippets.

The loop:

```text
Recognize a concept
  -> small practical task
  -> predict
  -> implement
  -> run in kind-ckad
  -> observe
  -> explain the gap between prediction and reality
  -> break it / troubleshoot
  -> record what is worth keeping
```

Comprehensiveness is not a goal. The goal is the smallest set of experiments
that builds the target skill.

---

## Teaching stance

The learner writes the implementation, runs the commands, reads the output, and
explains the behavior. AI supports that; it does not perform it.

In guided mode:

* clarify the task;
* ask questions that force a prediction;
* hint progressively, weakest hint first;
* review what the learner wrote;
* help interpret cluster output;
* do not reveal the answer before the learner has attempted it.

For troubleshooting, never lead with the root cause. Collect the symptom, ask
for a hypothesis, point at the evidence, and reveal the cause only after the
learner has had a real attempt.

Reveal early only when the learner explicitly asks, or explicitly asks Claude to
solve the task.

---

## Lab anatomy

```text
# Lab N — Title

Domain / CKAD skill

## Learning objective        one or two sentences, a capability not a topic
## Before you begin          namespace, time budget, prerequisites only
## Exercise 1 — Imperative
### Scenario A               Predict -> Task -> Observe -> Explain
### Scenario B               ...
## Exercise 2 — Declarative
### Scenario A               same scenario, other workflow
## Comparison                short reflection
## Success criteria          observable checklist
## Cleanup                   delete the lab namespace
## Optional experiments      clearly separated, never required
```

A default, not a template to fill mechanically. The objective decides how many
exercises and scenarios exist.

`labs/_TEMPLATE/` holds a copyable skeleton.

The objective states a capability:

> Predict and explain Pod phase, container state, and restart behavior.

not a topic:

> Learn Pod lifecycle.

---

## Start fast

The number to minimize is not the total length of a lab. It is **how much the
learner must read before the first meaningful action** — target roughly 30
seconds.

Before the first task, include only: title, CKAD skill, the objective, the
namespace and time budget, and anything needed to start safely.

Everything else — definitions, theory, behavior tables, command references —
comes after the observation, or goes to `notes/`, or becomes its own lab.

Prefer:

```text
Objective -> short context -> first task -> predict -> implement -> observe -> explain
```

over:

```text
Objective -> background -> definitions -> theory -> tables -> command reference -> first task
```

Before finalizing, reread the opening as the learner: can they start doing
something useful almost immediately? If not, cut.

---

## Granularity

**One goal per task.** A scenario has one immediate learning goal. Several small
scenarios each closing their own predict/observe/explain loop beat one large
task that withholds feedback until six variations are implemented.

**One scenario at a time.** Introduce variations incrementally — basic case,
observe, one meaningful variation, observe, compare. Not the full matrix.

**Progressive complexity.** Never open with the hardest case unless the
difficulty itself is the objective.

**No cognitive pile-up.** Do not combine multiple resources, failure modes,
namespaces, configuration mechanisms, and concepts in one initial task. The
learner must be able to name the purpose of the current action instantly.

**Short instructions.** Bullets and requirements, not prose:

```text
Create a Pod named `lifecycle-success`.

Requirements:
- image: busybox
- command exits with code 0
- restartPolicy: Never

Predict the result first.
```

**Small prediction sections, not big tables.** A prediction table is right only
when the comparison itself is the objective. Otherwise:

```text
### Scenario A

Predict:
- Pod phase:
- Container state:
- restartCount:
```

**Concise is not incomplete.** The learner must still know what to achieve, what
constraints apply, which resources are involved, what to observe, and what to
explain. Cut unnecessary reading, never necessary task information.

**Size.** One lab, one primary objective, completable in one focused session.
Prefer several focused labs over one broad one. Do not create scenarios to make
a lab longer, and move useful-but-inessential variations to
`## Optional experiments` or to their own lab.

---

## No solution leakage

A lab states requirements. It does not state implementations or outcomes.

Never put in a lab README:

* a manifest in a fenced `yaml` block;
* a `kubectl run` / `kubectl create` line carrying the task's own flags;
* the expected result before the prediction;
* a hint that gives away the behavior under test;
* success criteria that double as an answer key.

Not:

> The Pod will enter `Succeeded` because the container exits with code 0.

But:

> Predict the Pod phase and container state before creating the Pod.

Expected behavior is discussed after the observation, during review, on request,
or in `scratch/`.

Enforced by `tests/rules/r7-no-solution-leakage.sh`.

---

## Prediction before observation

For behavior-focused labs the learner predicts first — phase, container state,
`kubectl` output, scheduling, restart, probe, or networking behavior.

The prediction does not need to be right. A wrong prediction the learner can
explain afterwards is worth more than a right one they guessed.

A prediction is not an observation. Keep them visibly separate, including when
Claude is in solve mode.

---

## Evidence

Explanations rest on cluster output, not on recall:

```text
Observation -> Evidence -> Explanation
```

Use `kubectl get`, `describe`, `logs`, `events`, `exec`, `get -o yaml`,
`rollout status`. Collect the smallest evidence that settles the question. A lab
is not a documentation exercise.

---

## Imperative and declarative

Where both workflows genuinely apply to the core task — Pods, Deployments,
Services, common workloads, configuration, property changes — the lab contains
**both**, explicitly labelled, both required:

```text
Exercise 1 — Imperative
Exercise 2 — Declarative
```

Wording: *"Both exercises are required. Choose which one to do first."* Never
*"use whichever you prefer"*.

The two exercises test the same or a closely related skill, on the same or an
equivalent scenario, so the learner is comparing interaction styles rather than
learning two unrelated tasks. The declarative exercise must not read as the
solution file for the imperative one.

Having two workflows must not double the scenario count. Use the smallest
meaningful scenario in each.

If only one workflow is meaningful, use it and state in one line why the other
is not. Do not invent an artificial counterpart.

The test is not *"could this theoretically be expressed declaratively?"* but
*"can the learner realistically practise this skill both ways?"*

---

## Troubleshooting labs

A deliberate failure follows the same granularity rules as anything else:

```text
Small failure -> observe -> hypothesize -> inspect -> evidence -> fix -> verify
```

One cause, understandable, diagnosable. Not a multi-fault incident, unless
advanced troubleshooting is the stated objective.

Useful failure modes: `Pending`, `CrashLoopBackOff`, `ImagePullBackOff`, failed
readiness, failed liveness, missing ConfigMap or Secret, wrong Service selector,
Service without endpoints, wrong port, unmounted volume, wrong command or args,
Ingress routing, RBAC denial, NetworkPolicy blocking traffic.

---

## Success criteria

Observable and meaningful. They verify understanding, not configuration.

Prefer:

> Explain why the Pod reaches its observed phase and how that relates to the
> container state.

over:

> Set `restartPolicy: Never`.

When prediction is part of the lab, criteria may include that a prediction was
made before the experiment and that the learner can explain any difference. Do
not require the prediction to be correct.

`labs/NN-*/verify.sh` checks the stated requirements and dumps evidence. It must
never assert an expected outcome — that would leak the answer.

---

## Optional experiments

Marked `## Optional experiments`. Never required by the success criteria, never
a different topic, never the hiding place for the main answer, always small.

If one grows large enough to need real explanation, promote it to its own lab.

---

## Lab numbering

The number is the learning sequence. It is not an API version, a CKAD domain, a
feature, a research iteration, or a revision counter.

Before creating a lab, check whether the objective already exists. If it does,
improve that lab rather than adding a duplicate. Do not renumber existing labs
casually. Numbering is enforced by `tests/rules/r1-lab-numbering.sh`.

---

## Notes

A note answers: *what did I learn that will be useful again?*

Structure:

```text
What / Why / Example / Gotchas / Used in
```

`Used in` points at real files in this repository.

Categories, and no others without a strong reason:

```text
notes/concepts/          how something works
notes/troubleshooting/   symptom -> diagnosis -> fix
notes/patterns/          reusable approaches
```

Inline markers when useful: `> TODO:`, `> QUESTION:`, `> OBSERVATION:`.
Do not retro-fit them to existing notes.

Do not write a note because documentation exists. Write it because something was
learned.

---

## CKAD orientation

Labs target the current official domains: Application Design and Build;
Application Deployment; Application Observability and Maintenance; Environment,
Configuration and Security; Services and Networking.

Verify domain names and any percentage against current official CKAD
information before writing it into a lab. Do not copy figures from older
curricula.

Favour skills a performance-based exam actually tests: creating, modifying,
inspecting, troubleshooting, using `kubectl` efficiently, reading YAML,
interpreting cluster state, recovering from mistakes. Skip trivia.

**Time budget.** Every lab declares one in `## Before you begin`, sized like an
exam task. It makes speed visible, which is half of CKAD.

**Efficiency discussion.** Where several approaches work, discuss which is
faster, which is less error-prone, and when imperative beats declarative — not
to prescribe one method, but so the learner can choose well under time pressure.

`cluster/EXAM-SETUP.md` holds the shell and `kubectl` ergonomics that make this
possible.

**Version awareness.** When a lab depends on an API version, field, default,
deprecation, or controller behavior, verify it against the Kubernetes version in
`kind-ckad`. Do not trust an old tutorial. Document a deliberate version
difference explicitly.

---

## Repository changes

Keep changes focused: touch only what the lab needs, no drive-by refactoring, no
casual convention changes. When a structural change is genuinely needed, explain
why, make the smallest useful version of it, and leave learning content intact.

---

## Lab checklist

One list. Run it before calling a new or revised lab finished.

**Research** — see `CLAUDE.md` for the mechanism and the gate.

1. Existing labs inspected; the topic is not already covered.
2. Research gate passed: CKAD relevance and technical behavior both established
   from retrieved sources.
3. Version-sensitive behavior verified against the cluster's Kubernetes version.

**Design**

4. One clear primary objective, stated as a capability.
5. The smallest useful experiment identified.
6. The first practical action is reachable with minimal reading.
7. Each scenario has one immediate goal and is independently actionable.
8. Complexity increases progressively.
9. Theory is delayed until after the observation where possible.
10. No table or scenario exists only for completeness.
11. Every scenario is necessary for the primary objective; the rest are optional
    or deferred.

**Workflows**

12. Imperative and declarative coverage decided deliberately.
13. If both are meaningful, both exist, both are labelled, both are required.
14. They share the same or an equivalent scenario, and do not multiply scenarios.
15. If only one is used, the lab says why in one line.

**Learning integrity**

16. No solution leakage: no manifests, no solving commands, no pre-revealed
    outcomes.
17. Prediction comes before observation.
18. Required evidence is defined, and is the minimum that settles the question.
19. Troubleshooting tasks do not disclose the root cause.
20. Success criteria test understanding and are observable.
21. Optional experiments are separated and carry no required scope.

**Repository**

22. Namespace is `lab-NN`; a `## Cleanup` section deletes it.
23. Time budget declared.
24. Numbering unique and sequential; title matches the directory.
25. `verify.sh` checks requirements only, asserts no outcomes.
26. The learner's implementation was not modified.
27. `./tests/rules/run-all.sh` passes.

---

## Guiding principle

```text
Read little -> start quickly -> do one small thing -> observe -> explain -> repeat
```

not:

```text
Read everything -> understand all theory -> execute a large exercise -> finish
```

The best lab is not the one with the most features or the most scenarios. It is
the one producing the most learning per unit of cognitive overhead.
