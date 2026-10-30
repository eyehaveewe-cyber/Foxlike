#!/usr/bin/env python3
"""Import, test, export, and package Foxlike with the pinned Godot editor.

The build contains no downloaded game assets or remote runtime dependencies.
Install the standard Godot 4.7.2 export templates before running this tool.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
VERSION = "4.7.2"
TARGETS = {"windows": ("Windows", "Foxlike.exe"), "web": ("Web", "index.html")}


def run(command: list[str]) -> str:
    result = subprocess.run(command, cwd=ROOT, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT)
    print(result.stdout, end="", flush=True)
    if result.returncode or "SCRIPT ERROR:" in result.stdout or "Parse Error:" in result.stdout:
        raise RuntimeError(f"Command failed ({result.returncode}): {command}")
    return result.stdout


def checksum(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot", help="Path to Godot 4.7.2 editor")
    parser.add_argument("--platform", choices=["all", *TARGETS], default="all")
    parser.add_argument("--output", type=Path, default=ROOT / "build")
    parser.add_argument("--skip-tests", action="store_true", help="Export after a separately verified test run")
    args = parser.parse_args()
    godot = shutil.which(args.godot) or args.godot
    run([sys.executable, "tools/stamp_duel.py", "--check"])
    engine_version = run([godot, "--version"]).strip()
    if not engine_version.startswith(VERSION + ".stable"):
        raise RuntimeError(f"Expected Godot {VERSION} stable, found: {engine_version}")
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    run([godot, "--headless", "--path", str(ROOT), "--import"])
    if not args.skip_tests:
        run([godot, "--headless", "--path", str(ROOT), "--script", "res://tests/music_smoke.gd", "--", "--test-save"])
        run([godot, "--headless", "--path", str(ROOT), "--script", "res://tests/game_smoke.gd", "--", "--test-save"])
        run([godot, "--headless", "--path", str(ROOT), "--script", "res://tests/squadron_smoke.gd", "--", "--test-save"])
        run([godot, "--headless", "--path", str(ROOT), "--script", "res://tests/combat_revision_smoke.gd", "--", "--test-save"])
        run([godot, "--headless", "--path", str(ROOT), "--script", "res://tests/expansion_smoke.gd", "--", "--test-save"])
        run([godot, "--headless", "--path", str(ROOT), "--script", "res://tests/duel_smoke.gd", "--", "--test-save"])
        run([godot, "--headless", "--path", str(ROOT), "--script", "res://tests/orbit_smoke.gd", "--", "--test-save"])
        run([godot, "--headless", "--path", str(ROOT), "--script", "res://tests/orbit_exploration_smoke.gd", "--", "--test-save"])
        run([godot, "--headless", "--path", str(ROOT), "--script", "res://tests/tank_support_smoke.gd", "--", "--test-save"])
    manifest = {"game": "Foxlike: Asterion Flight", "engine": engine_version, "builds": []}
    selected = TARGETS if args.platform == "all" else {args.platform: TARGETS[args.platform]}
    for platform, (preset, entry) in selected.items():
        target_dir = output / platform
        target_dir.mkdir(parents=True, exist_ok=True)
        # Clear this tool's prior export, so removed engine output cannot leak into a new ZIP.
        for old in target_dir.iterdir():
            if old.is_file():
                old.unlink()
        run([godot, "--headless", "--path", str(ROOT), "--export-release", preset, str(target_dir / entry)])
        required = [entry, "Foxlike.pck"] if platform == "windows" else [entry, "index.js", "index.wasm", "index.pck"]
        for filename in required:
            artifact = target_dir / filename
            if not artifact.is_file() or artifact.stat().st_size == 0:
                raise RuntimeError(f"Missing export output: {artifact}")
        if platform == "windows":
            instructions = "Foxlike: Asterion Flight\n\nExtract this entire folder, then open Foxlike.exe. Keep Foxlike.pck beside the executable.\n\nGodot is not required to play this build. Keyboard, mouse and controller bindings are shown in-game.\n\nGame: https://github.com/eyehaveewe-cyber/Foxlike\nGodot Engine license: https://godotengine.org/license/\n"
        else:
            instructions = "Foxlike: Asterion Flight — Web build\n\nServe this folder through HTTP(S); do not open index.html using file://.\n\nLocal preview: python -m http.server 8000\nThen open http://localhost:8000\n\nWebGL 2 and WebAssembly are required. Click inside the game to enable audio.\nThis build is single-threaded and does not require cross-origin isolation headers.\n\nGame: https://github.com/eyehaveewe-cyber/Foxlike\nGodot Engine license: https://godotengine.org/license/\n"
            (target_dir / ".nojekyll").touch()
        (target_dir / "START-HERE.txt").write_text(instructions, encoding="utf-8")
        for name in ["LICENSE", "LICENSE.txt", "CREDITS.md"]:
            source = ROOT / name
            if source.is_file():
                shutil.copy2(source, target_dir / name)
        archive = output / f"Foxlike-{platform}.zip"
        with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=6) as bundle:
            for file in sorted(target_dir.rglob("*")):
                if file.is_file():
                    bundle.write(file, file.relative_to(target_dir))
        manifest["builds"].append({"platform": platform, "file": archive.name,
                                   "bytes": archive.stat().st_size, "sha256": checksum(archive)})
        print(f"Packaged {archive} ({archive.stat().st_size:,} bytes)")
    (output / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError) as error:
        print(f"Build failed: {error}", file=sys.stderr)
        raise SystemExit(1)
