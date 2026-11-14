# 달기지 리와인드

**현재는 문서와 이슈를 준비한 단계입니다. 아직 `project.godot`, 게임 코드, Blender 모델, 실행 가능한 웹 빌드가 없습니다.**

작은 달 기지를 1인칭으로 탐색하고 단말기에서 시설을 지은 뒤, 같은 사건을 되돌려 다른 설계의 결과를 비교하는 7턴 교육 게임을 만듭니다. 총 작업 시간은 24시간입니다.

## 지금 내 담당 시작하기

- **dyhan0528 — 게임 구현:** [본인 시작 절차](WORKFLOW.md#본인-dyhan0528) → [시작 명세](START_SPEC.md). 첫 결과물은 임시 도형의 이동·배치·한 턴·복원·비교·웹 연결본입니다.
- **jsjavsj — 모델링:** [팀원 모델링 절차](WORKFLOW.md#팀원-jsjavsj) → [자산 제작 규격](ASSET_BRIEF.md). 첫 결과물은 규격을 검증할 발전기 GLB 한 개입니다.
- **새 AI 채팅:** [담당별 붙여 넣을 요청문](WORKFLOW.md#새-ai-채팅에-붙일-요청문)을 사용합니다. AI가 문서·현재 이슈·환경을 대조하고 다음 행동을 안내합니다.

두 사람은 **각자 자기 컴퓨터에서** 환경 증거를 확인합니다. 상대 PC의 검사를 완료로 대신 기록하지 않습니다. 현재 이슈가 blocked인 이유와 해제 순서는 워크플로에 있습니다.

| 문서 | 용도 |
| --- | --- |
| [WORKFLOW](WORKFLOW.md) | 오늘 할 일, PowerShell 준비 명령, 역할별 순서와 인계 |
| [START_SPEC](START_SPEC.md) | 게임 규칙 v0.1, 상태·턴·복원 계약, 문서 산술 예제 |
| [ASSET_BRIEF](ASSET_BRIEF.md) | Blender 크기·피벗·GLB·폴더·인계 규격 |
| [PROJECT](PROJECT.md) / [SPEC](SPEC.md) | 기획 배경과 전체 기술 구조 |
| [WORK](WORK.md) | 실제 승인·검사·커밋·막힌 점 기록 |
| [SUBMISSION](SUBMISSION.md) | 제출 준비와 실제 접수 증거 구분 |

[공유 작업판](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues): #1 핵심 연결본 → #2 규칙 / #3 복원 / #4 모델 / #5 설명 → #6 독립 검증 → #7 제출 자료.

현재 기본 브랜치는 `docs/mission-spec-v2`이고 `main`은 아직 없습니다. 제품은 이슈별 `feature/HH-*` 브랜치에서 만듭니다. 이 문서를 실행 파일로 오인하거나 docs 브랜치에 제품 소스를 바로 작성하지 않습니다.
