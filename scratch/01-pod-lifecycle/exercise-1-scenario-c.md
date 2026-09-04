<!-- ai-generated -->
# Scenario C — Exit with failure, allow restarts (OnFailure)

## Prediction

Pod phase: Running (container keeps restarting).
Container state: Terminated/Error between restarts.
`get pods`: oscillates between Running and Error.
backoffLimit: does not exist on Pod spec — trap.

## Commands

```bash
kubectl run failure-onfailure --image=busybox --restart=OnFailure -- sh -c "echo attempt \$RANDOM && exit 1"
```

## Observation

```
First read (4s):
NAME                READY   STATUS   RESTARTS      AGE
failure-onfailure   1/1     Running  1 (2s ago)    4s

Second read (27s):
NAME                READY   STATUS   RESTARTS      AGE
failure-onfailure   0/1     Error    2 (24s ago)   27s

describe pod:
  Status: Running               ← Pod phase
  State: Terminated
    Reason: Error
    Exit Code: 1
  Last State: Terminated
    Reason: Error
    Exit Code: 1
  Restart Count: 2

Events:
  Warning BackOff 10s (x2 over 11s)  kubelet
  Normal Pulled 1s (x3 over 14s)      kubelet
  Normal Created 1s (x3 over 13s)      kubelet
  Normal Started 0s (x3 over 13s)      kubelet
```

`kubectl logs --previous`: FAILED (container too short-lived for containerd)

## Explanation

`restartPolicy: OnFailure` = restart forever if container crashes.
No `backoffLimit` on Pods — it's a Job-only field.
Pod stays Running because kubelet keeps restarting.
`get pods` STATUS oscillates: snapshot at moment of query.
`--previous` fails for extremely short-lived containers.

## Learner's approach — detailed comparison

1. **Correctly identified** that `backoffLimit` does not exist on Pod spec.
   Used `kubectl explain pod.spec.backoffLimit` → "field does not exist". ✓
   This is a key CKAD skill: verifying API fields exist.

2. **Predicted wrong** initially: said "Der restartet immer" (keeps restarting)
   but then guessed "3 mal maximal" when asked about backoffLimit.
   The learner vacillated between "infinite" and "limited by backoffLimit."
   Even after being told backoffLimit doesn't exist on Pods, predicted "3 mal"
   before correcting to "läuft weiter."

3. **Typo error**: typed `failure-onfailue` (missing 'l'). Small but in a timed
   exam, even typos cost precious seconds.

4. **Correct command syntax**: `kubectl run failure-onfailure --image=busybox
   --restart=OnFailure -- sh -c "echo attempt $RANDOM && exit 1"` — perfect.

5. **Gathered good evidence**: used `grep -A2 State` to get state+reason+exit
   code. Correct command for inspecting container state.

6. **Understanding gap**: The learner correctly concluded the pod keeps running,
   but struggled with the **pod phase** question. Asked me repeatedly to check
   `pod.status.phase` — this is a tooling crutch. In CKAD, you need to know
   the mapping without asking an AI.

7. **Stopped at the wrong place**: When I showed the learner that Pod phase is
   `Running` despite all containers being Terminated with exit code 1 — this
   was the core insight, but the learner didn't sit with it to internalize it.

## Key differences

| Aspect | Learner | Reference |
|--------|---------|-----------|
| backoffLimit check | ✓ Used `kubectl explain` | ✓ Same |
| backoffLimit prediction | ✗ Said "3 mal maximal" before correcting | Knew immediately |
| Pod phase understanding | Partially correct | Understood "Running" despite Terminated containers |
| `get pods` vs `describe pod` | Knew about difference | Observed oscillation pattern |
| Typo on pod name | Yes (failure-onfailue) | No typos |
| `--previous` logs | Correctly attempted, noted failure | Same |
| Evidence gathering | Good use of grep -A2 State | More systematic timing |
| Confidence in reasoning | Hesitant, needed prompting | Decisive |
