# Progress

Not "how many hours did I study". These instead:

* What Kubernetes behavior can I now explain?
* What can I diagnose without help?
* Which prediction was wrong, and why?

## Labs

Status: `todo` | `in progress` | `done` | `revisit`

| Lab | Status | First done | Time taken | Budget | Predictions right | Revisit by |
| --- | --- | --- | --- | --- | --- | --- |
| 01-pod-lifecycle | in progress | | | 12 min | | |

## Revisit policy

CKAD is a speed exam. A lab passed once is not a lab learned.

Re-run each `done` lab from scratch, timed, with no notes:

```text
first pass -> +3 days -> +2 weeks -> +6 weeks
```

Set `Revisit by` when you mark a lab `done`. A revisit that goes over budget or
produces a wrong prediction resets the lab to `revisit`.

## Exam mode

For a timed run:

1. `kubectl create namespace lab-NN`
2. Start a timer for the lab's declared budget.
3. Work only from the task text. No notes, no AI, no documentation beyond
   `kubectl explain` and `kubectl -h`.
4. Verify the result yourself.
5. Only then run `./labs/NN-*/verify.sh` and ask for a review.

Record the time even when you go over. The overrun is the signal.

## Wrong predictions

The most valuable column in this file. Log each one — they are where the actual
learning is.

| Date | Lab | Predicted | Actual | Why I was wrong |
| --- | --- | --- | --- | --- |
