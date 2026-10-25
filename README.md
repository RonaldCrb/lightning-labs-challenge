# Lightning Labs Platform Engineering Challenge

Kubernetes, Helm, and declarative GitOps (ArgoCD) implementation for bootstrapping and operating a local multi-node Bitcoin Core (`bitcoind`) and Lightning Network (`lnd`) cluster.

## Architecture & Components

1. **`bitcoind` Node** (`CHARTS/bitcoind`): Regtest Bitcoin Core StatefulSet with persistent volumes and RPC configuration.
2. **`lnd-alice` & `lnd-bob` Nodes** (`CHARTS/lnd`, `DOCKER/lndinit`): Automated wallet initialization (`lndinit`), Kubernetes RBAC secret management for TLS certificates and macaroons, and peer/channel bootstrapping.
3. **Declarative GitOps (`GITOPS/`)**: ArgoCD `ApplicationSet` manifests and multi-environment Helm umbrella charts (`regtest1`, `regtest2`).

### Requirements
- `docker`
- `minikube`
- `kubectl`
- `helm`

### Quickstart (Helm + Bootstrap Scripts)
- Start Minikube: `minikube start`
- Configure RPC credentials in `/SECRETS/bitcoin.conf` and match them in `/SECRETS/lnd.conf`
- Run `./bootstrap.sh` to deploy the charts and initialize wallets
- Run `./setup.sh` to fund `lnd-alice`, open channels to `lnd-bob`, and verify payment routing
- Run `./cleanup.sh` to tear down workloads

### Optional Block Generator
Use `./block-generator.sh` to mine 1 block every 10 seconds on regtest.

---

## GitOps Workflow (ArgoCD ApplicationSets)

### Requirements
- `argocd` CLI (`https://argo-cd.readthedocs.io/en/stable/cli_installation`)
- GitHub credentials (`$GITHUB_USER` and `$GITHUB_PAT`)

### Steps
1. Start Minikube: `minikube start`
2. Export `$GITHUB_USER` and `$GITHUB_PAT` (or configure `go-gitops.sh`)
3. Run `./bootstrap-gitops.sh` to deploy ArgoCD to the cluster
4. Run `./connect-gitops.sh` in a secondary terminal once pods are ready
5. Run `./go-gitops.sh` to register the `ApplicationSet` manifests in `GITOPS/sets`

### Engineering Notes & Resolved Issues
- **Automated Secret Provisioning (`lndinit`):** Removed static secret templates from the `lnd` chart and granted the `create` verb on the Kubernetes `Role` (`CHARTS/lnd/templates/role.yaml`) so `lndinit` provisions wallet seed and macaroon secrets dynamically without manual intervention.
- **Persistent Volume Lifecycle:** If re-initializing a node with a fresh seed after running `cleanup.sh`, clear stale hostPath volumes inside Minikube (`docker exec minikube rm -rf /data/lnd-bob /data/lnd-alice`) so `lndinit` does not encounter a passphrase mismatch against prior volume state:

<img title="invalid passphrase" alt="invalid passphrase" src="./inv-passphrase.png">

- **`lndinit` Security Context Note:** Enabling strict `securityContext` in `lndinit` triggers an upstream nil-pointer dereference in `lndinit`:

<img title="lndinit panic" alt="lndinit panic" src="./panic-nil-pointer.png">
