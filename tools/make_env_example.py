#!/usr/bin/env python3
"""Write a .env.example from a local .env without copying secret values.

Usage:
    python3 tools/make_env_example.py .env > .env.example
    python3 tools/make_env_example.py .env -o .env.example
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


def strip_value(line: str) -> str:
    raw = line.rstrip("\n")
    if not raw.strip() or raw.lstrip().startswith("#"):
        return raw
    if "=" not in raw:
        return raw
    key, _, _value = raw.partition("=")
    key = key.rstrip()
    if not key:
        return raw
    return f"{key}="


def convert(text: str) -> str:
    lines = [strip_value(line) for line in text.splitlines()]
    body = "\n".join(lines)
    return body + ("\n" if text.endswith("\n") or body else "")


def main() -> int:
    parser = argparse.ArgumentParser(description="Build .env.example without values")
    parser.add_argument("source", help="Path to a local .env file")
    parser.add_argument("-o", "--output", help="Write here instead of stdout")
    args = parser.parse_args()

    path = Path(args.source)
    if not path.is_file():
        print(f"error: {path} not found", file=sys.stderr)
        return 1

    rendered = convert(path.read_text(encoding="utf-8"))
    if args.output:
        Path(args.output).write_text(rendered, encoding="utf-8")
    else:
        sys.stdout.write(rendered)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
