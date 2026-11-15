# 현장 조작·어린이용 기지 운영 화면 명세

## 최신 이슈 정리 — 2026-11-15

완료된 구현 이슈 #26/#27/#28/#38/#39를 CLOSED로 정리했다. 남은 실제 플레이·환경별 확인은 #29 한 곳에서 추적하며 미실행 검사를 PASS 처리한 것은 아니다. A~D #43~#46도 CLOSED다.

열린 이슈는 3개: #47 실제 기능 연결·최소 인수, #29 기존 구현 기능의 최종 플레이 확인, #7 보류 중인 제출 준비. 따라서 8개 기능을 새로 구현해야 하는 상황이 아니다. 이하 과거 이력의 개별 OPEN/사용자 확인 대기 표현보다 이 최신 상태를 우선한다.

작성: 2026-11-15. 상태: A/B/C/D 구현 main 통합·인계 완료 및 이슈 종료. E 연결 구현 완료·사용자 확인 대기. 기준 main `97a9f34` (착수 시 최신 origin/main 재확인).

## 목표와 범위

7~12세가 긴 설명을 먼저 읽지 않고 기지 위치·자원 변화·다음 행동을 알아볼 수 있도록 개선한다. 빈 칸/건물 앞 E 조작, 한 화면의 격자보드와 자원 그래프, 아이콘과 짧은 정보 카드를 모두 이번 범위에 포함한다. PPT·영상·제출 작업은 제외한다. 기존 자원 계산·시설 비용·7턴·턴 확정·미확정 배치·되감기 규칙은 변경하지 않는다. 현장 조작은 기존 조작 기능의 진입점을 추가하며 새로운 시설 운전 규칙을 만들지 않는다.

현재 terminal.gd는 _select_slot에서 빈 칸 선택 즉시 edited(place)를 발생시킨다. 현장 E 진입에서 이 함수를 그대로 호출하면 의도하지 않은 건설이 발생한다. 선택과 실행을 분리한 공개 API를 추가해야 한다. mission.gd가 마우스·모드·E·Session 변경을 연결하므로 공통 연결은 통합 담당 한 세션이 소유한다.

## 기능 동작

- 탐색 중 가까운 빈 칸/건물을 바라보면 `E · 여기 짓기` 또는 `E · 건물 보기`를 표시한다. 벽 뒤·먼 대상에는 반응하지 않는다. 거리 기본값 4m를 조절 가능하게 두고 거리 기준은 대상 표면/칸 경계로 한다.
- E는 해당 칸을 선택한 조작 화면만 연다. 자원 소모·건설·철거·턴 진행은 명시적인 버튼으로 실행한다. 기존 중앙 단말기는 전체 기지 개요 진입점으로 유지한다.
- 건물 앞에서는 해당 시설의 이름·역할·효과·허용 행동을 표시한다. 고정 거주실 철거 등 기존 금지 행동은 막는다. 탐색 재개 시 기존 captured/drag/잠금 실패 처리를 유지한다.
- 단말기 기본 화면은 자원 영역 + 격자보드 + 선택 시설 카드 + 주 행동 버튼으로 구성한다. 1280×800과 960×600에서 격자와 자원 개요를 함께 볼 수 있게 한다. 좁은 화면에서는 보조 영역을 접거나 스크롤한다.
- 그래프는 전력·산소·식량의 현재/상한 막대와 배치 후 예상 변화로 한정한다. 현재와 예상을 라벨·외곽선 등으로 구분하며 색만 사용하지 않는다. 시간 추이 그래프는 이번 범위 밖이다.
- 기본 카드 문구는 이름, 한 문장 역할, 아이콘과 효과, 비용, 행동 중심으로 축약한다. 자세한 수식·긴 설명은 펼치는 도움말에 보존한다. 안전/불가 사유·확정/예상 구분을 숨기지 않는다. 실제 아동 사용성 검증 완료라고 주장하지 않는다.

## 세션 분배와 파일 소유권

본인 dyhan0528가 여러 세션을 운영한다. 한 작업 폴더에서 여러 세션이 branch 전환하지 않는다. 각 이슈는 별도 worktree/작업 폴더와 브랜치에서 최신 main을 기준으로 시작한다. 기존 SUBMISSION.md 등 사용자의 미커밋 변경을 보존한다.

| 작업 | 담당 | 독점 수정 영역 | 착수/의존성 |
| --- | --- | --- | --- |
| OPS-A 현장 대상 감지 | 본인 세션 A | 새 scripts/world/site_interaction.gd, station.gd의 대상 메타데이터/조회만, 전용 검사 | 즉시 가능; mission/player/HUD/terminal 수정 금지 |
| OPS-B 단말기 화면·선택 API | 본인 세션 B | scripts/ui/terminal.gd, scenes/ui/terminal.tscn, 전용 검사 | 즉시 가능; C/D 미완료 시 계약 데이터·임시 영역으로 독립 구현 |
| OPS-C 자원 그래프 | 본인 세션 C | 새 scripts/ui/resource_overview.gd, 전용 아이콘 assets/ui/operations/resources/, 전용 검사 | 즉시 가능; 기존 resource_meter는 읽기/재사용만 |
| OPS-D 어린이용 시설 카드 | 팀원 jsjavsj | 새 scripts/ui/facility_info_card.gd, assets/ui/operations/facilities/, 전용 검사 | 즉시 가능; #39 코드 claim은 PR42 병합으로 반환, 사용자 인수는 별도 유지 |
| OPS-E 연결·최소 검증 | 본인 통합 세션 | scripts/world/mission.gd, scripts/ui/hud.gd, scenes/world/mission.tscn(필요 시), 최종 문서 | 준비는 병렬 가능; 제품 연결은 A/B/C/D 인계 후 |

동시 독립 구현 4개(본인 3개 + 팀원 1개). 통합 E는 준비만 병렬이며 최종 연결은 순차다. B가 C/D를 장착하는 terminal.gd 최종 수정은 B 종료·소유권 반환 후 E가 맡는다. E가 병렬 단계에서 terminal.gd를 수정하지 않는다. 공통 시뮬레이션·player.gd·avatar_visual.gd·project.godot·UI 공통 스타일 수정은 기본 범위 밖이다. 필요하면 통합 이슈에 변경 제안을 남긴 뒤 소유권을 조정한다.

## 연결 계약 v1

아래는 구현해야 할 계약이며 현재 존재하는 API라고 가정하지 않는다. 각 작업은 class_name 전역 등록 대신 스크립트 preload 사용을 기본으로 한다. API 변경은 통합 이슈에서 합의하고 이 문서와 모든 의존 작업에 반영한다.

### A → E: 대상 조회

SiteInteraction은 Node3D로 별도 장착한다. `configure(station: Node3D)`와 `resolve_target(camera: Camera3D, max_distance: float = 4.0) -> Dictionary` 제공. 반환은 `{kind: "none"|"console"|"slot", slot_id: int, prompt: String}`이며 none/console은 slot_id=-1, slot은 0..Rules.SLOT_COUNT-1. 사용 입력과 UI 열기는 E만 담당한다. 가림/거리 판정, 건물 표면과 빈 칸 감지, 겹치는 대상의 가장 가까운 유효 선택은 A 책임. 빈 칸 감지를 위해 플레이어 이동을 막는 새 충돌체를 추가하지 않는다. 기존 station 충돌·선택 표시·시설 재생성 후에도 조회가 유효해야 한다.

### B → E: 선택과 실행 분리

Terminal에 `open_context(slot_id: int = -1) -> void` 제공. E가 먼저 기존 refresh(session)을 호출한 뒤 open_context를 호출한다. -1은 전체 개요, 유효 ID는 해당 칸 선택. 잘못된 ID는 선택 해제한다. open_context는 edited/advanced/rewound를 발생시키지 않는다. 기존 edited(action, slot_id, kind), cancelled, advanced, rewound, closed 등 신호를 보존한다. B는 보드의 선택과 명시적 건설 버튼을 분리하고 기존 즉시 건설 경로도 정리한다. 실제 상태 변경은 기존 mission/Session 경로만 사용한다.

### C/D → B/E: 독립 Control 컴포넌트

두 컴포넌트는 `set_view_model(data: Dictionary) -> void`를 제공한다. 최소 폭 280px, 가변 높이/컨테이너 레이아웃을 사용하며 자식 데이터의 누락에 안전한 빈 상태를 제공한다. Session/mission 직접 접근, 입력 E 처리, simulation 변경은 금지한다. 테스트용 고정 데이터는 제품 경로에 남기지 않는다.

ResourceOverview 데이터: `{resources: [{id: "energy"|"oxygen"|"food", label: String, current: float, capacity: float, preview: float, preview_capacity: float}], show_preview: bool}`. 현재와 예상은 서로 다른 용량으로 비율을 계산한다. 전력은 실제 energy_cap, 산소/식량은 기존 100. 수치가 범위를 넘으면 수치는 보존하고 막대만 0..1 제한. 잘못된 상한은 빈 막대/확인 불가. 표시용 데이터 변환은 E가 terminal 안에 연결하며 C는 규칙을 재계산하지 않는다.

FacilityInfoCard 데이터: `{slot_id: int, kind: String, title: String, summary: String, cost_text: String, effects: [{icon_id: String, label: String, value_text: String}], details: String, actions: [{id: String, label: String, enabled: bool, reason: String}]}`. 신호 `action_requested(action_id: String)` 제공. 허용 id는 place/remove/inspect이며 확정 실행은 B/E가 현재 선택·상태를 재검사한 후 기존 신호로 연결한다. disabled는 클릭을 막고 짧은 불가 사유를 표시한다. 긴 설명 펼침은 카드 내부 상태로 처리한다. 아이콘은 로컬 벡터/도형 등을 활용하고 글꼴에 따라 사라지는 이모지에 의존하지 않는다.

## 최소 확인 및 완료 기준

광범위한 전체 회귀 반복은 이번 범위에 강제하지 않는다. 각 구현자는 import/스크립트 오류 확인과 본인 기능의 핵심 확인 결과를 남긴다. 확인한 source SHA·환경·결과·미실행을 구분한다.

- A: 빈 칸/건물 대상 선택, 거리 밖/벽 뒤 차단, 기존 중앙 단말기 접근.
- B: open_context만으로 건설/자원 소모 없음, 명시적 행동만 실행, 두 해상도 기본 화면 잘림 확인.
- C: 현재10/20·예상10/40 구분, 0/상한, 미확정 예상 및 상태 비변형.
- D: 빈 칸/시설 카드, 비활성 행동, 도움말 접기/펼치기, 짧은 문구·아이콘 표시.
- E: 현장 E → 선택 → 건설 → 턴 진행 → 되감기 → 닫기/탐색 재개 한 흐름. 기존 중앙 단말기·고정 거주실 제한·마우스 재개도 확인. 실패한 핵심 동작은 미완료로 남긴다.

실제 Native/Web/iframe을 확인하지 않았다면 명시하며 자동 검사로 대체 PASS 처리하지 않는다. #26~29 및 #38/#39의 기존 미완료 인수는 이번 명세 작성으로 닫지 않는다. 목표는 작업 착수 후 약 2시간 내 기능 통합이며 보장이 아니다. 파일 분리/연결 규격 확정 10분, 병렬 구현 45~70분, 통합·핵심 확인 20~30분을 계획 여유로 사용한다.

## 세션 인계 절차

1. 이슈에 세션 식별명, 기준 SHA, 전용 브랜치/worktree, 실제 수정 파일 claim 기록. ready를 자동으로 in-progress로 바꾸지 않는다.
2. 본인 소유 파일만 구현한다. WORK.md/README/이 명세 같은 공용 문서는 각 세션이 동시에 편집하지 않고 이슈 본문/PR에 인계하며 E가 모은다.
3. main 대상 PR에 Refs 이슈번호, 제공 API, source SHA, 실행 확인, 미실행, 연결 예시를 기록한다. 미완료 최종 인수는 자동 close하지 않는다.
4. 최신 main 재확인 후 일반 merge. B 종료 시 terminal 소유권을 E로 반환. E가 A/B/C/D 실제 결과를 연결하고 최소 확인 후 문서·이슈 상태를 갱신한다.
5. 이 문서/이슈 게시 자체는 구현 시작·완료를 뜻하지 않는다. PPT·영상 작업을 생성하거나 착수하지 않는다.

## 게시 이슈

OPS-A: #43 https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/43
OPS-B: #44 https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/44
OPS-C: #45 https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/45
OPS-D: #46 https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/46
OPS-E: #47 https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/47

A/B/C는 아래 PR로 구현·검사·main 통합 완료. D도 PR #53 병합·API 인계를 완료했다. #43~#46은 CLOSED이며 #47은 ready, 최종 제품 연결이 남아 있다. 아래 최초 착수/배정 규칙과 현재 구현 상태를 구분한다.

## A/B/C 구현 인계 — 2026-11-15

검사 제품 main: `7342e58d317e2f5df1671086c17345e0e4a5ce90`. 이후 이 문서 PR은 제품 변경 없음.

| 작업 | 병합 PR / source | 확인 결과 | 인계 상태 |
| --- | --- | --- | --- |
| A #43 | PR #50 / 802caca554f6e16e2143ced032cba3b5d51493b2 | 대상 조회14/0, 기존 navigation70/0, import0 | SiteInteraction.configure/resolve_target 제공; E 입력·HUD는 #47 |
| B #44 | PR #51 / 42290c69c6fe49530b67bb9cd9513116c68e4819, 테스트 보강17d62c145b2bcdee77c82d35a6296ad4d7acf9b0 | core90+preview635+신규28=753/0, world_ui544/0, 실제 렌더28/0 | open_context 선택만 수행; 명시적 건설 버튼. terminal.gd 소유권 #47로 반환 |
| C #45 | PR #49 / ad24715be15e3a1676ee38334a3869830279ab76 | 전용38/0, 실제 렌더40/0, import0 | ResourceOverview.set_view_model 제공; 단말기 장착은 #47 |

root는 A/B/C 코드와 B의1280×800/960×600, C의840/280 PNG를 확인했다. 병합 제품7342e58에서 import0 및 A14+C38+B28=80개 핵심 확인을 재실행해 모두 통과했다. 독립 branch 검사와 병합본 검사를 구분하며 합산 횟수를 독립 기능 수로 주장하지 않는다.

- A 빈 칸 대상은 패드 표면을 내려다보아 조준한다. 건물은 충돌 표면까지4m, 벽 뒤/거리 밖은 none. player.camera를 resolve_target에 전달한다.
- B 연결 순서: refresh(session) → open_context(slot_id). -1은 전체 개요. 칸 클릭은 선택만 하며 ‘여기에 짓기’가 실제 draft를 만든다. 기존 edited 등 신호 유지. 960 화면에서 보드25칸·자원·건설 버튼은 보이고 아래 턴/보조 조작은 스크롤한다.
- C 최소폭280, 폭840 이상 가로3열·그 미만 세로. 현 단말기는 아직 기존 ResourceMeter를 사용하므로 새 그래프가 제품 화면에 장착됐다고 보고하지 않는다.
- D 시설 카드의 구현을 대신하지 않았다. #47이 실제 Session에서 view model을 만들고 C/D를 장착해야 한다. C 장착 이후 화면 높이는 재확인한다.
- 실제 Native/Web/iframe 사용자 조작 및 현장 E 최종 흐름은 이번 검사에 포함하지 않았다. #43~#45는 구현·전용 검사·main 병합·API 인계 범위를 완료해 사용자 요청으로 CLOSED 처리했다. 미완료 최종 연결·사용자 인수는 OPEN인 #47에서 추적한다. #46도 PR #53 구현 인계 완료로 CLOSED 처리했다. 기존 #26~29/#38/#39 인수와 #7 보류를 유지한다.
- 각 구현 worktree와 브랜치를 보존한다. 사용자 SUBMISSION.md 미커밋 변경은 건드리지 않았다. PPT/영상은 작업하지 않았다.
## D 인계 확인 및 현재 남은 작업

PR #53 MERGED, source `e2dd07d7169af5b7621e34d2b7374fee2dfddd53`, merge `617a48791ef160449921bc885bb92be6fb25fa18`. 팀원 Windows/Godot4.7.2 전용232/0 및 독립 재검사232/0, 렌더244/0(동일 검사+12PNG), 280/360/520폭 기록을 PR에서 확인했다. 이는 팀원 기록이며 root 재실행으로 주장하지 않는다. FacilityInfoCard.set_view_model 및 action_requested API·로컬 SVG7개가 main에 존재하고 독립 구현 인수를 충족해 #46 종료.

A~D 구현 이슈는 모두 CLOSED. 아래는 OPS-E 착수 전 인계 기록이다. 현재 구현 결과는 문서 끝 OPS-E 연결 절을 따른다. 당시 남은 구현은 #47: SiteInteraction→mission E/HUD 연결, Terminal.open_context 진입, 실제 Session 기반 자원/시설 카드 데이터 공급 및 장착, action 재검사와 최종 흐름 확인이다. 미착수이며 외부 구현 대기는 해소되었다. 코드 대조에서 mission의 SiteInteraction 및 terminal의 ResourceOverview/FacilityInfoCard 장착은 아직 없다.

기존 #38/#39는 수정 PR40/42 병합 완료·사용자 확인 대기, #26~#29는 남은 실제 조작/환경별 인수를 유지한다. #7 제출은 보류. 문서 검토·이슈 정리로 이 항목들을 PASS 처리하지 않는다.## OPS-E 연결 구현 — 사용자 확인 대기

현장 대상 조회를 mission의 E 입력/HUD에 연결했다. 매 E 입력에서 대상을 다시 조회해 지난 프레임의 오래된 대상이나 벽 뒤 대상을 열지 않는다. 빈 칸/건물은 해당 칸, 중앙 단말기는 전체 개요로 진입한다. open_context는 선택만 수행한다.

단말기에 ResourceOverview와 FacilityInfoCard를 실제 장착했다. Session의 확정/미확정 배치를 읽어 현재·예상 용량을 분리 표시하고, 선택한 실제 시설 또는 건설 후보의 역할·비용·효과·행동 가능 여부를 공급한다. 카드 요청은 terminal에서 재검사한 뒤 기존 Session 명령으로 실행한다. 거주실 철거·점유 칸 중복 건설을 막는다. 긴 설명은 카드 상세에 보존한다.

확인: Godot4.7.2 import0. 핵심 통합32, core90, 기존 단말기28, 마우스23, 입력20, UI38 = headless231/0. 실제 OpenGL 통합32/0 및1280×800/960×600 PNG 검토. tests/mouse_modes는 가짜 sees_console 대신 실제 카메라 조준으로 갱신하고 대체된 실제 플레이어 충돌을 probe 위치에서 치웠다. play_ui_integration은 새 그래프의 현재 수치/막대를 확인하도록 갱신했다.

통합 검사는 실제 Session/세계 충돌을 사용하지만 합성 입력이다. 현장 E→카드 건설/철거→턴→되감기→pause/캡처 재개, 중앙 단말기 및 고정 거주실을 확인했다. 실제 사용자 Native/Web/iframe 조작은 아직 미실행. 960×600에서는 하단 카드 행동·턴 조작에 스크롤이 필요하다. #47은 구현 통합 완료·사용자 최종 확인 대기로 OPEN 유지한다. 기존 미완료 환경/플레이 이슈와 제출 보류는 그대로다.
