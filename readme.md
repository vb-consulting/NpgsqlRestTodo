# TODO Application With Perfect Architecture

![System Diagram](system-diagram.png)

That's it!

- Fronted App is Svelte 5, TailwindCSS and DaisyUI.
- Backend Database is PostgreSQL 17 with automatic API.

Everything is Dockerized (see Task list), inlcuding build and watch processes. There is option for local builds too without Docker but you'll need a Bun runtime. You can install it from here: https://bun.sh/docs/installation

## Installation

You can use degit to clone this repo as a template:

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

Note: Install recommended extensions and use task explorer to run tasks!
