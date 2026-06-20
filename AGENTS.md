## Important notes

* Chores must be run in order, not in parallel.
* Whenever tofu plan is run, use lock=false to avoid accidently holding the lock.

## Environment

* If your working directory is `/root/lightning`, you are likely running inside a sandboxed containerized environment
* In order to make persistent changes to the environment you'll need to update jail.containerfile
* Anything in .env will be injected into the environment variables of this sandbox

## Agent requirements

* Github CLI (`gh`), for checking latest versions of software. Authenticated via a read-only token surfaced into `.env` as `GH_TOKEN`.
* Opentofu MCP, for checking provider versions.

## Objectives

Refer to objectives.md

## Chores

There's a human written procedure in chores.md and also an AI written skill.
