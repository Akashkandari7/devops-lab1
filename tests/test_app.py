import json
import os
import sys
import threading
import unittest
import urllib.error
import urllib.request
from http.server import HTTPServer

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "app"))

import app  # noqa: E402


class UnitTests(unittest.TestCase):
    def test_health_reports_up(self):
        self.assertEqual(app.health()["status"], "UP")

    def test_greet_default_name(self):
        self.assertEqual(app.greet()["message"], "Hello, DevOps!")

    def test_greet_custom_name(self):
        self.assertEqual(app.greet("Akash")["message"], "Hello, Akash!")

    def test_greet_blank_name_falls_back(self):
        self.assertEqual(app.greet("   ")["message"], "Hello, DevOps!")

    def test_add(self):
        self.assertEqual(app.add(2, 3), 6)


class HttpTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = HTTPServer(("127.0.0.1", 0), app.Handler)
        cls.base = f"http://127.0.0.1:{cls.server.server_port}"
        threading.Thread(target=cls.server.serve_forever, daemon=True).start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()

    def get(self, path):
        with urllib.request.urlopen(self.base + path) as resp:
            return resp.status, json.loads(resp.read())

    def test_health_endpoint(self):
        status, body = self.get("/health")
        self.assertEqual(status, 200)
        self.assertEqual(body["status"], "UP")

    def test_root_endpoint_with_name(self):
        status, body = self.get("/?name=Jenkins")
        self.assertEqual(status, 200)
        self.assertEqual(body["message"], "Hello, Jenkins!")

    def test_unknown_path_returns_404(self):
        with self.assertRaises(urllib.error.HTTPError) as ctx:
            self.get("/does-not-exist")
        self.assertEqual(ctx.exception.code, 404)


if __name__ == "__main__":
    unittest.main(verbosity=2)
