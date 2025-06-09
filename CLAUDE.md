# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tesseral is a B2B authentication platform with multi-tenant architecture. The system consists of:
- Go backend services using Connect-RPC
- React + TypeScript frontends (console for admins, vault-ui for end users)
- PostgreSQL database with sqlc for query generation
- Protocol buffers for API definitions

## Architecture

### Backend Services
- **backend**: Admin/console API (`/internal/backend`)
- **frontend**: User-facing auth API (`/internal/frontend`)
- **intermediate**: Login flow orchestration (`/internal/intermediate`)
- **saml**: SAML SSO implementation (`/internal/saml`)
- **scim**: SCIM provisioning (`/internal/scim`)
- **configapi**: Configuration API (`/internal/configapi`)
- **wellknown**: Well-known endpoints (`/internal/wellknown`)

### Frontend Applications
- **console** (`/console`): Admin dashboard at https://console.tesseral.example.com
- **vault-ui** (`/vault-ui`): Hosted auth pages for end users

### Key Architectural Decisions
- Multi-tenant: Projects belong to organizations, users belong to organizations
- Service separation with different auth mechanisms per service type
- Heavy use of code generation (protobuf, sqlc) for type safety
- Connect-RPC for modern, type-safe API communication
- Hosted login pages customizable per project

## Common Development Commands

### Initial Setup
```bash
# Copy environment variables
cp .env.example .env

# Add hosts entries
cat etc.hosts.example | sudo tee -a /etc/hosts

# Bootstrap everything (certs, DB, migrations, seed data)
make bootstrap
```

### Running Services
```bash
# Start all services with hot reload
make dev

# Or use Docker Compose directly
docker compose up -d

# Or use Tilt for better development experience
tilt up
```

### Database Operations
```bash
# Run migrations
make migrate      # up
make migrate down # down

# Generate SQL queries from sqlc
make queries

# Seed database with test data
make seed

# Clean up database
make cleanup
```

### Code Generation
```bash
# Generate all protobuf code
make proto

# Generate SQL queries
make queries
```

### Frontend Development
```bash
# Console
cd console
npm run dev   # Start dev server (port 3000)
npm run build # Production build
npm run test  # Run tests

# Vault UI
cd vault-ui
npm run dev   # Start dev server (port 3002)
npm run build # Production build
npm run test  # Run tests
npm run lint  # Run ESLint
npm run fmt   # Format code
```

### Testing
```bash
# Run all Go tests
go test -v ./...

# Run Go tests for specific package
go test -v ./internal/backend/...

# Frontend tests
cd console && npm run test
cd vault-ui && npm run test
```

### Linting and Formatting
```bash
# Go formatting
gofmt -w .

# Go linting
go vet ./...
errcheck ./...
staticcheck ./...

# Frontend linting (vault-ui only)
cd vault-ui && npm run lint
```

## Local Development Access

After running `make bootstrap` and `docker compose up -d`:

- **Console**: https://console.tesseral.example.com
- **Login**: `root@app.tesseral.example.com` / `password`
- **Email Viewer**: https://smtp.tesseral.example.com (MailDev)
- **Vault UI**: Available at project-specific domains

## Database Schema

Migrations are in `/cmd/openauthctl/migrations/`. Key tables:
- `projects`: Multi-tenant projects
- `organizations`: B2B organizations
- `users`: End users (belong to organizations)
- `sessions`: User sessions with JWT tokens
- `intermediate_sessions`: Temporary auth flow sessions

## API Development

1. Define API in protobuf files (`/internal/*/proto/`)
2. Run `make proto` to generate code
3. Implement service methods in `/internal/*/service/`
4. Add SQL queries in `/sqlc/queries-*.sql`
5. Run `make queries` to generate query code

## Authentication Flows

Different service types use different authentication:
- **Backend API**: API keys or user sessions
- **Frontend API**: User sessions only
- **Intermediate API**: Temporary tokens during login flow
- **SAML/SCIM**: Service-specific tokens

## Environment Variables

Key environment variables (see `.env.example`):
- `DATABASE_URL`: PostgreSQL connection
- `TESSERAL_KMS_KEY_ALIAS`: AWS KMS key for encryption
- `TESSERAL_SESSION_SIGNING_KEY`: JWT signing key
- `TESSERAL_SES_FROM_ADDRESS`: Email sender address
- `STRIPE_SECRET_KEY`: Stripe API key
- `SVIX_SERVER_URL`: Webhook service URL