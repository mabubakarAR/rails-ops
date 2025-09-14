# Jobify - Job Board Platform

Jobify is a comprehensive job board platform built with Ruby on Rails that connects companies with job seekers. It provides a modern, scalable solution for job posting, application management, and talent discovery.

## 🚀 Features

### Core Functionality
- **User Management**: Role-based authentication with companies and job seekers
- **Job Posting**: Companies can create and manage job listings
- **Application Management**: Job seekers can apply to jobs and track application status
- **Advanced Search**: Elasticsearch-powered search with filters and suggestions
- **Real-time Updates**: Hotwire Turbo Streams for live updates
- **Notifications**: Email and SMS notifications for important events

### Technical Features
- **RESTful API**: Comprehensive API with JWT authentication
- **Background Jobs**: Sidekiq for asynchronous processing
- **Admin Panel**: ActiveAdmin for administrative tasks
- **Testing**: Comprehensive RSpec test suite with FactoryBot
- **Containerization**: Docker and Kubernetes support
- **Monitoring**: Health checks and performance monitoring

## 🛠 Technology Stack

### Backend
- **Ruby on Rails 7.0+**: Web framework
- **PostgreSQL**: Primary database
- **Redis**: Caching and session storage
- **Elasticsearch**: Search and analytics
- **Sidekiq**: Background job processing

### Frontend
- **Hotwire**: Real-time updates with Turbo Streams
- **Bootstrap**: Responsive UI framework
- **Stimulus**: JavaScript framework

### Infrastructure
- **Docker**: Containerization
- **Kubernetes**: Orchestration
- **Nginx**: Reverse proxy and load balancing

## 📋 Prerequisites

- Ruby 3.1+
- Rails 7.0+
- PostgreSQL 14+
- Redis 6+
- Elasticsearch 8+
- Node.js 16+
- Docker (optional)
- Kubernetes (optional)

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/jobify.git
cd jobify
```

### 2. Install Dependencies
```bash
bundle install
npm install
```

### 3. Set up Database
```bash
rails db:create
rails db:migrate
rails db:seed
```

### 4. Set up Elasticsearch
```bash
rails elasticsearch:setup
```

### 5. Start Services
```bash
# Start Redis
redis-server

# Start Elasticsearch
elasticsearch

# Start Rails server
rails server
```

### 6. Access the Application
- Web Interface: http://localhost:3000
- API Documentation: http://localhost:3000/api/v1/docs
- Admin Panel: http://localhost:3000/admin

## 🐳 Docker Setup

### Using Docker Compose
```bash
# Build and start all services
docker-compose up -d

# Run database migrations
docker-compose exec web rails db:migrate

# Seed the database
docker-compose exec web rails db:seed

# Set up Elasticsearch
docker-compose exec web rails elasticsearch:setup
```

### Using Docker
```bash
# Build the image
docker build -t rails-ops .

# Run the container
docker run -p 3000:3000 rails-ops
```

## ☸️ Kubernetes Deployment

### Prerequisites
- Kubernetes cluster
- kubectl configured
- Helm installed

### Deploy to Kubernetes
```bash
# Apply configurations
kubectl apply -f k8s/

# Check deployment status
kubectl get pods
kubectl get services
```

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:

```bash
# Database
DATABASE_URL=postgresql://localhost:5432/rails_ops_development

# Redis
REDIS_URL=redis://localhost:6379/0

# Elasticsearch
ELASTICSEARCH_URL=http://localhost:9200

# Rails
RAILS_MASTER_KEY=your-rails-master-key
SECRET_KEY_BASE=your-secret-key-base

# Email (SMTP)
SMTP_USERNAME=your-smtp-username
SMTP_PASSWORD=your-smtp-password
SMTP_DOMAIN=your-smtp-domain

# SMS (Twilio)
TWILIO_ACCOUNT_SID=your-twilio-sid
TWILIO_AUTH_TOKEN=your-twilio-token
TWILIO_PHONE_NUMBER=your-twilio-number
```

### Database Configuration
The database configuration is in `config/database.yml`. Update the connection details as needed.

## 🧪 Testing

### Run Tests
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run tests with coverage
COVERAGE=true bundle exec rspec
```

### Test Coverage
The project uses SimpleCov for test coverage reporting. Coverage reports are generated in the `coverage/` directory.

## 📚 API Documentation

### Authentication
All API endpoints require JWT authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

### Base URL
```
https://your-domain.com/api/v1
```

### Key Endpoints
- `GET /jobs` - List all jobs
- `POST /jobs` - Create a new job
- `GET /jobs/:id` - Get job details
- `PUT /jobs/:id` - Update job
- `DELETE /jobs/:id` - Delete job
- `GET /search/jobs` - Search jobs
- `POST /applications` - Apply to a job
- `GET /applications` - List applications

For complete API documentation, see [API_DOCUMENTATION.md](docs/API_DOCUMENTATION.md).

## 🚀 Deployment

### Digital Ocean
See [DEPLOYMENT_DIGITAL_OCEAN.md](docs/DEPLOYMENT_DIGITAL_OCEAN.md) for detailed instructions.

### AWS
See [DEPLOYMENT_AWS.md](docs/DEPLOYMENT_AWS.md) for detailed instructions.

### Heroku
See [DEPLOYMENT_HEROKU.md](docs/DEPLOYMENT_HEROKU.md) for detailed instructions.

## 📊 Monitoring

### Health Checks
- Application health: `/health`
- Database health: `/health/database`
- Redis health: `/health/redis`
- Elasticsearch health: `/health/elasticsearch`

### Metrics
The application exposes metrics at `/metrics` for monitoring tools like Prometheus.

### Logging
Logs are structured in JSON format and can be easily parsed by log aggregation tools.

## 🔒 Security

### Authentication
- JWT-based authentication
- Role-based authorization
- Password hashing with bcrypt

### Data Protection
- Input validation and sanitization
- SQL injection prevention
- XSS protection
- CSRF protection

### Rate Limiting
- API rate limiting (1000 requests/hour per user)
- IP-based rate limiting for sensitive endpoints

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

### Code Style
- Follow Ruby style guidelines
- Use RuboCop for linting
- Write comprehensive tests
- Document new features

### Pull Request Process
1. Ensure tests pass
2. Update documentation if needed
3. Add changelog entry
4. Request review from maintainers

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Documentation
- [API Documentation](docs/API_DOCUMENTATION.md)
- [Deployment Guides](docs/)
- [Architecture Overview](docs/ARCHITECTURE.md)

### Getting Help
- Create an issue for bugs or feature requests
- Check existing issues before creating new ones
- Provide detailed information about your environment

### Community
- Join our Discord server
- Follow us on Twitter
- Star the repository if you find it useful

## 🗺 Roadmap

### Upcoming Features
- [ ] Mobile app (React Native)
- [ ] Advanced analytics dashboard
- [ ] AI-powered job matching
- [ ] Video interviews integration
- [ ] Multi-language support
- [ ] Advanced reporting tools

### Performance Improvements
- [ ] Database query optimization
- [ ] Caching strategies
- [ ] CDN integration
- [ ] Image optimization

## 🙏 Acknowledgments

- Ruby on Rails community
- Elasticsearch team
- Sidekiq contributors
- All open source contributors

---

**Made with ❤️ by the Jobify team**
