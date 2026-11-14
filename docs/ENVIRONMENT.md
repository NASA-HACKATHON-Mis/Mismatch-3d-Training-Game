# 현재 PC 환경 준비 결과

확인일 2026-11-14 Asia/Seoul. 담당 dyhan0528 / Worker project_setup. 이 기록은 **본인 PC만** 대상으로 한다. jsjavsj PC는 사용자가 “하고 있어”라고 답한 준비 중 상태이며 완료 증거는 아직 없다.

## 현재 결론

본인 PC의 로컬 준비는 완료했다. Godot 일반판·동일 템플릿·기존 Git 신원·독립 루트·계정/권한·브라우저 버전을 실제 확인했다. [자료 준비](DATA_SOURCES.md)도 별도 Worker와 Verifier가 완료했다. 전체 IMPLEMENTATION_READY는 아직 false다. 팀원 PC 증거와 이슈 ready/claim·시작 패킷 대조가 남았다. 게임 코드·모델·project.godot·Web 출력/GUI 입력 검증은 아직 없으며 환경 검사를 제품 검사로 표시하지 않는다.

## 실제 관측

| 항목 | 관측 결과 |
| --- | --- |
| 루트 | C:\Users\USER\Desktop\나사 첼린지\Junior-Astronaut-Mission-Trainer — 독립 Git 루트 |
| 재개 브랜치/HEAD | docs/mission-spec-v2 / 1fddcc5342431cbcb5aa72a7a616ed7836bad379, fetch 후 원격 일치 |
| 규칙 계약 | 410063037ba62da61f9119b4ba8b10cbdadc9ccb 포함 확인 |
| OS | Windows build 26200.9711, DisplayVersion25H2; registry ProductName은 Windows 10 Home으로 반환(이름을 추정 보정하지 않음) |
| PowerShell 점검 프로세스 | 5.1.26100.9711 |
| Git / gh | 2.56.0.windows.4 / 2.103.3 |
| GitHub | gh api user=dyhan0528, repo viewerPermission=ADMIN |
| 개인 준비 | 기존 본인 Git 설정 재사용, .user_info 생성·형식 검사·작성자/커미터 일치. 실제 값 비공개, Git 추적 제외 |
| Godot 실제 버전 | 4.7.2.stable.official.ed1daf0bf |
| export templates | 4.7.2.stable, archive 파일35개 설치. web_nothreads_debug.zip·web_nothreads_release.zip 포함 |
| Edge | C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe / 157.0.4341.46 |
| Chrome | C:\Program Files\Google\Chrome\Application\chrome.exe / 157.0.8103.78 |

브라우저는 파일 버전을 읽었다. 실제 WebGL2·GPU·게임 로딩·입력 검증은 첫 연결본 단계에서 수행한다. Get-ComputerInfo의 CIM 접근은 제한되어 registry/OSVersion 읽기로 OS 정보를 대조했다.

## 프로젝트 전용 Godot

- exe: `.tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe` (GUI exe도 같은 폴더).
- `_sc_` 파일로 self-contained editor_data를 사용한다. templates 경로는 `.tools/godot-4.7.2/editor_data/export_templates/4.7.2.stable/`이다.
- 전역 Godot 설정·PATH·시스템 설치를 변경하지 않았다. Blender는 모델 담당 PC에서 준비하므로 본인 PC에 설치하지 않았다.
- `.tools/`, `logs/`, `.user_info`는 Git 제외다. 브랜치를 전환해도 로컬 도구가 미추적 목록에 노출되지 않도록 .git/info/exclude에도 .tools/와 logs/를 추가했다.
- Godot `_sc_`만 켜고 project-manager를 시작한 첫 검사는 초기 app_userdata가 전역 APPDATA를 찾으며 접근 오류를 냈다. 이를 성공으로 처리하지 않고, **Godot 자식 프로세스에만 APPDATA를 프로젝트 내부 runtime_appdata로 지정**해 다시 검사했다.
- 재검사 `--headless --project-manager --quit --verbose`는 exit0·stderr빈문자열, editor_data의 설정 load/save 성공. 외부 환경변수나 전역 설정 파일을 덮어쓰지 않았다.

다음 Worker는 아래 방식으로 프로세스만 격리한다. 예시 인자는 실제 검증한 환경 검사이며 제품 실행 명령은 project.godot가 생긴 뒤 WORKFLOW guard와 함께 바꾼다.

```powershell
$RepoRoot = (Get-Location).Path
$EditorDir = Join-Path $RepoRoot '.tools/godot-4.7.2'
$RuntimeData = Join-Path $EditorDir 'editor_data/runtime_appdata'
$Launch = [Diagnostics.ProcessStartInfo]::new()
$Launch.FileName = Join-Path $EditorDir 'Godot_v4.7.2-stable_win64_console.exe'
$Launch.WorkingDirectory = $RepoRoot
$Launch.UseShellExecute = $false
$Launch.CreateNoWindow = $true
$Launch.Environment['APPDATA'] = $RuntimeData
foreach ($Argument in @('--headless','--project-manager','--quit')) { $Launch.ArgumentList.Add($Argument) }
$GodotProcess = [Diagnostics.Process]::Start($Launch)
$GodotProcess.WaitForExit()
"Godot exit=$($GodotProcess.ExitCode)"
```

위 ProcessStartInfo.ArgumentList/Environment 방식은 현재 작업의 PowerShell 7/.NET 실행 환경에서 검증했다. Windows PowerShell 5.1에서는 이 블록을 그대로 실행하지 않고 AI가 해당 PC 런타임에 맞는 프로세스별 실행 방식을 확인한다. 준비 점검 도구 자체는 아래 Windows PowerShell 5.1 명령으로 실행했다.

## 공식 다운로드·무결성

[공식 Windows 다운로드](https://godotengine.org/download/windows/)와 [공식 4.7.2 릴리스](https://github.com/godotengine/godot/releases/tag/4.7.2-stable), GitHub release API의 실제 자산을 확인한 뒤 내려받았다. 아래 SHA256은 공식 API digest와 다운로드 파일이 일치했다.

| 파일 | 크기(byte) | SHA256 |
| --- | --- | --- |
| Godot_v4.7.2-stable_win64.exe.zip | 86013866 | 731980f9608d61333e5baf54a2ef17210acc7a538446c0cb9969f002aca1e953 |
| Godot_v4.7.2-stable_export_templates.tpz | 1281349702 | f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011 |

Windows Authenticode 조회는 signer Prehensile Tales B.V.를 반환했으나 Status=UnknownError였다. 서명 검증 통과로 주장하지 않는다. 별도로 공식 배포 digest 대조와 실제 실행 버전 확인을 완료했다.

[self-contained 공식 설명](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html#self-contained-mode)을 근거로 프로젝트 전용 editor_data를 사용한다.

## 하네스 점검 도구 결과

`.user_info.example`, `tools/windows/check-environment.cmd`, `tools/windows/check-environment.ps1`은 원본과 SHA256 일치하며 수정하지 않았다. 기존 파일이 없는지 먼저 확인하고 복사했다.

CMD wrapper 호출은 PS1 경로를 잘못 해석해 실패했다. 원본 PS1을 절대 경로로 호출했을 때 OS의 script execution policy로 차단되어, 해당 한 번의 자식 프로세스에만 ExecutionPolicy Bypass를 지정했다. 시스템 실행 정책은 변경하지 않았다.

```powershell
$RepoRoot = (Get-Location).Path
$CheckScript = Join-Path $RepoRoot 'tools/windows/check-environment.ps1'
& "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $CheckScript -Workspace $RepoRoot
```

결과 exit0: 루트 일치, 작업 폴더 쓰기/임시 파일 삭제, 유효한 Git 작성자·커미터와 준비 값 일치. 신원 설정 변경은 필요 없어 ApplyIdentity를 쓰지 않았다. 도구의 GitHub/제품런타임 NOT_CHECKED는 도구 자체 범위이며 GitHub 계정과 Godot 실제 실행은 위의 별도 검사로 확인했다.

비공개 로컬 로그: `logs/windows-check-d39720b10ffc42fda70f7de1b629810b.log`, `logs/godot-environment-stdout.log`, `logs/godot-environment-stderr.log`. 로그와 설치 아카이브는 커밋하지 않는다.
