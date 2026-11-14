# HH-004 asset manifest

Owner: `jsjavsj`. Branch: `feature/HH-004-assets`. Contract commit: `410063037ba62da61f9119b4ba8b10cbdadc9ccb`.

First handoff for [HH-004](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/4). Both assets passed Blender GLB re-import and isolated Godot import and instantiation on `jsjavsj`'s PC. HH-001 accepted the first generator in [core commit 797e990](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/commit/797e99008635bcad6e3d6802b7e9789c36a88d99).

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
- Core verified the first generator slot placement, visual materials and facing, separate wrapper collision, and 2.4 m player clearance. The refreshed Web build loaded in a browser. Full browser play remains pending.

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

## Expanded handoff

The five remaining models were exported on 2026-11-14 with the same Blender 5.3.0 build and glTF 2.0 settings. Each editable source uses separate snake_case mesh components with applied transforms and a shared origin at the bottom center of the footprint. Each GLB has one mesh and three named PBR surfaces. The four facility footprints leave at least 2.2 m of geometric separation on the 6 m grid. The guide robot is a static model.

| Asset | Blender source | GLB export | Width × depth × height | Triangles | Materials | Source bytes / GLB bytes |
| --- | --- | --- | --- | ---: | --- | ---: |
| Battery bank | [facility_battery.blend](source/facility_battery.blend) | [facility_battery.glb](models/facility_battery.glb) | 3.3 × 2.68 × 2.253 m | 3,284 | `alloy_shell`, `equipment_blue`, `service_amber` | 126,751 / 189,660 |
| Habitat capsule | [facility_habitat.blend](source/facility_habitat.blend) | [facility_habitat.glb](models/facility_habitat.glb) | 3.26 × 3.66 × 3.1165 m | 4,704 | `alloy_shell`, `equipment_blue`, `service_amber` | 139,264 / 250,260 |
| Greenhouse | [facility_greenhouse.blend](source/facility_greenhouse.blend) | [facility_greenhouse.glb](models/facility_greenhouse.glb) | 3.44 × 3.75 × 2.9825 m | 2,924 | `alloy_shell`, `glazing_blue`, `leaf_green` | 155,946 / 164,528 |
| Passive regolith shelter | [facility_shelter.blend](source/facility_shelter.blend) | [facility_shelter.glb](models/facility_shelter.glb) | 3.8 × 3.79 × 2.795 m | 3,644 | `alloy_shell`, `regolith_shielding`, `service_amber` | 137,802 / 199,148 |
| Guide robot | [guide_robot.blend](source/guide_robot.blend) | [guide_robot.glb](models/guide_robot.glb) | 0.755091 × 0.5245 × 1.462 m | 4,152 | `alloy_shell`, `equipment_blue`, `service_amber` | 140,550 / 221,696 |

All five models are original to the project and use geometry and material colors. They have no third-party assets or textures. The battery charge lights, habitat porthole, greenhouse door handle, shelter door grips, and robot eyes face Blender +Y and Godot -Z. Together their sources and GLBs total 1,725,605 bytes.

Blender re-import matched the source bounds, applied transforms, materials, and triangle counts. Independent mesh checks matched the transformed source and GLB vertex positions and found zero degenerate triangles or winding mismatches. Fresh Windows Godot 4.7.2 Compatibility editor import and runtime validation both exited 0 with no warnings or errors. The five imported `PackedScene` instances retained one identity-transformed mesh, bottom-centered pivots at Y = 0, +Y up and -Z front, and the same named materials and triangle counts. Godot preserved the greenhouse glazing alpha of 0.26 with an alpha depth pre-pass.

Core handoff includes in-game appearance, slot placement, collision wrappers, player clearance, and Web export and play checks for the five expanded assets.

| Asset | Source SHA-256 | GLB SHA-256 |
| --- | --- | --- |
| `facility_battery` | `b6e2236d236a04022c256ae9837953926ea9b604eb0fa2565dfacc707517a258` | `ed2258979ba22a79e2a75da04006cccb5786a06f319c9f9f0664a0e04a845bd2` |
| `facility_habitat` | `625dc49af4264e6fd1687aea52e7f690817388c23954ec2949640a6f2629476d` | `4154da2673a0a103c0271f69d30891bcde5a68db429f2b2148125f3c4c055cdb` |
| `facility_greenhouse` | `68d60eb6c57177b8fefe4bb29865621f8986a4b5ce6ac53e27c0a71c63b85c5e` | `11b0ee8568c04067dac058fa7c73be14cd21dea76352a50f1d0b376ac593dc06` |
| `facility_shelter` | `bad027bc143ce8e1acca189aaf48aa8fa064b708e2325210a0b228899c488db1` | `e3540c8bf4c2a811ad365162a05c8193a1850c83e7f2bb1a5b8678bd7dc2322e` |
| `guide_robot` | `717d00885f10c7304db716b5615676908903a7ee9b462f5b6f4344132d7ec132` | `0331ccca98f52ff08deea8e6276362c750e58f0d7ff97522bd97b6d90902a845` |
