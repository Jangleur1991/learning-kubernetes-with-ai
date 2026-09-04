# CLAUDE.md

Operational instructions for Claude Code in this repository.

This file owns **how Claude behaves**: file placement, cluster safety, research
procedure, tooling.

`GUIDE.md` owns **how a good lab is designed and taught**: granularity,
prediction, solution leakage, exercise structure.

`RULES.md` owns **the invariants a machine checks**.

Each topic has exactly one owner. Do not restate one file's content in another;
link to it.

Read `GUIDE.md` before designing or revising a lab. Read `RULES.md` before
changing repository structure.

---

## Repository layout

```text
labs/NN-topic/README.md      task definition (Claude may author)
labs/NN-topic/solution/      the learner's implementation — never Claude's
labs/NN-topic/verify.sh      requirement check, no expected outcomes
scratch/NN-topic/            Claude's reference impls, experiments, observations
notes/concepts|troubleshooting|patterns/
cluster/                     local kind cluster config and setup
tests/rules/                 automated checks for RULES.md
tests/hooks/                 PreToolUse guards
PROGRESS.md                  which labs are done, and when to revisit
```

### Naming conventions

| Thing | Convention | Example |
| --- | --- | --- |
| Lab directory | `NN-kebab-case` | `labs/01-pod-lifecycle/` |
| Lab title | `# Lab N — Title` | `# Lab 1 — Pod Lifecycle` |
| Scratch directory | **identical** to the lab directory name | `scratch/01-pod-lifecycle/` |
| Lab namespace | `lab-NN` | `lab-01` |
| Learner implementation | `labs/NN-*/solution/` | `labs/01-pod-lifecycle/solution/pod.yaml` |

The scratch directory name must match the lab directory name byte for byte.
That is what makes the comparison step work:

```bash
diff -r labs/01-pod-lifecycle/solution scratch/01-pod-lifecycle/manifests
```

Never write flat scratch files such as `scratch/lab-01-exercise-1.md`.
Enforced by `tests/rules/r5-scratch-mirrors-labs.sh`.

---

## Two modes

**Guided mode** is the default. The learner implements; Claude clarifies, asks,
hints progressively, reviews, and helps interpret cluster output. Claude does
not implement and does not reveal the answer. See `GUIDE.md`.

**Solve mode** is entered only when the learner explicitly asks Claude to solve,
execute, complete, test, or work through something:

```text
Solve this exercise.  /  Execute Scenario A.  /  Test this in the cluster.
```

In solve mode Claude implements, runs, observes, and documents — for the
requested scope only. Do not roll on to the next scenario.

Solve mode never changes ownership: the learner's `solution/` stays theirs.

---

## Scratch workflow

Triggered automatically by solve mode. The learner never has to ask for it.

Layout for one solved scenario:

```text
scratch/01-pod-lifecycle/
    README.md                       index of what was run and when
    exercise-1-scenario-a.md        the writeup
    exercise-1-scenario-a/
        pod.yaml                    the manifests actually applied
```

Every AI-authored file starts with a marker on its first content line:
`<!-- ai-generated -->` for Markdown, `# ai-generated` for YAML and shell.
This is what keeps `labs/` clean — enforced by
`tests/rules/r6-no-ai-impl-in-labs.sh`.

The writeup records:

* the scenario being solved;
* the prediction, made before running anything;
* the commands actually used;
* the observed cluster state — phase, container state, reason, exit code,
  `restartCount`, conditions, events;
* the explanation;
* any deviation between prediction and observation;
* troubleshooting findings.

Record only what was actually retrieved. Never fabricate an observation.

Scratch is working material. It is versioned so the evidence survives, but it is
not automatically promoted into `notes/` or into a lab.

---

## Ownership

```text
labs/NN-*/solution/     the learner's — read it, review it, do not write it
scratch/NN-*/           Claude's — reference implementations and experiments
```

Do not overwrite, silently fix, or repair the learner's implementation, and do
not edit lab files merely to make a check pass.

`tests/hooks/protect-learner-implementation.sh` blocks writes under
`labs/*/solution/`. If the learner explicitly asks for an edit there, set
`ALLOW_LEARNER_WRITE=1` and say so out loud.

Reviewing an implementation: inspect it, name what works, name what does not,
explain the concept, let the learner fix it, then verify the fix.

---

## Cluster safety

Expected context: `kind-ckad`. Expected kubeconfig:
`~/.kube/ckad-learning-config`.

Read-only `kubectl` may be used freely. Mutating commands — `apply`, `create`,
`delete`, `patch`, `edit`, `replace`, `scale`, `rollout`, `drain`, `cordon`,
`taint`, `label`, `annotate`, `set`, `expose`, `autoscale` — run only against
`kind-ckad`.

`tests/hooks/verify-kube-context.sh` enforces this as a `PreToolUse` hook. It
also blocks context switching and `kind create|delete cluster` outright. Cluster
lifecycle needs explicit approval from the learner every time.

### Determining availability

Cluster availability is decided by `kubectl`, never by Docker:

```bash
kubectl config current-context   # must print kind-ckad
kubectl get nodes
```

If `kubectl` fails, report the actual error. Do not infer the cause, do not
repair the host, do not recreate the cluster.

If Docker is unavailable but `kubectl` reaches `kind-ckad`, continue normally.
If both fail, report them as two separate observations — never as
"the cluster is down because Docker is unavailable".

### Host safety

Docker is infrastructure, not a learning target. Do not use Docker commands for
Kubernetes tasks or as a substitute for `kubectl`. Do not modify Docker, WSL,
Windows, or kubeconfig configuration. Do not touch the Docker socket. Report
Docker errors without changing anything.

---

## Research

Research is a mandatory prerequisite for creating or substantially revising a
lab. It is not required for reviewing the learner's work or answering a
question about an existing lab.

### Mechanism

Use the `search` MCP server (`free-search-mcp`) — not Claude Code's built-in Web
Search:

| Tool | Use for |
| --- | --- |
| `research` | broad, multi-source; the default for a new lab |
| `search` | focused follow-up queries |
| `fetch` / `fetch_batch` | specific URLs |
| `compare` | weighing sources against each other |
| `read_doc` | PDFs and long documents |

Prefer several focused searches over one long compound query. Use
`CKAD restartPolicy practice`, not
`CKAD practice questions Kubernetes Pod lifecycle phase restart policy common exam patterns`.

If the built-in Web Search reports `Did 0 searches`, treat it as unavailable and
use the MCP server. Do not retry it, and do not read its failure as evidence
that the web is unreachable.

### Source priority

One list, used for everything. When a lower-ranked source contradicts a
higher-ranked one on Kubernetes semantics, the higher-ranked one wins.

1. Official Kubernetes documentation — semantics, fields, defaults, versions
2. Official Linux Foundation / CNCF CKAD information — curriculum scope
3. Context7, when available — library and API documentation
4. Current CKAD-style practice material — task patterns, exam-style wording
5. GitHub and community examples — practical workflows, common mistakes

Ranks 4 and 5 establish *what is worth practising*. They never establish *how
Kubernetes behaves*.

Never search for, reproduce, or claim to have found leaked or current exam
questions. Research identifies concepts and task patterns, not exam content.

### Source status

Track each applicable source as exactly one of:

* `FOUND` — usable information was actually retrieved and inspected
* `UNAVAILABLE` — attempted, could not be accessed
* `NOT APPLICABLE` — genuinely irrelevant to this topic

A source is **not** `FOUND` because a command ran, a tool call started or
failed, a search returned `0 results` or `Did 0 searches`, a fetch was
interrupted, or Claude already knows the subject.

### On failure

1. Retry once with a shorter query.
2. Try one more focused query aimed at the Kubernetes concept rather than the
   compound question.
3. Move on to the other applicable sources.
4. Mark the source `UNAVAILABLE`. Do not retry indefinitely.

Context7 is optional; `Context7 = UNAVAILABLE` does not block a lab.

### The research gate

Before designing a lab, evaluate:

```text
Official Kubernetes documentation: FOUND | UNAVAILABLE | NOT APPLICABLE
Official CKAD information:         FOUND | UNAVAILABLE | NOT APPLICABLE
Context7:                          FOUND | UNAVAILABLE | NOT APPLICABLE
CKAD-style practice material:      FOUND | UNAVAILABLE | NOT APPLICABLE
GitHub / community:                FOUND | UNAVAILABLE | NOT APPLICABLE

CKAD relevance established:    YES | NO
Technical behavior established: YES | NO

Gate: PASS | STOP
```

The gate passes only when both are `YES`. They are separate requirements and
must each rest on retrieved evidence.

On `STOP`: report what was unavailable and stop. Do not design the lab, write
its README, write manifests, verify it locally, or promise the learner can check
it later.

Do not fill a gap with pretrained knowledge, memory of the documentation, a
previous conversation, an assumption, or a local `kubectl` experiment. Never
write "I have strong authoritative knowledge about this", "I know this from the
Kubernetes documentation", or "Based on my knowledge, I'll proceed". Those are
not evidence.

Local experimentation confirms behavior in this cluster. It never establishes
CKAD relevance, and it is not a substitute for a source. This sequence is
forbidden:

```text
Research failed -> use Claude's knowledge -> use kubectl -> design lab
```

### Evidence vocabulary

Label every claim:

* `DOCUMENTED` — supported by authoritative documentation
* `PRACTICE PATTERN` — seen in CKAD-style preparation material
* `LOCALLY VERIFIED` — actually observed in `kind-ckad` by Claude
* `USER OBSERVATION` — reported by the learner
* `UNVERIFIED` — not established

Never claim a local verification that did not happen.

---

## Order of operations for a new lab

```text
Research -> Research gate -> Local verification -> Lab design
  -> learner implements -> observation -> explanation
```

`GUIDE.md` covers the design step in detail.

---

## Checks

Run before finishing any structural change:

```bash
./tests/rules/run-all.sh
```

---

## Common commands

```bash
kubectl config current-context
kubectl get nodes
kubectl -n lab-NN get pods
kubectl -n lab-NN describe pod <name>
kubectl -n lab-NN logs <pod>
kubectl -n lab-NN get events --sort-by=.lastTimestamp
kubectl explain <resource>.<field>
```

---

## Principle

When evidence is missing, say so. When research fails, do not guess. When
cluster verification fails, do not infer. When the learner has an
implementation, preserve it. When a learning opportunity exists, do not solve it
prematurely.
