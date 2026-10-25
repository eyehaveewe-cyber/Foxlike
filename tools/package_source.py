#!/usr/bin/env python3
"""Package the editable Godot project without an engine install or exported binaries."""
from pathlib import Path
import re
import fnmatch
import zipfile

ROOT = Path(__file__).resolve().parents[1]
DIRECTORIES = ("assets", "scenes", "scripts", "shaders", "tests", "tools")
FILES = ("project.godot", "export_presets.cfg", "README.md", "PROGRESS.md", "CREDITS.md", "docs/RUNNING.md", "docs/SOURCES.md", "docs/DESIGN.md", "docs/ASSET_IMPORTS.md", "docs/PLAYTEST_RESOLUTION.md", "docs/VERIFICATION.md", "docs/PHASE_01_IMPLEMENTATION.md", "docs/plans/Foxlike_Phase_01_Fair_Flight_Duel.docx")


def main():
    files = {ROOT / name for name in FILES}
    for directory in DIRECTORIES:
        files.update(p for p in (ROOT / directory).rglob("*")
                     if p.is_file() and "__pycache__" not in p.parts and p.suffix != ".pyc")
    # Check packaged res:// references, including scene scripts and audio resources.
    for path in sorted(files):
        if not path.is_file():
            raise RuntimeError(f"Missing source file: {path}")
        if path.suffix in (".godot", ".tscn", ".gd", ".cfg") and "tests" not in path.relative_to(ROOT).parts:
            for reference in re.findall(r'res://([^"\s]+)', path.read_text()):
                pattern = reference.replace("%s", "*")
                if not any(fnmatch.fnmatch(str(p.relative_to(ROOT)), pattern) for p in files):
                    raise RuntimeError(f"Unpackaged resource in {path.name}: {reference}")
    archive = ROOT / "build/Foxlike-source.zip"
    archive.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as bundle:
        for path in sorted(files):
            bundle.write(path, Path("Foxlike") / path.relative_to(ROOT))
    with zipfile.ZipFile(archive) as bundle:
        if bundle.testzip() is not None:
            raise RuntimeError("Source ZIP integrity check failed")
        assert "Foxlike/project.godot" in bundle.namelist()
    print(f"Packaged {len(files)} files: {archive}")


if __name__ == "__main__":
    main()
