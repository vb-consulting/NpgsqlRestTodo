# NpgsqlRestTodo - PostgreSQL Full-Stack TODO Application

A complete template application implementing a TODO feature with modern PostgreSQL-based architecture, automatic REST API generation, and comprehensive security features.

## Purpose

This template serves as: a **production boilerplate** (TODO code is placeholder to be replaced), **component library** for reusable parts, **proof of concept** for strongly-typed PostgreSQL→API→Frontend pipeline, and **skills development** playground. The TODO implementation is incomplete and intentionally temporary - meant to be removed and replaced with actual business logic.

## Project Overview

**NpgsqlRestTodo** is a full-stack application template that demonstrates modern PostgreSQL-centric development with:
- PostgreSQL backend with business logic implemented as functions and procedures
- Automatic REST API generation via NpgsqlRest
- Svelte 5 frontend with TypeScript and end-to-end type safety
- Fully Dockerized development and production environments
- Background job processing with Bun worker service

## Technology Stack

### Backend
- **PostgreSQL**: Primary database with TimescaleDB extensions
- **NpgsqlRest**: Automatic REST API generation from PostgreSQL functions
- **Authentication**: Cookie-based with encrypted persistence
- **Logging**: Serilog with TimescaleDB hypertables

### Frontend
- **Svelte 5**: Modern reactive framework with runes
- **TypeScript**: Full type safety with auto-generated API types
- **DaisyUI 5**: Tailwind-based component system
- **Tailwind CSS 4**: Utility-first styling

### Build & Runtime
- **Bun**: JavaScript runtime for build system and worker service
- **Rollup**: Module bundler with Svelte plugin
- **Docker**: Containerized services for all environments

### Infrastructure
- **Nginx**: Reverse proxy for production
- **PgBouncer**: Connection pooling for scalability
- **Temporal Tables**: Built-in data history tracking

## Essential Commands

### Development
```bash
# Frontend development (with file watching)
bun watch              # Main TODO app
bun watch:admin        # Admin interface

# Production builds
bun build              # Build main app
bun build:admin        # Build admin interface

# API refresh (after database changes)
bun refresh            # Refresh main app API
bun refresh:admin      # Refresh admin API
```

### Database Management
```bash
# Schema management
bun db-up              # Run migrations
bun db-list            # List pending migrations
bun db-schema          # Show current schema
bun db-history         # Show migration history

# Testing and utilities
bun db-test            # Run database tests
bun db-dump            # Export database
bun psql               # Open PostgreSQL shell
```

### Package Management
```bash
bun upgrade            # Upgrade Bun runtime
bun update             # Update all dependencies (including worker)
```

## Project Structure

```
NpgsqlRestTodo/
├── src/
│   ├── app/                    # Main TODO application
│   │   ├── api/               # Auto-generated API clients
│   │   ├── pages/             # Svelte page components
│   │   └── part/              # Layout and UI components
│   ├── admin/                 # Administration interface
│   ├── _lib/                  # Shared components and utilities
│   └── backend/               # PostgreSQL schema and functions
│       ├── 0__system/         # Core system functions
│       ├── 1__temporal/       # Temporal table system
│       ├── 2__public/         # Public schema tables
│       ├── 5__auth/           # Authentication system
│       └── 7__todo/           # TODO business logic
├── worker/                    # Background job processing
├── config/                    # Docker and service configurations
└── http/                      # HTTP request examples
```

## Key Features

### Auto-Generated APIs
- PostgreSQL functions automatically become REST endpoints
- TypeScript interfaces generated from database schemas
- HTTP test files created for development
- End-to-end type safety from database to frontend

### Database-Centric Architecture
- Business logic implemented as PostgreSQL functions
- Temporal tables for complete data history
- Automated audit fields for tracking changes
- Least-privilege security with scoped database users

### Development Experience
- Hot reload for both frontend and API changes
- Automatic TypeScript code generation
- Docker configurations for local and production environments
- Separated app/admin services for independent deployment

## Environment Configurations

### Development
- **Local (.local)**: Host-based build with Dockerized services
- **Dev (.dev)**: Fully containerized with hot reload

### Production
- **Prod**: Optimized builds with Nginx reverse proxy
- Includes PgBouncer connection pooling
- Separated app (port 8080) and admin (port 8081) services

## Database Migration System

Uses `pgmigrations` with convention-based file naming:
- `V[n]__`: Versioned migrations (run once)
- `R__`: Repeatable migrations (run when changed)
- `_R__`: Repeatable before versioned migrations
- `_B__`: Always run before all migrations
- `_A__`: Always run after all migrations

## Authentication & Security

- Cookie-based authentication with encryption
- External auth provider integration
- Email confirmation and password reset workflows
- Role-based access control
- Audit logging to TimescaleDB hypertables

## Background Processing

Bun-based worker service handles:
- Email confirmations and password resets
- PostgreSQL NOTIFY/LISTEN for real-time job processing
- Extensible job queue system with database persistence

## API Development Workflow

1. Write PostgreSQL function with business logic
2. Add annotation comment for HTTP exposure
3. Run `bun refresh` to regenerate API
4. Use auto-generated TypeScript client in frontend
5. Leverage generated HTTP files for testing

This creates a type-safe development pipeline from database to UI with automatic API generation.