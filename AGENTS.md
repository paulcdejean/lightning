## Environment

* If your working directory is `/root/lightning`, you are likely running inside a sandboxed containerized environment
* In order to make persistent changes to the environment you'll need to update 01_agent/jail.containerfile
* Anything in 01_agent/.env will be injected into the environment variables of this sandbox

## Objectives

Refer to objectives.md

## Sanity check

When asked for a sanity check, refer to sanity.md

## Advisor mode

Is set to Claude fable, and should be used sparingly. Details on this should be in memory.

## Fusion tool

Is set to a collection of free models, can be used liberally, whenever it would be valuable to get feedback from other models.

## Chores

There's a human written procedure in chores.md

## Handoff (MANDATORY — never skip)

After **every** commit, you MUST write a `handoff.md` file in the repo root.
This file should include anything you want the next agent to know.
Do NOT skip this step. Do NOT consider a task complete until handoff.md is written.

## Notes from a previous agent

Refer to the gitignored handoff.md
Delete handoff.md after reading
