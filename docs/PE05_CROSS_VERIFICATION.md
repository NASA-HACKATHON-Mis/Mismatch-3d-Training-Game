# PE-05 교차 검증 기록

현재 상태(2026-11-15): PR #36 통합 main `2f3da388d48623db5c137d05fd41505759c45418`의 독립 자동4880/0 및 Chrome 일반 페이지 일부 실조작을 확인했다. 사용자 입력과 조작이 겹쳐 추가 조작은 응답 대기 중이다. Native/iframe 실조작, 실제 held Space·점프 및 표시FPS는 미검증이며 #29는 OPEN/최종 인수 대기다. 아래 **공개 통합본 후속 검사** 절이 최신 상태다.

다음 부분 교차검증 절들은 과거 통합 전 main `3ea5bbc3c31ebbfb0dfbb0b3e299e04173bbc57c`의 이력이다. 당시 공개 후보 없음/미연결이라는 표현은 현재 통합본 상태를 뜻하지 않는다.

팀원 jsjavsj의 교차 검증을 Codex로 수행한다. PM root는 읽기/시각 검토, Worker ux12_worker는 렌더 및 기록, 독립 AI Verifier ux11_verifier는 다른 담당 PE-01/PE-04의 검사 재실행을 맡았다. 제품 코드는 변경하지 않는다. 사람의 실제 입력 검사와 AI 자동 검사를 구분한다.

## 과거 통합 전: 공개된 진행 상태

- PR #31 PE-02, #34 PE-03이 일반 merge되었고 player.gd/project.godot의 PE-03 claim은 #27에 반환 기록을 남겼다. #29 담당 dyhan0528가 최종 연결을 진행할 수 있다.
- #29는 OPEN이며, 조회 당시 본문은 PE-01~04 대기로 blocked였다. 댓글에는 dyhan0528가 main4a38d8b에서 독립 UI 준비를 시작했고 당시 #27의 player 소유권 반환을 기다린다고 기록했다. 이는 준비 착수 근거이며 최종 통합 완료 근거가 아니다.
- fetch 및 `git ls-remote --heads origin feature/PE-05*`에서 PE-05 공개 브랜치를 찾지 못했다. GitHub PE-05 키워드와 head:feature/PE-05-integration PR 조회도 결과가 없었다. 상대 PC의 미공개 작업 상태를 추정하지 않는다.
- 따라서 별도 후보 checkout이나 제품 수정 없이 현재 main의 공개 컴포넌트만 검사했다. 이후 공개 후보 SHA/PR을 받으면 그 정확한 소스를 대상으로 통합 교차 검증을 이어간다.

## 과거 통합 전: 게이지 렌더

Windows / Godot4.7.2 stable / OpenGL Compatibility / AMD Radeon Graphics. 기존 `scripts/simulation/tests/resource_gauges.gd -- --render`를 실행해 **70 checks/0 failures**, exit0을 확인했다. GPU 실행이 끝난 후 독립 headless 검사를 진행해 실행 경합을 피했다.

실제 PNG 6개는 `logs/pe01/`의 1280x800, 960x600, 480x800 각각 pause/explore 화면이다. 1280explore와 480pause에서 자원 이름·수치·막대 및 좁은 폭의 세로 배열을 확인했다. 초기20/20·60/100·36/100, draft 배터리의 HUD 미반영, 확정 뒤40용량, 되감기 뒤20용량 및 자원 표시 복귀는 기존 테스트의 실제 simulation/session 경로로 검사한다. 경계0/초과/상한변경/잘못된 상한도 검사한다.

이 fixture는 mission/player physics를 정지하고 UI를 코드로 조작한다. 따라서 explore 하단 E안내가 비어 있는 이미지는 게이지 렌더 증거이며 실제 이동·단말기 재접근이나 포인터 권한의 검증이 아니다. 새 기능을 기존8072 Web 빌드로 export하지 않았다.

PM은 1280x800-explore, 960x600-pause, 480x800-pause를 직접 검토하여 현재/상한·막대·가로/세로 배열 및 헤더/시작 패널이 겹치지 않음을 확인했다. Verifier는 960x600-explore의 숫자·막대 가독성을 확인했다. 모두 위 fixture 범위의 시각 검토다.

## 과거 통합 전: 독립 재실행 결과

동일 main3ea5bbc에서 Windows/Godot4.7.2, headless `--fixed-fps 60`, `.tmp/verification-appdata` 환경으로 resource_gauges64 + mouse_modes23 + navigation70 + core_contract90 + learning_ui15 = **262 checks/0 failures**, 각 exit0을 확인했다. 화면 표시60FPS를 실측한 결과가 아니라 검사 실행 설정이다.

resource_meter 상태 비변형과 잘못된 상한 표시, HUD 게이지 업데이트, mission의 잠금상태 전환 및 legacy 안전 fallback, 기존 보행/단말기 접근과 규칙/학습 UI 회귀에 대한 부분 교차 결과다. 실제 드래그 입력은 LookProbe 모의 객체로 대체되어 통합 인수가 남아 있다.

검사 파일 SHA256:

- resource_meter.gd: `92FF1D8F933380DD8386A137859B7F6DAB9ACBDF477D9FA2EEE665E395B0001A`
- hud.gd: `CE4ED7246D881D5C80DD572743168236AC0AACFFAD98D126638F959B22E58A30`
- mission.gd: `9A8EAAA3072A3C2D7947E55A0B667D5120251BA89F917BBDB36827200DE24F6D`

## 과거 통합 전: 남은 검증과 인계 주의점

- main에는 아직 Player.set_look_mode 및 Avatar 실제 장착이 없다. PE-04의 잠금실패→drag 분기는 모의 Player API로만 검사되었고 실제 Player에서는 안전한 pause/재시도 경로를 유지한다.
- 실제 입력 API가 추가되면 mouse_modes의 기존 Player 전제 검사와 모의 객체 검사를 구분해야 한다. 기존 API 없는 fallback을 명시적인 legacy fixture로 보존하고 실제 Player의 드래그 검사를 별도로 추가한다.
- 드래그는 실제 viewport 입력 순서, UI가 소비한 클릭, 게임 밖에서 누르고 진입, 영역 이탈/포커스 상실, 버튼 해제, held 입력 재개를 검증해야 한다. API 존재만으로 fallback이 열리므로 실제 player 입력과 탐색 중 지속 안내가 함께 연결되어야 한다.
- 최종 후보에서 게이지·몸·점프·captured/drag 연동, 기존 pose/apply_pose·되감기·결과화면·관찰 복귀, 전체 기지 동선을 다시 검사한다. Native/Web/iframe 실입력·시각 및 표시30/60/120FPS는 이번 컴포넌트 검사로 통과 처리하지 않는다.

#29와 관련 기능 이슈는 OPEN 유지. 이 기록은 최종 통합 인수 PASS나 상대 담당자의 구현 완료를 뜻하지 않는다. 배포/제출은 하지 않으며 #7은 보류한다.

## 공개 통합본 후속 검사 준비 — 2026-11-15

위 절은 공개 후보가 없던 시점의 부분 교차 검증 이력이다. 이후 PR #36이 일반 merge되어 main `2f3da388d48623db5c137d05fd41505759c45418`을 fetch/fast-forward했다. 구현 source `cab73f6b4cb67cce4321366c51800b218abaecbd`와 병합 HEAD의 전체 diff가 없음을 확인했다. 깨끗한 기준에서 문서 브랜치 `docs/PE-05-final-cross-verification`을 만들었다. 제품 파일은 수정하지 않는다.

별도 Web export `build/pe05-cross/index.html`이 exit0으로 완료되었다. Git 제외 테스트 서버 `logs/pe05_cross_server.py`를 localhost8073에 실행하며 기존8072 출력/서버를 변경하지 않는다. 일반 페이지 `http://127.0.0.1:8073/index.html`과 거부 fixture `http://127.0.0.1:8073/iframe-denied.html`은 HTTP200이다. iframe은 sandbox에 allow-scripts/allow-same-origin만 허용하고 allow-pointer-lock은 넣지 않았다. 이는 실제 브라우저의 잠금 거부→드래그 경로를 검사할 테스트 페이지이며 배포 설정 변경이 아니다.

| 출력 | 크기(bytes) | SHA256 |
| --- | ---: | --- |
| index.pck | 7420460 | `333FDB11260DE73EC911F6C7413BEC523A2CD9EE0FB5D569DEA89845D3D3146A` |
| index.wasm | 39514754 | `FC74679E3B97F76878947FCD4FBE1268CBFA6188182A2E33BBC3F5DC9BFA57D0` |

Native는 일반 제품을 `.tmp/pe05-native-appdata` 격리 환경으로 실행했다(PID27320/window7408522). 검사 fixture가 아닌 현재 main 게임이며 실제 UI 조작은 PM이 맡는다. 독립 headless 검사와 GPU 렌더 경합을 피하도록 조정했다. 실제 Native/Web/iframe 결과는 관찰 이후 별도로 기록하며 실행 준비 자체를 인수 PASS로 처리하지 않는다.

### 통합본 독립 자동 검사

Windows/Godot4.7.2, headless `--fixed-fps 60`, 격리 `.tmp/verification-appdata`에서 **4880 checks/0 failures**, 각 exit0을 확인했다. 구현자 보고4763(core90/guidance1243/learning15/mouse23/navigation70/outcome1277/input20/UI38/jump85/gauges64/rewind663/preview635/world540)을 재현하고 generator19/facility52/avatar46을 추가했다. main2f3da388과 cab73f6 제품 diff0을 대조했다. 점프의 실제 물리30/60/120Hz 높이도 동일하게 재현했다. 이는 합성 입력·물리·UI 회귀 검사이며 실제 Native/Web/iframe 사용자 조작 및 실제 표시FPS와 구분한다.

### Chrome 일반 페이지 실제 관찰 — 진행 중

PM이 localhost8073 일반 페이지에서 시작 클릭 뒤 실제 캡처 배너·팔·게이지 E20/20 O60/100 F36/100을 관찰했다. 실제 마우스 회전, Esc pause, 클릭 재개 및 E 단말기 진입을 확인했다.

단말기에서 발전기01/배터리12를 미확정 배치하면 토큰7, 현재 게이지20/20이 유지되고 배치 후 용량40이 별도 표시되었다. T1 진행 뒤 T2 E32/40 O62 F30, 과거기록의 T1 복원 뒤 토큰12·빈 시설·E20/20 O60 F36을 실제 확인했다. 짧은 CUA Space 입력에서는 점프 장면을 관찰하지 못했으므로 이 실행을 실제 점프 PASS로 기록하지 않는다. iframe과 Native의 추가 관찰은 아직 별도 기록 대기다.

### 실제 조작 일시 대기와 남은 검사

Chrome에서 새 사용자 입력이 감지되어 PM이 추가 조작을 멈추고 조작 위임 응답을 기다린다. iframe 검사 시도의 최종 화면 주소가 일반 index.html로 달라져 잠금 거부와 fallback의 실제 관찰을 확정하지 못했다. 따라서 iframe 드래그 fallback은 미검증이며 fixture 준비/HTTP200을 실제 성공으로 간주하지 않는다.

Native 창은 실행 준비만 완료했고 실제 조작 인수는 미검증이다. 실제 길게 누른 Space 및 점프 장면, 실제 표시30/60/120FPS도 미검증으로 남긴다. 자동4880 통과나 물리tick 측정으로 이 항목들을 대신하지 않는다. 실제 Chrome 확인 범위는 위 일반 페이지 관찰로 한정한다. #29 및 관련 기능은 OPEN, 최종 인수는 대기 상태다. 이 후속 기록은 독립 문서 검토를 통과해 Refs #29 문서 PR로 인계한다. 사용자 응답 이후 추가 증거는 후속 기록에 반영한다.
