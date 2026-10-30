"""Run the recovery pose in a pinned, isolated PBR flight-lab checkout."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess

PIN = "5e34e1fc7824d3099a50deb208bffc47dc824cb0"
ROOT = Path(__file__).resolve().parents[1]

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--pbr", type=Path, required=True)
    p.add_argument("--godot", required=True)
    p.add_argument("--display")
    p.add_argument("--capture-dir", type=Path)
    args = p.parse_args()
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=args.pbr, text=True).strip()
    if revision != PIN:
        raise RuntimeError("Use the pinned PBR draft lab in a disposable checkout")
    copies = [(ROOT / "scripts/campaign/airframe_pose.gd", args.pbr / "scripts/foxlike/recovery_pose_probe.gd"),
              (ROOT / "tests/pbr_recovery_contract.gd.txt", args.pbr / "tests/recovery_pose_probe.gd")]
    if any(dst.exists() for _, dst in copies):
        raise RuntimeError("Probe files already exist; refusing to overwrite checkout work")
    try:
        for src, dst in copies: shutil.copy2(src, dst)
        flags = ["--headless"] if not args.display else ["--audio-driver", "Dummy"]
        command = [args.godot, *flags, "--path", str(args.pbr), "--script", "res://tests/recovery_pose_probe.gd"]
        if args.capture_dir: command += ["--", "--capture-dir", str(args.capture_dir.resolve())]
        env = os.environ.copy()
        if args.display: env["DISPLAY"] = args.display
        result = subprocess.run(command, text=True, capture_output=True, timeout=180, env=env)
        output = result.stdout + result.stderr
        print(output)
        if result.returncode or "SCRIPT ERROR:" in output or "PBR_RECOVERY_CONTRACT: 90 checks; 0 failures" not in output:
            raise RuntimeError("PBR pose contract failed")
        evidence = {"pbr_revision":PIN,"pose_sha256":hashlib.sha256(copies[0][0].read_bytes()).hexdigest(),"checks":90,"result":"pass","scope":"local-only recovery family; no PBR merge or campaign changes"}
        (ROOT / "docs/evidence/pbr-recovery-contract.json").write_text(json.dumps(evidence, indent=2)+"\n")
    finally:
        for _, dst in copies:
            if dst.exists(): dst.unlink()

if __name__ == "__main__": main()
