# PE-03 점프·중력 인계

기준 main `280c0469e3b0f535628d3a2148e738e9be083527`, #27 / `feature/PE-03-jump`. jsjavsj 구현, AI Worker ux12_worker / 독립 AI Verifier ux11_verifier / PM root. dyhan0528의 사람 교차 검증과 구분한다.

## 변경과 계약

- `project.godot`에 jump/Space만 추가했다. `player.gd`의 기존 이동속도3·캡슐·마우스 입력·카메라·E 레이는 유지한다. mission/HUD/player.tscn은 수정하지 않는다.
- 조정 가능한 `gravity=9.8`, `jump_height=0.8`, 초기속도 `sqrt(2*gravity*jump_height)`를 사용한다. 탐색·실제 접지에서 새로 누른 입력만 소비한다. 공중 입력도 소비하므로 착지 때 예약되거나 길게 눌러 반복되지 않는다.
- `set_exploring`은 기존 속도초기화와 함께 현재 Space 눌림을 기억한다. UI 복귀 직전 눌린 키는 해제 후 새 입력이 필요하다. 공중 pause는 위치 고정·속도0, 재개는 중력부터 적용한다.
- `apply_pose`는 속도와 점프입력을 초기화한다. 기존 is_on_floor 값은 순간이동 직후 이전 위치의 정보일 수 있으므로 첫 move_and_slide로 접지를 새로 확인하기 전에는 점프하지 않는다. 그 첫 프레임에 누른 입력도 소비하며 추가 점프를 만들지 않는다.
- 기존 낙하 y<-3 복귀 및 되감기 apply_pose 경로를 유지한다. 몸 시각 씬/게이지/드래그 마우스 연결이나 Space 안내는 #29 담당이다. 점프가 보행 출입구 접근을 대신하지 않는다.

## 실제 물리 검사

Windows / Godot4.7.2 stable. 전용 fixture는 실제 Player CharacterBody3D·원래 캡슐·실제 move_and_slide를 사용한다. Engine.physics_ticks_per_second를30/60/120으로 바꾸고 프레임 경계를 기다린 뒤 실제 physics delta를 대조한다. 이는 **화면 표시 FPS 측정이 아닌 물리 tick 환경 검사**다. 각 틱마다 수동 호출하는 테스트 구동이며 브라우저/사용자 키 입력 검사로 확대하지 않는다.

| 물리 Hz | physics delta | 측정 최고 높이(m) | 목표0.8 대비 오차 |
| --- | --- | --- | --- |
| 30 | 0.0333333 | 0.86740 | 8.42% |
| 60 | 0.0166667 | 0.83414 | 4.27% |
| 120 | 0.0083333 | 0.81658 | 2.07% |

세 환경 모두 목표 대비10% 이내. 최고·최저 차이0.05082m는 목표 대비6.35%다. 첫 점프 틱에는 초기속도로 이동하고 이후 틱부터 중력을 적용하는 이산 적분에 따른 차이다. 판정을 느슨하게 만들거나 초기속도 공식을 바꾸지 않았다.

```text
--headless --path . --script res://scripts/simulation/tests/player_jump.gd
--path . --minimized --script res://scripts/simulation/tests/player_jump.gd -- --render
```

최종 headless85/0 및 실제 렌더97/0(PNG12): Space 바인딩·접지·초기속도·높이·hold 반복금지·공중 새 입력·UI release/repress·공중 pause/resume·apply_pose held·공중 복원 stale접지·낮은 천장·시설형 벽·낙하복귀, 실제 mission 되감기와 terminal/help/pause 상태 및 자원불변을 검사했다. 테스트의 카메라·캡슐 시각 마커는 fixture 전용이며 제품에 추가하지 않았다. `logs/pe03/jump_metrics.json`, `<30|60|120>-ground/apex/land/paused.png`가 측정·렌더 자료다.

기존 core90·learning15·avatar44 자체 검사 통과. navigation70/0으로 실제 보행 출입구·모서리·배치 전후·되감기 후·단말기 재접근 회귀를 검사한다. 실제 표시30/60/120FPS, Native/Web 사용자 조작, 새 마우스 대체모드·몸·HUD 연결 및 dyhan0528 사람 교차 검증은 #29에서 확인한다. 기존8072 빌드는 유지하며 배포·제출은 하지 않는다. PR은 Refs #27, 실제 통합 인수 전 OPEN을 유지한다.

원격 PE-01/PE-04 main4a38d8b를 무충돌 일반 merge하여 보존했다. 최신 mission의 실제 _open_help/_close_help 경로를 검사하며 mouse_modes23/0 및 resource_gauges64/0도 통과했다. 제품 점프 코드는 병렬 통합 전후 동일하다.
