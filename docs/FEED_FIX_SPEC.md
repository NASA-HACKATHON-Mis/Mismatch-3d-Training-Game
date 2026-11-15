# feed 우선 최소 픽스 명세

**2026-11-15 정정:** 이 문서는 PR #62의 축소 범위 구현 이력이다. 조회·표시만으로 feed_page_03의 필수 DONKI 사건 활용을 충족하지 못했으므로 #58/#61을 재개했다. 현재 추가 구현과 완료 기준은 [NASA 게임 연결 명세](NASA_GAMEPLAY_FIX.md)에 있다. 아래의 ‘피해 규칙 유지’, ‘다음 턴 답장’, ‘전체 완료’로 읽힐 수 있는 표현은 v0.2 당시 범위이며 v0.3에 우선하지 않는다. 기존 검사 통과는 빠진 요구의 충족을 뜻하지 않는다.

2026-11-15 · 기준 b189872 · 사용자 승인 범위: 데모 제외한 게이지/실제 자료/통신/화면 개선.

## 병렬 소유권

| 이슈 | 독점 파일 | 브랜치 |
| --- | --- | --- |
| #58 자료 서비스 | scripts/data/space_weather.gd, 전용 검사 | fix/feed-weather |
| #59 통신 규칙 | scripts/simulation/{scenario,simulation,snapshot_store,turn_preview}.gd, 직접 영향 검사 | fix/feed-comms |
| #60 화면 | terminal.gd, hud.gd, resource_overview.gd, 신규 UI 및 직접 영향 검사 | fix/feed-ui |
| #61 통합 | mission.gd, help.gd, 문서 및 통합 검사. 인계 후 다른 파일 수정 가능 | fix/feed-integration |

별도 worktree를 사용한다. 각 구현자는 공통 문서/Git main을 수정하지 않고 소유 범위 커밋을 인계한다. root가 검토·순차 병합·최종 확인한다. 기존 SUBMISSION.md와 생성 import 변경을 보존한다.

## 범위

- 상단 전력/생명유지(산소와 식량 위험)/차폐 준비. 차폐는 대피소 없음·준비·이번 턴 대피 선택 상태이며 가짜 방사선%를 만들지 않는다. 식량 현재/상한은 계속 확인 가능해야 한다. 물 생산/소비는 추가하지 않는다.
- DONKI 최근 FLR를 한 판 시작 전 비동기1회 조회. 8초 제한, 실패/빈 응답/잘못된 자료는 실제 내장2016 관측 대체. 조회 중에도 게임 시작 가능. 최초 탐색/턴 확정에 자료를 고정해 늦은 응답 및 되감기가 자료를 바꾸지 않는다.
- 최근 API 조회와 오늘 관측은 다르다. 관측일·조회일·원문 링크·최근 조회/내장 상태를 명시한다. SEP/CME 연결 ID만으로 해당 관측 상세를 읽었다고 표시하지 않는다. 실제 자료는 경보 설명의 참고 사례로 연결하며 기존 T4 피해 규칙은 유지한다.
- 통신 요청: 확정 전 토글/취소 가능, 턴 확정 시 저장 전력1 비용, 한 번에 대기 요청1개, 다음 턴 확정에 조언 도착. T7 신규 요청 불가. 자원 보상 없음. 게임 상담 처리 시간이며 실제 달 전파 지연과 같다고 설명하지 않는다.
- 통신 도입으로 rule_version0.2. 요청 안 하면 기존7턴 산술 결과 동일. 중복 command, 실패, 되감기, 취소에 비용/응답 중복 없음. 요청 여부를 턴 예상 계산에도 반영한다.
- 960×600/1280×800에서 건설/철거·턴 진행·필수 사건 선택은 고정 영역에 둔다. 긴 정보·상세 계산은 본문 스크롤/접기. 현장 E 조작을 HUD/안내서에 반영한다.
- 제외: 데모/PPT/영상/배포/제출, 물 규칙, RadLab/OSDR, 등급별 실제 피해량, 매판 무작위 사건. 전체 feed 문서 완전 충족으로 보고하지 않는다.

## 연결 계약

SpaceWeather: Node, updated(data), start(), freeze()->Dictionary, get_context()->Dictionary. context={mode,record_type,event_id,observed_at,fetched_at,class_type,source_url,explanation,status}; 반환은 복사본. mode live는 API 조회 성공이다.

Session: advice_requested:bool, set_advice_request(enabled)->Dictionary. command.advice_request 옵션; simulate_turn와 Preview.inspect의 다섯번째 선택 인자로 전달. state.communication={pending:{requested_turn,reply_turn},message,response_turn}; pending={}이면 대기없음.

Terminal: advice_request_changed(enabled) 신호, set_communication_state(data,requested), set_weather_context(data). mission이 실제 Session과 서비스에 연결한다. 통신/자료 서비스가 terminal을 직접 수정하지 않는다.

## 완료·검증

전용 오류 경계 검사 + 통합 요청/취소/응답/복원 흐름 + 기존 정상7턴 + 두 해상도 렌더를 확인한다. 네트워크 실제 조회 결과와 모의 실패 결과를 구분한다. 외부 브라우저 CORS/iframe/실제 아동 조작은 미실행이라면 #29에 남긴다. 구현 범위 충족·main 병합 후 #58~#61을 닫고 근거를 기록한다. 기존 #47 실제 조작 인수는 구현 완료와 별도로 판단한다.

## 2026-11-15 구현 및 확인 결과

제품 검사 기준 `9ff963923c92e4f98a7928c1bb7798043ae59155`. 별도 worktree 결과를 통합했고 마지막 변경은 통신 비용 예상 표시·훈련 중단 시 통신 문구 및 통합 회귀 검사다. 이후 문서 커밋은 제품 코드를 바꾸지 않는다.

| 확인 | 결과 |
| --- | --- |
| Godot 4.7.2 import | 종료 코드 0, 스크립트 오류 없음 |
| feed_integration | 23/0: 실제 mission 신호, 요청/취소, 비용 예상, T2 답장, 통신 중 전력 실패, 되감기, 자료 고정 |
| communication / space_weather | 43/0 + 32/0: 중복·T7·실패·응답 및 오류 자료/시간 초과/늦은 응답 대체 |
| core_contract / turn_preview | 90/0 + 635/0: 기존 7턴과 요청 없는 산술·예상 일치 |
| learning_ui / mouse_modes | 15/0 + 23/0 |
| operations_integration / feed_ui headless | 34/0 + 102/0 |
| 실제 OpenGL 렌더 | operations 34/0, feed_ui 110/0. 960×600·1280×800 화면 PNG 직접 확인 |
| 실제 NASA 연결 | 공식 API HTTP200/14건, Godot HTTPRequest live C2.8. 관측 2026-11-14T21:16Z, 조회 2026-11-15T10:32:26Z |
| 독립 코드 검토 | 서비스/통합 연결에서 중대한 결함 없음. 내부 상태 코드 한국어화, 실패 후 답장 문구 보정 |

headless 핵심 검사 합계 997/0, 실제 렌더 검사 144/0이다. 렌더 후 마지막 문구 보정은 feed_integration에서 재확인했다. UI의 큰 지도·긴 본문은 작은 화면에서 스크롤하지만 건설/철거·필수 선택·턴 진행은 고정된다. 원시 로그와 캡처는 검사 worktree의 `logs/`에 보관하며 Git 추적 대상이 아니다. 첫 learning 검사 실행의 잘못된 파일명은 실제 `learning_ui.gd`로 정정해 15/0을 확인했다.

실제 사용자 Native/Web/iframe 조작, 브라우저 CORS, 7~12세 사용성 인수는 실행하지 않았다. #29에서 기존 기능과 한 번에 확인하며 #47의 사용자 인수도 OPEN 유지한다. 기존 Web 출력·서버는 갱신하지 않았다. PPT·영상·배포·제출은 이번 완료 범위에 포함하지 않는다.
