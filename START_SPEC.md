# 바로 구현할 시작 계약 — 게임 규칙 v0.1

대상: 달기지 리와인드, Blender + Godot/GDScript 1인칭 3D·웹. 작성 기준 2026-11-14 Asia/Seoul.
**이 문서는 구현할 규칙을 고정한 계약이다. 게임 코드·제품 실행 검증 완료를 뜻하지 않는다. 현재 구현 준비와 claim은 WORK의 최신 실행 준비 해제 기록을 따른다.** 환경·두 PC·자료 검토·claim은 WORKFLOW 순서로 충족한다.

아래 수치는 **NASA 실측값이 아닌 교육용 게임 규칙**이다. 규칙을 바꾸면 rule_version을 올리고 산술 예제·snapshot 호환·이슈 기준을 함께 갱신한다. v0.1의 수치·배치·턴 규칙은 이전 PROJECT/SPEC의 ‘추후 확정’ 표현에 우선한다.

## 첫 구현의 완료선

HH-001은 임시 도형으로 `이동 → E로 단말기 → 시설 하나 배치 → 다음 턴 → 위치 포함 복원 → 같은 턴 비교 → Web 출력`을 연결한다. 이 단계에서 최종 5시설 GLB를 요구하지 않는다. 이후 HH-002가 전체 7턴 규칙, HH-003이 복원·비교 확장, HH-004가 시각 자산을 채운다.

Godot 일반판 4.7.2 + 동일 export templates를 실행 후보로 사용하고 실제 exe 버전을 기록한다. Compatibility·GDScript·단일스레드 Web이다. 후보 버전 표기만으로 설치를 완료 처리하지 않는다. 프로젝트 파일·preset이 생긴 후에만 WORKFLOW의 조건부 import/export 명령을 실행한다.

## 1. 공간·슬롯·입력

- 5행×5열, row/col은 각각 0~4, `slot_id = row * 5 + col`이다.
- 슬롯 바닥 중심의 Godot 좌표는 `(x,y,z)=((col-2)*6, 0, (row-2)*6)`m다. 위는 +Y, 정면/북쪽은 -Z다.
- 시설 footprint는 최대4×4m, 높이는 자산별 ASSET_BRIEF 범위다. 6m 간격의 빈 2m는 통로이며 슬롯 밖에는 건설하지 않는다.
- 시작 거주실은 slot12, 일조 우대는 slot0·4, 차폐 지형 우대는 slot0·20이다. slot0은 발전과 대피소의 자리 경쟁을 만든다.
- 일조 우대는 발전량, 차폐 우대는 대피소 건설비에만 영향을 준다. 실제 달 지형·방사선값을 표현하지 않는다.
- 단말기 위치는 `(0,0,18)`, 안전 스폰 발 위치는 `(0,0,20)`, 초기 시선은 yaw0/pitch0(-Z)이다. 시설 영역 밖의 통로와 단말기·스폰 구역은 건설 불가다.
- Player는 CharacterBody3D, 발 원점을 기준으로 캡슐 높이1.8m·반지름0.3m, Camera3D 높이1.6m를 초기값으로 사용한다. 이동3m/s, 점프·달리기는 MVP 제외, 시선 pitch는 ±80도로 제한한다. 실제 조작감은 별도 검증한다.
- WASD 이동, 마우스 시선, 2m 안의 단말기를 조준하고 E로 연다. 단말기 중 이동·시선 잠금, velocity=0, 포인터 표시. ESC는 단말기를 닫고 포인터를 해제한 pause 모드로 간다. 게임 화면 클릭 후에만 다시 capture하고 explore 모드로 간다.
- 포커스 손실도 pause·입력 해제다. 이동·대기·연출은 논리 턴을 진행하지 않는다. 단말기의 다음 턴만 계산을 확정한다.

## 2. 초기 상태와 시설

세 지속 자원은 공용 전력 E, 산소 O, 식량 F다. 모든 값은 정수 게임 단위다. 초기 `E=20, O=60, F=36`, 산소·식량 상한100, 전력 기본 상한20이다. 초기 건설 예산12토큰이며 네 번째 지속 자원이 아니다. 고정 승무원 소비는 턴당 O6/F6이다.

| 시설 | 비용 | 턴 효과 | 제한 |
| --- | --- | --- | --- |
| 거주실 | 시작 무료1개 | E6 소비, O8 생산 | slot12 고정·정확1개·이동/철거/중복 금지 |
| 발전기 | 3 | 일조slot0/4에서 E18, 다른 칸 E12 생산 | T2~3 고장 때 모두0 |
| 배터리 | 2 | 공용 E상한 +20 | 설치시 E 추가 없음, 별도 충전량 없음 |
| 재배실 | 3 | 가동 턴 E4 소비, growth+1; 3이면 F18 수확 후 growth0 | 정지 턴에는 소비·성장·수확 없음 |
| 대피소 | 차폐slot0/20에서3, 다른 칸4 | T4 대피 선택 허용 | 전력 소비 없음, 물리 차폐/활동 제약으로 표현 |

거주실 외 개수는 예산과 빈 칸으로 제한한다. 여러 재배실은 각자 growth를 가진다. 공용 E 하나만 존재하며 배터리별 충전 표시·별도 재충전 합산은 하지 않는다. E상한은 `20 + 20 * 배터리개수`다.

## 3. 배치·철거·취소

턴 시작 snapshot을 기준으로 draft를 편집한다. 예산 부족·점유 슬롯·예약 공간·플레이어 캡슐과 겹치는 설치는 거부하고 원인을 표시한다. 설치를 거부하면 상태·예산을 바꾸지 않는다.

- 이번 draft에서 새로 놓은 시설 취소: 실제 지불 비용100% 반환.
- 이전 턴에 확정한 시설 철거: `floor(actual_paid_cost / 2)` 반환. 할인 대피소도 지불 원가 기준이다.
- 확정 시설의 무료 이동은 없다. 철거 후 새로 설치하며 새 instance_id와 growth0을 부여한다.
- draft 전체 취소: 턴 시작 격자·예산·자원을 그대로 복원한다. 중간 철거·환급을 따로 합산하지 않는다.
- 배터리 제거가 확정되면 E를 새 cap로 clamp한다. draft 전체 취소 또는 과거 snapshot 복원은 당시 E를 그대로 복구한다.
- 환급·비용은 확정된 draft 상태에 한 번만 반영한다. UI 미리보기는 실제 상태를 쓰지 않는다.

## 4. 고정 사건과 선택

| 턴 | 사건 | 선택과 효과 |
| --- | --- | --- |
| T2 | 전력 고장 | T2·T3 모든 발전량0. `normal`은 농장 유지, `conserve`는 T2·T3 농장 정지(E4/농장 절약, 성장도 정지) |
| T4 | 우주날씨 경보 | `shelter`는 대피소가 있어야 가능하며 T4 모든 농장 정지. `continue` 또는 대피소 없는 상태는 safety 훈련 중단 |
| T5 | 보급 지연 | 원래 T5 예정 F12가 T7로 연기됨. T5 지급 없음, T7에 한 번 지급. 확인 버튼만 있고 추가 보상 선택 없음 |

T2와 T4의 선택은 명시적으로 골라야 다음 턴을 확정할 수 있다. 사건 없는 턴에는 별도 선택이 없다. 동일 시나리오의 사건 턴·강도는 되돌린 뒤에도 같다. 보급 지연과 고장은 교육용 가정이다. 우주날씨 경보도 현재 v0.1에서는 교육용 사건이며 실제 DONKI 기록을 수집했다고 주장하지 않는다.

## 5. 정확한 턴 처리 순서

입력은 `TurnCommand(attempt_id, turn_id, command_id, draft, event_choice)`다. command.attempt_id가 현재 시도와 다르면 늦게 도착한 이전 분기 요청을 거절하고 상태를 바꾸지 않는다. 현재 시도에서 이미 확정된 동일 turn_id/command_id는 저장된 결과만 반환한다. 그 외 command.turn_id가 현재 턴과 다르면 거절한다. 한 번 확정 중에는 버튼과 편집을 잠근다.

1. 턴 시작 snapshot에서 draft의 합법성·예산·필수 거주실을 검증한다. 불법이면 오류만 반환한다.
2. 격자·예산·시설 변경을 적용하고 배터리 제거로 줄어든 E cap를 적용한다.
3. T2 선택을 T3까지 지속할 모드로 기록하고 이번 턴 사건 상태·가동 농장을 결정한다.
4. T4 안전 조건 실패면 `failed_safety` 결과를 저장한다. E/O/F/growth 계산은 하지 않는다.
5. 발전량 G와 수요 D를 계산한다. `D = 6 + 4 * 가동농장수`, `available = E + G`다.
6. `available <= D`면 `E=max(0, available-D)`로 하고 `failed_power`를 저장한다. O/F/growth/보급은 이 턴에 적용하지 않는다.
7. 충분하면 `E=min(cap, available-D)`다. 발전 직후 cap를 먼저 적용하지 않아 당일 발전의 직접 사용을 허용한다.
8. `O=min(100,O+8-6)`를 적용한다.
9. 가동 농장별 growth+1, growth가3이면 harvest +=18 및 growth=0. 정지 농장은 그대로 둔다.
10. T7이면 아직 지급되지 않은 F12 보급을 한 번 더한다. `supply_delivered=true`로 기록한다.
11. `F=min(100,F+harvest+supply-6)`를 적용한다. O 또는 F가0 이하이면 화면은0으로 clamp하고 `failed_life_support`로 중단한다.
12. 살아 있고 T7이면 `completed`, 그 전이면 해당 턴 결과를 저장하고 다음 턴 시작 snapshot을 만든다.

초기/턴 종료의 자원이0이면 계속 진행하지 않는다. 실패는 사망 대신 훈련 중단과 원인·되돌리기 안내다. 실패 결과도 해당 turn_id로 저장하고 적용된 단계와 미적용 단계를 명시한다.

## 6. 상태·모듈 인터페이스

논리 상태는 씬 Node 참조와 분리된 값이다. JSON으로 표현 가능한 원시 값/배열/사전만 저장하고 깊은 복사한다. 위치 Vector3는 숫자3개로 직렬화한다.

- `Scenario`: scenario_id, rule_version='0.1', fixed_slots, fixed_events, source_labels.
- `GameState`: turn_id, phase, grid[25], E/O/F, budget, next_instance_id, facilities(instance_id/type/slot_id/actual_paid_cost/growth), fault_mode, event_schedule, event_applied, supply_delivered, mission_progress, player(position/yaw/pitch), input_mode.
- `Snapshot`: 턴 편집 전 GameState 전체. 규칙·시나리오 ID 포함. 이번 draft와 UI의 가변 객체를 공유하지 않는다.
- `TurnResult`: turn_id, command_id, phase, state_after, delta, causes, applied_steps, not_applied_steps. 실패와 완료를 구분한다.
- `Session`: attempt_id, current_history, previous_attempt 한 개, committed_command_ids, UI draft. 분기 무한 트리 제외.
- `validate_draft(snapshot,draft)`: 합법성·비용 오류 또는 검증된 draft 반환.
- `simulate_turn(snapshot,draft,event_choice)`: 순수 함수로 결과 계산. 프레임 시간·현재 시각·새 난수·애니메이션에 의존하지 않는다.
- `commit_turn(command)`: 중복 방지와 결과 저장만 담당하고 순수 함수를 한 번 사용한다.
- `restore_turn(turn_id)`: 아래 복원 계약 수행. `compare_turn(turn_id)`는 양쪽 결과가 존재할 때만 비교한다.

`Station`은 GameState를 읽어 slot_id→시설 wrapper를 재구성한다. Terminal의 row/col과 Station의 slot_id는 같은 매핑이다. 시각 메시가 자원 상태를 소유하지 않는다. 파일 구조는 SPEC의 계획을 따른다.

## 7. 복원·시도 비교

되돌리기는 벌점 없는 학습 기능이다. 사용자가 선택한 턴 시작 snapshot으로 복원하고 미래의 생산·소비·성장·보급·보상을 새 분기에 더하지 않는다.

1. 입력·턴 확정을 잠그고 연출을 종료한다. 현재 시도의 history를 previous_attempt 한 개로 깊은 복사한다. 기존 previous_attempt는 교체한다.
2. 선택한 snapshot의 격자·E/O/F·예산·시설 성장·원가·사건 모드/일정·보급 flag·임무·턴·instance counter를 복원한다.
3. 복원 뒤 새 attempt_id를 만들고 command 중복 방지 집합도 새 분기로 분리한다. 과거 결과를 새 보상으로 적용하지 않는다.
4. Station 메시·충돌을 동기화한 뒤 플레이어 위치·yaw/pitch를 복원한다. velocity와 눌린 키 상태는0이다.
5. 저장 위치가 복원된 충돌과 겹치면 `(0,0,20)` 안전 스폰을 사용하고 “안전한 위치로 돌아왔어요”를 표시한다. 저장 위치가 유효하면 그대로 둔다.
6. 입력 모드는 안전하게 `terminal`로 두어 포인터를 보이고 이동을 잠근다. snapshot의 이전 모드는 기록에는 보존하지만 자동 마우스 capture를 강제하지 않는다. 사용자가 닫고 클릭해야 explore로 간다.

같은 turn_id의 terminal result만 비교한다. 둘 다 완료면 “T3 완료 vs T3 완료”, 한쪽 실패면 “T3 중단 vs T3 완료”로 표시하고 미적용 단계도 알려준다. 아직 도달하지 않은 턴을 보간하지 않는다. 이전 시도가 T3에 끝났다면 T7 두 결과 비교를 만들지 않는다.

## 8. 문서 산술 검산 — 제품 테스트 아님

rules_review가 메모리 계산으로 아래 경로를 검산했다. 실제 Godot 구현·UI·웹 검증 결과가 아니다. 정상 예시는 T1 편집에 발전slot0(3), 배터리slot11(2), 재배slot13(3), 대피소slot24(4)를 설치해 예산12를 쓴다. T2 normal, T4 shelter를 선택한다.

| 턴 종료 | E | O | F | 재배 growth | 이유 |
| --- | --- | --- | --- | --- | --- |
| T1 | 28 | 62 | 30 | 1 | 20+18-10, cap40 |
| T2 | 18 | 64 | 24 | 2 | 고장 G0, 농장 유지 |
| T3 | 8 | 66 | 36 | 0 | 고장 G0, 세 번째 성장·F18 수확 |
| T4 | 20 | 68 | 30 | 0 | 대피·농장 정지, 8+18-6 |
| T5 | 28 | 70 | 24 | 1 | 보급 없음 |
| T6 | 36 | 72 | 18 | 2 | 정상 가동 |
| T7 | 40 | 74 | 42 | 0 | E는cap40, 수확18+연기보급12-소비6 |

**실패 경로:** 배터리만 빼고 같은 배치·normal 선택이면 예산2가 남고 E cap20이다. T1 E20/O62/F30/g1, T2 E10/O64/F24/g2, T3 available10=D10으로 E0·`failed_power`다. T3 O/F/growth는 적용하지 않아 O64/F24/g2 그대로다.

**되돌린 경로:** 실패 뒤 T2 시작 snapshot(E20/O62/F30/g1, budget2)으로 돌아가 `conserve`만 바꾼다.

| 턴 종료 | E | O | F | growth | 이유 |
| --- | --- | --- | --- | --- | --- |
| T2 | 14 | 64 | 24 | 1 | 농장 정지, D6 |
| T3 | 8 | 66 | 18 | 1 | 농장 정지, D6 |
| T4 | 20 | 68 | 12 | 1 | 대피·농장 정지 |
| T5 | 20 | 70 | 6 | 2 | 농장 재가동, 보급 없음 |
| T6 | 20 | 72 | 18 | 0 | 수확18 |
| T7 | 20 | 74 | 24 | 1 | 연기보급12 |

같은 T3 비교는 E0→8, O64→66, F24→18이다. 실패 시도가 O/F를 계산하지 않았다는 설명을 붙인다. same snapshot+normal 재실행은 같은 T3 실패를 재현해야 한다. 성장·수확·보급이 복원 중 복제되면 계약 위반이다.

## 9. 인수 체크와 데이터

- 슬롯25개와 단말기 칸 매핑, 거주실 고정, 비용/환급, 배터리 cap·단일 E를 검증한다.
- 정상·실패·복원 경로를 같은 값으로 재현하고 이중 클릭·반복 복원·UI 취소에서 상태 중복이 없는지 확인한다.
- 입력 잠금·ESC·포커스·안전 스폰을 GUI로 확인하고 초기 연결본을 실제 목표 브라우저에서 검증한다.
- 표시 단위는 게임 자원이며 kWh·실제 피폭량·실제7일로 표시하지 않는다. 재배 성장3턴도 현실 재배 기간이 아니다.
- v0.1 사건은 교육용이다. DONKI를 수집하기 전 “NASA 실제 경보 데이터” 배지를 붙이지 않는다. 실제 자료를 쓰면 원문 URL·관측시각·필드·가공·사용 조건을 기록한다.
- 공식 출처 후보: [DONKI](https://ccmc.gsfc.nasa.gov/tools/DONKI/), [NASA APIs](https://api.nasa.gov/), [OSDR](https://osdr.nasa.gov/bio/repo/), [CSA 식량 교육](https://www.asc-csa.gc.ca/eng/youth-educators/toolkits/food-production/). 실제 수집/라이선스 검토 미완료는 별도 준비 항목이다.

## 10. 인계와 통합

게임 상태·공유 씬·충돌 wrapper 책임은 dyhan0528/core, GLB·원본·자산 manifest 책임은 jsjavsj다. HH-004가 Godot 씬을 동시에 편집하지 않는다. 첫 플레이 가능한 통합 대상은 `feature/HH-001-core-loop`이며 모델·후속 게임 기능은 독립 검토 후 해당 브랜치를 대상으로 PR 통합하는 운영 계획이다.

이번 문서 작업은 PR 작성·merge를 실행하지 않는다. 이후 실제 source/target 커밋·충돌 책임·검증 범위를 WORK에 기록해 통합한다. main은 현재 없으며 정식 main 승격·배포·실제 제출은 마지막 별도 단계다. 지금 시작을 위해 main을 먼저 만들 필요는 없다.
