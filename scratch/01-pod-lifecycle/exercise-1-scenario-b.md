<!-- ai-generated -->
# Scenario B — Exit with failure (Never)

## Prediction

Pod phase: Failed, container Terminated/Error, exit 1.
STATUS column: Error.

## Commands

```bash
kubectl run failure-never --image=busybox --restart=Never -- sh -c "echo oops && exit 1"
```

## Observation

```
NAME              READY   STATUS   RESTARTS   AGE
failure-never     0/1     Error      0         28s

describe pod failure-never:
  Status: Failed
  State: Terminated, Reason: Error, Exit Code: 1
```

## Explanation

Exit code 1 + `restartPolicy: Never` = container crashes once, no restarts.
Pod ends up Failed. `get pods` shows `Error` (simplified), phase shows `Failed`.

## Learner's approach (Scenario B was pre-existing)

The learner had already completed Scenario B. Predicted correctly.
