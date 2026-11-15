# PE-04 마우스 상태 제어 인계

담당 dyhan0528 · 2026-11-15 · 이슈 #28 · 기준 main `6e790cd699b5ad1911a9dc065041efd8e02c3e7b`

## 이번 구현 범위

mission.gd에 시점 입력 상태 `look_mode`를 추가했다. 기존 화면 상태 `mode`는 유지한다. `explore`에서 캡처 탐색 또는 드래그 탐색을 선택하며 다른 화면에서는 시점 입력을 비활성화한다.

| 상황 | 화면 상태 | 시점 상태 | 결과 |
| --- | --- | --- | --- |
| 시작/재개 클릭 | capturing | disabled | 최대 2초 동안 잠금 응답 대기 |
| 잠금 성공 | explore | captured | 이동·캡처 시점 허용 |
| 잠금 실패 + 입력 API 있음 | explore | drag | 커서 표시, 드래그 입력 계약으로 전환 |
| 잠금 실패 + 입력 API 없음 | pause | disabled | 기존 재시도/새 탭 안내 유지 |
| Esc·포커스 상실·캡처 모드의 잠금 해제 | pause | disabled | 이동·시점 중단, 커서 표시 |
| 단말기/관찰/도움말 | 기존 화면 상태 | disabled | 기존 UI 조작 유지 |

드래그 모드에는 캡처가 없다는 이유로 일시정지하지 않는다. 취소·시간 초과 뒤 늦게 도착한 성공 응답은 탐색을 자동 재개하지 않으며, 드래그 모드에서 늦게 잠긴 커서는 다시 해제한다. 실제 잠금 재시도는 기존 시작/재개 사용자 동작에서 수행한다.

## PE-05에서 연결할 계약

- `Player.set_look_mode(value: String)`을 구현한다. 값은 captured / drag / disabled. mission은 `set_exploring`으로 이동을 갱신한 뒤 이 메서드를 호출한다.
- captured는 실제 캡처 상태에서만 상대 시점 입력을 허용한다. drag는 게임 영역에서 시작한 왼쪽 드래그만 허용하고 버튼 해제·영역 이탈·포커스 상실·모드 전환에서 드래그를 종료한다. UI가 소비한 입력으로 회전을 시작하지 않는다.
- `mission.look_mode_changed(value: String)` 신호를 HUD 안내에 연결한다. drag에서는 잠금 실패와 “왼쪽 버튼을 누른 채 드래그로 둘러봐요”를 지속해서 보여준다. 현재 pause 전용 `set_input_notice`만 호출하면 탐색 중에는 안 보이므로 그것으로 대체하지 않는다.
- 화면 `mode`는 drag에서도 explore이므로 기존 이동·E 단말기·HUD 표시 계약을 유지한다. 드래그 모드의 커서가 브라우저 영역을 벗어나지 않는다고 보장하지 않는다.
- 팀원 #27 완료 후 player.gd 소유권을 받아 위 입력을 연결한다. 이번 작업은 player.gd/hud.gd/help.gd를 수정하지 않았다.

## 검사 범위와 남은 인수

전용 검사 `scripts/simulation/tests/mouse_modes.gd`는 기존 플레이어의 안전한 실패 경로와 모의 플레이어를 이용한 상태 전환을 확인한다. 모의 객체에는 실제 드래그 시점 입력을 구현하지 않았다. 이 검사는 브라우저 권한·커서 경계·UI 드래그 실조작 검증을 대신하지 않는다.

명령: Godot `--headless --path . --script res://scripts/simulation/tests/mouse_modes.gd`.

실제 입력 API·HUD 연결 전에는 사용자가 잠금 실패 후 드래그로 플레이할 수 없다. 따라서 #28은 상태 제어 코드 통합 후에도 OPEN으로 유지한다. #29에서 연결, Native/Web/iframe 실조작 및 jsjavsj 교차 검증 후 남은 수용 조건을 판단한다.

실행 결과: Godot 4.7.2 Windows import exit 0, stderr 비어 있음. headless mouse_modes 23 / navigation 70 / core_contract 90 / outcome_ui 1149 / world_ui 532 = 총 1864개 검사 실패 0, 모두 exit 0. 로컬 증거 logs/pe04-*-stdout.log 및 stderr.log. 상태 전환 검사는 모의 Player API를 사용하며 실제 Native/Web/iframe 포인터 실조작과 팀원 교차 검증은 미실행이다.
