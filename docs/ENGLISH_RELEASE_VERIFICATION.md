# English release verification

Scope: English game/UI/guide, existing seven-slide presentation, honest NASA snapshot labels and source-driven English documentation. Reviewed on 15 November 2026.

## Checked implementation

| Area | Result | Evidence |
| --- | --- | --- |
| Runtime English across actual play | 106 UI states, 24,424 displayed/tooltip strings (673 unique), no Hangul; 24,663 assertions passed | `english_ui.gd`, including help, map, site, history, rewind, success and failure routes |
| Core resource/simulation contract | 90 checks, zero failures | `core_contract.gd` |
| Real archive/provenance, fallback, empty results and freeze | 74 checks, zero failures | `nasa_data.gd` |
| Actual archive → seven turns → rewind | 36 checks, zero failures | `nasa_integration.gd` |
| Physical-only construction and dashboard authority | 62 checks, zero failures | `operations_integration.gd` |
| Advice cost/delivery, cancellation, failure and rewind | 23 checks, zero failures | `feed_integration.gd` |
| Source UI and English content | 68 checks, zero failures; OpenGL renders at 960×600 and 1280×800 | `nasa_ui.gd` |
| Dashboard, operations, feed UI, facility cards, learning, history, preview, guidance, gauges, resources and outcomes | All 12 relevant suites passed, 5,206 checks including the NASA UI suite | Scoped dashboard agent; translated expectations retain semantic behavior assertions |
| Site, field menus, map, mouse, avatar, view safety, navigation, world UI, input and play UI | All 10 suites passed, 2,491 checks | Scoped world agent; numerical simulation rules unchanged |
| Launcher | PowerShell syntax passed; existing clean-install/reuse/path-rejection evidence retained | Only the start-button instruction changed to match “Start mission” |
| Documentation | All local Markdown links resolved; all nine captured source pages independently reviewed | README, LOCAL_RUN, DATA_SOURCES, SOURCE_REQUIREMENTS_CHECKLIST, SUBMISSION_EN |
| Presentation | All seven slides rendered and visually reviewed; native content and notes contain no remaining Hangul | Existing saved Page updated in place; two English gameplay captures embedded |

The source review also scanned all 23 runtime GDScript files plus scene/resource/project/SVG text for residual Korean display content. Historical planning documents and original raw agency data are not translated or rewritten as current evidence. The owner's separate local `SUBMISSION.md` is preserved.

Tests with outdated expectations for the former pause popup and detached-arm angle were updated to verify the current intended behavior: closing panels resumes exploration without onboarding, and an actual jump changes the connected rig's pose. Runtime interaction and physics rules were not changed to satisfy those old assertions.

## Delivery boundaries

- The updated English presentation is the saved Spaces deck. The earlier local Korean `.pptx` is an old exported snapshot; download the current English `.pptx` from the viewer. It was not silently overwritten or represented as updated.
- A single fetched NASA catalogue snapshot is never called a live feed. Historical dates and original retrieval timestamps are retained. Game costs are not physical measurements.
- Existing Korean development records remain historical. Current player-facing content, primary instructions, source review and submission draft are English.
- Actual child comprehension, remaining manual Native/Web/iframe checks, public demo/playable links and owner submission are still pending in #29 and #7.
- Rendering and automated assertions do not claim a full manual seven-turn playthrough on every platform or actual judging submission.
