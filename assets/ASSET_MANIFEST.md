# HH-004 asset manifest

Owner: `jsjavsj`. Branch: `feature/HH-004-assets`. Contract commit: `410063037ba62da61f9119b4ba8b10cbdadc9ccb`.

First handoff for [HH-004](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/4). Both assets passed Blender GLB re-import. Godot import and integration await HH-001 core review.

| Asset | Blender source | GLB export | Width × depth × height | Triangles | Materials | Source bytes / GLB bytes |
| --- | --- | --- | --- | ---: | ---: | ---: |
| Tilted solar generator | [facility_generator.blend](source/facility_generator.blend) | [facility_generator.glb](models/facility_generator.glb) | 3.6 × 3.2 × 2.592986 m | 4,532 | 3 | 136,414 / 252,068 |
| 1 m reference cube | [scale_reference_1m.blend](source/scale_reference_1m.blend) | [scale_reference_1m.glb](models/scale_reference_1m.glb) | 1 × 1 × 1 m | 26 | 2 | 89,523 / 2,884 |

## Export settings

Exported 2026-11-14 with Blender 5.3.0 build `02f0899d78e3` and Khronos glTF Blender I/O v5.3.43. Sources use metric units and scale 1.0. Each GLB has one mesh node, one primitive per material, applied transforms, and an origin at the center of the footprint at ground level. Blender +Y marks the forward direction. glTF maps it to -Z with +Y up. The generator's orange inverter access panel and the cube's orange inlaid arrow mark the front.

Binary glTF 2.0 export uses selection only, +Y up, mesh normals, and metallic/roughness materials. The generator uses `alloy_shell`, `photovoltaic_blue`, and `service_amber`. The cube shares `alloy_shell` and `service_amber`. The files have no textures, animations, cameras, lights, or geometry compression. The empty `source/.gdignore` keeps the Blender sources out of Godot's automatic import.

## Provenance

Both assets were modeled for this project from original geometric primitives. They contain no third-party meshes, materials, textures, logos, or other licensed content. No third-party attribution is required.

## Validation and core handoff

- Blender background validation opened both sources and imported each GLB into a fresh scene. Bounds, pivot, scale, triangle count, and material names matched the source. The GLB header, indexed triangles, and axes were also checked directly.
- Generator glTF bounds in X/Y/Z metres are `(-1.8, 0, -1.6)` through `(1.8, 2.592986, 1.6)`. The model fits the 4 × 4 × 3 m envelope. Its geometry leaves 2.4 m width and 2.8 m depth between neighboring generators on a 6 m grid.
- Cube glTF bounds are `(-0.5, 0, -0.5)` through `(0.5, 1, 0.5)`. The inlaid arrow is on the plane `Z = -0.5` m.
- Core review is pending for Godot import, scale, facing, appearance, wrapper collision and player clearance, and web export. Model the remaining facilities and robot after the first Godot import is accepted.
