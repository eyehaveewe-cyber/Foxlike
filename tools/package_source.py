#!/usr/bin/env python3
"""Package the editable Godot project without an engine install or exported binaries."""
from pathlib import Path
import re
import fnmatch
import zipfile
from check_documentation import check_docs, documentation_files, local_links

ROOT = Path(__file__).resolve().parents[1]
DIRECTORIES = ("assets", "scenes", "scripts", "shaders", "tests", "tools")
FILES = ("project.godot", "export_presets.cfg", "README.md", "PROGRESS.md", "CREDITS.md")


def main():
    check_docs()
    files = {ROOT / name for name in FILES}
    for directory in DIRECTORIES:
        files.update(p for p in (ROOT / directory).rglob("*")
                     if p.is_file() and "__pycache__" not in p.parts and p.suffix != ".pyc")
    # Keep the handoffs, evidence and every local documentation link portable.
    # Media enters only when a document references it; unrelated exports stay out.
    files.update(p for p in (ROOT / "docs").rglob("*")
                 if p.is_file() and p.suffix in (".md", ".docx", ".json"))
    for document in documentation_files():
        files.add(document)
        files.update(target for _, target, _ in local_links(document) if target.is_file())
    # Check packaged res:// references, including scene scripts and audio resources.
    for path in sorted(files):
        if not path.is_file():
            raise RuntimeError(f"Missing source file: {path}")
        if path.suffix in (".godot", ".tscn", ".gd", ".cfg") and "tests" not in path.relative_to(ROOT).parts:
            for reference in re.findall(r'res://([^"\s]+)', path.read_text(encoding="utf-8")):
                pattern = reference.replace("%s", "*")
                if not any(fnmatch.fnmatch(p.relative_to(ROOT).as_posix(), pattern) for p in files):
                    raise RuntimeError(f"Unpackaged resource in {path.name}: {reference}")
    archive = ROOT / "build/Foxlike-source.zip"
    archive.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as bundle:
        for path in sorted(files):
            bundle.write(path, (Path("Foxlike") / path.relative_to(ROOT)).as_posix())
    with zipfile.ZipFile(archive) as bundle:
        if bundle.testzip() is not None:
            raise RuntimeError("Source ZIP integrity check failed")
        assert "Foxlike/project.godot" in bundle.namelist()
    print(f"Packaged {len(files)} files: {archive}")


if __name__ == "__main__":
    main()
