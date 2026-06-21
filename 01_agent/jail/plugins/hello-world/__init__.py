"""Hermes plugin: a model-invocable `web_search` tool backed by OpenRouter.

Why this exists: OpenRouter's own `openrouter:web_search` server tool can be
injected via extra_body, but owl-alpha (and likely other models) treat that
opaque provider-side entry as "not directly invocable" and never call it. A
plugin-registered tool has a normal function schema the model WILL call (it was
already trying to call `web_search` by name), and we route the call to a handler
that performs the search through OpenRouter's `web` plugin (powered by Exa) using
the same OPENROUTER_API_KEY — one credential, no separate search vendor.

Assumptions about the Hermes plugin API (adjust to match the installed version
if the plugin fails to load — the startup error will point at the exact call):
  * Hermes discovers this package and calls `register(ctx)` at startup.
  * `ctx.register_tool(name=, toolset=, schema=, handler=)` registers a tool.
  * `schema` carries the description + JSON-Schema parameters.
  * `handler` is invoked with the parsed tool arguments.

Only the Python standard library is used, so no extra packages are installed.
"""

import json
import os
import urllib.error
import urllib.request

OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"
# A free model is fine for grounding the search; override via env if desired.
SEARCH_MODEL = os.environ.get("OPENROUTER_SEARCH_MODEL", "openrouter/owl-alpha")


def _search(query):
    api_key = os.environ.get("OPENROUTER_API_KEY")
    if not api_key:
        return "web_search error: OPENROUTER_API_KEY is not set in the environment."

    body = {
        "model": SEARCH_MODEL,
        # The `web` plugin runs an Exa search server-side and grounds the reply.
        "plugins": [{"id": "web", "max_results": 5}],
        "messages": [
            {
                "role": "user",
                "content": (
                    "Search the web and answer concisely with current information. "
                    "Always cite source URLs. Query: " + query
                ),
            }
        ],
    }
    req = urllib.request.Request(
        OPENROUTER_URL,
        data=json.dumps(body).encode("utf-8"),
        headers={
            "Authorization": "Bearer " + api_key,
            "Content-Type": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            data = json.load(resp)
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", "replace")
        return "web_search error: HTTP %s - %s" % (exc.code, detail)
    except Exception as exc:  # surface any failure to the agent rather than crash
        return "web_search error: %s" % exc

    try:
        message = data["choices"][0]["message"]
    except (KeyError, IndexError):
        return "web_search error: unexpected response shape: " + json.dumps(data)[:500]

    parts = []
    content = message.get("content")
    if content:
        parts.append(content if isinstance(content, str) else json.dumps(content))

    # OpenRouter returns web citations as message.annotations (type url_citation).
    sources = []
    for ann in message.get("annotations") or []:
        cite = ann.get("url_citation") or {}
        url = cite.get("url")
        if url:
            sources.append("- %s (%s)" % (cite.get("title") or url, url))
    if sources:
        parts.append("Sources:\n" + "\n".join(sources))

    return "\n\n".join(parts) if parts else "web_search returned no content."


def _handler(*args, **kwargs):
    """Tolerant of however Hermes passes tool args (dict, kwargs, or bare str)."""
    query = kwargs.get("query")
    if query is None:
        for arg in args:
            if isinstance(arg, dict) and "query" in arg:
                query = arg["query"]
                break
            if isinstance(arg, str):
                query = arg
                break
    if not query:
        return "web_search error: missing 'query' argument."
    return _search(query)


def register(ctx):
    ctx.register_tool(
        name="web_search",
        toolset="web",
        schema={
            "description": (
                "Search the web for current, real-time information and return a "
                "concise answer with source URLs. Use when you need facts newer "
                "than your training data."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "The search query.",
                    }
                },
                "required": ["query"],
            },
        },
        handler=_handler,
    )
