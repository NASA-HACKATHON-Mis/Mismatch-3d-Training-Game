# 달기지 리와인드 발표 자료

2026-11-15. Mismatch 팀의 한국어 발표용 7장(표지 포함), 약 3~5분 구성입니다. 각 장의 발표자 노트에 한국어 설명, 영문 요약, 출처를 넣었습니다. 실제 제출·공개 배포 완료를 뜻하지 않습니다.

## 발표 파일 열기

- [저장된 발표 자료](page://page_9e457a7f503c8191b880e1686caf1818)
- Page ID: `page_9e457a7f503c8191b880e1686caf1818`
- Artifact reference: `artifact_external_0cf93c24-cf66-49a9-9001-f7c612fe9d30`
- ChatGPT/Codex 발표 뷰어에서 `.pptx`로 다운로드할 수 있습니다. 이 참조는 소유 계정의 저장된 덱이며 공개 심사용 URL이 아닙니다.

## 7장 구성

| 장 | 제목 | 설명 요점 |
| --- | --- | --- |
| 1 | 달기지 리와인드 | 직접 짓고 되감아 다른 선택의 결과를 배우는 1인칭 게임 |
| 2 | 기지를 운영하며 선택의 대가를 배워요 | 7~12세 설계 대상, 건설·7턴 운영·되감기 비교 |
| 3 | 현장에서는 건설하고, 지도에서는 현황을 봐요 | 현장 전용 설치·철거, 어디서나 4로 여는 5×5 읽기 전용 지도 |
| 4 | 전력·산소·식량은 서로 연결돼요 | 시설 비용과 효과, 예산12, 절전과 식량의 상충 |
| 5 | NASA 기록이 경보와 선택 비용을 바꿔요 | FLR·SEP·CME를 보호 전력·대피 필요·답장 대기에 연결 |
| 6 | 같은 턴을 되감으면 선택의 차이가 보여요 | 실제 회귀 예시 T3: E0/O64/F24와 E8/O66/F18 비교 |
| 7 | 로컬에서 직접 실행하는 훈련 프로토타입 | RUN_GAME.cmd 자동 설치·실행, 1/2/3/4/Esc, 구현·미검증 구분 |

## 근거 및 표현 범위

- 우선 기획 자료: 작업 공간 `문서/feed_page_01~04.png`. feed_page_02의 표지 포함 7장 이내 구성을 따릅니다. 이 이미지를 최신 공식 행사 규정으로 재확인했다고 주장하지 않습니다.
- 현재 구현: [NASA 게임 연결 명세](../NASA_GAMEPLAY_FIX.md), [현장 조작 명세](../URGENT_FIELD_INTERACTION.md), [게임 규칙](../../START_SPEC.md).
- NASA 실제 원문: [CCMC DONKI](https://ccmc.gsfc.nasa.gov/tools/DONKI/), [DONKI 기록 조회](https://kauai.ccmc.gsfc.nasa.gov/DONKI/), 저장소 `research/nasa-2024-05/` 원문과 metadata.
- 교육용 변환: FLR A/B/C→추가전력0, M→2, X→4. 직접 관측 SEP 존재는 대피 필수 및 +2. CME 기록 존재는 답장2턴, 없으면1턴. 수치는 실제 달 피폭·통신 시간을 예측하지 않습니다.
- 실제 보관 사례: X5.8 FLR `2024-05-11T01:10:00-FLR-001`, SEP `2024-05-13T18:07:00-SEP-002`, CME `2024-05-13T09:12:00-CME-001`. 자료별 서로 다른 기록을 한 사건의 인과관계로 단정하지 않습니다.
- 되감기 예시: `scripts/simulation/tests/rewind_ui.gd`의 배터리 없는 배치, T2 재배 유지/절전, 같은 T3 비교. 전력+8/산소+2/식량-6을 확인한 게임 단위입니다. 이 예시에는 조언 요청이 없습니다.
- CSA 식량 설명: [Growing healthy food in space and remote areas](https://www.asc-csa.gc.ca/eng/sciences/food-production/growing-healthy-food-in-space-and-remote-areas.asp).
- 시설·로봇 자산: [자산 목록](../../assets/ASSET_MANIFEST.md)의 팀 제작. 글꼴 Noto Sans KR은 [SIL OFL](../../resources/fonts/OFL.txt). NASA·CSA의 보증이나 인증으로 표현하지 않습니다.
- AI 사용: Codex가 기획 정리, 코드·문서 작성과 검사를 보조했습니다. 확인되지 않은 모델 제작 도구 사용은 추측하지 않았습니다.

## 화면과 확인 기록

- 표지: 실제 Godot 1인칭 장면, avatar 커밋 `4ca6b27`의 `logs/fix-player/1280x800-front.png`.
- 현장 편집: 실제 통합 렌더 `07b6361`, `fix-urgent-integration/logs/ops-e/edit-1280x800.png`.
- 새 지도: `fix-playtest-ui/logs/map/grid-1280x800.png`. 부모 통합 담당자가 지도/Esc72/0 및 NASA36/0을 확인한 버전입니다.
- 자동 설치: launcher 커밋 `044de24`의 실제 설치/실행 확인을 받아 안내에 반영했습니다.
- 저장된 덱은 1280×720, 7장입니다. 텍스트와 표는 편집 가능합니다. 모든 장을 실제 PNG로 렌더해 글자·표·사진 배치·잘림을 검토했고, 최신 지도와 실행 안내를 반영한 3·7장을 재렌더했습니다.
- 이 검토는 저장된 Spaces 덱의 렌더 확인입니다. PowerPoint 데스크톱에서 연 검증이나 공식 제출/공유 권한 검증으로 보고하지 않습니다.

한국어 발표본과 영어 제출 본문은 구분합니다. 공개 심사 링크, 영문 제출 문안, 실제 아동 사용성 및 Web/iframe 인수는 별도 작업이며 이 덱을 만들었다는 이유로 완료 처리하지 않습니다.
