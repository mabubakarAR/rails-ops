# Heroku Deployment Guide

## Prerequisites
- Heroku account
- Heroku CLI installed
- Git repository with your code

## Step 1: Install Heroku CLI

1. Install Heroku CLI:
```bash
# macOS
brew tap heroku/brew && brew install heroku

# Linux
curl https://cli-assets.heroku.com/install.sh | sh

# Windows
# Download from https://devcenter.heroku.com/articles/heroku-cli
```

2. Login to Heroku:
```bash
heroku login
```

## Step 2: Create Heroku App

1. Create Heroku app:
```bash
heroku create rails-ops-app
```

2. Set buildpacks:
```bash
heroku buildpacks:set heroku/ruby
heroku buildpacks:add --index 1 heroku/nodejs
```

## Step 3: Set up Database

1. Add PostgreSQL addon:
```bash
heroku addons:create heroku-postgresql:mini
```

2. Get database URL:
```bash
heroku config:get DATABASE_URL
```

## Step 4: Set up Redis

1. Add Redis addon:
```bash
heroku addons:create heroku-redis:mini
```

2. Get Redis URL:
```bash
heroku config:get REDIS_URL
```

## Step 5: Set up Search (Elasticsearch)

1. Add Bonsai Elasticsearch addon:
```bash
heroku addons:create bonsai:starter
```

2. Get Elasticsearch URL:
```bash
heroku config:get BONSAI_URL
```

## Step 6: Configure Environment Variables

1. Set environment variables:
```bash
heroku config:set RAILS_ENV=production
heroku config:set SECRET_KEY_BASE=$(rails secret)
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)
heroku config:set ELASTICSEARCH_URL=$(heroku config:get BONSAI_URL)
```

2. Set additional variables:
```bash
heroku config:set SMTP_USERNAME=your-smtp-username
heroku config:set SMTP_PASSWORD=your-smtp-password
heroku config:set TWILIO_ACCOUNT_SID=your-twilio-sid
heroku config:set TWILIO_AUTH_TOKEN=your-twilio-token
```

## Step 7: Deploy Application

1. Deploy to Heroku:
```bash
git push heroku main
```

2. Run database migrations:
```bash
heroku run rails db:migrate
heroku run rails elasticsearch:setup
```

3. Seed database:
```bash
heroku run rails db:seed
```

## Step 8: Set up Background Jobs

1. Add Sidekiq worker:
```bash
heroku ps:scale worker=1
```

2. Create Procfile:
```bash
echo "web: bundle exec puma -C config/puma.rb" >> Procfile
echo "worker: bundle exec sidekiq -C config/sidekiq.yml" >> Procfile
```

## Step 9: Set up SSL

1. Enable SSL:
```bash
heroku certs:auto:enable
```

2. Check SSL status:
```bash
heroku certs
```

## Step 10: Set up Monitoring

1. Add New Relic addon:
```bash
heroku addons:create newrelic:wayne
```

2. Add Papertrail addon:
```bash
heroku addons:create papertrail:choklad
```

## Step 11: Configure Custom Domain

1. Add custom domain:
```bash
heroku domains:add your-domain.com
```

2. Configure DNS:
```bash
heroku domains
# Add CNAME record pointing to the Heroku domain
```

## Step 12: Set up CI/CD

1. Create GitHub Actions workflow:
```yaml
name: Deploy to Heroku

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: akhileshns/heroku-deploy@v3.12.12
      with:
        heroku_api_key: ${{secrets.HEROKU_API_KEY}}
        heroku_app_name: "rails-ops-app"
        heroku_email: "your-email@example.com"
```

2. Set GitHub secrets:
- `HEROKU_API_KEY`: Your Heroku API key

## Step 13: Performance Optimization

1. Enable gzip compression:
```bash
heroku config:set RAILS_SERVE_STATIC_FILES=true
```

2. Set up CDN:
```bash
heroku addons:create cloudflare:free
```

3. Optimize database:
```bash
heroku pg:info
heroku pg:psql
```

## Step 14: Backup Strategy

1. Set up automated backups:
```bash
heroku addons:create pgbackups:auto-month
```

2. Manual backup:
```bash
heroku pg:backups:capture
```

3. Restore backup:
```bash
heroku pg:backups:restore <backup-url>
```

## Step 15: Scaling

1. Scale web dynos:
```bash
heroku ps:scale web=2
```

2. Scale worker dynos:
```bash
heroku ps:scale worker=2
```

3. Scale database:
```bash
heroku addons:upgrade heroku-postgresql:mini
```

## Environment Variables

Create a `.env` file for local development:
```bash
DATABASE_URL=postgresql://localhost:5432/rails_ops_development
REDIS_URL=redis://localhost:6379/0
ELASTICSEARCH_URL=http://localhost:9200
RAILS_MASTER_KEY=your-rails-master-key
SECRET_KEY_BASE=your-secret-key-base
```

## Troubleshooting

1. Check app logs:
```bash
heroku logs --tail
```

2. Check dyno status:
```bash
heroku ps
```

3. Check addon status:
```bash
heroku addons
```

4. Check database status:
```bash
heroku pg:info
```

5. Check Redis status:
```bash
heroku redis:info
```

6. Check Elasticsearch status:
```bash
heroku addons:info bonsai
```

## Cost Optimization

- Use free tier addons for development
- Monitor usage with Heroku metrics
- Use dyno sleeping for development
- Optimize database queries
- Use CDN for static assets
- Implement caching strategies

## Security Considerations

- Use environment variables for secrets
- Enable SSL/TLS
- Use strong passwords
- Regular security updates
- Monitor access logs
- Use Heroku Shield for compliance
