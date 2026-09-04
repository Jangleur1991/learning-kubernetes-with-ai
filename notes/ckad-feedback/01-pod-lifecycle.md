<!-- ai-generated -->
# CKAD Feedback — Lab 01 Pod Lifecycle

## 2026-09-04 — Exercise 1, Scenario A/B (rekonstruiert aus bestehenden Notizen)

**Gut:** Command-Splitting-Fehler bei `kubectl run` selbst diagnostiziert und die Completed/Succeeded- bzw. Error/Failed-Falle dokumentiert.
**Verbessern:** Der `<cmd> -- sh -c "<args>"`-Split saß noch nicht automatisch, hat einen vollen Debug-Zyklus gekostet.
**Nächster Schritt:** `kubectl run ... -- sh -c "..."` ein paar Mal aus dem Gedächtnis üben, ohne Fehlerschleife.

---

## 2026-09-04 — Exercise 1, Scenario C (auf Anfrage gelöst)

**Gut:** `kubectl explain pod.spec.backoffLimit` genutzt statt zu raten; `grep -A2 State` statt vollem describe-Output.
**Verbessern:** Nach bestätigtem "Feld existiert nicht" trotzdem noch zwischen Optionen geschwankt, statt die Konsequenz sofort zu ziehen.
**Nächster Schritt:** "restartPolicy + Exit Code -> Pod-Phase" für Never/OnFailure laut durchgehen, ohne kubectl explain als Krücke.
