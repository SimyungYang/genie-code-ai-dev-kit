"""Databricks App: AI Dev Kit MCP Server.

No git clone at runtime — packages installed via requirements.txt.
Instant startup, no cold-start delay.
"""

import logging
import os
import sys
import time

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

_start = time.monotonic()

# Remove stale ai-dev-kit cache paths that may conflict with pip-installed packages
sys.path = [p for p in sys.path if ".ai-dev-kit" not in p]

# Import MCP server — packages are pre-installed via requirements.txt
from databricks_mcp_server.server import mcp  # noqa: E402

logger.info("MCP server imported in %.1fs", time.monotonic() - _start)

# --- ASGI app with health check ---

from starlette.middleware import Middleware  # noqa: E402
from starlette.middleware.cors import CORSMiddleware  # noqa: E402

_host = os.environ.get("DATABRICKS_HOST", "")
if _host and not _host.startswith("https://"):
    _host = f"https://{_host}"
WORKSPACE_URL = _host.rstrip("/")

app = mcp.http_app(
    path="/mcp",
    stateless_http=True,
    middleware=[
        Middleware(
            CORSMiddleware,
            allow_origins=[WORKSPACE_URL] if WORKSPACE_URL else ["*"],
            allow_credentials=bool(WORKSPACE_URL),
            allow_methods=["*"],
            allow_headers=["*"],
        )
    ],
)

logger.info("App ready in %.1fs", time.monotonic() - _start)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
