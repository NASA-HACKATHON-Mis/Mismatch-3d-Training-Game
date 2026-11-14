# HH-004 asset manifest

Owner: `jsjavsj`. Branch: `feature/HH-004-assets`. Contract commit: `410063037ba62da61f9119b4ba8b10cbdadc9ccb`.

First handoff for [HH-004](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/4). Both assets passed Blender GLB re-import and isolated Godot import and instantiation on `jsjavsj`'s PC. HH-001 game integration awaits core review.

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
- Core review is pending for in-game appearance, slot placement, wrapper collision, player clearance, and web export. Model the remaining facilities and robot after core accepts the first import.

## Godot import verification — 2026-11-14

The Windows x86_64 standard portable console executable `Godot_v4.7.2-stable_win64_console.exe` reported `4.7.2.stable.official.ed1daf0bf`. The supplied ZIP matched the recorded release SHA-256 `731980f9608d61333e5baf54a2ef17210acc7a538446c0cb9969f002aca1e953`.

The two GLBs from commit `5e3d0f4fa8804e8c8f8567c2fffe9deadb97a441` were copied into an isolated Compatibility project at `.tmp/hh004-godot-validation`. The initial import created both scene resources but reported write failures in the default roaming `user://` directory. The clean rerun used a process-local `APPDATA` inside the test directory and fresh import caches.

```powershell
& $exe --version
& $exe --headless --language en --editor --path $testDir --import
& $exe --headless --language en --path $testDir --script res://validate.gd
```

The clean editor import and runtime check both exited 0, with no errors or warnings in `import.log` or `runtime.log`. The runtime instantiated both imported `PackedScene` resources and confirmed one `ArrayMesh` instance per scene, identity root and mesh transforms, a bottom-centered pivot at Y = 0, +Y-up geometry, and -Z-facing front markers. Imported mesh bounds matched the glTF bounds above. The generator retained 4,532 triangles and three named `StandardMaterial3D` surfaces. The cube retained 26 triangles and two named surfaces, with its front arrow at Z = −0.5 m.

| Tested GLB | SHA-256 |
| --- | --- |
| `facility_generator.glb` | `1ddc9a79c25254ac6dde48b2acf46e116cc7540d033c0bdda3220923b97126c1` |
| `scale_reference_1m.glb` | `9d4180cb0c0046862f86a99ced5c0bc8b84697d19ed37274b8df70c99f83b5cd` |
