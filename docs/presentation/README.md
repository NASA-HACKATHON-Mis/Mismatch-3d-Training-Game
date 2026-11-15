# Lunar Base Rewind presentation

Updated 15 November 2026. Team Mismatch's English presentation contains seven slides including the cover, with English speaker notes for a 3–5 minute talk. All visible text, native tables and gameplay screenshots are English.

## Download or open the presentation

- **[Download the English PowerPoint file](Lunar-Base-Rewind-English.pptx)** — seven editable slides, English speaker notes and embedded gameplay images. On GitHub, use **View raw** or **Download raw file**.

- [Saved English presentation](https://chatgpt.com/space/page_9e457a7f503c8191b880e1686caf1818)
- Title: **Lunar Base Rewind · Mismatch**
- Page ID: `page_9e457a7f503c8191b880e1686caf1818`
- The GitHub PowerPoint is an export of the saved English deck, sequence 9. The live editor link requires account access; GitHub provides the downloadable snapshot.

Use the English file linked above. The earlier Korean export in the owner's documents folder is retained as an older local copy. Later edits to the live deck require a new GitHub export.

## Seven-slide outline

| Slide | Title | Main point |
| --- | --- | --- |
| 1 | Lunar Base Rewind | Build, rewind and learn from choices in a first-person game |
| 2 | Learn how each choice shapes a lunar base | Designed for ages 7–12: build, operate for seven turns, rewind and compare |
| 3 | Build on site. Check the whole base on the map. | Local-only building/removal; press 4 anywhere for the read-only 5×5 base map |
| 4 | Power, oxygen and food depend on each other | Facility costs and effects, a 12-token budget, and the power/food trade-off |
| 5 | NASA records change alerts and choice costs | Actual archived FLR/SEP/CME observations inform explicitly educational rules |
| 6 | Replay the same turn to see what changed | Deterministic T3 comparison: power/oxygen/food 0/64/24 versus 8/66/18 |
| 7 | A playable local training prototype | Automatic local launch, controls, implemented behavior and remaining usability validation |

## NASA data and claim boundaries

Slide 5 visibly states: **Embedded historical observations (May 2024), not a live feed.** The source column identifies NASA DONKI; the mapped effects are labeled **Educational rule**.

The archived source files cover 8–13 May 2024 and were retrieved on 15 November 2026: 87 FLR, 14 SEP and 21 CME records. The prototype embeds selected actual observations for offline use. An optional API request runs once per product at startup; the mission then freezes the resulting event context. Observation date, query interval and retrieval time are separate. An API response is not a continuously updating live feed.

The speaker notes distinguish **Embedded historical data - not live**, **Fetched NASA records - not a live feed**, and **Mixed fetched and historical records - not a live feed**. Unavailable API data falls back to the embedded archive with its historical label.

| Input | Educational mapping |
| --- | --- |
| FLR class A/B/C, M, X | Additional protection power 0, 2, 4; M and X require shelter |
| SEP event with direct observations | Shelter required and 2 additional protection power |
| CME presence | Advice reply after two turns; one turn without a recorded CME |

These mappings are not predictions of lunar radiation dose, signal latency or operational space weather. The rules remain at version 0.3. RadLab and OSDR are contextual references where documented, not invented numerical feeds.

The example uses separate records from the same archive period: X5.8 FLR `2024-05-11T01:10:00-FLR-001`, SEP `2024-05-13T18:07:00-SEP-002`, and CME `2024-05-13T09:12:00-CME-001`. The presentation does not assert that they form one causal event.

## Sources and credits

- Planning brief: workspace `feed_page_01.png` through `feed_page_04.png`, prioritized over `docs_page_01.png` through `docs_page_05.png`. The supplied feed page 02 allows a demo of up to seven slides including the cover, or a video of up to 30 seconds with English subtitles. This deck follows the seven-slide option; the screenshots are the supplied planning brief, not a claim that current official event rules were independently reverified.
- Implementation: [NASA gameplay specification](../NASA_GAMEPLAY_FIX.md), [field interaction specification](../URGENT_FIELD_INTERACTION.md), and [game rules](../../START_SPEC.md).
- Actual NASA source: [CCMC DONKI](https://ccmc.gsfc.nasa.gov/tools/DONKI/) and repository [archived source files and metadata](../../research/nasa-2024-05/).
- Rewind comparison: [rewind UI regression fixture](../../scripts/simulation/tests/rewind_ui.gd), a layout without a battery or advice request; compare T2 continued growth against conservation at the same T3. The change is +8 power, +2 oxygen and -6 food, in game units.
- CSA food reference: [Growing healthy food in space and remote areas](https://www.asc-csa.gc.ca/eng/sciences/food-production/growing-healthy-food-in-space-and-remote-areas.asp).
- Team-created facility and robot assets: [asset manifest](../../assets/ASSET_MANIFEST.md). Noto Sans KR font: [SIL Open Font License](../../resources/fonts/OFL.txt). The deck does not imply NASA or CSA endorsement.
- AI disclosure: Codex assisted planning, code, documentation and checks. No unverified model-creation tool is credited.

## Screenshot provenance and validation

- Cover: actual Godot first-person scene from avatar commit `4ca6b27`, `logs/fix-player/1280x800-front.png`; no Korean UI is present.
- English on-site controls: `fix-english-world/.tmp/field-install.png`, 1280×800.
- English map: `fix-english-world/logs/map/grid-1280x800.png`, 1280×800. The screen explicitly marks planned changes; it is a read-only overview.
- The English gameplay captures use world commit `aa4553f` and the shared English UI changes in `87745d7` (cherry-picked as `b9242af` in the capture worktree). Both images are embedded in the saved deck.
- The automatic launcher description carries forward the installation/launch verification for commit `044de24`.
- The same seven slide IDs, order, native tables, theme and 1280×720 layout were preserved. All seven slides were rendered to PNG and visually checked; slides 4 and 5 were re-rendered after final wording adjustments. A recursive audit of all slide content and speaker notes found no remaining Hangul. The new screenshots were also visually checked for English text and clipping.
- This validates the saved presentation's renderer output. Desktop PowerPoint, public judging access, actual child usability and continuous browser/iframe controls are separate checks. Creating this deck does not complete public submission.

## GitHub file validation

The exported PPTX retains seven slides, seven English speaker-note pages, three non-empty embedded game images, and native tables on slides 4–6. File-package integrity, layout/heading geometry and first-party re-import checks passed. The slide count, English text and historical-not-live disclosure were checked in the exported package as well. All seven slides were re-imported, rendered and visually checked after export. This does not claim desktop PowerPoint or actual judging submission has been tested.
