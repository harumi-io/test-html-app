# Test HTML App

A simple test application for validating the CI-driven write-back deployment pattern with ArgoCD and External Secrets Operator.

## Architecture

```
Developer Push -> GitHub Actions (Build/Update) -> Git Repo
                                                      |
                                                      v
                  ArgoCD (Sync) -> Kubernetes <- External Secrets (AWS SM)
```

## CI-Driven Write-Back Pattern

1. **Code Change**: Developer pushes changes to `src/` or `Dockerfile`
   - GitHub Actions builds new Docker image
   - Pushes to ECR
   - Updates `k8s/deployment.yaml` with new image tag
   - Commits and pushes back to repo

2. **Config Change**: Developer updates `k8s/configmap.yaml`
   - GitHub Actions calculates new config hash
   - Updates annotation in `k8s/deployment.yaml`
   - Commits and pushes back to repo
   - Kubernetes triggers rolling update due to annotation change

3. **ArgoCD Sync**: ArgoCD watches the repo
   - Detects changes in `k8s/` directory
   - Syncs to Kubernetes cluster
   - Rolling update occurs

## Prerequisites

- ArgoCD installed on EKS cluster
- External Secrets Operator installed with ClusterSecretStore
- ECR repository created: `harumi-dev-test-html-app`
- AWS Secrets Manager secret: `harumi/test-html-app/dev`

## Setup

1. **Create ECR Repository** (via Terraform):
   ```bash
   cd infrastructure/core-infrastructure
   terraform apply -var-file=dev.tfvars
   ```

2. **Create AWS Secret**:
   ```bash
   aws secretsmanager create-secret \
     --name harumi/test-html-app/dev \
     --secret-string '{"api_key":"test-key","database_url":"postgresql://localhost:5432/test"}'
   ```

3. **Deploy ArgoCD Application**:
   ```bash
   kubectl apply -f k8s/argocd-app.yaml
   ```

## Testing

1. **Test Image Update**:
   ```bash
   # Make a change to src/index.html
   git add . && git commit -m "test: update index.html" && git push
   # Watch GitHub Actions build and update deployment
   ```

2. **Test Config Update**:
   ```bash
   # Make a change to k8s/configmap.yaml
   git add . && git commit -m "test: update config" && git push
   # Watch GitHub Actions update config hash and ArgoCD sync
   ```

3. **Verify Deployment**:
   ```bash
   kubectl get pods -n test-html-app
   kubectl get externalsecret -n test-html-app
   ```

## Local Development

```bash
# Build locally
docker build -t test-html-app .

# Run locally
docker run -p 8080:80 test-html-app

# Open http://localhost:8080
```