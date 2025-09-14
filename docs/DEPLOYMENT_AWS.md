# AWS Deployment Guide

## Prerequisites
- AWS account
- AWS CLI installed and configured
- Docker installed locally
- kubectl installed locally
- eksctl installed locally

## Step 1: Create EKS Cluster

1. Install eksctl:
```bash
# macOS
brew install eksctl

# Linux
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```

2. Create EKS cluster:
```bash
eksctl create cluster \
  --name rails-ops-cluster \
  --region us-west-2 \
  --nodegroup-name workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 5 \
  --managed
```

3. Update kubeconfig:
```bash
aws eks update-kubeconfig --region us-west-2 --name rails-ops-cluster
```

## Step 2: Create ECR Repository

1. Create ECR repository:
```bash
aws ecr create-repository --repository-name rails-ops --region us-west-2
```

2. Get login token:
```bash
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-west-2.amazonaws.com
```

3. Build and push image:
```bash
docker build -t rails-ops:latest .
docker tag rails-ops:latest <account-id>.dkr.ecr.us-west-2.amazonaws.com/rails-ops:latest
docker push <account-id>.dkr.ecr.us-west-2.amazonaws.com/rails-ops:latest
```

## Step 3: Set up RDS Database

1. Create RDS PostgreSQL instance:
```bash
aws rds create-db-instance \
  --db-instance-identifier rails-ops-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 15.4 \
  --master-username postgres \
  --master-user-password YourPassword123 \
  --allocated-storage 20 \
  --vpc-security-group-ids sg-xxxxxxxxx \
  --db-subnet-group-name default
```

2. Get RDS endpoint:
```bash
aws rds describe-db-instances --db-instance-identifier rails-ops-db --query 'DBInstances[0].Endpoint.Address'
```

## Step 4: Set up ElastiCache Redis

1. Create ElastiCache Redis cluster:
```bash
aws elasticache create-cache-cluster \
  --cache-cluster-id rails-ops-redis \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --num-cache-nodes 1 \
  --vpc-security-group-ids sg-xxxxxxxxx
```

2. Get Redis endpoint:
```bash
aws elasticache describe-cache-clusters --cache-cluster-id rails-ops-redis --query 'CacheClusters[0].RedisEndpoint.Address'
```

## Step 5: Set up OpenSearch (Elasticsearch)

1. Create OpenSearch domain:
```bash
aws opensearch create-domain \
  --domain-name rails-ops-search \
  --cluster-config InstanceType=t3.small.search,InstanceCount=1 \
  --ebs-options EBSEnabled=true,VolumeType=gp3,VolumeSize=20
```

2. Get OpenSearch endpoint:
```bash
aws opensearch describe-domain --domain-name rails-ops-search --query 'DomainStatus.Endpoint'
```

## Step 6: Deploy to EKS

1. Update secrets.yaml with actual values:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: rails-ops-secrets
type: Opaque
stringData:
  database-url: "postgresql://postgres:YourPassword123@<rds-endpoint>:5432/rails_ops_production"
  redis-url: "redis://<redis-endpoint>:6379/0"
  elasticsearch-url: "https://<opensearch-endpoint>:443"
  rails-master-key: "your-rails-master-key"
  secret-key-base: "your-secret-key-base"
```

2. Update web-deployment.yaml with ECR image:
```yaml
image: <account-id>.dkr.ecr.us-west-2.amazonaws.com/rails-ops:latest
```

3. Apply configurations:
```bash
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/sidekiq-deployment.yaml
kubectl apply -f k8s/web-deployment.yaml
kubectl apply -f k8s/ingress.yaml
```

## Step 7: Set up Application Load Balancer

1. Install AWS Load Balancer Controller:
```bash
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=rails-ops-cluster \
  --set serviceAccount.create=false \
  --set region=us-west-2 \
  --set vpcId=vpc-xxxxxxxxx
```

2. Update ingress.yaml for ALB:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rails-ops-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  rules:
  - host: your-domain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: rails-ops-web-service
            port:
              number: 80
```

## Step 8: Run Database Migrations

1. Run migrations:
```bash
kubectl exec -it deployment/rails-ops-web -- bundle exec rails db:migrate
kubectl exec -it deployment/rails-ops-web -- bundle exec rails elasticsearch:setup
```

## Step 9: Set up Monitoring

1. Install CloudWatch Container Insights:
```bash
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent-rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent-daemonset.yaml
```

## Step 10: Set up Auto Scaling

1. Install Cluster Autoscaler:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

2. Update Cluster Autoscaler deployment:
```bash
kubectl patch deployment cluster-autoscaler -n kube-system -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict":"false"}},"spec":{"containers":[{"name":"cluster-autoscaler","command":["cluster-autoscaler","--v=4","--stderrthreshold=info","--cloud-provider=aws","--skip-nodes-with-local-storage=false","--expander=least-waste","--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/rails-ops-cluster"]}]}}}}'
```

## Environment Variables

Create a `.env` file:
```bash
AWS_REGION=us-west-2
DATABASE_URL=postgresql://postgres:YourPassword123@<rds-endpoint>:5432/rails_ops_production
REDIS_URL=redis://<redis-endpoint>:6379/0
ELASTICSEARCH_URL=https://<opensearch-endpoint>:443
RAILS_MASTER_KEY=your-rails-master-key
SECRET_KEY_BASE=your-secret-key-base
```

## Cost Optimization

- Use Spot instances for non-critical workloads
- Enable EBS optimization
- Use CloudWatch for monitoring and alerting
- Implement proper resource limits and requests
- Use AWS Cost Explorer for cost analysis

## Troubleshooting

1. Check EKS cluster status:
```bash
eksctl get cluster --name rails-ops-cluster
```

2. Check node status:
```bash
kubectl get nodes
kubectl describe nodes
```

3. Check pod logs:
```bash
kubectl logs -f deployment/rails-ops-web
```

4. Check ALB status:
```bash
kubectl describe ingress rails-ops-ingress
```
