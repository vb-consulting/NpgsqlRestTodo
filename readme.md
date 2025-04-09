# TODO Application With Perfect Architecture

![System Diagram](system-diagram.png)

A modern web application architecture showcasing:

- **Frontend**: Svelte 5, TailwindCSS, and DaisyUI for a responsive and interactive UI
- **Backend**: PostgreSQL 17 with auto-generated REST API (via NpgsqlRest)
- **Deployment**: Fully Dockerized environment with optimized builds for both development and production

Following Uncle Bob's principles, this project avoids SQL strings in favor of PostgreSQL Functions and Stored Procedures, creating a clean separation of concerns with database-driven business logic.

## Installation

You can use degit to quickly clone this repository as a template without initializing a new Git repository:

```console
$ bun install -g degit
$ degit vb-consulting/NpgsqlRestTodo my_project
$ cd my_project
$ code .
```

Alternatively, you can click the "Use this template" button in the upper right corner of the GitHub repository page.

**Recommended setup**: 
- Install the recommended VS Code extensions (defined in `.vscode/extensions.json`)
- Use the VS Code Task Explorer to run predefined tasks
- Make sure Docker and Docker Compose are installed for containerized development

## Development Workflow

### Running Commands

This project offers a comprehensive set of tasks organized into 8 categories (defined in `.vscode/tasks.json`):

| Category | Description | Example Commands |
|----------|-------------|-----------------|
| **app** | Frontend application tasks | Build, watch, refresh API |
| **bun** | Package management | Update Bun, upgrade dependencies |
| **db** | Local database operations | Run migrations, schema dumps, tests |
| **dockerdb** | Database containers | Start dev/prod database instances |
| **dockerdev** | Docker development environment | Run the full stack with hot reloading |
| **dockerlocal** | Hybrid local/Docker setup | Run database in Docker, frontend locally |
| **dockermigrations** | Containerized migrations | Run database operations without local tools |
| **dockerprod** | Production deployment | Build and run optimized containers |

The recommended workflow is to use VS Code's Task Explorer to run these commands, or run them directly using Bun scripts defined in `package.json`.

## Frontend Application

The frontend is built with a modern JavaScript stack optimized for developer experience and performance:

- **Svelte 5**: Reactive UI framework with minimal boilerplate
- **TailwindCSS**: Utility-first CSS framework
- **DaisyUI**: Component library for Tailwind CSS
- **Rollup**: Module bundler with build caching for faster development
- **TypeScript**: Type safety with incremental compilation
- **Bun**: Fast JavaScript runtime and package manager

The application follows a modular architecture:
- **API Layer**: Auto-generated TypeScript clients in `/src/api/`
- **Core Logic**: Application state and business logic in `/src/app/`
- **Component Library**: Reusable components in `/src/app/lib/` (shared) and `/src/app/part/` (application-specific)
- **Assets**: Static files in `/src/assets/`
- **Styling**: Global styles and Tailwind configuration in `/src/style/`

## Database

The backend architecture leverages PostgreSQL's powerful features:

- **PostgreSQL Functions and Procedures**: Business logic implemented directly in the database
- **Background Job Processing**: Dedicated worker component running Bun JavaScript modules for tasks like email sending
- **TimescaleDB HA**: High-availability database image with 113+ preinstalled PostgreSQL extensions
- **Production-Ready**: Docker Compose configuration includes PgBouncer for connection pooling and NGINX as a web server/proxy

This approach minimizes the need for a traditional middleware layer, allowing direct and efficient communication between the frontend and database.


## Project Structure

```
NpgsqlRestTodo/
│
├── .vscode/                     # VS Code configuration and task definitions
│
├── database/                    # Backend PostgreSQL code
│   ├── 000__sys/                # System utilities and core functions
│   ├── 100__public/             # Public schema objects (versioned migrations)
│   ├── 200__logs/               # Logging tables in separate schema
│   ├── 300__app/                # Application business logic routines
│   ├── 400__auth/               # Authentication system
│   │   ├─── private/            # Internal authentication functions
│   │   └─── public/             # Public-facing authentication endpoints
│   │
│   └── TESTS/                   # Database unit tests
│
├── config/                      # Build and environment configuration
│   ├── docker-compose.*.yml     # Docker Compose configurations
│   └── Dockerfile.*             # Container definitions
│
├── dist/                        # Build output directory
│
├── http/                        # Auto-generated HTTP request examples
│
├── src/                         # Frontend source code
│   ├── api/                     # Auto-generated API clients ($api)
│   │
│   ├── app/                     # Application components
│   │   ├── lib/                 # Framework-agnostic utilities ($lib)
│   │   └── part/                # Application-specific components ($part)
│   │
│   ├── assets/                  # Static assets
│   │   └── confirm/             # Email confirmation page
│   │
│   └── style/                   # Global styles and Tailwind config
│
└── worker/                      # Background job processing
    └── queue_modules/           # Job processor implementations
```

## Troubleshooting

- **Permissions Issue for `dist` on Linux**: After Docker builds, local builds may fail due to permissions. Fix with:
```bash
sudo chown -R $(whoami) ./dist/
```

- **CORS Policy Issue on WSL**: WSL defaults to http://localhost:5000, causing CORS errors. Use http://127.0.0.1:5000 instead, as the API expects requests from this address.

- **WSL Docker Watching Issues**: File watching may fail in Docker on WSL. Set this environment variable in `./config/docker-compose.dev.yml` under the `rollup-watch` service:
```yaml
environment:
  - ENABLE_POLLING=true
```

- **Docker Volume Permissions**: If you encounter permission issues with Docker volumes, make sure the volumes have appropriate permissions:
```bash
docker-compose down -v && docker-compose up
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Questions and Support

If you have questions or need assistance, please visit the [discussion board](https://github.com/vb-consulting/NpgsqlRestTodo/discussions).

## License

This project is licensed under the [MIT License](https://github.com/vb-consulting/NpgsqlRestTodo/blob/master/LICENSE), which allows you to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software.

## Acknowledgements

If you find this project useful, please consider giving it a star on GitHub and sharing your feedback on the [discussion board](https://github.com/vb-consulting/NpgsqlRestTodo/discussions).
