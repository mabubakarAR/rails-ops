# Digital Ocean Deployment Guide

## Prerequisites
- Digital Ocean account
- Docker installed locally
- kubectl installed locally
- doctl CLI installed locally

## Step 1: Create Digital Ocean Kubernetes Cluster

1. Install doctl CLI:
```bash
# macOS
brew install doctl

# Linux
snap install doctl

# Or download from: https://github.com/digitalocean/doctl/releases
```

2. Authenticate with Digital Ocean:
```bash
doctl auth init
# Enter your API token when prompted
```

3. Create a Kubernetes cluster:
```bash
doctl kubernetes cluster create rails-ops-cluster \
  --region nyc1 \
  --version 1.28.2-do.0 \
  --node-pool "name=worker-pool;size=s-2vcpu-4gb;count=3;auto-scale=true;min-nodes=1;max-nodes=5"
```

4. Get kubeconfig:
```bash
doctl kubernetes cluster kubeconfig save rails-ops-cluster
```

## Step 2: Build and Push Docker Image

1. Build the Docker image:
```bash
docker build -t rails-ops:latest .
```

2. Tag for Digital Ocean registry:
```bash
docker tag rails-ops:latest registry.digitalocean.com/rails-ops/rails-ops:latest
```

3. Push to Digital Ocean registry:
```bash
docker push registry.digitalocean.com/rails-ops/rails-ops:latest
```

## Step 3: Deploy to Kubernetes

1. Update the image in web-deployment.yaml:
```yaml
image: registry.digitalocean.com/rails-ops/rails-ops:latest
```

2. Apply Kubernetes configurations:
```bash
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/redis-deployment.yaml
kubectl apply -f k8s/elasticsearch-deployment.yaml
kubectl apply -f k8s/sidekiq-deployment.yaml
kubectl apply -f k8s/web-deployment.yaml
kubectl apply -f k8s/ingress.yaml
```

3. Wait for deployments to be ready:
```bash
kubectl get pods
kubectl get services
```

## Step 4: Run Database Migrations

1. Get the web pod name:
```bash
kubectl get pods -l app=rails-ops-web
```

2. Run migrations:
```bash
kubectl exec -it <pod-name> -- bundle exec rails db:migrate
```

3. Create Elasticsearch indices:
```bash
kubectl exec -it <pod-name> -- bundle exec rails elasticsearch:setup
```

## Step 5: Configure Domain and SSL

1. Get the external IP:
```bash
kubectl get service rails-ops-web-service
```

2. Point your domain to the external IP

3. Install cert-manager for SSL:
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

4. Update ingress.yaml with your domain and SSL configuration

## Step 6: Monitor and Scale

1. Check logs:
```bash
kubectl logs -f deployment/rails-ops-web
kubectl logs -f deployment/rails-ops-sidekiq
```

2. Scale the application:
```bash
kubectl scale deployment rails-ops-web --replicas=5
kubectl scale deployment rails-ops-sidekiq --replicas=3
```

## Environment Variables

Create a `.env` file with the following variables:
```bash
DATABASE_URL=postgresql://postgres:password@postgres-service:5432/rails_ops_production
REDIS_URL=redis://redis-service:6379/0
ELASTICSEARCH_URL=http://elasticsearch-service:9200
RAILS_MASTER_KEY=your-rails-master-key
SECRET_KEY_BASE=your-secret-key-base
```

## Troubleshooting

1. Check pod status:
```bash
kubectl describe pod <pod-name>
```

2. Check service endpoints:
```bash
kubectl get endpoints
```

3. Check ingress:
```bash
kubectl describe ingress rails-ops-ingress
```

4. View logs:
```bash
kubectl logs -f <pod-name>
```

## Cost Optimization

- Use smaller node sizes for development
- Enable auto-scaling
- Use Digital Ocean Spaces for file storage
- Monitor resource usage with Digital Ocean monitoring
