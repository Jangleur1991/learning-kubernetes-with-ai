# Local Kubernetes Cluster

This directory contains the configuration and documentation for the local Kubernetes cluster used by the CKAD learning repository.

The cluster is a disposable local Kubernetes environment used for hands-on exercises, experimentation, and troubleshooting.

The environment uses:

```text
Windows
  │
  └── WSL2
       │
       └── Ubuntu
            │
            └── Docker Desktop
                 │
                 └── kind
                      │
                      ├── control-plane
                      ├── worker
                      └── worker
```

The Kubernetes nodes are Docker containers. They are not separate virtual machines.

---

## Cluster identity

The learning cluster is named:

```text
ckad
```

The corresponding Kubernetes context is:

```text
kind-ckad
```

The cluster consists of:

```text
1 × control-plane
2 × worker
```

The cluster is intentionally disposable.

It exists only as the execution environment for the learning repository.

---

## Prerequisites

The following software is required:

* Windows with WSL2
* Ubuntu running under WSL2
* up-to-date WSL
* Docker Desktop
* Docker Desktop WSL2 backend
* Docker Desktop WSL integration for Ubuntu
* `kubectl`
* `kind`

---

## 1. WSL setup

Check the installed WSL version from PowerShell:

```powershell
wsl --version
```

Keep WSL up to date:

```powershell
wsl --update
```

After updating WSL, restart it:

```powershell
wsl --shutdown
```

Then start Ubuntu again and restart Docker Desktop.

The WSL version is important because the Kubernetes nodes require appropriate cgroup support.

---

## 2. Docker Desktop setup

Docker Desktop must be running.

Docker Desktop should use the WSL2 backend.

Ubuntu must be enabled under:

```text
Docker Desktop
→ Settings
→ Resources
→ WSL Integration
```

Enable integration for the Ubuntu distribution used for this repository.

Verify Docker access from Ubuntu:

```bash
docker info
```

The command must succeed.

---

## 3. Verify cgroups

The kind nodes require cgroup v2 in this environment.

Check:

```bash
docker info | grep -i cgroup
```

Expected:

```text
Cgroup Driver: cgroupfs
Cgroup Version: 2
```

The cgroup version is the important requirement.

### Historical cgroup problem

The first cluster creation attempt failed while Docker was using cgroup v1.

The kubelet reported:

```text
kubelet is configured to not run on a host using cgroup v1
```

The kubelet therefore did not start correctly and the Kubernetes API server never became available.

Updating WSL resolved the problem and resulted in a working cgroup v2 environment.

A manual attempt to force cgroup v2 through `.wslconfig` caused Docker Desktop WSL integration to stop working.

Therefore, do not add manual `.wslconfig` cgroup configuration unless there is a specific reason.

The preferred approach is:

```text
Update WSL
    ↓
WSL provides cgroup v2
    ↓
Docker Desktop
    ↓
kind
    ↓
Kubernetes
```

---

## 4. Install and verify kubectl

Verify that `kubectl` is installed:

```bash
kubectl version --client
```

If it is not installed, install it according to the official Kubernetes documentation.

The exact Kubernetes server version is provided by the kind node image.

---

## 5. Install and verify kind

Verify:

```bash
kind version
```

The repository uses kind to create the local Kubernetes cluster.

---

## 6. Cluster configuration

The kind configuration is stored in:

```text
cluster/kind-config.yaml
```

The configuration should contain:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

name: ckad

nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

The explicit:

```yaml
name: ckad
```

is important.

It ensures that the cluster is consistently named:

```text
ckad
```

and that kind creates the Kubernetes context:

```text
kind-ckad
```

---

## 7. Create the cluster

Run the following command from the repository root:

```bash
kind create cluster --config cluster/kind-config.yaml
```

kind will create the following nodes:

```text
ckad-control-plane
ckad-worker
ckad-worker2
```

The nodes are Docker containers managed by kind.

Cluster creation may take a short amount of time while the Kubernetes control plane starts.

---

## 8. Verify that the kind cluster exists

Check the kind clusters:

```bash
kind get clusters
```

Expected:

```text
ckad
```

Check the Docker containers:

```bash
docker ps --filter "name=ckad"
```

Expected containers:

```text
ckad-control-plane
ckad-worker
ckad-worker2
```

---

## 9. Verify the Kubernetes context

Check the current context:

```bash
kubectl config current-context
```

Expected:

```text
kind-ckad
```

If the context is different, do not start modifying Kubernetes resources.

---

## 10. Create the dedicated learning kubeconfig

The learning repository uses a dedicated kubeconfig so that the Kubernetes environment used by Claude Code is separated from other Kubernetes environments on the machine.

Create the dedicated kubeconfig:

```bash
kind get kubeconfig --name ckad > "$HOME/.kube/ckad-learning-config"
```

Verify that it contains the learning context:

```bash
KUBECONFIG="$HOME/.kube/ckad-learning-config" kubectl config get-contexts
```

The expected context is:

```text
kind-ckad
```

---

## 11. Use the dedicated kubeconfig

Set the kubeconfig in the WSL shell:

```bash
export KUBECONFIG="$HOME/.kube/ckad-learning-config"
```

Verify:

```bash
echo "$KUBECONFIG"
```

Expected:

```text
/home/jan/.kube/ckad-learning-config
```

Verify the context:

```bash
kubectl config current-context
```

Expected:

```text
kind-ckad
```

Verify the cluster:

```bash
kubectl get nodes
```

Expected:

```text
ckad-control-plane
ckad-worker
ckad-worker2
```

All nodes should normally have status:

```text
Ready
```

### Important

Do not replace the dedicated kubeconfig with the user's general kubeconfig when working with Claude Code.

The dedicated kubeconfig is an intentional isolation boundary for the learning environment.

---

## 12. Start Claude Code

Claude Code should be started from the WSL shell in which the dedicated kubeconfig is configured:

```bash
export KUBECONFIG="$HOME/.kube/ckad-learning-config"
claude
```

Verify from Claude Code:

```bash
kubectl config current-context
kubectl get nodes
```

Expected:

```text
kind-ckad
```

with all three nodes in `Ready` state.

Claude may use `kubectl` against the learning cluster.

Claude should not receive direct access to the Docker socket for normal Kubernetes learning tasks.

The intended architecture is:

```text
Claude Code
    │
    └── kubectl
          │
          ▼
      kind-ckad
```

and not:

```text
Claude Code
    │
    └── Docker socket
          │
          ▼
      Docker daemon
```

---

## 13. Verify the complete environment

After creating the cluster, the following checks should succeed:

### WSL

```bash
uname -a
```

### Docker

```bash
docker info
```

### kind

```bash
kind version
kind get clusters
```

Expected cluster:

```text
ckad
```

### Kubernetes context

```bash
kubectl config current-context
```

Expected:

```text
kind-ckad
```

### Kubernetes nodes

```bash
kubectl get nodes -o wide
```

Expected topology:

```text
ckad-control-plane
ckad-worker
ckad-worker2
```

### Kubernetes system pods

```bash
kubectl get pods -A -o wide
```

The Kubernetes system components should become `Running` or otherwise reach their expected healthy state.

---

## 14. Basic cluster smoke test

Before starting the learning labs, verify that the cluster can run a normal workload.

Create a temporary nginx deployment:

```bash
kubectl create deployment smoke-test --image=nginx
```

Wait for it:

```bash
kubectl rollout status deployment/smoke-test
```

Check:

```bash
kubectl get pods
```

When the pod is running, remove the smoke test:

```bash
kubectl delete deployment smoke-test
```

This verifies that:

* the API server is reachable;
* the scheduler is working;
* the kubelet can start workloads;
* the container runtime can pull and run an image;
* basic Kubernetes functionality works.

The smoke test is temporary and is not part of the learning labs.

---

## 15. Useful cluster commands

### kind

List clusters:

```bash
kind get clusters
```

Inspect the cluster:

```bash
kind get nodes --name ckad
```

### Kubernetes context

```bash
kubectl config current-context
kubectl config get-contexts
```

### Nodes

```bash
kubectl get nodes
kubectl get nodes -o wide
kubectl describe node <node>
```

### Pods

```bash
kubectl get pods
kubectl get pods -A
kubectl get pods -A -o wide
kubectl describe pod <pod>
kubectl logs <pod>
```

### Deployments

```bash
kubectl get deployments
kubectl describe deployment <deployment>
kubectl rollout status deployment/<deployment>
```

### Services

```bash
kubectl get services
kubectl describe service <service>
```

### Cluster resources

```bash
kubectl get all -A
```

### Events

```bash
kubectl get events -A --sort-by=.lastTimestamp
```

### Kubernetes documentation

```bash
kubectl explain <resource>
```

Examples:

```bash
kubectl explain pod
kubectl explain deployment
kubectl explain service
```

---

## 16. Delete the cluster

The cluster is disposable.

Delete it with:

```bash
kind delete cluster --name ckad
```

Verify:

```bash
kind get clusters
```

The `ckad` cluster should no longer be listed.

Deleting the cluster removes the Kubernetes nodes and their cluster state.

It does not delete the learning repository.

The following remain in the repository:

```text
labs/
notes/
scratch/
cluster/
```

---

## 17. Recreate the cluster

If the cluster becomes inconsistent during experimentation, recreate it.

Delete:

```bash
kind delete cluster --name ckad
```

Create again:

```bash
kind create cluster --config cluster/kind-config.yaml
```

Set the dedicated kubeconfig again if necessary:

```bash
kind get kubeconfig --name ckad > "$HOME/.kube/ckad-learning-config"
```

Export it:

```bash
export KUBECONFIG="$HOME/.kube/ckad-learning-config"
```

Verify:

```bash
kubectl config current-context
kubectl get nodes
```

Expected:

```text
kind-ckad
```

with three `Ready` nodes.

---

## 18. Troubleshooting

Do not immediately delete and recreate the cluster when something fails.

First inspect the actual state.

### Check whether the cluster exists

```bash
kind get clusters
```

Expected:

```text
ckad
```

### Check the Docker containers

```bash
docker ps --filter "name=ckad"
```

Expected:

```text
ckad-control-plane
ckad-worker
ckad-worker2
```

### Check the current context

```bash
kubectl config current-context
```

Expected:

```text
kind-ckad
```

### Check nodes

```bash
kubectl get nodes
```

### Check system pods

```bash
kubectl get pods -A
```

### Check recent events

```bash
kubectl get events -A --sort-by=.lastTimestamp
```

### Check a node

```bash
kubectl describe node <node>
```

### Check kubelet/container logs

Use Docker only for cluster infrastructure troubleshooting:

```bash
docker logs ckad-control-plane
```

Do not use Docker commands as a substitute for normal Kubernetes troubleshooting.

For CKAD practice, prefer diagnosing the Kubernetes state with `kubectl` first.

---

## 19. Common connection problem

If `kubectl` reports:

```text
The connection to the server ... was refused
```

check the following in order:

```bash
kind get clusters
docker ps --filter "name=ckad"
kubectl config current-context
kubectl get nodes
```

Also verify the dedicated kubeconfig:

```bash
echo "$KUBECONFIG"
```

Expected:

```text
/home/jan/.kube/ckad-learning-config
```

If the kind containers are running but `kubectl` cannot connect, inspect the API server container:

```bash
docker logs ckad-control-plane
```

Do not recreate the cluster until the problem has been investigated.

---

## 20. Historical setup issue: cgroup v1

The initial cluster creation failed because Docker was using cgroup v1.

The kubelet reported:

```text
kubelet is configured to not run on a host using cgroup v1
```

The resulting symptoms included:

```text
API server connection refused
kubelet not starting correctly
kind cluster creation failing during control-plane initialization
```

Updating WSL resolved the underlying cgroup problem.

The working configuration is:

```text
WSL2
  ↓
cgroup v2
  ↓
Docker Desktop
  ↓
kind
  ↓
Kubernetes
```

A manual `.wslconfig` configuration was previously tested to force cgroup v2.

That configuration broke Docker Desktop's WSL integration.

Therefore, do not force cgroup configuration through `.wslconfig` unless necessary.

---

## 21. Repository relationship

```text
cluster/
├── README.md          → local cluster setup and troubleshooting
└── kind-config.yaml   → kind cluster configuration

labs/                  → hands-on Kubernetes exercises
notes/                 → concepts, troubleshooting, patterns
scratch/               → temporary AI-generated experiments
tests/rules/           → automated repository checks
```

The `cluster/` directory documents the local execution environment.

The `kind-config.yaml` defines the cluster topology.

The `labs/` directory contains the actual learning exercises.

The `notes/` directory contains reusable knowledge discovered during learning.

The `scratch/` directory contains temporary AI-generated implementations and experiments.

---

## 22. Principle

Keep the local Kubernetes environment intentionally simple.

The cluster exists to support hands-on CKAD learning.

Do not add additional infrastructure unless it is required for the current learning objective.

The cluster is disposable.

The repository is the durable learning artifact.
