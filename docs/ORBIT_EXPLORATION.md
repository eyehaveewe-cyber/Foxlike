# Asterion orbital exploration

## Player controls

Enter **Planet Orbits / Peaceful Hub** from the flight deck. The entire catalog is available for peaceful exploration; choosing a planet does not complete or unlock a campaign mission.

| Input | Result |
| --- | --- |
| P / options Planet Grid | Choose among twelve planets, or open the original PBR system chart |
| N | Cycle the selected planet's moon waypoints and return station |
| F | Turn the nose toward the waypoint without redirecting existing velocity |
| T, then hold W | Travel drive, up to 1,500 m/s in open space |
| Space | Powered braking to hover |
| I | Engine cutoff/restart; cutoff preserves existing travel momentum |
| H | Toggle powered hover assistance |
| W/S, A/D, Q/E | Forward/reverse, strafe, descend/rise |
| Arrows / RMB drag | Turn and pitch |
| G / LMB / controller A | Catch a visible asteroid within 700 m, press again to fling |
| R | Drop the tether without a throw impulse |
| J / B | Admit a local asteroid / toggle visitors |
| Home | Explicit recovery to the current planet's station |
| F2 / F3 / M | View / hide interface / ambient sound |

Options expose the waypoint, facing and travel-drive actions for menu/controller access. Existing stick, bumper, trigger, assist, camera and station-return mappings remain. A physical controller has not been tested.

The travel drive accelerates the real ship, with a 700 m/s² thrust budget and a 900 m/s² powered speed governor. Its maximum approaches 125 m/s near station/celestial surfaces and 1,500 m/s in clear space. Leaving the drive off retains normal 62 m/s thrusters and 125 m/s boost. Engine cutoff disables thrust, assistance and the drive governor. Harmless collision holds and the outer-room boundary remain active. To arrive gently, restart engines and brake.

F only faces the target. It is not autopilot. When a planet blocks the direct line, steer around its limb before continuing. The waypoint gives surface distance and an arrival cue; the moon remains an ordinary world-space body throughout the trip.

## Imported catalog

| World | Source type | Physical moons | Rings |
| --- | --- | ---: | --- |
| Ember | Rocky | 2 | |
| Dune | Desert | 3 | |
| Pelagos | Ocean | 4 | |
| Viridia | Terrestrial | 3 | |
| Vesper | Volcanic | 6 | |
| Cobalt | Storm | 5 | |
| Jovian | Gas giant | 18 | |
| Boreas | Ice giant | 12 | Yes |
| Aurora | Frozen | 9 | |
| Chronos | Ringed giant | 16 | Yes |
| Nyx | Carbon | 8 | |
| Terminus | Crystal | 7 | Yes |

These names, colors, counts, ring flags, chart coordinates and route connections come from the owner's Project Barrel Roll. The source does not name its individual moons. Foxlike assigns stable planet-and-number IDs and labels, such as VIRIDIA 01, with authored scaled radii, positions and slow orbits. Those 3D moon layouts and flight parameters are new Foxlike work.

## Space and rendering

Each selected planet has a continuous 100,000-unit radius exploration space around the station. Units are presented as meters for navigation, but planet/moon scales and distances are authored for flight, not real astronomical proportions. Main radii derive from PBR's chart sizes, with Viridia at 6,000. A safe 2,700-unit gap separates each planet's surface from the station. Moons range from 330 to 800 units in radius and orbit outside their planet. All generated moons fit within the room. Surface collision uses analytic sphere sweeps with a 25-unit ship stand-off; there are no landing levels or destructible moon surfaces.

World selection is an explicit sector transfer and starts stationary at the destination station. It clears old visitors and any held lance, resets drive/velocity/clock and preserves the user's sound/time preferences. Planet-to-planet journeys are not continuous solar-system flights. Trips from each planet's station to its moons are continuous, with no approach teleport or loading boundary.

Only the chosen planet and its moons are instantiated. Planets/moons share 128×64, 48×24 and 16×8 sphere meshes; apparent radius selects the level at 0.10 and 0.015, sampled five times a second. Surface shader detail drops with mesh detail. Clouds cull below 0.025 apparent radius and atmosphere below 0.008; rings use 128 or 32 segments. Station windows/nameplates cull at 4.5/2.5 km, and the station mesh at 22 km. Collisions keep their full analytic shape regardless of visual detail. Camera far distance is 240 km. No target-machine frame-rate improvement is claimed without profiling that machine.

Asteroids retain a maximum of 24 live visitors. New arrivals cluster around the ship even far from the station; old unheld visitors more than 14 km away retire. Held visitors remain physical spring bodies. Station, planet and moon cover block the lance. Asteroid gravity uses a scaled primary-planet/co-orbiting approximation; moons are slow authored orbits, not mutually gravitating N-body objects. The ship's unpowered flight is local inertial coasting. Rings are visual dust, not solid barriers.

The chosen arrangement preserves reachable 3D bodies and short moon-flight times. A literal solar-system distance model would require a separate scale/precision/travel design. A backdrop-only moon would cost less but would not satisfy reachable flight. Those alternatives were not implemented.

## Verification

`tests/orbit_exploration_smoke.gd` exercises all twelve real grid cards, chart selection, 93 distinct physical moons, ring flags, safe berths/bounds, unknown-ID rejection, continuous moon travel, powered speed bounds, full-speed unpowered surface protection, LOD consistency, distant visitor placement, lance cleanup on world swap, waypoint cycling and frame-rate-independent coasting. Its 70 checks join 40 hub checks and 235 campaign/duel checks.

The deterministic Viridia station-to-first-moon case reached less than 300 units from the surface in 13.72 simulated seconds, with a peak of 795.89 units/s. The script continually faces the waypoint and holds ordinary thrust. This proves continuous integrated travel and collision, not human handling quality. Native captures use the actual scene and shader output. Windows/Web exports build; actual browser runtime, physical controller and human feel remain open.

The dated evidence is in [VERIFICATION.md](VERIFICATION.md). Exact imported source blobs and adaptations are in [ASSET_IMPORTS.md](ASSET_IMPORTS.md).
