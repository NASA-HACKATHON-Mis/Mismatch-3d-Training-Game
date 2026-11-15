# 실제 자료·출처 준비 기록

확인일: 2026-11-14 (Asia/Seoul). 작성 Worker: data_prep. 목적은 HH-005의 자료 준비이며 제품 구현·게임 검증 완료를 의미하지 않는다.

## 준비 결과

- DONKI 공식 공개 API에서 과거 태양 플레어 사건 **1개**를 실제 수집했다.
- 원문 응답은 [research/donki-sample.json](../research/donki-sample.json)에 보관했다. 필드와 숫자는 수정하지 않았다.
- [metadata](../research/donki-sample.metadata.json)에 조회 URL·시각·사건 ID·SHA256·사용 구분을 기록했다.
- CSA 원문 두 페이지와 저작권 안내를 읽고 식량 교육 카드 초안을 준비했다.
- 게임의 고장·대피·보급 지연 및 자원 수치는 START_SPEC v0.1의 교육용 모델이다. 실제 사건으로부터 계산하지 않는다.

## 1. DONKI 과거 관측 사례

공식 소개: [NASA CCMC DONKI](https://ccmc.gsfc.nasa.gov/tools/DONKI/)  
공식 API 설명: [DONKI API Reference](https://ccmc.gsfc.nasa.gov/DONKI/api/)  
공식 기계 판독 설명: [OpenAPI](https://ccmc.gsfc.nasa.gov/DONKI/api/openapi/)

API 페이지의 공개 설명 모듈에서 OpenAPI 링크를 확인했고, OpenAPI에 기록된 server와 /get/FLR 경로·날짜 매개변수를 사용했다. API 키를 요청하거나 저장하지 않았다. OpenAPI의 예제 복사가 아니라 아래 URL을 실제 GET한 응답이다.

[실제 조회 URL](https://ccmc.gsfc.nasa.gov/DONKI-API/get/FLR?startDate=2016-01-01&endDate=2016-01-02&catalog=M2M_CATALOG&class=ALL&version=Latest)

| 필드 | API 원문에서 확인한 값 |
| --- | --- |
| flrID | 2016-01-01T23:10:00-FLR-001 |
| catalog | M2M_CATALOG |
| beginTime | 2016-01-01T23:10Z |
| peakTime | 2016-01-02T00:11Z |
| endTime | 2016-01-02T01:01Z |
| classType | M2.3 |
| sourceLocation | S21W73 |
| activeRegionNum | 12473 |
| instrument | GOES-P: EXIS 1.0-8.0 |
| submissionTime | 2025-09-09T19:05Z |
| versionId | 5 |

사건의 원문 상세 링크는 API 응답의 [DONKI event 9963](https://ccmc.gsfc.nasa.gov/DONKI/view/FLR/9963/-1)이다. 별도 웹 읽기 도구에서는 상세 화면 접근에 실패했다. 따라서 위 필드는 상세 화면 교차 검증이 아니라 **공식 API 응답 직접 확인** 근거다.

Z는 UTC이다. 관측 시각과 자료의 submissionTime, 우리 프로젝트의 조회 시각은 서로 다르다. version=Latest는 조회 당시의 데이터 개정판을 뜻하며 실시간 관측을 뜻하지 않는다.

- 실제 응답 항목 수: 1
- 조회 완료 시각: 2026-11-14T15:49:09.6214612+09:00
- 원문 응답 SHA256: A2AD2A855F30AB79DAEF95CDF819F02803BE2A2FB2F219C32F3EF374DB3BF6B0
- 보관 방식: 응답 바이트를 그대로 저장한 UTF-8 JSON. 불변 스냅샷이며 자동 갱신하지 않는다.
- 원문의 linkedEvents는 관련 기록 ID다. 이 게임에서 직접 검증한 인과관계나 개인 피폭량 계산으로 사용하지 않는다.

### 사용할 교육 카드 초안

제목: **태양에서 실제로 있었던 일**

본문: “NASA의 DONKI 기록에는 2016년 1월 1일 시작된 M2.3 등급의 태양 플레어가 있어요. 우주 임무를 계획할 때는 이런 우주 날씨 기록도 살펴봐요.”

아래 표시: “과거 관측 자료 · 시작 2016-01-01 23:10 UTC · NASA CCMC / DONKI · 자료 조회 2026-11-14”

필드 표시에는 ID·시각·등급과 출처 링크를 포함한다. 게임의 T4 경보는 이 사건의 재현이 아니라 교육용 가정이라고 별도로 표시한다. 이 등급을 대피소 성능·우주인 건강·달의 실제 방사선량으로 환산하지 않는다.

## 2. DONKI 사용 조건 확인

확인한 원문:
- [DONKI Rules-of-the-Road 및 면책 설명](https://ccmc.gsfc.nasa.gov/tools/DONKI/)
- [CCMC Publications Policy](https://ccmc.gsfc.nasa.gov/publication-policy/)

DONKI는 연구·프로토타입 품질의 자료이며 운영 안전 예측으로 취급하지 않는다. 사건·검증 연구에 관한 협력 요청과 학술 출판·발표의 CCMC 감사 표기/출판 보고 요청을 확인했다. 공개 API 접근이 NASA의 제품 보증이나 승인이라는 뜻은 아니다.

이 프로젝트의 준비 범위는 출처를 붙인 작은 과거 기록과 교육용 설명이다. 모델 실행 결과를 사용하지 않았고, 학술 결과나 실제 우주인 안전 판단을 산출하지 않는다. 발표·제출 자료에는 다음 자체 작성 감사 문구를 넣는다.

“과거 우주 날씨 사례에는 NASA Goddard Space Flight Center의 Community Coordinated Modeling Center(CCMC)가 제공하는 DONKI 자료를 사용했습니다.”

NASA 로고·외부 이미지·모델 결과를 이 자료 묶음에 포함하지 않았다. 다른 자료나 상업적 활용으로 확장하면 해당 원문의 조건을 다시 검토한다.

## 3. CSA 식량 설명과 카드 초안

원문:
- [공식 교육 자료 모음](https://www.asc-csa.gc.ca/eng/youth-educators/toolkits/food-production/)
- [Growing healthy food in space and in remote areas](https://www.asc-csa.gc.ca/eng/sciences/food-production/growing-healthy-food-in-space-and-remote-areas.asp)
- [CSA Terms — Copyright / Permission to reproduce](https://www.asc-csa.gc.ca/eng/terms.asp)

원문에서 확인한 핵심은 먼 목적지일수록 보급을 자주 받기 어려워 자급 능력이 중요해진다는 점, 우주 식량에는 무게·부피·영양·보존성 조건이 있다는 점이다. 본문에 있는 개인별 열량 수치는 게임 식량 단위와 연결하지 않는다.

| 카드 | 어린이용 자체 요약 문구 | 연결할 게임 선택 |
| --- | --- | --- |
| 멀리 갈수록 스스로 준비해요 | “우주기지가 지구에서 멀어질수록 새 식량을 자주 받기 어려워져요. 가져온 식량을 아끼고 직접 기르는 방법을 함께 준비해요.” | 초기 비축·재배·보급 지연 |
| 우주 식량은 짐도 생각해요 | “우주로 가져가는 식량은 영양뿐 아니라 무게와 부피, 오래 보관할 수 있는지도 중요해요.” | 제한된 자원이라는 배경 설명 |

카드 표시는 “자료: Canadian Space Agency · 한국어 교육용 요약: 본 프로젝트 · CSA의 공식 번역이 아님”으로 한다. 이 한국어 문구는 직접 인용이 아니라 자체 요약이다. 재배 3턴·수확 18·보급 T7은 이 원문의 측정 결과가 아닌 게임 규칙이다.

CSA 안내는 정확성·출처 인정·기관 보증 오인 방지 등의 조건으로 비상업 교육/정보 목적 복제를 허용한다. 상업적 재배포는 별도 허가 조건이며, 제3자 자료는 각 권리자 조건을 따른다. CSA 로고는 별도 허가 대상이므로 포함하지 않았다. 이번에는 텍스트의 자체 요약과 출처 링크만 준비했고 사진·영상은 복제하지 않았다.

## 4. 제품에 연결할 때의 구분

| 구분 | 준비 자료 | 제품 표시 |
| --- | --- | --- |
| 실제 관측 기록 | DONKI 응답 1건 | 과거 관측·UTC·기관·원문 URL·조회일 |
| 출처가 있는 설명 | CSA 원문 자체 요약 | 기관·원문 URL·한국어 요약 표시 |
| 교육용 모델 | START_SPEC v0.1의 자원·턴·사건 | 게임용 수치·시간 압축·실제 위험 예측 아님 |

오프라인에서는 내장한 과거 자료만 보여주며 “실시간 연결됨”을 표시하지 않는다. 원문 링크를 누를 때만 네트워크가 필요하다. 원자료 갱신 시 기존 파일을 조용히 덮어쓰지 말고 새 조회 시각·해시·개정판을 남긴다.

## 5. 확인 결과와 남은 범위

- 완료: 공식 API 스키마 확인, 실제 GET·JSON 파싱·1개 사건 확인, 응답 바이트 보관·SHA256 계산, 원자료와 게임 수치 분리, CCMC/CSA 사용 안내 확인, 자체 요약 초안.
- 미완료: 독립 Verifier 최종 검사, Godot UI 적용, 실제 사용자 이해도·링크·오프라인 표시 검증.
- 별도 event 상세 웹 화면의 읽기 실패는 해결됐다고 표시하지 않는다. 원문 응답 링크 자체는 보존한다.
- 제품 소스·모델·Git 브랜치/커밋·원격 이슈는 이 Worker가 변경하지 않았다. 다른 Worker의 .gitignore/WORK/환경 변경은 건드리지 않았다.
- operation ID DATA-PREP-001: 공식 API 읽기와 지정 docs/research 파일 준비. 요청한 범위 안의 자료 준비이며 배포·제출은 수행하지 않았다.

## 6. 게임 안내서 적용

HH-005는 보관된 DONKI 응답과 metadata에서 사건 ID·등급·시작/최대/종료 UTC·개정판·조회일을 읽는다. 실제 자료 화면의 출처 버튼은 NASA 사건 상세, 처음 조회한 API 주소, CSA 원문을 연다. 화면의 CSA 설명은 프로젝트가 작성한 한국어 요약이다. 카드 표시는 오프라인에서 동작하며 출처 링크는 사용자가 눌렀을 때만 연다. 실제 관측과 게임 4턴의 경보를 명시적으로 구분한다.
