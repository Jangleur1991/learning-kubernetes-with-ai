# `describe pod` - State, Reason, Exit Code

## What

Mit `grep -A2 State` siehst du den Container-Zustand plus Reason und Exit Code in einer Zeile.

## Why

Ohne `-A2` zeigt `grep State` nur eine Zeile: `Terminated`. Die Details (Warum? Exit-Code?) stehen darunter.

## Beispiel

```bash
describe pod failure-never | grep -A2 State

# Ergebnis:
#     State:          Terminated
#       Reason:       Error
#       Exit Code:    1
```

## Used in

- `labs/01-pod-lifecycle/` Scenario B
