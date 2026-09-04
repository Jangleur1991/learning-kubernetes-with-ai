<!-- ai-generated -->
# Wann wird die Pod-Phase terminal?

## What

Die Pod-Phase wird nur dann terminal (`Succeeded` oder `Failed`), wenn laut
`restartPolicy` kein weiterer Neustart mehr ansteht. Solange ein Neustart
möglich ist, bleibt die Phase `Running` — egal wie oft der Container schon
gecrasht ist.

## Why

Eine Tabelle mit jeder restartPolicy/Exit-Code-Kombination ist schwer
auswendig zu lernen. Eine Regel reicht: "Kann der Kubelet noch mal starten?
Wenn ja: Running. Wenn nein: terminal."

## Beispiel

Herleitung statt Nachschlagen, angewendet auf `restartPolicy: Never` und
`restartPolicy: OnFailure` — siehe `labs/01-pod-lifecycle/` Scenario A, B, C
für die konkreten Fälle und die beobachteten Werte.

## Gotchas

- `Running` heißt hier nicht "Container führt gerade seinen Befehl aus",
  sondern "Pod ist am Leben, mindestens ein Container wird gestartet oder
  neu gestartet".
- `restartPolicy: Always` noch nicht selbst durchdacht — siehe
  `## Optional experiments` in `labs/01-pod-lifecycle/README.md`. Die
  Regel gilt genauso, aber die Konsequenz für `Always` ist bewusst offen
  gelassen.
- Verwandter Gotcha bereits notiert in
  `notes/troubleshooting/command-as-single-string.md`: `Always` +
  fehlgeschlagener Container zeigt `CrashLoopBackOff` in der STATUS-Spalte.

## Used in

- `labs/01-pod-lifecycle/` Scenario A, B, C
- siehe auch `notes/concepts/three-statuses.md` (STATUS-Spalte vs. Phase vs.
  Container-Zustand, Tabelle nur für `Never`)
