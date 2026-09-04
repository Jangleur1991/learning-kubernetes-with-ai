# kubectl run: command mit Argumenten wird nicht richtig aufgeteilt

## What
Bei `kubectl run` wird das Command nach `--` manchmal als einzelner String statt als Command + Argumente interpretiert. Busybox hat kein Executable mit Leerzeichen im Namen → `executable file not found in $PATH`.

## Why
`kubectl run` nimmt alles nach `--` als `command` für den Container. Das Shell-Argument-Splitting kann dazu führen, dass der komplette String als Executable interpretiert wird, statt als `command` + `args` aufgeteilt zu werden.

## Example

So sieht es in `kubectl describe pod` aus, wenn es falsch gelaufen ist:

```
exec: "sh -c 'echo done && exit 0'": executable file not found in $PATH
```

Das bedeutet: Kubernetes hat versucht, ein Executable mit dem Namen `sh -c 'echo done && exit 0'` zu finden — statt `sh` mit `-c` als Argument auszuführen.

## Fix
`command` und `args` explizit trennen:

```bash
kubectl run success-never --image=busybox -- sh -c "echo done && exit 0"
```

Wichtig: `sh` steht als separater Parameter vor `-c`, nicht als Teil eines Strings.

## Gotchas
- Busybox / Alpine haben `/bin/sh`, nicht `/bin/bash`
- `kubectl run` ohne `--restart=Never` setzt `restartPolicy: Always` (default)
- `restartPolicy: Always` + fehlgeschlagener Container = `CrashLoopBackOff`

## Used in
- `labs/01-pod-lifecycle/`
