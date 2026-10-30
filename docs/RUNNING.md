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

The normal flight deck opens the ten-operation campaign. See [operation order and controls](../README.md#operations-and-continuity) and [implementation contracts](EXPANDED_CAMPAIGN.md). Continue restores the current authored objective checkpoint. Replays preserve the canonical ending, frontier and carrier/rival/rescue facts.

WASD/arrows or left stick steer; Space/LMB/RT fires. Shift/RB boosts or hovers Jackal; Ctrl/LB brakes; Q/E or A rolls. T/right-stick press cycles targets, R/X fires a missile, B fires Nova, and I/D-pad down interacts. Tap F/Y for companion abilities; hold it and choose 1–4 or D-pad up/right/down/left for attack/protect/cover/regroup. Tab/left-stick press changes formation. Z/X/V or D-pad up/left/right selects the spatial stunts. Escape/Start pauses; M mutes. Keyboard and controller button bindings can be changed in settings; shown bindings are authoritative.

Cinder has finite hover fuel with grounded recharge and a ground alternative to each barrier. Required carrier or cargo loss fails the operation; optional support loss changes the debrief. Retry restores the latest authored boundary, including confirmed systems, companion damage and resources. A crash after Crown’s defeat restarts the escape with Crown still defeated.

Focus loss and controller disconnection pause safely. Release held controls before resuming. Pitch hold, camera roll, shake, boost FOV and 100%/150% interface size are adjustable. Physical controller verification remains validation work. Jonathan’s October 30 instruction removes the human-playtest prerequisites from programming.

The old compact scene is `tests/compact_campaign.tscn`, used by historical regression/render fixtures and excluded from playable exports. It is not a selectable second campaign.

## Build Windows and Web

Install Godot's matching **4.7.2 export templates** using **Editor → Manage Export Templates**. From the repository root:

Use Python 3.11 or newer for the release packager.

```sh
python tools/package_release.py --godot /path/to/godot
```

The tool imports resources, exports both platforms and writes ZIPs plus a SHA-256 manifest under `build/`. To export one platform, use `--platform windows` or `--platform web`. Use `--skip-tests` only after running the same suites separately.

<!-- native-suite-list:start -->
The packager runs these 12 native suites before exporting:

- `tests/operations_smoke.gd`
- `tests/operation_routes.gd`
- `tests/operation_journey_smoke.gd`
- `tests/music_smoke.gd`
- `tests/game_smoke.gd`
- `tests/squadron_smoke.gd`
- `tests/combat_revision_smoke.gd`
- `tests/expansion_smoke.gd`
- `tests/duel_smoke.gd`
- `tests/orbit_smoke.gd`
- `tests/orbit_exploration_smoke.gd`
- `tests/tank_support_smoke.gd`
<!-- native-suite-list:end -->

Regenerate the documented lists with `python tools/check_documentation.py --write` after changing the packager. CI checks these lists and local documentation links.

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

To publish deliberately, run **Build playable game** from the Actions page and enable its **publish_pages** checkbox. Ordinary pushes only test and package. The workflow reports the deployment URL after an explicitly requested successful deployment. No deployment is part of this implementation task.

## Build sources

The workflow downloads the editor and templates from the [official Godot builds repository](https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable). It uses pinned release tags for the official GitHub checkout, artifact upload and Pages actions. Export behavior follows the [Godot 4.7 command-line documentation](https://docs.godotengine.org/en/4.7/tutorials/editor/command_line_tutorial.html) and [Web export documentation](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html).
