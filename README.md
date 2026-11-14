# devops-utilities

Public repo holding the deployment workflow and a leakage guard. Every value that touches a private system comes from GitHub secrets or workflow inputs; nothing structural is committed here.

## Workflows

| Workflow | Trigger | What it does |
|---|---|---|
| `.github/workflows/lllorigins-deployments.yml` | `workflow_dispatch` | Self-contained Helm deployment workflow managing GitHub Environment approval gates and secrets. Inputs: `environment` (GitHub Environment), `service`, `deploy-tag`, `github-repository`, `github-sha`, optional `smoke-url`. Pulls the service's chart from the configured OCI chart registry at the tag's version, runs `helm upgrade --install --wait` with the per-environment values file, executes an optional post-deploy smoke test, and publishes a New Relic deployment marker. Concurrency is serialized per service and environment. |
| `.github/workflows/leakage-guard.yml` | `pull_request`, push to `master` | Scans repository files for sensitive patterns (OCIDs, hardcoded registry hostnames, private domains, credentials, and external checkout targets). |
