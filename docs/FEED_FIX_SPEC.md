# feed 우선 최소 픽스 명세

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
