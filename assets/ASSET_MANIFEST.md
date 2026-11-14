# Asset manifest - HH-004 preparation

Owner: jsjavsj
Branch: feature/HH-004-assets
Contract commit: 410063037ba62da61f9119b4ba8b10cbdadc9ccb

Status: PREPARATION ONLY / BLOCKED. No models created, exported, or imported. Repo-local Git author identity is configured from user-provided values. Authenticated GitHub plugin account jsjavsj and supplied identity were verified. Shared implementation readiness and the exclusive task claim must be confirmed before production. Other-PC readiness is not established by this record.

## Local environment evidence

The coordinating agent ran version and factory-startup background checks on this PC: Blender 5.3.0, build hash 02f0899d78e3, executable `C:\Program Files\Blender Foundation\Blender 5.3\blender.exe`. Background startup exited 0 and the glTF exporter was available. This is not GLB export or Godot import validation.

## Planned first handoff

Dimensions are design targets, not measured results.

| Asset | Planned source | Planned export | Target width x depth x height | Maximum | Status |
| --- | --- | --- | --- | --- | --- |
| facility_generator | assets/source/facility_generator.blend | assets/models/facility_generator.glb | 3.6 x 3.2 x 2.6 m | 4 x 4 x 3 m | Not created |
| scale_reference_1m | assets/source/scale_reference_1m.blend | assets/models/scale_reference_1m.glb | 1 x 1 x 1 m | 1 x 1 x 1 m | Not created; separate cube |

Planned setup: Metric, unit scale 1.0, one Blender unit per metre; bottom-centre origins and ground at Blender Z=0; apply rotation/scale before export. Verify Godot front -Z and up +Y after GLB axis conversion. Use ASCII snake_case names and simple metallic/roughness materials. Exclude unrelated objects, cameras, and lights from export. Core owns collision wrappers.

Planned provenance: original procedural assets created for this project; no external assets selected. This is an intention, not completed provenance/licence verification.

Generator targets: 2,000-5,000 triangles, 1-3 materials. Prefer each GLB below 5 MB and source below 20 MB; every file must be below 100 MB. Texture use/sizes undecided; target 512-1024 px if needed.

## Evidence pending creation

| Field | facility_generator | scale_reference_1m |
| --- | --- | --- |
| Export date / Blender version used | Not exported | Not exported |
| Measured dimensions / origin / facing | Not measured | Not measured |
| Triangle / material count | Not measured | Not measured |
| Texture dimensions | Not created | Not created |
| Source / GLB byte sizes | Not created | Not created |
| Final provenance / licence | Pending creation | Pending creation |
| Godot import / scale / axes / materials | Not tested | Not tested |
| Core acceptance | Pending | Pending |

## Checklist

- [x] Configure user-provided repo-local Git identity and verify the authenticated GitHub plugin account.
- [ ] Confirm shared readiness gates.
- [ ] Confirm HH-004 ready status and exclusive claim before production.
- [ ] Create generator and separate cube; record actual measurements and provenance.
- [ ] Export GLB; record exact exporter settings, date, and file sizes.
- [ ] Core validates import, axes, scale, materials, and placement clearance.
- [ ] Record accepted evidence and eventual feature commit before expanding assets.
