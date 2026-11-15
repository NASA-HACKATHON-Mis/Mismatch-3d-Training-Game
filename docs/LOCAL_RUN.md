# Local play on Windows

The automatic launcher supports Windows 10/11 64-bit, keyboard and mouse, and OpenGL 3.3 graphics. Extract the complete repository ZIP, then double-click `RUN_GAME.cmd`. Do not run inside the ZIP.

Windows PowerShell 5.1 reuses standard Godot 4.7.2 from `.tools/godot-4.7.2` or downloads the official pinned package, checks SHA256 and installs it inside the project. It imports assets before opening the game. No administrator access, PATH changes, Git, Python, Blender, .NET Godot or export templates are required to play.

The first download requires internet and is about 86 MB. Once installed, the game works offline with genuine historical NASA records labelled as historical and not live. `-Offline` skips NASA requests; it does not supply an engine that has never been installed.

## Commands

```powershell
.\RUN_GAME.cmd
.\RUN_GAME.cmd -Offline
.\RUN_GAME.cmd -NoLaunch
.\RUN_GAME.cmd -SmokeTest
.\RUN_GAME.cmd -NoLaunch -ToolsDirectory .tmp\clean-engine
```

- `-NoLaunch`: engine preparation, version check and asset import without a game window.
- `-SmokeTest`: preparation followed by a short headless game run with embedded records.
- `-ToolsDirectory`: alternate engine/download folder for isolated checks; must stay inside the project.
- Each launch imports updated assets and scripts, while reusing an existing engine.

APPDATA changes only for the child Godot process, to a project-local directory. The `_sc_` marker also keeps editor data local. Logs are `logs/launcher-<timestamp>.log`, `logs/launcher-import.log` and `logs/game-<timestamp>.log`; they are not tracked. Keep the console open while playing; it ends when the game closes.

## Troubleshooting

| Problem | Action |
| --- | --- |
| Download failed | Check GitHub access and rerun. A checksum mismatch stops installation. |
| Wrong engine version | Preserve the project-local engine folder named in the error under a different name, then rerun. |
| Import failed | Read `logs/launcher-import.log`; confirm the entire ZIP was extracted. |
| Window hidden | Alt+Tab → Lunar Base Rewind. |
| OpenGL startup error | Check graphics driver and GPU support. |
| Pointer capture unavailable | Hold left mouse and drag to look. |
| Organization blocks PowerShell | Use an administrator-approved method. The process-local ExecutionPolicy setting does not change system policy. |

On macOS/Linux, install standard Godot 4.7.2 manually, open `project.godot`, and press F5. Automatic installation and OS-specific play checks are not included for those platforms.

## Pinned engine

- [Official Godot 4.7.2 release](https://github.com/godotengine/godot/releases/tag/4.7.2-stable)
- Asset: `Godot_v4.7.2-stable_win64.exe.zip`
- Size: 86,013,866 bytes
- SHA256: `731980f9608d61333e5baf54a2ef17210acc7a538446c0cb9969f002aca1e953`
- Digest checked against the official release asset on 15 November 2026.

The launcher pins this exact version, file and hash rather than running an arbitrary latest release.

## Verified scope

Windows PowerShell 5.1 was used in a path with Korean characters and spaces. A clean project-local folder completed a real download, hash check, extraction, version check, full import and 120-frame headless game run. A subsequent `-NoLaunch -Offline` reused the engine without changing the ZIP timestamp. An outside-project destination was rejected. These checks do not replace child usability or complete manual playthroughs on every platform.
