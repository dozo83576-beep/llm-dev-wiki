"""Pytest bootstrap: tools/ modules import siblings directly (script-style),
so the tools directory must be on sys.path when they are imported as tools.*."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
