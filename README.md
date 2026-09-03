# Kubernetes Learning

Hands-on Kubernetes learning and CKAD preparation.

## Goal

Learn Kubernetes through hands-on projects, experiments,
troubleshooting, and deliberate practice.

The goal is not to maximize study time or video consumption.
The goal is to build understanding that can be explained,
applied, and defended.

## Structure

* `labs/` — hands-on Kubernetes exercises
* `notes/` — knowledge learned in context
* `scratch/` — temporary AI-generated reference implementations
* `GUIDE.md` — instructions for Claude Code working in this repository
* `RULES.md` — enforceable repository invariants
* `tests/rules/` — automated checks for repository rules

## Learning workflow

The basic loop is:

```text
Learn just enough
      ↓
Attempt the task myself
      ↓
Run it in Kubernetes
      ↓
Observe the result
      ↓
Investigate / troubleshoot
      ↓
Compare with an AI reference when useful
      ↓
Understand the differences
      ↓
Write down what I learned
      ↓
Turn important invariants into rules
```

### 1. Start with a concrete task

Do not start by trying to "learn Kubernetes".

Start with a small practical problem that requires a Kubernetes concept.

For example:

> Deploy nginx and make it reachable through a Service.

The task should be small enough that I can attempt it myself.

### 2. Attempt it myself

I write the Kubernetes manifests and commands myself.

I use:

* `kubectl`
* `kubectl explain`
* Kubernetes documentation
* the Udemy course
* experiments in my local cluster

AI should not give me the complete solution before I have attempted the task.

### 3. Use the course when I need it

The Udemy course is a reference and explanation source,
not the primary learning loop.

If I encounter a concept I don't understand,
I consume only the relevant part of the course when possible.

Then I return to the lab and apply what I learned.

### 4. Run and investigate

A manifest is not considered understood just because it looks correct.

I apply it to the cluster and inspect the actual behavior.

For example:

```bash
kubectl get pods
kubectl describe pod <name>
kubectl logs <name>
kubectl get svc
kubectl get endpoints
```

I should be able to explain why the resulting system behaves as it does.

### 5. Compare with AI

After my first implementation, I can ask Claude Code
to create a reference implementation in `scratch/`.

I compare the two implementations and investigate
every meaningful difference.

The purpose is not to determine which YAML is "correct".

The purpose is to understand:

* why the implementations differ;
* whether the difference matters;
* which approach I prefer;
* when the alternative would be useful.

### 6. Capture learning immediately

When something genuinely new is learned during a lab,
I create a note immediately rather than scheduling a later study session.

Notes follow:

```text
What
Why
Example
Gotchas
Used in
```

The `Used in` section should point back to real files in this repository.

### 7. Turn important discoveries into rules

When I discover something that should always be true,
I ask whether it can become an enforceable rule.

The process is:

```text
Observation
    ↓
"What should always be true?"
    ↓
"How could a test detect a violation?"
    ↓
RULES.md
    ↓
Automated test
```

If I cannot describe how to detect a violation,
it is a preference or guideline rather than a rule.

### 8. Practice troubleshooting

Not all labs should be about creating something from scratch.

Some labs should start with a broken Kubernetes system.

The goal is to practice:

```text
Observe
  ↓
Hypothesis
  ↓
kubectl / experiment
  ↓
Evidence
  ↓
Diagnosis
  ↓
Fix
  ↓
Explain
```

### 9. Practice under CKAD conditions

Once a concept has been practiced,
repeat it as a time-constrained CKAD-style task.

During exam-mode exercises:

* use only the task requirements;
* avoid AI hints unless explicitly requested;
* work primarily with `kubectl`;
* verify the final state yourself;
* only then have AI evaluate the result.

## Progress

The useful measure of progress is not:

> "How many hours of Kubernetes did I study?"

Instead ask:

* What Kubernetes behavior can I now explain?
* What problem can I diagnose without help?
* What rule did I discover or tighten?
* What technical decision can I defend better than before?

If I can answer those questions with concrete examples,
the learning is working.
