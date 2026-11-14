# 달기지 리와인드

작은 달 기지를 1인칭으로 탐색하고 단말기에서 시설을 지어요. 7턴 동안 전력·산소·식량을 지킨 뒤, 같은 턴을 되감아 다른 설계와 결과를 비교할 수 있어요.

이 브랜치에는 임시 3D 모델로 만든 첫 플레이 버전이 있습니다. Godot 4.7.2에서 실행되며 단일 스레드 Web 출력도 생성했습니다. 브라우저에서의 전체 플레이 검증과 팀원 Blender 모델 통합은 아직 남았습니다.

## 실행 및 첫 플레이

1. **Godot 4.7.2 일반판**에서 이 폴더의 `project.godot`를 열고 **F6이 아닌 F5**로 프로젝트를 실행합니다. 이미 준비된 Windows PC의 portable 위치와 APPDATA 격리 방법은 [환경 기록](docs/ENVIRONMENT.md)을 참고하세요.
2. 화면을 클릭해 시작합니다. **WASD**로 걷고 마우스로 둘러봅니다. 시작 위치에서 정면 단말기를 바라보고 **E**를 누릅니다. **Esc**로 단말기를 닫거나 멈출 수 있고, 화면을 다시 클릭하면 이동합니다.
3. 발전기를 고르고 **01**번 일조 칸을 누른 뒤 **T1 확정**을 누릅니다. 아래에서 **T1**을 선택하고 **선택 턴 시작으로** 돌아갑니다. 이번에는 발전기 없이 T1을 다시 확정해 보세요. 아래의 같은 턴 비교에 두 시도의 전력 차이가 표시됩니다.
4. 7턴을 모두 도전하려면 첫 턴에 발전기 **01**, 배터리 **12**, 재배실 **14**, 대피소 **25**를 놓으세요. T2에서 **재배 유지**, T4에서 **대피하기**, T5에서 **확인**을 선택합니다.

화면의 칸 번호는 01–25이며 코드의 슬롯 ID는 0–24입니다. 자원과 사건은 교육용 가상 규칙입니다. 한국어 Windows에서는 한국어, 웹에서는 첫 빌드의 기본 영어 UI를 표시합니다.

## Web 출력과 검사

`Web` preset과 Godot 4.7.2용 export templates를 사용합니다. 편집기의 **프로젝트 → 내보내기**에서 Web을 선택하고 `build/web/index.html`로 출력하세요. 이 폴더는 Git 추적에서 제외됩니다. WebGL2 브라우저에서 로컬 정적 서버로 열어 주세요. 예를 들어 Python이 있는 PC라면 저장소 폴더에서 `python -m http.server 8061 --bind 127.0.0.1 --directory build/web`를 실행한 다음 [로컬 게임](http://127.0.0.1:8061/)을 열 수 있습니다.

Windows portable 실행 방법은 [환경 기록](docs/ENVIRONMENT.md)을 따르고, 인자에 아래 명령의 옵션을 전달합니다.

```text
--headless --path . --editor --import
--headless --path . --script res://scripts/simulation/tests/core_contract.gd
--headless --path . --export-release Web build/web/index.html
```

[규칙 v0.1](START_SPEC.md) · [작업 기록과 검증 범위](WORK.md) · [팀원 워크플로](WORKFLOW.md) · [모델 제작 규격](ASSET_BRIEF.md) · [GitHub 이슈](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues)
