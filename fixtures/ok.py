"""Fixture for the ci self-test: must parse and run."""
import json
import sys

print(json.dumps({"python": sys.version.split()[0], "ok": True}))
