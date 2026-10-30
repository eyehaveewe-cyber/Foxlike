#!/usr/bin/env python3
"""Check local documentation links and regenerate the documented native suite lists."""
from __future__ import annotations

import argparse
import ast
from pathlib import Path
import re
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
REGIONS = {
    "README.md": "native-suite-commands",
    "docs/RUNNING.md": "native-suite-list",
}


def documentation_files() -> set[Path]:
    files = set(ROOT.glob("*.md"))
    for folder in ("docs", "assets"):
        files.update((ROOT / folder).rglob("*.md"))
    return files


def local_links(document: Path):
    text = re.sub(r"```[^\n]*\n.*?```", "", document.read_text(encoding="utf-8"), flags=re.S)
    for match in re.finditer(r"!?\[[^\]]*\]\((?:<([^>]+)>|([^\s)]+))(?:\s+[^)]*)?\)", text):
        value = match[1] or match[2]
        url = urlsplit(value)
        if url.scheme or url.netloc:
            continue
        target = (document.parent / unquote(url.path)).resolve() if url.path else document.resolve()
        yield value, target, unquote(url.fragment)


def native_suites() -> list[str]:
    tree = ast.parse((ROOT / "tools/package_release.py").read_text(encoding="utf-8"))
    return [
        node.value.removeprefix("res://") for node in ast.walk(tree)
        if isinstance(node, ast.Constant) and isinstance(node.value, str)
        and re.fullmatch(r"res://tests/[a-z_]+\.gd", node.value)
    ]


def generated_region(document: str, suites: list[str]) -> str:
    if document == "README.md":
        lines = ["```bash", "godot --headless --path . --import"]
        lines += [f"godot --headless --path . --script res://{suite} -- --test-save" for suite in suites]
        lines += ["python tools/package_release.py --godot godot", "```"]
        return "\n".join(lines)
    return (
        f"The packager runs these {len(suites)} native suites before exporting:\n\n"
        + "\n".join(f"- `{suite}`" for suite in suites)
    )


def anchors(document: Path) -> set[str]:
    found: set[str] = set()
    for heading in re.findall(r"^#{1,6}\s+(.+)$", document.read_text(encoding="utf-8"), re.M):
        base = re.sub(r"[^\w\- ]", "", heading.lower()).replace(" ", "-")
        slug = base
        suffix = 1
        while slug in found:
            slug = f"{base}-{suffix}"
            suffix += 1
        found.add(slug)
    return found


def check_docs(write: bool = False) -> tuple[int, int]:
    suites = native_suites()
    if not suites or len(suites) != len(set(suites)):
        raise RuntimeError("Missing or duplicate native suites in package_release.py")
    for relative, name in REGIONS.items():
        document = ROOT / relative
        text = document.read_text(encoding="utf-8")
        start, end = f"<!-- {name}:start -->", f"<!-- {name}:end -->"
        if text.count(start) != 1 or text.count(end) != 1:
            raise RuntimeError(f"Missing generated-list markers in {relative}")
        before, rest = text.split(start)
        _, after = rest.split(end)
        expected = before + start + "\n" + generated_region(relative, suites) + "\n" + end + after
        if expected != text:
            if not write:
                raise RuntimeError(f"Stale suite list in {relative}; run python tools/check_documentation.py --write")
            document.write_text(expected, encoding="utf-8")
    count = 0
    documents = documentation_files()
    for document in sorted(documents):
        for value, target, fragment in local_links(document):
            count += 1
            if not target.is_relative_to(ROOT) or not target.exists():
                raise RuntimeError(f"Broken local link in {document.relative_to(ROOT)}: {value}")
            if fragment and target.suffix == ".md" and fragment not in anchors(target):
                raise RuntimeError(f"Missing heading in {document.relative_to(ROOT)}: {value}")
    return len(documents), count


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="Refresh generated suite lists before checking")
    args = parser.parse_args()
    documents, links = check_docs(args.write)
    print(f"DOCUMENTATION: {documents} Markdown files, {links} local links and {len(native_suites())} native suites verified")


if __name__ == "__main__":
    main()
