# Rails Ops API Documentation

## Overview

Rails Ops is a comprehensive job board platform that connects companies with job seekers. This API provides endpoints for managing companies, job seekers, jobs, and applications.

## Base URL

```
https://your-domain.com/api/v1
```

## Authentication

All API endpoints require authentication using JWT tokens. Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

## Rate Limiting

- **Rate Limit**: 1000 requests per hour per user
- **Headers**: 
  - `X-RateLimit-Limit`: Maximum requests per hour
  - `X-RateLimit-Remaining`: Remaining requests in current window
  - `X-RateLimit-Reset`: Time when the rate limit resets

## Error Handling

All errors follow a consistent format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": "Additional error details"
  }
}
```

### Common Error Codes

- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Unprocessable Entity
- `500` - Internal Server Error

## Data Models

### User
```json
{
  "id": 1,
  "email": "user@example.com",
  "role": "company|job_seeker",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

### Company
```json
{
  "id": 1,
  "name": "Acme Corp",
  "description": "A great company",
  "website": "https://acme.com",
  "logo_url": "https://acme.com/logo.png",
  "location": "San Francisco, CA",
  "industry": "Technology",
  "size": "50-200",
  "founded_year": 2020,
  "user_id": 1,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

### Job Seeker
```json
{
  "id": 1,
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+1234567890",
  "location": "San Francisco, CA",
  "bio": "Experienced developer",
  "skills": ["Ruby", "Rails", "JavaScript"],
  "experience_years": 5,
  "education": "Bachelor's in Computer Science",
  "resume_url": "https://example.com/resume.pdf",
  "user_id": 1,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

### Job
```json
{
  "id": 1,
  "title": "Senior Ruby Developer",
  "description": "We are looking for a senior Ruby developer...",
  "requirements": ["Ruby", "Rails", "PostgreSQL"],
  "location": "San Francisco, CA",
  "employment_type": "full_time",
  "salary_min": 120000,
  "salary_max": 180000,
  "currency": "USD",
  "remote": true,
  "status": "active",
  "company_id": 1,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

### Application
```json
{
  "id": 1,
  "status": "pending|reviewed|accepted|rejected",
  "cover_letter": "I am interested in this position...",
  "job_id": 1,
  "job_seeker_id": 1,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

## Authentication Endpoints

### Register User
```http
POST /auth/register
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "role": "company|job_seeker"
}
```

**Response:**
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "role": "company"
  },
  "token": "jwt-token-here"
}
```

### Login User
```http
POST /auth/login
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "role": "company"
  },
  "token": "jwt-token-here"
}
```

### Logout User
```http
DELETE /auth/logout
```

**Response:**
```json
{
  "message": "Successfully logged out"
}
```

## Company Endpoints

### List Companies
```http
GET /companies
```

**Query Parameters:**
- `page` (integer): Page number (default: 1)
- `per_page` (integer): Items per page (default: 20, max: 100)
- `search` (string): Search term
- `industry` (string): Filter by industry
- `location` (string): Filter by location
- `size` (string): Filter by company size

**Response:**
```json
{
  "companies": [
    {
      "id": 1,
      "name": "Acme Corp",
      "description": "A great company",
      "website": "https://acme.com",
      "logo_url": "https://acme.com/logo.png",
      "location": "San Francisco, CA",
      "industry": "Technology",
      "size": "50-200",
      "founded_year": 2020,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100,
    "per_page": 20
  }
}
```

### Get Company
```http
GET /companies/:id
```

**Response:**
```json
{
  "company": {
    "id": 1,
    "name": "Acme Corp",
    "description": "A great company",
    "website": "https://acme.com",
    "logo_url": "https://acme.com/logo.png",
    "location": "San Francisco, CA",
    "industry": "Technology",
    "size": "50-200",
    "founded_year": 2020,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### Create Company
```http
POST /companies
```

**Request Body:**
```json
{
  "name": "Acme Corp",
  "description": "A great company",
  "website": "https://acme.com",
  "logo_url": "https://acme.com/logo.png",
  "location": "San Francisco, CA",
  "industry": "Technology",
  "size": "50-200",
  "founded_year": 2020
}
```

**Response:**
```json
{
  "company": {
    "id": 1,
    "name": "Acme Corp",
    "description": "A great company",
    "website": "https://acme.com",
    "logo_url": "https://acme.com/logo.png",
    "location": "San Francisco, CA",
    "industry": "Technology",
    "size": "50-200",
    "founded_year": 2020,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### Update Company
```http
PUT /companies/:id
```

**Request Body:**
```json
{
  "name": "Updated Company Name",
  "description": "Updated description"
}
```

**Response:**
```json
{
  "company": {
    "id": 1,
    "name": "Updated Company Name",
    "description": "Updated description",
    "website": "https://acme.com",
    "logo_url": "https://acme.com/logo.png",
    "location": "San Francisco, CA",
    "industry": "Technology",
    "size": "50-200",
    "founded_year": 2020,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### Delete Company
```http
DELETE /companies/:id
```

**Response:**
```json
{
  "message": "Company deleted successfully"
}
```

## Job Seeker Endpoints

### List Job Seekers
```http
GET /job_seekers
```

**Query Parameters:**
- `page` (integer): Page number (default: 1)
- `per_page` (integer): Items per page (default: 20, max: 100)
- `search` (string): Search term
- `skills` (string): Filter by skills (comma-separated)
- `location` (string): Filter by location
- `experience_years` (integer): Filter by experience years

**Response:**
```json
{
  "job_seekers": [
    {
      "id": 1,
      "first_name": "John",
      "last_name": "Doe",
      "phone": "+1234567890",
      "location": "San Francisco, CA",
      "bio": "Experienced developer",
      "skills": ["Ruby", "Rails", "JavaScript"],
      "experience_years": 5,
      "education": "Bachelor's in Computer Science",
      "resume_url": "https://example.com/resume.pdf",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100,
    "per_page": 20
  }
}
```

### Get Job Seeker
```http
GET /job_seekers/:id
```

**Response:**
```json
{
  "job_seeker": {
    "id": 1,
    "first_name": "John",
    "last_name": "Doe",
    "phone": "+1234567890",
    "location": "San Francisco, CA",
    "bio": "Experienced developer",
    "skills": ["Ruby", "Rails", "JavaScript"],
    "experience_years": 5,
    "education": "Bachelor's in Computer Science",
    "resume_url": "https://example.com/resume.pdf",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### Create Job Seeker
```http
POST /job_seekers
```

**Request Body:**
```json
{
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+1234567890",
  "location": "San Francisco, CA",
  "bio": "Experienced developer",
  "skills": ["Ruby", "Rails", "JavaScript"],
  "experience_years": 5,
  "education": "Bachelor's in Computer Science",
  "resume_url": "https://example.com/resume.pdf"
}
```

**Response:**
```json
{
  "job_seeker": {
    "id": 1,
    "first_name": "John",
    "last_name": "Doe",
    "phone": "+1234567890",
    "location": "San Francisco, CA",
    "bio": "Experienced developer",
    "skills": ["Ruby", "Rails", "JavaScript"],
    "experience_years": 5,
    "education": "Bachelor's in Computer Science",
    "resume_url": "https://example.com/resume.pdf",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### Update Job Seeker
```http
PUT /job_seekers/:id
```

**Request Body:**
```json
{
  "first_name": "Updated Name",
  "bio": "Updated bio"
}
```

**Response:**
```json
{
  "job_seeker": {
    "id": 1,
    "first_name": "Updated Name",
    "last_name": "Doe",
    "phone": "+1234567890",
    "location": "San Francisco, CA",
    "bio": "Updated bio",
    "skills": ["Ruby", "Rails", "JavaScript"],
    "experience_years": 5,
    "education": "Bachelor's in Computer Science",
    "resume_url": "https://example.com/resume.pdf",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### Delete Job Seeker
```http
DELETE /job_seekers/:id
```

**Response:**
```json
{
  "message": "Job seeker deleted successfully"
}
```

## Job Endpoints

### List Jobs
```http
GET /jobs
```

**Query Parameters:**
- `page` (integer): Page number (default: 1)
- `per_page` (integer): Items per page (default: 20, max: 100)
- `search` (string): Search term
- `location` (string): Filter by location
- `employment_type` (string): Filter by employment type
- `salary_min` (integer): Minimum salary filter
- `salary_max` (integer): Maximum salary filter
- `remote` (boolean): Filter by remote jobs
- `status` (string): Filter by job status
- `company_id` (integer): Filter by company

**Response:**
```json
{
  "jobs": [
    {
      "id": 1,
      "title": "Senior Ruby Developer",
      "description": "We are looking for a senior Ruby developer...",
      "requirements": ["Ruby", "Rails", "PostgreSQL"],
      "location": "San Francisco, CA",
      "employment_type": "full_time",
      "salary_min": 120000,
      "salary_max": 180000,
      "currency": "USD",
      "remote": true,
      "status": "active",
      "company": {
        "id": 1,
        "name": "Acme Corp",
        "logo_url": "https://acme.com/logo.png"
      },
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100,
    "per_page": 20
  }
}
```

### Get Job
```http
GET /jobs/:id
```

**Response:**
```json
{
  "job": {
    "id": 1,
    "title": "Senior Ruby Developer",
    "description": "We are looking for a senior Ruby developer...",
    "requirements": ["Ruby", "Rails", "PostgreSQL"],
    "location": "San Francisco, CA",
    "employment_type": "full_time",
    "salary_min": 120000,
    "salary_max": 180000,
    "currency": "USD",
    "remote": true,
    "status": "active",
    "company": {
      "id": 1,
      "name": "Acme Corp",
      "description": "A great company",
      "website": "https://acme.com",
      "logo_url": "https://acme.com/logo.png",
      "location": "San Francisco, CA",
      "industry": "Technology",
      "size": "50-200",
      "founded_year": 2020
    },
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### Create Job
```http
POST /jobs
```

**Request Body:**
```json
{
  "title": "Senior Ruby Developer",
  "description": "We are looking for a senior Ruby developer...",
  "requirements": ["Ruby", "Rails", "PostgreSQL"],
  "location": "San Francisco, CA",
  "employment_type": "full_time",
  "salary_min": 120000,
  "salary_max": 180000,
  "currency": "USD",
  "remote": true
}
```

**Response:**
```json
{
  "job": {
    "id": 1,
    "title": "Senior Ruby Developer",
    "description": "We are looking for a senior Ruby developer...",
    "requirements": ["Ruby", "Rails", "PostgreSQL"],
    "location": "San Francisco, CA",
    "employment_type": "full_time",
    "salary_min": 120000,
    "salary_max": 180000,
    "currency": "USD",
    "remote": true,
    "status": "active",
    "company_id": 1,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### Update Job
```http
PUT /jobs/:id
```

**Request Body:**
```json
{
  "title": "Updated Job Title",
  "description": "Updated job description"
}
```

**Response:**
```json
{
  "job": {
    "id": 1,
    "title": "Updated Job Title",
    "description": "Updated job description",
    "requirements": ["Ruby", "Rails", "PostgreSQL"],
    "location": "San Francisco, CA",
    "employment_type": "full_time",
    "salary_min": 120000,
    "salary_max": 180000,
    "currency": "USD",
    "remote": true,
    "status": "active",
    "company_id": 1,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### Delete Job
```http
DELETE /jobs/:id
```

**Response:**
```json
{
  "message": "Job deleted successfully"
}
```

## Application Endpoints

### List Applications
```http
GET /applications
```

**Query Parameters:**
- `page` (integer): Page number (default: 1)
- `per_page` (integer): Items per page (default: 20, max: 100)
- `status` (string): Filter by application status
- `job_id` (integer): Filter by job
- `job_seeker_id` (integer): Filter by job seeker

**Response:**
```json
{
  "applications": [
    {
      "id": 1,
      "status": "pending",
      "cover_letter": "I am interested in this position...",
      "job": {
        "id": 1,
        "title": "Senior Ruby Developer",
        "company": {
          "id": 1,
          "name": "Acme Corp"
        }
      },
      "job_seeker": {
        "id": 1,
        "first_name": "John",
        "last_name": "Doe"
      },
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100,
    "per_page": 20
  }
}
```

### Get Application
```http
GET /applications/:id
```

**Response:**
```json
{
  "application": {
    "id": 1,
    "status": "pending",
    "cover_letter": "I am interested in this position...",
    "job": {
      "id": 1,
      "title": "Senior Ruby Developer",
      "description": "We are looking for a senior Ruby developer...",
      "requirements": ["Ruby", "Rails", "PostgreSQL"],
      "location": "San Francisco, CA",
      "employment_type": "full_time",
      "salary_min": 120000,
      "salary_max": 180000,
      "currency": "USD",
      "remote": true,
      "company": {
        "id": 1,
        "name": "Acme Corp",
        "description": "A great company",
        "website": "https://acme.com",
        "logo_url": "https://acme.com/logo.png",
        "location": "San Francisco, CA",
        "industry": "Technology",
        "size": "50-200",
        "founded_year": 2020
      }
    },
    "job_seeker": {
      "id": 1,
      "first_name": "John",
      "last_name": "Doe",
      "phone": "+1234567890",
      "location": "San Francisco, CA",
      "bio": "Experienced developer",
      "skills": ["Ruby", "Rails", "JavaScript"],
      "experience_years": 5,
      "education": "Bachelor's in Computer Science",
      "resume_url": "https://example.com/resume.pdf"
    },
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### Create Application
```http
POST /applications
```

**Request Body:**
```json
{
  "job_id": 1,
  "cover_letter": "I am interested in this position..."
}
```

**Response:**
```json
{
  "application": {
    "id": 1,
    "status": "pending",
    "cover_letter": "I am interested in this position...",
    "job_id": 1,
    "job_seeker_id": 1,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### Update Application
```http
PUT /applications/:id
```

**Request Body:**
```json
{
  "status": "reviewed"
}
```

**Response:**
```json
{
  "application": {
    "id": 1,
    "status": "reviewed",
    "cover_letter": "I am interested in this position...",
    "job_id": 1,
    "job_seeker_id": 1,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### Delete Application
```http
DELETE /applications/:id
```

**Response:**
```json
{
  "message": "Application deleted successfully"
}
```

## Search Endpoints

### Search Jobs
```http
GET /search/jobs
```

**Query Parameters:**
- `q` (string): Search query
- `location` (string): Filter by location
- `employment_type` (string): Filter by employment type
- `salary_min` (integer): Minimum salary filter
- `salary_max` (integer): Maximum salary filter
- `remote` (boolean): Filter by remote jobs
- `skills` (string): Filter by required skills (comma-separated)
- `page` (integer): Page number (default: 1)
- `per_page` (integer): Items per page (default: 20, max: 100)

**Response:**
```json
{
  "jobs": [
    {
      "id": 1,
      "title": "Senior Ruby Developer",
      "description": "We are looking for a senior Ruby developer...",
      "requirements": ["Ruby", "Rails", "PostgreSQL"],
      "location": "San Francisco, CA",
      "employment_type": "full_time",
      "salary_min": 120000,
      "salary_max": 180000,
      "currency": "USD",
      "remote": true,
      "status": "active",
      "company": {
        "id": 1,
        "name": "Acme Corp",
        "logo_url": "https://acme.com/logo.png"
      },
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100,
    "per_page": 20,
    "query": "ruby developer",
    "filters": {
      "location": "San Francisco, CA",
      "employment_type": "full_time"
    }
  }
}
```

### Search Companies
```http
GET /search/companies
```

**Query Parameters:**
- `q` (string): Search query
- `industry` (string): Filter by industry
- `location` (string): Filter by location
- `size` (string): Filter by company size
- `page` (integer): Page number (default: 1)
- `per_page` (integer): Items per page (default: 20, max: 100)

**Response:**
```json
{
  "companies": [
    {
      "id": 1,
      "name": "Acme Corp",
      "description": "A great company",
      "website": "https://acme.com",
      "logo_url": "https://acme.com/logo.png",
      "location": "San Francisco, CA",
      "industry": "Technology",
      "size": "50-200",
      "founded_year": 2020,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100,
    "per_page": 20,
    "query": "technology company",
    "filters": {
      "industry": "Technology",
      "location": "San Francisco, CA"
    }
  }
}
```

### Search Job Seekers
```http
GET /search/job_seekers
```

**Query Parameters:**
- `q` (string): Search query
- `skills` (string): Filter by skills (comma-separated)
- `location` (string): Filter by location
- `experience_years` (integer): Filter by experience years
- `education` (string): Filter by education
- `page` (integer): Page number (default: 1)
- `per_page` (integer): Items per page (default: 20, max: 100)

**Response:**
```json
{
  "job_seekers": [
    {
      "id": 1,
      "first_name": "John",
      "last_name": "Doe",
      "phone": "+1234567890",
      "location": "San Francisco, CA",
      "bio": "Experienced developer",
      "skills": ["Ruby", "Rails", "JavaScript"],
      "experience_years": 5,
      "education": "Bachelor's in Computer Science",
      "resume_url": "https://example.com/resume.pdf",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100,
    "per_page": 20,
    "query": "ruby developer",
    "filters": {
      "skills": "Ruby,Rails",
      "location": "San Francisco, CA"
    }
  }
}
```

## Webhook Endpoints

### Application Status Update Webhook
```http
POST /webhooks/application_status_update
```

**Request Body:**
```json
{
  "application_id": 1,
  "old_status": "pending",
  "new_status": "reviewed",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

**Response:**
```json
{
  "message": "Webhook processed successfully"
}
```

## SDKs and Libraries

### Ruby
```ruby
require 'rails_ops_client'

client = RailsOpsClient.new(
  api_key: 'your-api-key',
  base_url: 'https://your-domain.com/api/v1'
)

# List jobs
jobs = client.jobs.list(page: 1, per_page: 20)

# Create application
application = client.applications.create(
  job_id: 1,
  cover_letter: "I am interested in this position..."
)
```

### JavaScript
```javascript
const RailsOpsClient = require('rails-ops-client');

const client = new RailsOpsClient({
  apiKey: 'your-api-key',
  baseUrl: 'https://your-domain.com/api/v1'
});

// List jobs
const jobs = await client.jobs.list({ page: 1, per_page: 20 });

// Create application
const application = await client.applications.create({
  job_id: 1,
  cover_letter: "I am interested in this position..."
});
```

### Python
```python
from rails_ops_client import RailsOpsClient

client = RailsOpsClient(
    api_key='your-api-key',
    base_url='https://your-domain.com/api/v1'
)

# List jobs
jobs = client.jobs.list(page=1, per_page=20)

# Create application
application = client.applications.create(
    job_id=1,
    cover_letter="I am interested in this position..."
)
```

## Changelog

### Version 1.0.0 (2024-01-01)
- Initial API release
- Authentication endpoints
- CRUD operations for all entities
- Search functionality
- Webhook support

## Support

For API support, please contact:
- Email: api-support@your-domain.com
- Documentation: https://your-domain.com/docs
- Status Page: https://status.your-domain.com
