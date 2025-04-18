# TODO Application With Perfect Architecture

![System Diagram](system-diagram.png)

That's it!

- **App** is your **Frontend**: Svelte 5, TailwindCSS, and DaisyUI.
- **Database** is your **Backend**: PostgreSQL 17 with an auto-generated REST API (via NpgsqlRest).
- **Deployment**: Fully Dockerized, including build and watch processes. Local builds are also supported with the Bun runtime.

## Installation

You can use degit to clone this repo as a template:. Degit copies repo without repo intialization.

```console
$ bun install -g degit
bun add v1.2.8 (adab0f64)

installed degit@2.8.4 with binaries:
 - degit

1 package installed [980.00ms]
$ degit vb-consulting/NpgsqlRestTodo my_project
> cloned vb-consulting/NpgsqlRestTodo#HEAD to my_project
$ cd my_project
$ code .
```

You can also click big green button "Use this template" in the upper right corner of the GitHub.

Note: Install recommended extensions for VS Code and use task explorer to run tasks!

## Running Commands

Tasks are organized into 8 categories (see `tasks.json` for details):

- **app**: Build, watch, or refresh autogenerated application files.
- **bun**: Update Bun or upgrade packages.
- **db**: Local database commands (e.g., dump schema, run migrations, or test). Requires local `pgmigrations` and PostgreSQL client.
- **dockerdb**: Start the database container (dev or prod, detached or interactive).
- **dockerdev**: Run everything in Docker with the app in watch mode (uses Rollup in `/src/`).
- **dockerlocal**: Run everything in Docker except the app—use local build/watch commands instead.
- **dockermigrations**: Dockerized database commands (e.g., dump, migrate, test)—no local tools needed.
- **dockerprod**: Build or run a production-ready Docker image (minified, no watch mode).

## Application

## Database

Backend is implemnted almost exclusivly as PostgreSQL Functions and Procedures.

## Directory Structure

```
NpgsqlRestTodo/
│
├── .vscode/                     # VS Code configuration. Cotnains tasks and extension recommendations.
│
├── database/                    # Backend, PostgreSQL code. This your Backend.
│   ├── 000__sys/                # System Routines.
│   ├── 100__public/             # Public schema objects. Versioned migrations.
│   ├── 200__logs/               # Logging Tables in separate schema
│   ├── 300__app/                # Application Routines.
│   ├── 400__auth/               # Authentication Routines.
│   │   ├─── private/            # Private Authentication Routines
│   │   │
│   │   └─── public/             # Public Authentication Routines Exposed as Endpoints
│   │
│   └── TESTS/                   # Database tests
│
├── config/                      # Configuration files
│
├── dist/                        # Build output directory (empty in repo and ignored by git)
│
├── http/                        # Auto-generated HTTP request examples for testing
│
├── src/                         # Application source code. Root dir contains entry points for compiler. Each .ts have coresponding .js in dist dir
│   ├── api/                     # Auto-generated API modules. Alias is $api
│   │
│   ├── app/                     # Application code. Root dir contains Svelte components for coresponding pages.
│   │   ├── lib/                 # Library code. Reusable components and reusable modules that are not application specific. Alias is $lib
│   │   └── part/                # UI components Reusable components and reusable modules that are application specific. Application parts. Alias is $part
│   │
│   ├── assets/                  # Static assets. Files are copied on each build.
│   │   └── confirm/             # Confirmation page
│   │
│   └── style/                   # CSS styles
│
└── worker/                      # Background job worker
    └── queue_modules/           # Job processors
```


## Troubleshooting

- **Permissions Issue for `dist` on Linux**: After Docker builds, local builds may fail due to permissions. Fix with:
```bash
sudo chown -R $(whoami) ./dist/
```

- **CORS Policy Issue on WSL**: WSL defaults to http://localhost:5000, causing CORS errors. Use http://127.0.0.1:5000 instead, as the API expects requests from this address.

- **WSL Docker Watching Issues**: File watching may fail in Docker on WSL. Set this environment variable in `./config/docker-compose.dev.yml` under the `rollup-watch` service:
```
ENABLE_POLLING=true
```

## Got Questions?

Take them to a [discussion board](https://github.com/vb-consulting/NpgsqlRestTodo/discussions).

## Licence

[MIT License](https://github.com/vb-consulting/NpgsqlRestTodo/blob/master/LICENSE) let's you do anyhting.

## Say Thank You

Also at [discussion board](https://github.com/vb-consulting/NpgsqlRestTodo/discussions).