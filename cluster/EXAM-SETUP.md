# Exam setup

Shell and `kubectl` ergonomics. Under CKAD time pressure, typing speed is a real
part of the score — this file is not optional polish.

`README.md` in this directory covers building the cluster. This file covers
working in it quickly.

---

## Shell

Add to `~/.bashrc`:

```bash
# kubeconfig for the learning cluster
export KUBECONFIG=~/.kube/ckad-learning-config

# the single most useful alias
alias k=kubectl
source <(kubectl completion bash)
complete -o default -F __start_kubectl k

# dry-run to YAML — the fastest way to a manifest skeleton
export do='--dry-run=client -o yaml'

# delete without waiting out the grace period
export now='--force --grace-period=0'
```

Then:

```bash
k run web --image=nginx $do > pod.yaml
k delete pod web $now
```

`$do` and `$now` are the two exports the CKAD community converged on. Learn them
as muscle memory; they are allowed and they save minutes.

---

## Namespace

Set it once per lab instead of typing `-n` on every command:

```bash
k config set-context --current --namespace=lab-01
k config view --minify | grep namespace     # confirm where you are
```

Reset when the lab is done:

```bash
k config set-context --current --namespace=default
```

---

## vim

`~/.vimrc`:

```vim
set expandtab
set tabstop=2
set shiftwidth=2
set number
" toggle before pasting a block, or the indentation cascades
set pastetoggle=<F2>
```

YAML is indentation-sensitive and the exam terminal is not forgiving. Get this
in place before you need it.

---

## Finding fields without leaving the terminal

```bash
k explain pod.spec.containers.livenessProbe
k explain deploy.spec.strategy --recursive | head -40
k api-resources | grep -i ingress          # resource name, short name, apiVersion
k get pod web -o yaml | less               # a real object beats documentation
```

`kubectl explain --recursive` is usually faster than searching the docs site.

---

## Speed patterns

| Task | Fast route |
| --- | --- |
| Pod manifest | `k run NAME --image=IMG $do > p.yaml` |
| Deployment manifest | `k create deploy NAME --image=IMG $do > d.yaml` |
| Service for a deployment | `k expose deploy NAME --port=80 $do > s.yaml` |
| ConfigMap from literals | `k create cm NAME --from-literal=k=v $do` |
| Secret from literals | `k create secret generic NAME --from-literal=k=v $do` |
| Job / CronJob | `k create job NAME --image=IMG $do` |
| Edit a running object | `k edit TYPE NAME` |
| Change one field | `k patch TYPE NAME -p '{"spec":{...}}'` |
| Watch a rollout | `k rollout status deploy/NAME` |
| Wait for a condition | `k wait --for=condition=Ready pod/NAME --timeout=60s` |
| All events, newest last | `k get events --sort-by=.lastTimestamp` |

`k run` and `k create` cover generators for Pod, Deployment, Job, CronJob,
Service, ConfigMap, Secret, ServiceAccount, Role, RoleBinding, Ingress,
Namespace, Quota, PDB. Anything else is hand-written YAML — know which is which
before the clock starts.

---

## Verify, do not assume

```bash
k get pod NAME -o jsonpath='{.status.phase}{"\n"}'
k get ep NAME                    # a Service with no endpoints is the classic trap
k describe pod NAME | tail -20   # events live at the bottom
```

---

## Claude Code note

The Bash sandbox blocks the loopback connection to the kind API server. A
top-level `kubectl` command is exempted in `.claude/settings.local.json`, but a
*script* that calls `kubectl` is not automatically exempt — add it to
`excludedCommands` or the connection is refused with:

```text
The connection to the server 127.0.0.1:PORT was refused
```

This affects Claude only. Your own terminal is unaffected.
