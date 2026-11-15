# #39 시야·전신 그림자·근접 팔 수정

기준 main `b6558cf391abccdcd76ac9da966218eb9c097bdf`(PR40 source23d487f와 전체diff0). #39 담당 jsjavsj / Worker ux12_worker / 독립 AI Verifier ux11_verifier / PM root. 브랜치 `fix/player-view-shadow-arms`.

## 변경 범위

- Player의 아래 시야를65°, 위 시야를75°로 제한한다. 실제 마우스 입력과 apply_pose가 같은 제한을 적용하므로 과거 저장된 ±80° 자세도 새 안전 범위로 복원한다. 위치/yaw·점프값·이동속도·캡슐·E2m 레이는 유지한다.
- 닫힌 몸통/머리 메시를 SHADOWS_ONLY로 추가한다. 카메라 앞에 몸통이나 머리 내부면을 그리지 않으면서 기존 팔/다리와 연결된 그림자를 만든다.
- 아래35°보다 깊게 보면 팔도 SHADOWS_ONLY로 전환한다. 하향에서 크게 보이던 양팔 면을 없애고 다리 쪽을 볼 수 있게 하되 땅의 팔 그림자는 유지한다. 다시 위를 보면 팔 표시를 복구한다.
- world collision mask1의 양팔 전체 부피(query box0.98×0.85×1.20m)를 검사한다. 자기 RID는 제외하고 shape 리소스를 재사용한다. 정면뿐 아니라 측면 벽도 감지하며 근접하면 팔을 즉시 안쪽/뒤쪽으로 수납한다. 캡슐이나 세계 충돌을 확대하지 않는다.
- 탐색 중 실제 move_and_slide 후 수납을 갱신한다. pause는 상태를 유지하고 apply_pose에서는 새 위치의 여유와 시야에 맞춰 즉시 재평가한다. 벽 제거/개방 위치 복원에서는 정상 팔 위치로 돌아온다.

수정 제품은 scripts/player/player.gd, scripts/player/avatar_visual.gd 두 파일이다. station.gd/기존모델/규칙/player.tscn/캡슐/HUD는 수정하지 않는다.

## 자체 검사와 시각 검토

Windows/Godot4.7.2 stable/OpenGL Compatibility/AMD Radeon Graphics. 전용 `scripts/simulation/tests/player_view_safety.gd`를 실행했다. 기본628 checks와 실제18PNG를 포함한 렌더646 checks/0 failures, exit0.

검사는 실제 apply_pose와 drag 입력으로 pitch 제한을 확인한다(카메라 rotation을 직접 써서 우회하지 않는다). 실제 CharacterBody 보행으로 정면/좌우벽에 접근한 뒤 팔의 모든 메시 꼭짓점이 벽 뒤로 넘어가지 않는지 확인한다. 원래 캡슐0.3/1.8 유지, shadow-only 닫힌 몸통/머리, down→front 복원 표시전환, pause 불변, 근접/개방 복원 시 즉시 재평가, 실제 단말기 ray true 유지 및 시뮬레이션 상태 불변을 포함한다.

이미지: `logs/fix-player/<1280x720|800x900>-front/down/up/down-left/down-right/wall-front/wall-left/wall-right/ground-shadow.png`. 실제 제품 세계/태양 아래의 땅 투영을 렌더했다. PM은 하향 가로/세로에서 양팔 가림이 사라지고 다리 표면이 보이며 내부 관통이 보이지 않음을 확인했다. 정면/측면벽에서 팔 돌출이 사라지고 몸통/머리 연결 그림자가 보임을 확인했다.

부츠/발은 현재 하단 HUD에 가려 명확히 식별되지 않으므로 **발 인지 PASS를 주장하지 않는다**. 이를 위해 HUD 범위를 확대하지 않았다. 외부 관찰카메라에서 shadow-only 몸통 자체가 보이지 않는 것은 의도한 1인칭 표현이며 완전한3인칭 캐릭터 구현이 아니다.

실행 명령:

```text
--headless --path . --script res://scripts/simulation/tests/player_view_safety.gd
--path . --minimized --script res://scripts/simulation/tests/player_view_safety.gd -- --render
```

오프스크린 실제렌더와 자동 입력/물리 검사만 수행했다. Desktop/Chrome 실조작은 하지 않았고 기존8072/8073 출력·서버와 Native 창은 변경하지 않는다. 사용자 직접 플레이가 최종 인수다. Refs #39 PR로 인계하며 #39 OPEN, #29 및 관련 인수도 자동 종료하지 않는다. 배포/제출은 하지 않는다.

독립 AI 검사955/0: view628+jump85+input20+avatar46+edgeposts16+navigation70+core90, 각 exit0. 점프·드래그·최신#38 차단봉/태양·단말기 보행 회귀를 포함한다. 독립 Verifier도 땅의 몸통/머리 그림자, 최대하향 팔가림 제거, 측면벽 수납 PNG를 확인했다. Godot editor import exit0.

사용자 확인용 빌드는 기존 출력을 덮지 않은 `build/fix-player/index.html`, 별도 localhost8074로 제공한다. 이는 로컬 미리보기이며 외부 배포가 아니다. 실제 브라우저 플레이 결과는 아직 없다.

추가 독립 rewind_ui663/outcome_ui1277도 통과해 최종 합계 **2895/0**이다. 실제 mission의 복원·성공/3종중단·결과재열기·도움말/Esc 회귀를 포함한다. Web export exit0, `http://127.0.0.1:8074/index.html` HTTP200. PCK7422492bytes의 파일/HTTP본문 SHA256은 모두 `B7D86B7841E328454456EB61417C59147B7F672292CC5FB162BD0FCEEFFE6544`이며 wasm SHA256은 `FC74679E3B97F76878947FCD4FBE1268CBFA6188182A2E33BBC3F5DC9BFA57D0`이다.
