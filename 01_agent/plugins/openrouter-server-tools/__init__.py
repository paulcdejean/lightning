"""OpenRouter server-tools plugin for Hermes.

OpenRouter offers "server tools" — web_search, web_fetch, datetime, and more —
that the model invokes and OpenRouter executes server-side (billed to the same
OPENROUTER_API_KEY). Two plugin hooks are needed to make them work in Hermes:

  1. register_tool(): advertises each server tool to the model and installs a
     no-op safety-net handler. Without the advertisement the model treats an
     injected server tool as "not directly invocable" and never calls it.
  2. register_middleware("llm_request"): appends the real
     {type: "openrouter:web_search", parameters: {...}} declarations to the
     outgoing request's tools array, so OpenRouter recognises and executes them.

The enabled tools and their parameters are read from config.yaml under
plugins.entries.openrouter-server-tools.server_tools (see that file for the full
list). If the config can't be read, a minimal default set keeps core web tools
working.
"""

import json
import logging

logger = logging.getLogger(__name__)

PLUGIN_NAME = "openrouter-server-tools"

# Fallback used only if the config can't be read — keeps the core web tools live.
_DEFAULT_SERVER_TOOLS = [
    {"type": "openrouter:web_search"},
    {"type": "openrouter:web_fetch"},
    {"type": "openrouter:datetime"},
]


def _load_server_tools():
    """Read the configured server-tool list from config.yaml; fall back to defaults."""
    try:
        from hermes_cli.config import load_config

        entries = (load_config().get("plugins") or {}).get("entries") or {}
        tools = (entries.get(PLUGIN_NAME) or {}).get("server_tools")
        if isinstance(tools, list) and tools:
            return tools
    except Exception as exc:
        logger.warning(
            "%s: could not read server_tools from config (%s); using defaults",
            PLUGIN_NAME,
            exc,
        )
    return _DEFAULT_SERVER_TOOLS


def _stub_handler(tool_type):
    """Safety net only: OpenRouter normally intercepts the call before Hermes sees it."""

    def handler(params, **kwargs):
        logger.debug("%s reached Hermes' dispatcher (OpenRouter did not intercept)", tool_type)
        return json.dumps(
            {"note": f"{tool_type} is an OpenRouter server-side tool, executed by OpenRouter."}
        )

    return handler


def register(ctx):
    server_tools = _load_server_tools()
    types = [t.get("type") for t in server_tools if isinstance(t, dict) and t.get("type")]
    logger.info("%s: enabling server tools: %s", PLUGIN_NAME, ", ".join(types))

    # 1. Advertise each server tool to the model, with a no-op safety-net handler.
    for tool_type in types:
        ctx.register_tool(
            name=tool_type,
            toolset="web",
            schema={
                "name": tool_type,
                "description": f"OpenRouter server-side tool '{tool_type}', executed by OpenRouter.",
                # Permissive stub schema — OpenRouter validates the real arguments.
                "parameters": {
                    "type": "object",
                    "properties": {
                        "query": {
                            "type": "string",
                            "description": "Primary input (e.g. a search query or URL), if applicable.",
                        }
                    },
                    "additionalProperties": True,
                },
            },
            handler=_stub_handler(tool_type),
            override=True,
        )

    # 2. Inject the real server-tool declarations into each outgoing request.
    def inject_server_tools(request, **kwargs):
        tools = request.get("tools")
        if isinstance(tools, list):
            present = {t.get("type") for t in tools if isinstance(t, dict)}
            for st in server_tools:
                if isinstance(st, dict) and st.get("type") and st["type"] not in present:
                    tools.append(dict(st))
                    present.add(st["type"])
        return {"request": request}

    ctx.register_middleware("llm_request", inject_server_tools)
