# Local Kubernetes Cluster

This directory contains the configuration for the local Kubernetes cluster used for the CKAD learning repository.

The cluster runs `kind` on Docker Desktop using the WSL2 backend.

## Architecture

```text
Windows
  │
  └── WSL2
       │
       └── Ubuntu
            │
            └── Docker Desktop WSL2 integration
                 │
                 └── kind
                      ├── kind-control-plane
                      ├── kind-worker
                      └── kind-worker2
```

The kind nodes are Docker containers. They are not separate virtual machines.

## Prerequisites

The local cluster requires:

* Windows with WSL2
* Ubuntu running under WSL2
* up-to-date WSL
* Docker Desktop with WSL2 backend
* Docker Desktop WSL integration enabled for Ubuntu
* `kubectl`
* `kind`

### WSL

Keep WSL up to date:

```powershell
wsl --update
```

Check the installed version:

```powershell
wsl --version
```

After updating WSL, restart the WSL environment:

```powershell
wsl --shutdown
```

Then restart Docker Desktop.

> The WSL version is relevant because the Kubernetes development environment depends on the cgroup capabilities provided by the WSL kernel.

### Docker Desktop

Docker Desktop must be running with the WSL2 backend.

Ubuntu must have WSL integration enabled in:

`Docker Desktop → Settings → Resources → WSL Integration`

Verify Docker access from Ubuntu:

```bash
docker info
```

### kubectl and kind

Verify:

```bash
kubectl version --client
kind version
```

## Cgroups

The Kubernetes nodes require cgroup v2.

Verify the Docker configuration:

```bash
docker info | grep -i cgroup
```

Expected:

```text
Cgroup Version: 2
```

The working environment currently uses:

```text
Cgroup Version: 2
```

The Docker cgroup driver is:

```text
Cgroup Driver: cgroupfs
```

The cgroup version is the important requirement for the kind node in this setup.

### Previous cgroup v1 issue

The cluster initially failed while Docker was using cgroup v1.

The kind node's kubelet reported:

```text
kubelet is configured to not run on a host using cgroup v1
```

As a result, the kubelet did not start correctly and the Kubernetes API server never became available.

Updating WSL resulted in a working cgroup v2 environment.

Do not force cgroup configuration through `.wslconfig` unless necessary. A previous attempt to force cgroup v2 manually caused the Docker Desktop WSL integration to stop working.

## Cluster configuration

The cluster topology is defined in:

```text
kind-config.yaml
```

Current configuration:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

This creates:

```text
1 × control-plane
2 × worker
```

## Create the cluster

From the repository root:

```bash
kind create cluster --config cluster/kind-config.yaml
```

kind uses the cluster name `kind` by default.

## Verify the cluster

```bash
kubectl get nodes -o wide
```

```bash
kubectl get pods -A -o wide
```

```bash
kubectl config current-context
```

Expected context:

```text
kind-kind
```

## Useful commands

### Cluster

```bash
kind get clusters
kind delete cluster
```

### Nodes

```bash
kubectl get nodes
kubectl describe node <node>
```

### Pods

```bash
kubectl get pods -A
kubectl get pods -A -o wide
kubectl describe pod <pod>
```

### Cluster resources

```bash
kubectl get all -A
kubectl get events -A --sort-by=.lastTimestamp
```

## Recreate the cluster

The cluster is intentionally disposable.

If the cluster becomes inconsistent during an experiment:

```bash
kind delete cluster
kind create cluster --config cluster/kind-config.yaml
```

Learning artifacts such as manifests, notes, and troubleshooting findings belong in the repository. The cluster itself is only the execution environment.

## Repository relationship

```text
cluster/       → local Kubernetes environment
labs/          → hands-on exercises
notes/         → concepts, troubleshooting, patterns
scratch/       → temporary AI-generated experiments
tests/         → automated repository checks
```

The cluster configuration documents the local execution environment. Kubernetes concepts and lessons learned belong in `notes/`.
