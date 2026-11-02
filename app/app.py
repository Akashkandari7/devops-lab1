"""Sample web application used for the DevOps Lab 1 CI/CD pipeline.

Uses only the Python standard library so the Jenkins agent needs nothing
beyond the python3 that ships with Ubuntu 24.04.
"""

import json
import os
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, HTTPServer

APP_NAME = "devops-lab1-sample-app"
VERSION = os.environ.get("APP_VERSION", "dev")


def health():
    return {"status": "UP", "app": APP_NAME, "version": VERSION}


def greet(name=None):
    name = (name or "DevOps").strip() or "DevOps"
    return {"message": f"Hello, {name}!", "time": datetime.now(timezone.utc).isoformat()}


def add(a, b):
    return a + b


class Handler(BaseHTTPRequestHandler):
    def _send(self, code, body):
        payload = json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self):
        path, _, query = self.path.partition("?")
        params = dict(p.split("=", 1) for p in query.split("&") if "=" in p)

        if path == "/":
            self._send(200, greet(params.get("name")))
        elif path == "/health":
            self._send(200, health())
        else:
            self._send(404, {"error": "not found", "path": path})

    def log_message(self, fmt, *args):
        print(f"[{self.log_date_time_string()}] {fmt % args}", flush=True)


def main():
    port = int(os.environ.get("PORT", "8000"))
    server = HTTPServer(("0.0.0.0", port), Handler)
    print(f"{APP_NAME} v{VERSION} listening on port {port}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
