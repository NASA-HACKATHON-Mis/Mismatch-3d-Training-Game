# Windows 로컬 실행

지원: Windows 10/11 64비트, 키보드·마우스, OpenGL 3.3을 지원하는 그래픽 환경. 저장소 ZIP을 **전체 압축 해제**한 뒤 루트의 `RUN_GAME.cmd`를 더블클릭한다. ZIP 안에서 직접 실행하지 않는다.

실행기는 Windows 기본 PowerShell 5.1을 사용한다. Godot 4.7.2 일반판이 프로젝트 `.tools/godot-4.7.2`에 있으면 재사용하고, 없으면 공식 Windows 패키지를 받아 SHA256을 확인한 뒤 그 폴더에만 설치한다. 모델·글꼴 등을 import한 다음 게임 창을 연다. 관리자 권한·전역 PATH 변경이 없으며 Git, Python, Blender, .NET판 Godot와 export templates는 플레이에 필요하지 않다.

첫 설치에는 인터넷이 필요하고 Godot ZIP은 약 86 MB다. 설치가 끝난 다음에는 인터넷 없이도 실행할 수 있다. NASA 조회가 실패하면 실제 내장 보관 자료를 사용하는 기존 게임 규칙을 따른다. `RUN_GAME.cmd -Offline`은 조회를 생략하고 내장 자료로 시작한다.

## 실행과 확인

```text
RUN_GAME.cmd
RUN_GAME.cmd -Offline
RUN_GAME.cmd -NoLaunch
RUN_GAME.cmd -SmokeTest
```

- `-NoLaunch`: 엔진 준비·버전 검사·asset import까지 확인하고 GUI를 열지 않는다.
- `-SmokeTest`: 위 준비 뒤 실제 게임 장면을 headless로 짧게 실행한다. 내장 NASA 자료를 사용한다.
- 검사 격리용 `-ToolsDirectory .tmp\clean-engine`은 엔진/다운로드 위치만 바꾼다. 경로는 프로젝트 내부여야 한다.
- 매 실행에서 import를 수행하므로 Git 갱신 후에도 새 asset과 스크립트를 반영한다. 엔진은 재다운로드하지 않는다.

APPDATA는 Godot 자식 프로세스에만 프로젝트 내부 경로로 지정한다. `_sc_` 표식으로 편집기 데이터도 프로젝트에 둔다. 로그는 `logs/launcher-날짜.log`, `logs/launcher-import.log`, `logs/game-날짜.log`이며 Git에 포함하지 않는다. 실행 중 콘솔 창은 닫지 않고 게임 창을 사용한다. 게임을 종료하면 실행기도 끝난다.

## 문제가 생기면

- 다운로드 실패: 인터넷과 GitHub 접근을 확인한 뒤 같은 파일을 다시 실행한다. SHA256이 다르면 설치·실행하지 않고 멈춘다.
- 버전 불일치: 오류에 표시된 프로젝트의 `.tools/godot-4.7.2` 폴더를 다른 이름으로 보존한 뒤 재실행한다.
- import 실패: `logs/launcher-import.log`를 확인한다. 프로젝트 ZIP 전체가 풀렸는지 확인한다.
- 창이 보이지 않으면 Alt+Tab에서 `Lunar Base Rewind`를 찾는다. OpenGL 시작 오류는 그래픽 드라이버와 GPU 지원을 확인한다.
- 조직 정책이 PowerShell 실행을 막으면 관리자에게 승인받은 실행 방식을 사용한다. 실행기의 `ExecutionPolicy Bypass`는 해당 프로세스 한 번에만 적용되며 시스템 정책을 변경하지 않는다.

macOS/Linux 자동 설치는 제공하지 않는다. 해당 OS의 Godot 4.7.2 일반판에서 `project.godot`를 열고 F5로 실행할 수 있으나 이번 Windows 실행기 검증 범위에는 포함하지 않는다.

## 고정 배포 출처

2026-11-15 공식 GitHub release asset digest와 대조한 값이다. [Godot 4.7.2 공식 배포](https://github.com/godotengine/godot/releases/tag/4.7.2-stable), [공식 release API](https://api.github.com/repos/godotengine/godot/releases/tags/4.7.2-stable), [self-contained 데이터 경로 설명](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html#self-contained-mode).

- 파일: `Godot_v4.7.2-stable_win64.exe.zip`
- 크기: 86,013,866 bytes
- SHA256: `731980f9608d61333e5baf54a2ef17210acc7a538446c0cb9969f002aca1e953`

자동 설치는 이 버전·파일·해시에 고정되어 있으며 임의의 최신 버전을 실행하지 않는다. Web 내보내기와 제출 배포는 별도 작업이다.

## 이번 구현 검증

Windows 기본 PowerShell 5.1에서 한국어·공백이 포함된 프로젝트 경로를 사용했다. 빈 `.tmp/clean-engine`에 공식 ZIP을 실제 다운로드해 SHA256 검증·압축 해제·Godot 버전 확인·전체 asset import·게임 장면 120프레임 headless 실행을 완료했다. 이어 `RUN_GAME.cmd -NoLaunch -Offline -ToolsDirectory .tmp\clean-engine`로 기존 설치를 재사용했고 다운로드 ZIP 수정 시각이 그대로인 것을 확인했다. 프로젝트 바깥 설치 경로는 실패 코드로 거절했다. 실행 중인 사용자 게임은 종료하지 않았다.
