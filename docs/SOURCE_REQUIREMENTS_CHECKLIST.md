# Captured requirements: image-by-image review

Reviewed 15 November 2026 against the actual game and all nine supplied screenshots in the owner's `문서` folder. **feed_page has priority over docs_page.** These captures are source requirements, not evidence that submission or user acceptance already happened. This checklist supersedes the older pre-NASA implementation gap report.

Status: **Implemented** = code/document evidence exists; **Partial** = a narrower scope is explicit; **Pending** = actual delivery or acceptance remains; **Optional** = suggested extension not claimed complete.

| Capture | Requirement / emphasis | Status and evidence |
| --- | --- | --- |
| feed_page_01 | Playable lunar/Mars base for ages 7–12; life support, power, food, shielding and communications; meaningful tradeoffs | **Implemented:** first-person lunar board, five facility types, limited budget and resource bars; local construction, seven turns, delayed advice and rewind. See README and `scripts/simulation/`. |
| feed_page_01 | Simple gauges and child-friendly causal feedback; learn and retry | **Implemented / acceptance pending:** Power, Life support and Shelter readiness; icons plus text/bars; preview and actual history comparison. Child comprehension has not been validated. |
| feed_page_01 | Oxygen/water concept, varied/replayable events | **Partial:** oxygen and food are simulated, water is not. Rewind compares decisions under a frozen dataset; event timing is fixed, not procedurally randomized. |
| feed_page_02 | Nine English project-form fields | **Prepared:** `docs/SUBMISSION_EN.md` covers all nine. Public URLs, team verification and actual submission remain pending. |
| feed_page_02 | Demo: ≤30-second English-subtitled video OR ≤7 slides including cover; separate final-project link | **Partial:** seven-slide English deck exists; public sharing URL and playable hosting URL still required. A video is an alternative, not an additional mandatory artifact in the capture. |
| feed_page_03 | Required DONKI FLR, SEP and CME materially affect the game | **Implemented:** flare/observed-particle protection profile and CME-based reply delay; original three-product offline archive and one-shot online requests. See `docs/DATA_SOURCES.md`. |
| feed_page_03 | RadLab strongly recommended; CSA food explanations; OSDR cards and Mars Trek options | **Implemented:** CSA summaries with links. **Optional/unimplemented:** RadLab, OSDR, Mars Trek. No dose/biology/terrain results are claimed. |
| feed_page_03 | Communications latency teaches planning | **Implemented as a game abstraction:** advice costs power and arrives after 1/2 turns. These are not physical seconds/minutes of Moon/Mars signal travel. |
| feed_page_04 | Clearly visible source, observation date, retrieval date and online/archive status | **Implemented:** guide and dashboard source labels, per-product metadata, explicit not-live language and frozen-run status. |
| feed_page_04 | Influence, Creativity, Validity, Relevance and Presentation; team/eligibility/form requirements | **Prepared:** submission draft maps the product to judging themes. **Pending:** owner verifies participant registration, team size/eligibility, authorship, terms and submission status. No award/nomination is claimed. |
| docs_page_01 | Build a Junior Astronaut Mission Trainer; working prototype for children | **Implemented:** locally runnable Godot training game; English presentation and instructions. |
| docs_page_02 | Engineering tradeoffs, fun/science balance, limited systems and real data | **Implemented:** facility costs, power/food decisions, alert response, delayed advice and replay comparison. Educational numbers are distinguished from observations. |
| docs_page_03 | Ages 7–12, a working prototype, real or historical NASA sources | **Implemented / acceptance pending:** actual archived records and game mechanics exist; child playtesting remains open. Desktop play is supported, not falsely described as browser-only. |
| docs_page_04 | Plain language, accessibility and simple resources; browser convenience | **Implemented / partial:** English labels, icon+name+bar combinations, keyboard/mouse and responsive scroll layouts. Touch/mobile and complete Web/iframe acceptance remain pending. |
| docs_page_04 | Curated real embedded data is an honest alternative when APIs are unavailable; static data must not masquerade as live | **Implemented and strengthened:** archive dates 8–13 May 2024; collection 15 Nov 2026; public historical/fetched/mixed not-live labels; valid empty records preserved; immutable snapshot. |
| docs_page_05 | NASA API, DONKI, OSDR, RadLab and Mars Trek resource list; appropriate attribution | **Implemented:** DONKI/API and agency attribution. Resource listing is not interpreted as a demand to claim all optional datasets. |

## Submission readiness checklist

- [x] Working local prototype and automatic Windows engine setup.
- [x] English game, guide, README and seven-slide presentation.
- [x] Required DONKI products connected to meaningful choices, with genuine embedded originals.
- [x] Observation date and retrieval date separated; no historical data advertised as live.
- [x] English nine-field draft with NASA, partner/source and actual AI-tool disclosure.
- [ ] Publicly viewable demo URL tested without signing in.
- [ ] Publicly playable final-project URL and deployed-build browser/input check.
- [ ] Remaining user acceptance, including ages 7–12, recorded in issue #29.
- [ ] Owner confirms registered team/eligibility, originality, all third-party attribution and current form details.
- [ ] Owner performs and confirms actual submission for judging.

## Related design/usability capture

The additional design/usability request document supports short action labels, clear gauges, contextual local controls, first-person body/collisions, a visible light source and predictable Esc behavior. Those implementation fixes are present; they are not a substitute for actual user acceptance. Persistent save/resume and public Web delivery remain declared limitations. No deferred feature is marked complete merely because it appears in a design document.

## Reviewer handoff

Implementation evidence: `scripts/data/space_weather.gd`, `scripts/simulation/weather_rules.gd`, `scripts/world/mission.gd`, `scripts/ui/terminal.gd`, `scripts/ui/help.gd`, `scripts/ui/grid_view.gd`, original archive metadata, and the current integration tests. Submission evidence: `docs/SUBMISSION_EN.md` and `docs/presentation/README.md`. Earlier Korean planning/audit records are retained as history; this English checklist describes the current product.
