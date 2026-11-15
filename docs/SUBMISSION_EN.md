# English submission draft

Prepared from all supplied form captures on 15 November 2026. This is submission-ready text with clearly marked delivery gaps, not a claim that a public build or judging submission already exists. Preserve the owner's separate `SUBMISSION.md` draft. Before submitting, confirm the current official form and replace only verified links/details.

## 1. Project Name

**Lunar Base Rewind**

Team: **Mismatch**. Confirm the registered team name and participant details in the actual submission form.

## 2. High-Level Project Summary

Lunar Base Rewind is a first-person lunar base training game for children aged 7–12. Players walk to construction sites, choose facilities and keep power, oxygen and food available through seven turns. Real NASA DONKI flare, particle-event and coronal-mass-ejection records set space-weather and delayed-advice training conditions. Players can rewind a decision and compare outcomes, making the costs of engineering choices visible. Genuine historical records are embedded for offline play and clearly labelled as historical, not live. The game uses simplified educational rules rather than predicting real astronaut exposure or lunar outages.

## 3. Link to Project Demo

**Pending: add a publicly viewable link to the English seven-slide presentation.**

The existing deck has seven slides including the cover. Its saved workspace Page is linked in `docs/presentation/README.md`; workspace access is not assumed to be public judging access. Use the presentation viewer to download PowerPoint if needed, publish/share an accessible copy, then verify the final link without signing in. The captured submission requirement permits either up to seven slides or a video of up to 30 seconds with English subtitles. A video is not included in this delivery.

## 4. Link to Final Project

**Pending: add a publicly playable game URL after hosting and browser checks.**

Source repository: https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game

The repository provides local play through `RUN_GAME.cmd` with automatic Windows engine preparation. Source access and a local executable are not substituted for a public playable URL. A Web export requires public hosting and verification of loading, inputs, Esc/pointer capture and source labels in the deployed build.

## 5. Detailed Project Description

The mission is to keep a small lunar base working for seven turns. Players explore a 5×5 board in first person. Construction and removal happen only while standing near the relevant site. The central terminal is an operations dashboard; it displays the layout, resource bars, event responses, turn forecast and history. A global read-only map lets players see installed and planned facilities while exploring.

A solar array supplies power, a battery stores surplus, the habitat supports oxygen, a greenhouse produces food over time and a shelter supports the weather response. Construction tokens are limited. A battery adds capacity rather than creating energy, and growing food competes with other power demands. Fixed training events introduce a temporary array fault, a space-weather alert and delayed supplies. Asking Earth for advice costs power and produces a delayed response.

The defining learning action is rewind: restore a recorded turn's starting state, change a decision and compare both outcomes. The NASA dataset stays frozen so the comparison reflects the player's choices. Icons, short English actions, resource bars and contextual menus reduce reliance on long instructions. Keyboard/mouse controls and two desktop layout sizes have implementation checks; actual child usability remains to be tested.

The prototype uses Godot 4.7.2, GDScript and Blender-authored assets. It runs locally on Windows with a project-local automatic engine installer; Web export is supported as a separate deployment workflow. Resource units, event timing, shielding costs and reply delays are educational abstractions. Water, physical radiation dose, procedural events, mobile/touch control and persistent save/resume are outside the current scope.

## 6. NASA Data

We use NASA Goddard Space Flight Center's Community Coordinated Modeling Center (CCMC) DONKI catalogue: **FLR, SEP and CME**. These products affect the game rather than appearing only as citations. Flare class sets protection power, observation-backed SEP records add a particle-event protection requirement, and CME records select the longer delayed-advice exercise. Model-only SEP entries do not count as observed particle events for that rule.

At startup the game requests each product once in parallel for a recent 30-day window. Failed or incomplete products use curated original records from **8–13 May 2024**, collected on **15 November 2026 UTC**: 87 FLR, 14 SEP and 21 CME records. Original JSON and metadata preserve source URLs, observation dates, retrieval times and hashes. Valid empty recent SEP/CME results stay empty. The guide identifies historical, fetched or mixed provenance; all are explicitly **not a live feed**. Starting play freezes the records for that run and its rewinds.

This is a simplified training mapping, not a physical radiation-dose model or an operational forecast. Records within one interval are not asserted to form one causally linked event. Source: https://ccmc.gsfc.nasa.gov/tools/DONKI/ . Implementation and full provenance: `docs/DATA_SOURCES.md`.

## 7. Space Agency Partner & Other Data

Canadian Space Agency food-production education material informs project-written summaries about growing food and limited resupply. The in-game guide links to the source. Game growth cycles, yields and supply turns are our teaching rules, not CSA measurements. We do not claim CSA endorsement or official translation.

Source: https://www.asc-csa.gc.ca/eng/sciences/food-production/growing-healthy-food-in-space-and-remote-areas.asp

The repository includes model sources/exported assets and the Noto Sans KR font with its license. No NASA/CSA logos or article photographs/videos are included in the data bundle. RadLab, OSDR and Mars Trek are not integrated and are not claimed as sources of game results. The team must verify the complete third-party/code/asset attribution list before the final form is submitted.

## 8. Use of Artificial Intelligence

**OpenAI Codex** assisted implementation, bug fixes, English interface and documentation, automated checks and presentation preparation. The team specifies the intended behavior, reviews the output and remains responsible for the final project, attribution and submission. AI-authored explanations do not replace the original NASA records: the archived API responses and provenance are retained. No other AI tool is named here without evidence of actual use; add any additional tools only after confirming them with the team.

## 9. Verification

Before selecting the form's final verification and submission controls, the owner must confirm:

- The team and participants are registered and eligible, including the permitted team size.
- The public demo and playable links work without account access and point to the intended final revision.
- The work, third-party material, source attribution and actual AI-tool disclosure are accurately represented.
- The final text matches the current official form and event terms.
- The owner has actually submitted for judging and recorded confirmation.

Implementation checks and a prepared draft do not constitute these owner attestations. Track outstanding submission work in issue #7 and manual acceptance in issue #29.
