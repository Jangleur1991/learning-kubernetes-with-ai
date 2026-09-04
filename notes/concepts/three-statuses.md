# Pod-Phase vs Container-Zustand vs STATUS-Spalte

## What

Drei verschiedene Dinge, die auf den ersten Blick gleich aussehen:

1. Pod-Phase (`describe pod` → `Status:`): `Succeeded` / `Failed`
2. Container-Zustand (`describe pod` → `State:`): `Terminated`
3. STATUS-Spalte von `get pods`: `Completed` / `Error`

## Why

In der Prüfung liest man `get pods` und denkt, die Phase sei `Completed`. Ist
sie nicht — `get pods` zeigt eine vereinfachte Darstellung, nicht die echte
Phase.

## Beispiel

```bash
# Container beendet mit Exit 0
get pod success-never
# STATUS: Completed
describe pod success-never
# Status: Succeeded

# Container beendet mit Exit 1
get pod failure-never
# STATUS: Error
describe pod failure-never
# Status: Failed
```

## Mapping Container-Reason → get pods STATUS → Pod-Phase

| Container-Reason | Exit Code | STATUS-Spalte | Pod-Phase |
|---|---|---|---|
| `Completed` | 0 | `Completed` | `Succeeded` |
| `Error` | 1 | `Error` | `Failed` |

## Commands

- `kubectl get pod <podname>` → vereinfachte STATUS-Spalte
- `kubectl describe pod <podname>` → Phase + Container-Status + Events (alles auf einmal)
- `kubectl explain pod.status.phase` → alle möglichen Pod-Phasen
- `kubectl explain pod.status.containerStatuses.state` → alle möglichen Container-Status

## Gotchas

- `Completed` ≠ `Succeeded` — zwei verschiedene Dinge
- `Error` ≠ `Failed` — die STATUS-Spalte zeigt `Error`, nicht `Failed`
- In der Prüfung immer `describe pod` nutzen, wenn die echte Phase gefragt ist

## Used in

- `labs/01-pod-lifecycle/` Scenarios A und B
