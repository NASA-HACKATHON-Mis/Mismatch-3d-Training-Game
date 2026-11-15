# 필수 NASA 자료의 게임 규칙 연결 — v0.3

2026-11-15. 우선 근거는 `문서/feed_page_03.png`의 DONKI 필수 활용 계획이다. 이전 PR #62의 수집·표시만으로 필수 활용을 완료했다고 판단한 범위를 정정한다. 이번 완료선은 **자료가 실제 선택의 비용과 결과를 바꾸고, 같은 자료로 되감으면 같은 결과를 재현하는 것**이다.

## 병렬 소유권

| 이슈 | 작업 | 독점 파일/브랜치 |
| --- | --- | --- |
| #58 | 실제 FLR·SEP·CME 수집과 내장 대체 | data/space_weather, research, 전용 검사 / fix/nasa-data |
| #63 | 관측 자료를 사용하는 교육용 사건 규칙 | simulation 5개 모듈, 전용 검사 / fix/nasa-rules |
| #64 | 자료→선택→결과의 화면 설명 | terminal/help/HUD/resource_overview/outcome, 전용 검사 / fix/nasa-ui |
| #61 | 실제 Session 연결·명세·최소 인수 | mission, 문서, 통합 검사 / fix/nasa-integration |

각 작업은 main `527db8c`에서 별도 worktree로 시작한다. 자료/규칙/화면은 동시에 편집하고 공통 연결은 인계 후 root가 병합한다. main의 SUBMISSION.md와 기존 생성 파일 변경은 보존한다.

## 데이터와 규칙

FLR/SEP/CME 각 공식 endpoint를 시작 시 한 번씩 병렬 조회한다. 시간/본문 제한과 오류 대체를 유지하고 실제 2024-05-08~13 기록을 내장한다. 자료별 최신 조회/내장/최근 기록 없음과 조회일을 구분한다. SEP/CME의 정상 빈 응답은 관측 기록 없음으로 취급하며 현재 안전을 뜻하지 않는다. 오류 시 내장 사례를 사용하면 그 사실을 표시한다. 서로 다른 관측 기간의 기록을 하나의 실제 사건으로 주장하지 않는다.

| 입력 | 교육용 훈련 규칙 | 플레이어에게 생기는 변화 |
| --- | --- | --- |
| FLR 최대 등급 A/B/C | 주의, 보호 추가전력 0 | T4 대피 또는 재배 계속 중 선택 |
| FLR 최대 등급 M | 경계, 보호 추가전력 2 | T4 대피 필수, 대피 전력 비용 |
| FLR 최대 등급 X | 높은 경보, 보호 추가전력 4 | T4 대피 필수, 더 큰 전력 비용 |
| 직접 관측을 포함한 SEP 기록 존재 | 높은 경보, 보호 추가전력 +2 | FLR 등급과 별개로 대피 필수 |
| CME 기록 존재 | 통신 장애 훈련, 답장 대기 2턴 | 도움을 일찍 요청해야 함; 없으면 기존 1턴 |

보호전력은 T4에서 대피를 선택할 때 전력 수요에 합산한다. 대피는 해당 턴 재배를 멈춘다. 대피 필수 조건에서 계속 진행하거나 대피소 없이 대피하면 안전 실패다. 주의 단계에서 계속 진행하면 재배를 이어갈 수 있다. 통신 비용은 확정 시 1E 그대로이며 현재 턴+대기 턴이7을 넘으면 신규 요청할 수 없다. 기존 대기 요청의 도착 턴은 고정된다.

FLR 등급·SEP/CME 존재는 **교육용 훈련 조건을 고르는 입력**이다. 보호전력0/2/4/+2와 답장1/2턴은 제작자가 정한 게임 규칙이다. 실제 달의 방사선량·통신 장애·전파 시간 또는 CME 도달을 계산하지 않는다. 모델 전용 SEP 기록은 직접 관측이 있는 것으로 판정하지 않는다. 숫자를 실제 피폭 단위로 표시하지 않는다.

## API와 상태

- context.records = {FLR:[], SEP:[], CME:[]}. 각 원소는 record_type/event_id/observed_at/source_url, FLR은 class_type, SEP은 instruments/evidence_type를 포함한다.
- context.sources = 자료별 mode/status/fetched_at/request_url. 기존 최상위 FLR 요약 필드는 호환용이며 규칙은 records를 읽는다.
- WeatherRules.build(context)는 mapping_version, context, alert_level, shelter_required, protection_energy, communication_delay, summary, source_ids, 대표 FLR 등급/ID 및 SEP/CME ID를 반환한다.
- Session.configure_weather(context)는 T1 초기 상태에서 한 번 적용하고 T1 snapshot도 갱신한다. 같은 자료 재호출은 멱등, 다른 자료 재설정은 거절한다. 전체 profile은 state.weather와 결과 기록에 남는다.
- Mission은 최초 탐색/턴 확정 전에 서비스 자료를 freeze하고 Session에 적용한다. 미리보기·실제 계산·되감기가 같은 profile을 사용한다. 최초 조회 중에도 내장 자료로 즉시 시작할 수 있다.
- UI의 training_profile은 엔진이 만든 profile이며 화면은 별도로 비용을 계산하지 않는다. 도움말은 대표 근거와 전체 건수를 보여 준다.

## 최소 인수

- M과 X에서 같은 배치/대피 선택의 전력 결과가 달라진다.
- 약한 FLR에서 SEP 유무가 같은 계속 진행 선택의 완료/안전 실패를 바꾼다.
- CME 유무에 따라 같은 요청의 도착 턴과 늦은 요청 허용 여부가 달라진다.
- 실제 내장 3종 자료로 정상7턴을 완료할 수 있다. 같은 profile+같은 선택의 되감기 재실행은 같은 자원/통신 결과를 만든다.
- 자료 실패/빈 응답/늦은 응답 처리를 확인한다. 라이브 조회 성공은 실제 NASA 자료 수신을 뜻하며 달 위험 예측 성공을 뜻하지 않는다.
- 고정 행동이 두 해상도에서 보이며 경보/비용/답장 안내가 엔진과 일치한다.

RadLab은 강력 추천, CSA/OSDR은 추천, Mars Trek은 선택이다. 이 수정은 필수 DONKI 연결을 먼저 완료한다. 전체 데이터 후보를 사용한 것으로 보고하지 않는다. PPT·영상·제출 작업은 포함하지 않는다.

## 실제 확인 결과 — 2026-11-15

검사 제품 SHA: `4ec6b79da8594407167d4e8d1c3d9f8865096dfa` (이후 문서 변경만 추가).

| 검사 | 결과 |
| --- | --- |
| Godot 4.7.2 import | 종료0, 스크립트 오류 없음 |
| NASA 자료 정규화·오류·대체·동결 | nasa_data57/0 |
| 자료별 게임 결과·빈 SEP/CME·모델 제외·최대등급·복원 | weather_rules105/0 |
| 실제 내장3종→Mission→7턴→통신→대피비용→되감기 | nasa_integration34/0 |
| NASA 인과 표시 및 자료별 출처 | nasa_ui48/0 |
| 기존 통신 연결·규칙·예상·현장E·안내 | feed_integration23/0, core_contract90/0, turn_preview635/0, operations_integration34/0, learning_ui15/0 |
| 통합 핵심 합계 | headless1041/0 |
| 실제 OpenGL 960×600/1280×800 | nasa_integration34/0+nasa_ui48/0=82/0, PNG 직접 확인 |
| 실제 NASA API/Godot | FLR14/SEP0/CME90 모두live. SEP0을 보관폭풍으로 바꾸지 않음 |
| 독립 검토 | 자료 원문3개 SHA와 metadata일치, 정규화→엔진 및 freeze→snapshot→UI/restore 계약 확인 |

실제 내장자료 최대FLR은 X5.8(`2024-05-11T01:10:00-FLR-001`), 대표 SEP는 `2024-05-13T18:07:00-SEP-002`, CME는 `2024-05-13T09:12:00-CME-001`이다. 이 입력은 보호전력6·답장2턴을 선택한다. 실제 Mission에서 T1 질문→T3답장, T4 대피 비용6으로 E13, 동일 T4 되감기 후 E13 재현, T7 E37/O74/F42 완료를 확인했다. 자료별 다른 조건에서 결과가 달라지는 검사는 weather_rules에 있다.

로그·이미지는 검사 worktree의 `logs/`에 있으며 Git 추적에서 제외한다. 실제 사용자 조작·브라우저 CORS/iframe 인수는 #29에 남긴다. 이번 수정은 Native Godot 자료 조회와 통합 게임 코드 확인이며 기존 Web 출력/서버는 갱신하지 않았다. 최종 main과 이슈 종료 상태는 연결 PR을 따른다.
