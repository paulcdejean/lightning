"""OpenRouter server tools plugin.

Registers server-side tools (openrouter:web_search, openrouter:web_fetch,
openrouter:datetime, etc.) so the model can use them.

Two mechanisms work together:
1. LLM request middleware injects {type: "openrouter:web_search"} into the
   API request's tools array so the model knows about server tools.
2. Tools are also registered in the Hermes registry with a no-op handler as
   a safety net — if Hermes sees a server tool call in the response (which
   shouldn't happen since OpenRouter intercepts them), it returns a graceful
   response instead of an error.

Configure via config.yaml:

    plugins:
      entries:
        openrouter-web-search:
          server_tools:
            - type: openrouter:web_search
              parameters:
                engine: exa
                max_results: 5
            - type: openrouter:web_fetch
            - type: openrouter:datetime

Or via environment variable:

    OPENROUTER_SERVER_TOOLS='[{"type":"openrouter:web_search"}]'
"""

import json
import logging
import os

logger = logging.getLogger(__name__)

_DEFAULT_SERVER_TOOLS = [
    {"type": "openrouter:web_search"},
]


def _load_server_tools():
    """Load server tool definitions from config or environment."""
    try:
        from hermes_cli.config import load_config
        config = load_config()
        plugins_cfg = config.get("plugins") or {}
        entries = plugins_cfg.get("entries") or {}
        plugin_cfg = entries.get("openrouter-web-search") or {}
        tools = plugin_cfg.get("server_tools")
        if tools and isinstance(tools, list):
            return tools
    except Exception as exc:
        logger.debug("Could not read plugin config: %s", exc)

    env_tools = os.environ.get("OPENROUTER_SERVER_TOOLS", "").strip()
    if env_tools:
        try:
            parsed = json.loads(env_tools)
            if isinstance(parsed, list):
                return parsed
        except json.JSONDecodeError:
            pass

    return _DEFAULT_SERVER_TOOLS


def register(ctx):
    server_tools = _load_server_tools()
    if not server_tools:
        logger.info("openrouter-web-search: no server tools configured")
        return

    logger.info(
        "openrouter-web-search: registering %d server tool(s)",
        len(server_tools),
    )

    # --- 1. Register tools in the Hermes registry (safety net) ---
    for tool_def in server_tools:
        if not isinstance(tool_def, dict):
            continue
        tool_type = tool_def.get("type", "")
        if not tool_type:
            continue

        # Use the exact type as the registry name so it matches
        # what the model generates in tool_calls.
        tool_name = tool_type

        def make_handler(tt):
            def handler(params, **kwargs):
                # Safety net: OpenRouter should intercept server tool
                # calls before Hermes dispatches them.
                logger.debug(
                    "Server tool %s dispatched through Hermes (not intercepted by OpenRouter)",
                    tt,
                )
                return json.dumps({
                    "success": True,
                    "note": f"{tt} is a server-side tool executed by OpenRouter.",
                })
            return handler

        ctx.register_tool(
            name=tool_name,
            toolset="web",
            schema={
                "name": tool_name,
                "description": f"Server-side {tool_type} (executed by OpenRouter)",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "query": {
                            "type": "string",
                            "description": "Search query or input",
                        },
                    },
                },
            },
            handler=make_handler(tool_type),
            override=True,
        )
        logger.debug("Registered Hermes tool: %s", tool_name)

    # --- 2. Inject server tools into the API request via middleware ---
    def inject_server_tools(request, **kwargs):
        """LLM request middleware — appends server tool defs to the tools array."""
        tools = request.get("tools")
        if not isinstance(tools, list):
            return request

        existing_types = set()
        for t in tools:
            if isinstance(t, dict):
                t_type = t.get("type")
                if t_type:
                    existing_types.add(t_type)

        added = []
        for st in server_tools:
            if not isinstance(st, dict):
                continue
            st_type = st.get("type", "")
            if st_type in existing_types:
                continue
            # Server tools use {type: "openrouter:web_search"} format
            tools.append(dict(st))
            existing_types.add(st_type)
            added.append(st_type)

        if added:
            logger.debug("Injected server tools into API request: %s", added)

        return {"request": request}

    ctx.register_middleware("llm_request", inject_server_tools)
