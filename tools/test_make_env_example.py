#!/usr/bin/env python3
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from make_env_example import convert


def test_strips_values_keeps_comments():
    src = "# local only\nOPENAI_API_KEY=sk-live-not-real\n\nDB_URL=postgres://u:p@localhost/db\n"
    out = convert(src)
    assert "sk-live-not-real" not in out
    assert "postgres://u:p@localhost/db" not in out
    assert "OPENAI_API_KEY=" in out
    assert "DB_URL=" in out
    assert out.startswith("# local only")


if __name__ == "__main__":
    test_strips_values_keeps_comments()
    print("ok")
