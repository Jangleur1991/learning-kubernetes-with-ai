<!-- ai-generated -->
# Scenario A — Exit with success (Never)

## Prediction

Pod phase: Succeeded, container Terminated/Completed, exit 0.
Container state: Terminated, Reason: Completed.

## Commands

```bash
kubectl run success-never --image=busybox --restart=Never -- sh -c "echo done && exit 0"
```

## Observation

```
NAME              READY   STATUS    RESTARTS   AGE
success-never     0/1     Completed   0        6s

describe pod success-never:
  Status: Succeeded
  State: Terminated, Reason: Completed, Exit Code: 0
```

## Explanation

Exit code 0 + `restartPolicy: Never` = container runs once, exits cleanly.
Pod reaches Succeeded. STATUS column in `get pods` shows `Completed`
(simplified), phase shows `Succeeded` (full).

## Learner's approach (Scenario A was pre-existing)

The learner had already completed Scenario A. No specific issues to compare.
