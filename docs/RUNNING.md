# Running Foxlike

Foxlike targets **Godot 4.7.2 stable** using the Compatibility renderer. The source project and exported builds contain the game; there are no asset downloads during play.

## Play a Windows build

On this repository's **Actions → Build playable game** page, open a successful run and download **Foxlike-playable-builds**. Extract that artifact, then extract `Foxlike-windows.zip`. Run `Foxlike.exe` with `Foxlike.pck` beside it. You do not need the Godot editor to play an exported build.

## Run from source

1. Install the standard [Godot 4.7.2 editor](https://godotengine.org/download/archive/4.7.2-stable/).
2. [Download the complete source ZIP](https://github.com/eyehaveewe-cyber/Foxlike/archive/refs/heads/main.zip) and extract it, or clone this repository. The extracted `Foxlike-main` folder contains `project.godot` alongside `scenes`, `scripts`, and `assets`.
3. Import `project.godot` in Godot and press **F6** from `scenes/main.tscn`, or **F5** to run the project.

Command line:

```sh
godot --path /path/to/Foxlike
```

## Mission controls and progression

The campaign has six missions: Viridia, Aurora, Terminus, Cinder, Anchorage and Tempest. Each has its own boss. Cleared missions remain selectable; old saves that completed Terminus grant access to Cinder. Mission refit restores shields, six missiles, three Nova bombs and companion health.

- **Rail flight:** WASD/arrows or mouse steer. Hold Shift / RB plus left, down or right for the somersault, long loop or corkscrew.
- **Cinder tank:** A/D moves sideways, W/S aims vertically, and holding Shift / RB fires the jet packs. Release to land; fuel recharges on the ground. Release after exhaustion before another jump. Flight rolls and stunts are unavailable in the tank.
- **Anchorage arena:** A/D turns, W/S changes altitude, and the radar tracks the player, carrier and attackers. Flying outward toward the rim triggers a 2.4-second climbing turnaround. Defend Dragonfly's hull while fighting Harrow. Boost-direction stunts are disabled here.
- **Weapons and squadron:** Space/left click fires lasers; R/right click launches a locked missile; B fires a Nova; F commands ready companion abilities; Tab changes formation. Missiles have a six-round starting load, eight-round cap and 2.5-second firing cooldown. Cyan crates add three rounds and green repair supplies add two.

See the [complete control table](../README.md#controls). Physical controller testing remains outstanding.

## Build Windows and Web

Install Godot's matching **4.7.2 export templates** using **Editor → Manage Export Templates**. From the repository root:

```sh
python tools/package_release.py --godot /path/to/godot
```

The tool imports resources, runs all four suites (`game_smoke.gd`, `squadron_smoke.gd`, `combat_revision_smoke.gd` and `expansion_smoke.gd`), exports both platforms and writes ZIPs plus a SHA-256 manifest under `build/`. To export one platform, use `--platform windows` or `--platform web`. Use `--skip-tests` only after running the same tests separately.

## Play the browser build locally

Extract `Foxlike-web.zip` and serve its directory:

```sh
python -m http.server 8000
```

Open `http://localhost:8000` in a WebGL 2-capable browser. Click the game to enable sound. Opening `index.html` directly through `file://` does not work. This is a single-threaded Web export, so ordinary static hosting works without cross-origin isolation headers.

## Optional GitHub Pages

The build workflow always creates downloadable Windows and Web packages. It deploys the browser build only when both of these repository settings are configured:

1. **Settings → Pages → Build and deployment → Source: GitHub Actions**.
2. **Settings → Secrets and variables → Actions → Variables**: set repository variable `ENABLE_PAGES` to `true`.

Then run **Build playable game** from the Actions page or push to `main`. The workflow reports the deployment URL. The expected repository Pages address is `https://eyehaveewe-cyber.github.io/Foxlike/`, but that address is live only after a successful Pages deployment.

## Build sources

The workflow downloads the editor and templates from the [official Godot builds repository](https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable). It uses pinned release tags for the official GitHub checkout, artifact upload and Pages actions. Export behavior follows the [Godot 4.7 command-line documentation](https://docs.godotengine.org/en/4.7/tutorials/editor/command_line_tutorial.html) and [Web export documentation](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html).
