# PE-05 최종 통합 후보 — 팀원 검증 인계

2026-11-15 · 구현 담당 dyhan0528 · 교차 검증 담당 jsjavsj · 이슈 #29

## 연결 완료

- 실제 Player 씬에 AvatarVisual을 yaw 루트 자식으로 장착했다. 실제 이동 속도·접지·점프가 팔다리 자세를 구동하고 pause에서는 동결한다. 되감기/낙하 복귀는 잔여 시각 상태와 드래그를 초기화한다.
- 실제 Player.set_look_mode를 연결했다. 잠금 실패 후 drag 탐색이 가능하며, UI가 소비한 클릭과 영역 밖에서 시작한 드래그는 시점을 움직이지 않는다. 버튼 해제·영역 이탈·포커스 상실·상태 전환에서 드래그를 해제한다.
- mission의 look_mode_changed를 HUD에 연결해 탐색 중 드래그 안내를 표시한다. 점프/드래그 기능이 있는 경우에만 시작 화면과 안내서에 조작법을 표시한다.
- 단말기에 공용 자원 게이지를 연결했다. 현재 확정 자원과 미확정 배치 용량/턴 예측을 분리하며 HUD와 단말기가 턴 진행·되감기 후 같은 값을 표시한다.
- 하단 안내의 자동 줄바꿈으로 패널 높이가 변경될 때 위치를 다시 계산한다. 실제 렌더에서 안내가 화면 밖으로 밀리는 문제를 발견해 수정했다.

기존 점프 물리값·캡슐·시설 충돌·자원 계산·7턴 규칙은 변경하지 않았다. 기존 SUBMISSION.md 로컬 초안은 게시에서 제외했다.

## 구현자 검사 결과

Windows / Godot 4.7.2.stable.official.ed1daf0bf. 실제 렌더: OpenGL Compatibility / Intel UHD Graphics.

| 검사 | 통과 수 |
| --- | ---: |
| core_contract | 90 |
| guidance_ui | 1243 |
| learning_ui | 15 |
| mouse_modes | 23 |
| navigation | 70 |
| outcome_ui | 1277 |
| play_input_integration | 20 |
| play_ui_integration | 38 |
| player_jump | 85 |
| resource_gauges | 64 |
| rewind_ui | 663 |
| turn_preview | 635 |
| world_ui | 540 |
| **headless 합계** | **4763** |

모든 검사 실패 0, 각 프로세스 exit 0 및 stderr 비어 있음. 점프 검사는 실제 물리 30/60/120Hz에서 목표 0.8m 대비 각각 8.42%/4.27%/2.07% 오차다. 표시 FPS 검증은 아니다.

추가 실제 렌더 검사: play_ui_integration 38/0, avatar_visual 62/0. 단말기·지속 안내 PNG 4개 및 실제 장착된 캐릭터의 2크기×8시야/자세 PNG 16개를 생성했다. 960×600 단말기/드래그 안내 및 1280×720 정면/아래 보기 등을 직접 확인했다. 로컬 증거는 logs/pe05/, logs/pe02/, logs/pe05-final-*.log에 있다. 로그와 PNG는 Git 제외이며 아래 명령으로 재생성할 수 있다.

```text
--headless --path . --editor --import --quit
--headless --path . --script res://scripts/simulation/tests/play_input_integration.gd
--headless --path . --script res://scripts/simulation/tests/play_ui_integration.gd
--path . --minimized --script res://scripts/simulation/tests/play_ui_integration.gd -- --render
--path . --minimized --script res://scripts/simulation/tests/avatar_visual.gd -- --render
--headless --path . --export-release Web build/pe05/index.html
```

Godot 경로와 프로세스별 APPDATA 격리는 docs/ENVIRONMENT.md를 따른다. Web release export는 성공했으며 기존8072 빌드를 덮어쓰지 않았다. 팀원은 자신의 검증 폴더로 새로 export한다.

## 팀원이 이어서 할 일

1. #29/PR에 기록된 정확한 후보 또는 main 병합 SHA를 fetch하고 본인 PC의 깨끗한 작업 브랜치에서 체크아웃한다. 기존 미커밋 변경을 보존한다.
2. 위 신규 검사와 영향을 받는 기존 회귀 검사를 재실행한다. mouse_modes는 legacy 모의 객체를 따로 유지하고 play_input_integration이 실제 Player의 viewport 입력 경로를 검사한다.
3. Native와 Web에서 시작→잠금/드래그→걷기/Space 점프→아래로 몸 확인→E 단말기→배치/턴→되감기→Esc/재개→기지 출입을 직접 조작한다. 일반 페이지의 캡처 성공, iframe의 잠금 거부, UI 클릭, 영역 이탈, 포커스 상실, 길게 누른 입력 복귀를 구분해서 기록한다.
4. 실제 검증 SHA·OS·브라우저 버전·Native/Web/iframe·통과/실패/미실행·증거를 #29에 기록한다. 문제가 있으면 재현 단계와 함께 반환한다.

**아직 최종 인수 완료는 아니다.** 이 후보의 Native/Web/iframe 사용자 실조작과 jsjavsj의 최종 통합 교차 검증은 남아 있다. 이전 브라우저 시도는 Computer Use가 현재 URL을 확실히 판별하지 못해 중단됐고 로컬 서버 실행도 실패했으므로 실제 Web 조작 PASS로 기록하지 않는다. 합성 입력·실제 렌더 검사는 해당 범위만 증명한다. #25~29는 남은 인수를 확인한 뒤 종료하며 배포/제출은 별도다.
