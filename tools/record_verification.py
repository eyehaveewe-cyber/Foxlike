"""Record real native/browser results and the verified source snapshot."""
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
EXPECTED = ["OPERATIONS_SMOKE", "OPERATION_ROUTES", "OPERATION_JOURNEY_SMOKE", "MUSIC_SMOKE", "GAME_SMOKE", "SQUADRON_SMOKE", "COMBAT_REVISION_SMOKE", "EXPANSION_SMOKE", "DUEL_SMOKE", "ORBIT_SMOKE", "ORBIT_EXPLORATION_SMOKE", "TANK_SUPPORT_SMOKE"]

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    log = (ROOT / "build/final-native-exports.log").read_text()
    results = {name: {"checks": int(count), "failures": int(failures)} for name, count, failures in
               re.findall(r"^(\w+): (\d+) (?:checks|assertions); (\d+) failures", log, re.M)}
    if set(results) != set(EXPECTED) or any(r["failures"] for r in results.values()) or "SCRIPT ERROR:" in log:
        raise RuntimeError("Native validation did not complete successfully")
    for path, marker in [("build/operations-final.log", "OPERATIONS_SMOKE"), ("build/journey-final.log", "OPERATION_JOURNEY_SMOKE"), ("build/music-final.log", "MUSIC_SMOKE")]:
        focused = (ROOT / path).read_text()
        if "SCRIPT ERROR:" in focused or not re.search(rf"^{marker}: {results[marker]['checks']} (?:checks|assertions); 0 failures", focused, re.M):
            raise RuntimeError("Focused final validation failed: " + path)
    browser = json.loads((ROOT / "build/web-smoke/results.json").read_text())
    if not browser["passed"] or browser["errors"]:
        raise RuntimeError("Exported browser validation failed")
    manifest = json.loads((ROOT / "build/manifest.json").read_text())
    for build in manifest["builds"]:
        if digest(ROOT / "build" / build["file"]) != build["sha256"]:
            raise RuntimeError("Export archive does not match its manifest")
    files = [ROOT / "project.godot", ROOT / "export_presets.cfg"]
    for folder, pattern in [("scripts", "*.gd"), ("scenes", "*.tscn"), ("shaders", "*.gdshader")]:
        files += sorted((ROOT / folder).rglob(pattern))
    report = {"date":"2026-10-30", "engine":manifest["engine"], "native_suites":results,
              "native_total":sum(r["checks"] for r in results.values()),
              "browser":{"version":browser["browser"],"viewport":browser["viewport"],"checks":len(browser["checks"]),"errors":browser["errors"]},
              "source_sha256":{p.relative_to(ROOT).as_posix():digest(p) for p in files},
              "exports":manifest["builds"],
              "scope":"Arranged native state/physics tests and actual Chromium keyboard smoke; no human campaign completion, physical controller or Windows hardware result.",
              "known_cleanup":"Rapid native teardown can retain audio-thread playback references; focused audio teardown waits for release. No script/parse failures passed the gate."}
    out = ROOT / "docs/evidence/expanded-results.json"
    out.write_text(json.dumps(report, indent=2)+"\n")
    print(f"VERIFIED: {report['native_total']} native checks / {report['browser']['checks']} browser checks / {len(files)} source hashes")

if __name__ == "__main__": main()
