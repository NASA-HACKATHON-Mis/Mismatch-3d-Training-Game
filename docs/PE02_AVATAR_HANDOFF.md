# PE-02 독립 우주복 시각 씬 인계

기준 `738ef431cb70ecf1c0fb9e8bbca16297762c536b`, 이슈 #26, 브랜치 `feature/PE-02-avatar`. 구현 jsjavsj/AI Worker ux12_worker, 독립 AI 검증 ux11_verifier, PM root. dyhan0528의 사람 교차 검증은 별도이며 이 문서의 AI 검사와 같지 않다.

## PE-05 연결 계약

- `scenes/player/avatar_visual.tscn`을 Player의 수평 회전 루트에 **identity transform 자식**으로 장착한다. Camera3D 자식으로 넣지 않는다. 현재 카메라 y=1.6, FOV72, near0.05 및 pitch ±80도를 기준으로 제작했다.
- `update_motion(local_velocity: Vector3, grounded: bool, active: bool, delta: float)`를 연결한다. 속도는 Player의 로컬 좌표(예: `player.global_basis.inverse() * player.velocity`), grounded는 `is_on_floor()`이다. 실제 점프와 입력 상태 연결은 #29에서 수행한다.
- active는 실제 이동 가능한 탐색일 때만 true이다. 단말기·도움말·일시정지·관찰은 false를 전달한다. false는 phase와 관절을 즉시 동결한다. 다시 active일 때 정지/접지이면 걷기나 공중 자세를 즉시 기본 자세로 돌린다.
- 자율 process/physics_process, 입력 처리, 카메라 수정, 캐릭터 이동, 시뮬레이션 접근이 없다. 몸 루트와 다리는 yaw만 상속하고 팔/다리 관절은 별도로 움직인다. 큰 카메라 흔들림은 없다.
- 기본 도형과 재질만 쓰며 외부 자산·의존성이 없다. MeshInstance3D만 생성하므로 기존 캡슐이나 레이를 바꾸지 않는다. 시각 모델 교체는 이 씬/스크립트 안에서 처리하며 이동 코드 변경을 요구하지 않는다.

## 실행 검사

Windows, Godot 4.7.2 stable / OpenGL Compatibility, AMD Radeon Graphics. 실제 게임 씬을 독립 SubViewport fixture에 로드하고 테스트에서만 Avatar를 장착했다. 게임의 Player 파일·씬 및 HUD·mission은 변경하지 않았다.

```text
--headless --path . --script res://scripts/simulation/tests/avatar_visual.gd
--path . --minimized --script res://scripts/simulation/tests/avatar_visual.gd -- --render
```

렌더 실행은 60 checks/0 failures(동작44+PNG16). 1280×720, 800×900에서 정면, pitch ±80도, 좌우 yaw ±90도, 걷기, 공중, 착지를 확인한다. `logs/pe02/<크기>-front/down/up/left/right/walk/air/land.png`에 실제 렌더를 기록했다. HUD는 실제 단말기 ray/플레이어 방향으로 채운다.

검사 항목: 초기 inactive 동결, 걷기 자세 구분, inactive 즉시 동결, 정지 시 잔여 swing 없음, 공중 자세 구분, 착지 idle, 카메라/플레이어 pose·시뮬레이션 불변, 충돌 노드 0, 실제 단말기 정면 ray=true 전후 동일 및 후면 false.

## 남은 인수

독립 씬만 제공하므로 일반 게임에는 아직 표시되지 않는다. 실제 입력·Space 점프 연동, 단말기/안내서/일시정지 active 연동, 되감기/낙하 위치 복원 뒤 표시, Windows Native/Web 실조작 및 dyhan0528 교차 검증은 #29 통합에서 완료한다. 기존 서버8072 빌드는 덮어쓰지 않는다. 이 PR은 `Refs #26`이며 이슈는 OPEN 통합 대기로 유지한다.
