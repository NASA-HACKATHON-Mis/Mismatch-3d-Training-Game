# NASA and partner data: provenance and game use

Current implementation audit: 15 November 2026. This is the authoritative current source description; earlier FLR-only development notes have been superseded.

## Genuine embedded records

The game ships original NASA CCMC DONKI responses for **8–13 May 2024** in `research/nasa-2024-05/`. They are historical catalogue records, not current conditions. The API may include observations and model products; normalization preserves that distinction. Model-only SEP entries do not trigger the observation-backed SEP rule.

| Product | Records | Retrieved (UTC) | SHA256 of original response |
| --- | --- | --- | --- |
| FLR | 87 | 2026-11-15T10:48:21Z | `429fa9cb2c1d3457beb6c3de5f15fe34315de114c450d5fb6b74a0e906e8ea25` |
| SEP | 14 | 2026-11-15T10:48:20Z | `30c225b9a0fabee1ece4e0b56d0ccdbfe54f0b85e2a58815a885517db1fe4cfe` |
| CME | 21 | 2026-11-15T10:48:20Z | `2802ecb3dc15da06e6f36a23e8c717b3971dbafe879738a8a0a83d212104d1c8` |

Each accompanying `.metadata.json` stores the exact request URL, observation window, retrieval timestamp, HTTP status, item count and hash. Original bytes are not rewritten to look recent. A new game launch does not replace the archive's collection date with its startup time.

## Startup, fallback and freeze

`scripts/data/space_weather.gd` makes at most one startup request for each of FLR, SEP and CME, in parallel, using a recent 30-day window. Each response is limited to 2 MiB and the shared deadline is eight seconds. The current official API host is `ccmc.gsfc.nasa.gov`.

Unavailable, malformed, timed-out or unfinished products retain their genuine archive. Valid empty SEP/CME arrays mean no matching catalogue record and stay empty. An empty FLR case uses the historical example. No API key is embedded. `LUNAR_OFFLINE=1`, including the launcher's `-Offline` mode, skips requests entirely.

The first exploration or turn commit freezes the complete record/provenance context. Late responses cannot change the run. Rewind restores the same context so a result comparison changes player decisions rather than silently changing the source dataset.

| Public label | Interpretation |
| --- | --- |
| Embedded historical data - not live | Historical records, including during offline/failure fallback |
| Fetched NASA records - not a live feed | A single successful catalogue snapshot, not continuous monitoring |
| Mixed fetched and historical records - not a live feed | Per-product provenance must be consulted |

The guide separates observation dates, retrieval dates and source links. `mode="live"` remains an internal compatibility value meaning a successful HTTP fetch. It is **not** a public live-feed claim. The context explicitly carries `is_live_feed=false`, a public `source_label`, and `snapshot_frozen`.

## Educational mapping, version 0.3

`scripts/simulation/weather_rules.gd` derives a deterministic training profile from the frozen records. Representative IDs and original source URLs travel with the profile and turn history.

| Input | Training rule |
| --- | --- |
| Strongest FLR class A/B/C, M, X | Protection power 0, 2, 4 respectively; M/X also require shelter |
| Observation-backed SEP present | Add 2 protection power; shelter is required |
| CME catalogue records present | Advice reply after two turns; otherwise one turn |

The embedded X5.8/SEP case yields 6 protection power. Shelter response pauses greenhouse growth. An Earth-advice request costs 1 power on commit. These values are game units, not radiation measurements, measured outages or propagation times. Records in one date window are not asserted to be a single causally linked event. No real astronaut safety calculation or physical lunar forecast is produced.

The planned events remain a fixed teaching schedule: T2–T3 array fault, T4 weather alert, T5 supply delay, T7 delivery. NASA records select conditions within the exercise; they do not claim a real power fault occurred on the Moon.

## NASA and CSA attribution

We acknowledge NASA Goddard Space Flight Center's Community Coordinated Modeling Center (CCMC) for DONKI catalogue records used in this educational prototype.

- [DONKI overview and usage context](https://ccmc.gsfc.nasa.gov/tools/DONKI/)
- [API reference](https://ccmc.gsfc.nasa.gov/DONKI/api/) and [OpenAPI](https://ccmc.gsfc.nasa.gov/DONKI/api/openapi/)
- [CCMC publications policy](https://ccmc.gsfc.nasa.gov/publication-policy/)
- [CSA food-production toolkit](https://www.asc-csa.gc.ca/eng/youth-educators/toolkits/food-production/)
- [CSA: growing healthy food in space and remote areas](https://www.asc-csa.gc.ca/eng/sciences/food-production/growing-healthy-food-in-space-and-remote-areas.asp)
- [CSA terms](https://www.asc-csa.gc.ca/eng/terms.asp)

CSA material informs original, short learning summaries about food self-sufficiency and difficult resupply. The game's growth cycle, harvest size and delivery turn are not measurements taken from that article. The in-game summaries are written by this project and are not official CSA translations. No NASA/CSA endorsement is implied. Agency logos, article photographs and videos are not included in this data bundle.

RadLab, OSDR and Mars Trek appear in the supplied challenge resources but are not integrated. The project does not claim measured radiation-dose comparisons, space-biology experiments or real terrain data. The supplied feed recommends these at different priority levels; it requires DONKI FLR/SEP/CME, which are integrated.

## Retained earlier example

`research/donki-sample.json` and its metadata preserve an earlier genuine FLR-only learning example: `2016-01-01T23:10:00-FLR-001`, M2.3. It was retrieved on 14 November 2026 and is historical, not the current three-product training fallback. Its hash is `a2ad2a855f30ab79daef95cdf819f02803be2a2fb2f219c32f3ef374db3bf6b0` as recorded in metadata; consult the metadata for the authoritative exact bytes/hash. Old integration fixtures may deliberately use this example to exercise the no-CME one-turn path.

## Evidence and limits

`nasa_data.gd` verifies original hashes/counts, timestamps, empty results, failure fallback, parallel request count, immutable context and non-live labels. `nasa_integration.gd` exercises the real game through profile selection, requests, turns and rewind. Tests of a successful fetch prove retrieval, not that the returned observations occurred today. Automated tests do not establish child comprehension or every browser's CORS/hosting behavior.
