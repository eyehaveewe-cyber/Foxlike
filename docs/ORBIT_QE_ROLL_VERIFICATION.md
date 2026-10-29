# Orbital Q/E roll verification — 2026-10-29

Based on Foxlike commit `0374ec6574cfbab07e2318824a9580d93269fee1`. In Planet Orbits / Peaceful Hub, hold Q or E to rotate around the ship's nose. Releasing the key retains the angle. Z/X now descend/rise; the chase camera stays upright to show the roll. Rolling alone does not change drift; Home or choosing a planet resets it.

## Checks

- Godot 4.7.2 Web packaging completed with 370 passing checks across the existing and new suites. `tests/orbit_incremental_roll_smoke.gd` contributes 17 checks for actual key events, roll, direction, local thrusters, coasting, frame rates, pause, waypoint facing and reset. The package script runs this suite with the existing regressions.
- Actual Chromium WebGL2 desktop staging at 1280×720 entered Planet Orbits and selected Viridia. Real keyboard input rolled with Q, held the bank after release and reversed it with E. X thrust increased speed from rest to 8.3 m/s, Space reduced it to 0.1 m/s, Escape opened options, and the on-screen Return to Flight Deck returned to the menu. No captured page or console errors occurred.
- Screenshots: [level](evidence/orbit-qe-roll/level.png), [rolled](evidence/orbit-qe-roll/rolled.png), [held](evidence/orbit-qe-roll/held.png), [reversed](evidence/orbit-qe-roll/reversed.png), [thrust](evidence/orbit-qe-roll/thrust.png) and [braking](evidence/orbit-qe-roll/brake.png).

The browser used Chromium's SwiftShader software renderer. Wall-clock rendering was slow, so it is not a hardware performance or human flight-feel test. Physical controllers were not tested. Phase One's pending human duel acceptance remains unchanged.
