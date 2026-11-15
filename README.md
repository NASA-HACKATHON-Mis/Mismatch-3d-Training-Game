# Lunar Base Rewind

[Separate English README](README_EN.md) · [Download presentation](docs/presentation/Lunar-Base-Rewind-English.pptx)

A first-person lunar base training game for children aged **7–12**, built for **Build a Junior Astronaut Mission Trainer**. Walk to a site, build a small base, manage seven turns, then rewind a decision and compare the result. Power, oxygen and food are limited: every useful facility has a cost.

**NASA data changes the training conditions.** Real DONKI flare, particle-event and coronal-mass-ejection records select the alert and delayed-advice rules. Genuine **8–13 May 2024 historical records** are embedded for offline play and labelled **“Embedded historical data - not live.”** A successful online request is also a single catalogue snapshot, not a continuous live feed. Resource costs, shielding and turn delays are educational rules, not physical predictions.

## Run locally

**Windows 10/11, 64-bit:** download the repository ZIP, extract the **entire** folder, and double-click **[RUN_GAME.cmd](RUN_GAME.cmd)**. The launcher installs the pinned official Godot 4.7.2 engine inside the project if missing, verifies its SHA256, imports assets and starts the game. No administrator access, Git, Python, Blender or export templates are needed to play. The first engine installation needs internet; subsequent play can be offline.

```powershell
.\RUN_GAME.cmd
.\RUN_GAME.cmd -Offline
.\RUN_GAME.cmd -NoLaunch
.\RUN_GAME.cmd -SmokeTest
```

`-Offline` skips NASA requests. `-NoLaunch` prepares/imports without opening the game; `-SmokeTest` also runs a short headless check. Use **Alt+Tab → Lunar Base Rewind** if the window opens behind another app. See [setup and troubleshooting](docs/LOCAL_RUN.md).

**Other operating systems / existing editor:** install standard Godot 4.7.2 for your OS, open `project.godot`, and press **F5**. Automatic installation is Windows-only; macOS/Linux play has not been verified in this pass. A keyboard, mouse and compatible graphics device are required. Blender is only needed to edit source models.

## Play in a minute

1. Choose **Start mission**. Use **WASD** to walk, the mouse to look and **Space** to jump. If pointer capture is unavailable, hold the left mouse button and drag to look.
2. Walk close to a site and look at its floor or building. Press **1** for **Build / Remove**. Choose a facility and confirm at that site. The shortcut alone never spends resources.
3. Return to the operations terminal beside the entrance robot and press **E** or **2**. Review resource bars, base map and turn preview; choose an event response and advance the turn.
4. Open history to rewind to the start of a recorded turn. Change a decision, run it again and compare actual results. Previewing or inspecting history does not change the simulation.

For a seven-turn practice route, build a **Solar array at 01, Battery at 12, Greenhouse at 14 and Shelter at 25** before advancing T1. Keep growing at T2, take shelter if required at T4 and acknowledge the delivery delay at T5. The embedded historical case requires shelter; a different fetched dataset can change that condition. All resources and turns are game units.

| Input | Action |
| --- | --- |
| WASD / mouse / Space | Walk / look / jump |
| 1 near a site | Local Build / Remove menu; confirmation required |
| 2 or E near a site | Read-only details |
| 3 near a site | Inspect that site's 3D view |
| 4 while exploring | Read-only 5×5 base map, including current and planned facilities |
| E or 2 near the central terminal | Operations dashboard and turn controls |
| H in a menu or pause / Tab / Enter | Guide / move UI focus / activate a focused control |
| Esc | Close the panel to its previous context; pause when exploring |

**Building and removal are allowed only at the physical site.** The central dashboard and global map cannot construct remotely. Displayed slots are 01–25; internal IDs are 0–24. Inspection does not move the player or advance time. The robot is a landmark, not a separate quest character. Closing a panel resumes exploration without repeating the welcome instructions.

## Decisions and tradeoffs

Start with 12 construction tokens, 20 power, 60 oxygen and 36 food. The habitat is already built. Icons, names, bars and short actions carry the main instructions; numbers provide detail. The HUD groups information as **Power / Life support / Shelter readiness**. Shelter readiness reports shelter preparation, **not radiation dose**. Water is not separately simulated.

| Facility | Construction tokens | Benefit and cost |
| --- | --- | --- |
| Solar array | 3 | Generates 18 power on a sunny site, otherwise 12; unavailable during the T2–T3 fault |
| Battery | 2 | Adds 20 storage capacity; building one does not create power |
| Greenhouse | 3 | Uses 4 power per active turn; produces 18 food after three active turns |
| Shelter | 3 on a shielded site; otherwise 4 | Enables protection; sheltering pauses growth and can use protection power |
| Habitat | Already installed | Uses 6 power to produce 8 oxygen per turn; the crew consumes 6 oxygen and 6 food |

The fixed training schedule introduces a solar-array fault at T2–T3, a data-selected space-weather alert at T4 and a delivery delay at T5, with 12 food delivered at T7. Failure explains the stopping point and supports rewind. Completion shows seven turns of choices and resources. Closing the result does not restart the mission.

**Ask Earth for advice** costs 1 power when committed. The reply arrives after one turn, or two in the CME-based communications exercise. Requests can be cancelled before commit and give no free resources. Rewind restores requests and replies. New requests that cannot receive a reply by T7 are blocked. Delays represent compressed training time, not Moon/Earth signal travel time.

## Real NASA data and honest offline use

At startup the game requests **FLR, SEP and CME once each in parallel**, for the preceding 30 days, with an eight-second deadline and a 2 MiB response limit. A failed or unfinished product falls back to its historical response. Valid empty SEP/CME responses remain empty; no current event is invented. Empty/unusable FLR uses the labelled historical case. Beginning exploration or committing a turn freezes the dataset for that run and its rewinds.

| In-game source label | Meaning |
| --- | --- |
| Embedded historical data - not live | Original embedded records from 8–13 May 2024 |
| Fetched NASA records - not a live feed | One successful fetch; records retain their observation dates |
| Mixed fetched and historical records - not a live feed | Fetched and archived products are identified individually |

The guide separates **observation period, retrieval timestamp, product source, representative event and original link**. The archive was retrieved on **15 November 2026 UTC**; that does not make its 2024 observations current. Original bytes and provenance live in [research/nasa-2024-05](research/nasa-2024-05): **87 FLR, 14 SEP and 21 CME records**, with URLs, timestamps and SHA256 metadata.

| Required product | Record → educational game effect |
| --- | --- |
| DONKI FLR | Strongest flare selects protection power: A/B/C → 0, M → 2, X → 4; M/X require shelter |
| DONKI SEP | Observation-backed particle records add 2 protection power and require shelter; model-only entries are excluded from this observation rule |
| DONKI CME | Records select a two-turn advice-delay exercise; no record selects one turn |

The historical case includes an X5.8 flare and observed SEP, giving 6 protection power. Records in one interval are **not claimed to be one causally linked event**. The game does not estimate astronaut exposure or forecast real lunar outages. See [source provenance and mapping](docs/DATA_SOURCES.md).

## Challenge coverage and submission

All nine supplied source captures were reviewed, with **feed_page taking priority over docs_page**. The [image-by-image checklist](docs/SOURCE_REQUIREMENTS_CHECKLIST.md) distinguishes implemented requirements, scope limits and submission tasks. Desktop local play supports the working-prototype route; browser delivery remains a useful separate step.

- **English presentation:** [download PowerPoint](docs/presentation/Lunar-Base-Rewind-English.pptx) · [seven-slide overview and sources](docs/presentation/README.md). Seven slides includes the cover. The captured demo rule allows either up to seven slides **or** a video of up to 30 seconds with English subtitles.
- **English submission draft:** [all nine form fields](docs/SUBMISSION_EN.md), including data, attribution and AI use. The owner-edited `SUBMISSION.md` remains separate.
- **Before submission:** supply a publicly viewable demo URL and a publicly playable final-project URL, verify the team/form details and actually submit. A local file, private Page or GitHub source URL is not a public playable game. Public deployment and submission are not claimed here.
- **Manual acceptance remains open:** actual child usability, remaining Native/Web/iframe input cases and host-specific loading. See [issue #29](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/29) and [submission issue #7](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/7).

**Scope limits:** no separate water model, measured radiation dose, RadLab integration, OSDR research cards, Mars Trek terrain, mobile/touch controls, procedural event schedule or persistent save/resume. The world is a designed lunar training board. Restarting begins a new session; rewind works within the current session. These extensions are not described as complete.

## Sources, attribution and AI

NASA Goddard Space Flight Center's **Community Coordinated Modeling Center (CCMC)** provides the [DONKI catalogue](https://ccmc.gsfc.nasa.gov/tools/DONKI/) and [API reference](https://ccmc.gsfc.nasa.gov/DONKI/api/). The Canadian Space Agency's [food-production education resources](https://www.asc-csa.gc.ca/eng/youth-educators/toolkits/food-production/) inform project-written learning summaries about food and resupply. These summaries and rules are not official agency translations, endorsements or safety advice. The in-game guide includes source links and dates.

Blender model sources and exported game assets are included in this repository. The bundled [Noto Sans KR font and license](resources/fonts/README.md) also support English. See [data attribution](docs/DATA_SOURCES.md) and asset documentation for specific materials. **OpenAI Codex** assisted code implementation, English UI/documentation, checks and presentation preparation; the team remains responsible for verification and submission. No unverified AI tool is attributed to the team.

## Development and verification

Built with **Godot 4.7.2 / GDScript** and Blender-authored models. The current user-facing game, guide, README and presentation are English; earlier Korean planning records remain historical development records.

With Godot on your path, run from the project root:

```text
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://scripts/simulation/tests/core_contract.gd
godot --headless --path . --script res://scripts/simulation/tests/nasa_data.gd
godot --headless --path . --script res://scripts/simulation/tests/nasa_integration.gd
godot --headless --path . --script res://scripts/simulation/tests/operations_integration.gd
godot --headless --path . --script res://scripts/simulation/tests/map_navigation.gd
godot --headless --path . --script res://scripts/simulation/tests/english_ui.gd
```

Automated checks cover rules, provenance/fallback, frozen data, rewind, local-only construction, maps and panel returns. Render checks at 1280×800 and 960×600 are distinct from actual child acceptance. The Windows launcher has been exercised from an empty engine folder through download, checksum, import and game startup, plus installed-engine reuse and outside-project path rejection.

For Web, install matching Godot export templates and use the **Web** preset to export `build/web/index.html`. Serve that folder over HTTP(S), not `file://`. If Python is already installed, a local preview is `python -m http.server 8061 --bind 127.0.0.1 --directory build/web`. Templates and Python are developer tools, not local-play prerequisites. A Web build still needs hosting and browser acceptance before it is a submission link.

[Current source](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/tree/main) · [Issues](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues) · [Source review](docs/SOURCE_REQUIREMENTS_CHECKLIST.md) · [Historical rules](START_SPEC.md)
