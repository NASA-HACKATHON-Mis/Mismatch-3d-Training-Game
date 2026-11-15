# 진행·결정·인계

이 파일은 새 프로젝트의 초기 진행 기록이다. 빈 양식은 완료 증거가 아니다. 과거 프로젝트의 결정을 상속하지 않는다.

| 항목 | 실제 기록 |
| --- | --- |
| 프로젝트 이름 / 확인된 절대경로 | 달기지 리와인드 (가칭) / C:\Users\USER\Desktop\나사 첼린지\Junior-Astronaut-Mission-Trainer |
| 현재 단계 / 실제 시작 시각 | 역할별 워크플로·시작 계약 v0.1 작성 및 공개 저장소 반영. 2026-11-14 KST; 24시간 제작 시작 시각 미정. |
| 시간·인원 / 역할 / 호스트·대상 | 총 24시간 사용자 지정. PM: 부모 에이전트 / 문서 준비 Worker: project_setup. Windows 호스트. 2명·대상 Windows 2대는 기존 기본값이며 명시 재확인 아님. |
| 주제·자료 / 공식 조사·한계 | DONKI 과거1건·CSA 설명/사용조건 준비 및 독립검증 완료. docs/DATA_SOURCES.md 참조. 행사 전체 규정·마감과 제품 적용은 미완료. |
| 비교·추천 / 선택·승인 | 사용자 Blender + Godot·GDScript 1인칭 3D·웹 출력 방향 승인. C+A 달 기지·24시간·균형 유지. 규칙 v0.1 고정. 본인 Godot·템플릿·신원/루트·브라우저와 실제 자료 준비 완료. 팀원 4fa7e0e 환경 증거와 #4 claim 확인 완료. 아래 최신 준비 해제 기록 참조. |
| 창의성 선호（안정적/균형/실험적/자유 설명）/ 답변 또는 명시한 가정 | 사용자 균형 선택. |
| Git 루트 / 기존 변경 / 브랜치 | 독립 루트 확인, docs/mission-spec-v2. 시작 계약 410063037ba62da61f9119b4ba8b10cbdadc9ccb를 docs 및 두 feature refs에 push·SHA 확인. 현재 docs에서 후속 기록만 변경. 제품 소스 없음. |
| 신원 확인 / 인증·권한 확인 상태（개인 값 제외） | PM 읽기 확인: gh 활성 계정 dyhan0528, 저장소 ADMIN. dyhan0528·jsjavsj 각각 admin. 조직 Owner 여부 미검증. 로컬 유효 user.name/user.email 존재, 개인 값 기록 안 함. |
| 저장소 / origin / 원격 승인 범위 | 사용자 제공 https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game.git — 최초 빈 저장소에서 현재 문서/기능 브랜치 운영 중. origin 연결·fetch 성공. 아래 최신 실행 기록에 따른 Git·docs push·MVP 이슈 범위 승인. |
| 명세 커밋 / 필요한 원격 반영 | 현재 시작 계약 410063037ba62da61f9119b4ba8b10cbdadc9ccb, START_SPEC v0.1. 원격 확인. 초기 초안80ff557과 구분. 최신 HH-001 구현 준비 해제 기록 참조. |
| 실제 이슈 URL·상태 / 담당 | #1~#7 생성·본문 대조 완료. 모두 OPEN. #1 core_loop_worker와 #4 assets_worker in-progress; #2/3/5/6/7은 선행 연결본 대기. HH-004 jsjavsj, 나머지 dyhan0528. 아래 실제 작업판 참조. |
| local-only 예외 / 승인·대체 증거 | |
| IMPLEMENTATION_READY / 증거 확인 | true (HH-001 임시 연결본 구현 시작 범위). 두 PC·계약·이슈 claim 확인. 제품 소스/제품 검증 완료를 뜻하지 않음. |
| 다음 행동 / 막힌 점 / 남은 결정 | 독립 준비 검토 후 core_loop_worker가 임시 도형 연결본을 구현·검증한다. jsjavsj 자산 작업과 경로 분리. |

## 승인 MVP 이슈 배치와 공유 작업판（START E）

제품 폴더의 사본에서 현재 승인된 MVP 전체의 작업을 실제 생성·조회한 뒤 한 행씩 기록한다. 아래 빈 양식은 생성 증거가 아니다. 일부 URL 누락/생성 실패는 배치 미완료다. local-only 예외는 승인된 유예 범위와 대체 증거를 따로 기록한다.

- 배치 승인 범위 / 명세 커밋 / 전체 작업 누락 점검 / 실제 생성·조회 결과:
- 두 사람의 책임·GitHub 계정 매핑 확인 / 미확인 담당과 다음 확인:

| 안정 ID / 실제 GitHub URL | 사람 책임자·계정 / Worker·Verifier | 상태（blocked/ready/in-progress/review/done）·조회 시각 | 인수 조건 / 선행 이슈·해제 증거 | 경로·인터페이스 책임 | 작업 브랜치·소유자 / 기준 브랜치·커밋 / 명세 커밋 | claim·시작 기록 |
| --- | --- | --- | --- | --- | --- | --- |

## 각자 복사본과 작업 시작 확인

각 사람이 자기 컴퓨터에서 확인한 실제 결과를 따로 기록한다. 다른 사람의 확인을 복사하여 완료 처리하지 않는다.

- 사람 / 컴퓨터·OS / 제품 절대경로 / 실제 Git 루트:
- 공유 origin·원격 확인 / 승인된 fetch 결과 / 명세·기준·필요한 통합 커밋 대조:
- 현재 브랜치·HEAD·dirty 상태 / 기존 변경 보호:
- 선택한 ready 이슈 / 선행 조건 충족 증거 / 경로·인터페이스 비중복 확인:
- 시작 전 실제 assignee·claim 조회 / 승인된 배정·in-progress 갱신 / 재조회 결과·시각:
- 동시 claim·충돌·미확인 사항 / 조정 결과（해결 전 시작 금지）:

GitHub의 claim 기록은 원자적 잠금이 아니다. 실제 담당과 상태가 충돌하면 담당 합의 전 시작하지 않는다. 새 작업·분담·명세 변경은 영향 코드 변경 전에 이슈와 작업판에 반영한다. 로컬 백로그나 초안만으로 원격 이슈 요건을 충족하지 않는다.

## 작업별 기록

- 안정 작업 ID / 목적·산출물 / 선행 계약:
- 사람·Worker·독립 Verifier / 이슈 ID별 feature/fix 브랜치·소유자·허용 경로:
- 기준 브랜치·커밋 / 실제 현재 브랜치·HEAD·dirty 상태 / 기존 변경 보호 방법:
- 명시적 main 직접 작업 예외（있을 때만）/ Owner 승인·대상·사유·범위:
- 허용·금지 변경 / Git·원격 승인 범위:
- 명세·구현 커밋 / 검증 snapshot（커밋+dirty diff 또는 파일 해시）:
- 검증 명령 / OS·도구 버전 / 실제 결과 / 미실행 영향:
- 인수 조건 / 검토 결과 / 실제 이슈 갱신:
- 검증 snapshot과 커밋 트리 대조 / 승인된 작업 브랜치 push·원격 확인:
- main 통합 담당·방식 / source·target 브랜치·커밋 / 로컬·원격 승인 범위:
- 통합 snapshot·독립 검증 / 필요한 main 원격 반영 / 이슈 종료 근거:
- 다음 행동 / 막힌 점:

사용자 지정 총 24시간으로 변경되었다. 미승인 배분 제안은 기획·데이터·환경 3시간, 구현 12시간, 독립 검증 5시간, 제출 4시간이다. 실제 시작 시각은 미정이다. 제출 증거는 [SUBMISSION.md](SUBMISSION.md)에 기록한다.

## 실행 요청별 기록（START D-1）

- 안정 operation ID / 시도 번호 / 정확한 명령·페이로드（비밀 제외）:
- 대상 루트·repo·브랜치·경로 / 사용자 승인 근거·범위:
- 런타임 요청 ID（제공될 때만）/ 필요한 실행 권한·실제 응답:
- 상태（unrequested/pending/delivery_error/executing/completed/cancelled/unknown）/ 관측 시각·증거:
- 오류 원문 / 성공·실패 / 실제 실행·부분 반영 확인:
- 제공되는 상태 조회 방법 / 한 번의 대기 한도·조회 횟수 / 다음 확인:
- 사용자 중단·취소 요청 / 실제 취소 관측 / 남은 부작용:
- 읽기 전용 결과 대조 / 미실행·기존 요청 종료 증거 / 재시도 가능 여부:

pending 또는 부작용 unknown 상태에서는 재시도하지 않는다. 시간 경과만으로 취소하지 않는다. 전달 실패는 거절로 추정하지 않으며, 기능이 없으면 한계를 기록한다.

## 초기 문서 준비 실행 기록

- operation ID: SETUP-001 / 시도 1 / 상태: completed (폴더 및 사본 4개 생성 성공 응답 확인).
- 사용자 승인 근거: 현재 폴더에 새 폴더 생성 요청, 총 24시간·균형 선택.
- 대상: 이 문서가 있는 Junior-Astronaut-Mission-Trainer 폴더만.
- 실행: 대상 부재 확인 후 New-Item -ItemType Directory; PROJECT.md, SPEC.md, WORK.md, SUBMISSION.md를 Copy-Item으로 복사. 기존 파일 덮어쓰기 없음.
- operation ID: SETUP-002 / 시도 1 / 상태: completed (PROJECT 및 WORK 저장 성공, 내용 읽기 확인).
- 페이로드: PROJECT.md와 WORK.md의 초기 상태·승인 범위·미확인 사항을 기록. SPEC.md와 SUBMISSION.md는 미작성 템플릿 유지.
- 금지 범위 준수: 하네스 원본 변경, 제품 소스, Git init/설정, 원격 작업, 도구 복사 없음.
- 런타임 요청 ID: 별도 제공되지 않음.

## 공식 조사와 환경 확인 인계 — 2026-11-14 초기 추천 이력

- 2026-11-14 Asia/Seoul PM이 공식 브라우저 본문·기술 문서·환경 명령 결과를 Worker project_setup에 전달했다. Worker의 직접 웹 조사로 표시하지 않는다.
- 공식 요구: 7–12세 대상, 달·화성 기지의 생명유지·방사선 차폐·전력·식량·통신지연 선택과 대가, 작동 프로토타입, 핵심 자원 2~3개 권장. 데이터 및 해석 한계는 PROJECT 참조.
- 추천은 A 달 기지 7턴 운영·되돌려 비교를 최우선으로 B 스토리 카드, C 설계 퍼즐, D 협동 대안을 포함한다. 당시 사용자 선택 없음. 이후 C+A 선택은 아래 최신 결정 참조.
- PM 환경 관측: git 2.56.0.windows.4 / gh 2.103.3 / node v24.22.1. npm --version은 현재 PATH에서 명령 인식 불가. Git init·원격·신원 점검 및 설치 미수행.
- operation ID: RESEARCH-DOC-001 / 시도 1 / 상태: completed (문서 갱신 성공 응답, 후속 읽기 및 해시 확인).
- 대상·페이로드: 기존 PROJECT/SPEC/WORK/SUBMISSION 4개 파일의 공식 확인 상태, 콘셉트·스택 후보, 환경 관측, 제출 미완료 기록만 갱신. 다른 파일 생성 없음.
- 승인 근거: 사용자의 문서 조사 후 여러 추천 요청 및 부모 PM의 동일 문서 범위 후속 패킷. 사용자 미선택 사항을 승인으로 기록하지 않음.
- 검증: 문서 내용 읽기, 이전 접근 미확인 문구의 해소, SHA256 산출. 제품 검사 미실행(제품 소스 없음). 독립 검증은 PM에게 인계.



## 독립 검증 및 문구 정정

- Verifier verify_planning의 검토 지적을 PM이 전달: 실제 NASA 데이터 활용·자료 출처 표시의 권장 사항을 의무로 표현하지 않도록 정정 필요.
- operation ID: REVIEW-FIX-001 / 시도 1 / 상태: completed (PROJECT 정정 저장 성공, WORK 기록).
- PROJECT.md의 문구를 “실제 NASA 데이터 활용 권장, 사용 자료의 출처 표시 권장”으로 정정했다. 네 문서 검색에서 같은 과도한 의무 표현은 PROJECT 한 곳에서 확인했다.
- 독립 검증의 이 지적은 반영했으며, 변경된 PROJECT/WORK의 최종 재검증은 Verifier에 요청한다. 재검증 완료로 선표시하지 않는다.
- 하네스 원본 사전 해시가 없어 원본 불변을 독립적으로 입증할 수 없다. Worker project_setup은 하네스 원본을 수정하지 않았으며, 이는 작업 수행 내역에 대한 보고다.
- 실제 데이터 수집·라이선스 검토·사용자 선택·Git/이슈·구현 준비·제출 상태는 기존 미완료/미정 구분을 유지한다.

## 2026-11-14 결정 이력 — 기획안 v1 (아래 v2로 갱신)

- 사용자 요청: “이 상태로 기획안 만들어줘, 다음에 또 뭐해야돼????”를 PM이 전달했다.
- 선택된 방향: C 기지 건설 중심 + A 시간 되돌리기, 달 기지, 24시간, 균형. 이름은 달기지 리와인드(가칭).
- 기획안 범위: 격자 건설, 시설 5종, 전력·산소·식량 3자원, 7턴 5~8분 목표, 과거 턴 복원·재설계·같은 턴 비교.
- 5×5 지도, 고정 일조·차폐 구역, 초기 고정 건설 토큰은 추천 세부 설계로 기록했다. 수치·환급·세부 처리 순서는 미확정이다.
- 승인 범위: PROJECT 기획안과 SPEC 계약 초안, WORK 결정 갱신. 스택·새 의존성·설치·Git·원격·제품 소스 승인은 포함하지 않는다.
- operation ID: PLAN-V1-001 / 시도 1 / 상태: completed (PROJECT/SPEC/WORK 문서 쓰기 성공; 후속 읽기 및 해시 확인으로 인계).
- 산출물: PROJECT.md 기획안 v1, SPEC.md 게임 상태·턴·되돌리기 계약 초안, 이 WORK.md 최신 결정. SUBMISSION.md 변경 없음.
- 다음 순서: 기술 선택 → 수치·인터페이스 및 자료 추출 → 환경·Git·사람 담당 → MVP 전체 실제 이슈·검토된 명세 커밋 → 작은 연결본 → 전체 구현·독립 검증·제출.
- 24시간 계획 제안: 기획·자료·환경 3시간 / 구현 12시간 / 독립 검증 5시간 / 제출 4시간. 실제 시작 시각 미정.
- IMPLEMENTATION_READY: 미완료. 실제 작업 이슈·명세 커밋·기술 선택·환경 준비 증거 없음. 제품 코드·Git·설치·원격 작업 수행하지 않음.
- Worker 자체 검토 범위: 결정/제안 구분, snapshot 전체 복원, 동일 사건·같은 턴 비교, 어린이 실패 표현, 교육용 모델 표시, 기존 출처·미확인 사항 보존. 제품 실행 검사는 미실행(소스 없음).
- 독립 검증: verify_planning에 새 문서 snapshot을 인계한다. 이전 문서 검증을 기획안 v1 검증 완료로 재사용하지 않는다.

## 2026-11-14 최신 결정 — 1인칭 3D v2

- 사용자 Blender 모델링·1인칭 3D 제안 후, PM의 Blender + Godot·GDScript / 웹 유지·초기 브라우저 검증 / 작은 로우폴리 달 기지 / 안내 캐릭터 하나 / 시설 5종 / 단말기 건설 / 이동 중 시간 정지 / 위치 포함 복원 / 임시 도형 우선 제안에 “알았어 해줘”로 승인했다.
- 현재 기술 방향은 승인됐다. 과거 TypeScript/Vite 추천과 스택 미선택 기록은 이력이며 현재 상태가 아니다.
- Godot 4.7.2 일반판 x86_64와 동일 export templates는 PM 공식 다운로드 페이지 확인에 따른 고정 후보다. 실제 다운로드·설치·실행 미확인. Blender 정확 버전은 공식 다운로드 조회 403으로 미확인.
- 최신 PM 환경 확인: PATH, C:\Program Files\Blender Foundation, C:\Program Files\Godot, Downloads 깊이 2, HKLM/HKCU uninstall 목록에서 관련 실행파일·설치 항목을 발견하지 못했다. 시스템 전체 미설치로 단정하지 않는다.
- 현재 git rev-parse 결과는 not a git repository. Git init·설정·원격 작업은 수행하지 않았다. 당시 저장소·팀 계정 질문 중이었다. 이후 제공·검증 결과는 아래 최신 저장소 확인 기록 참조.
- operation ID: PLAN-V2-001 / 시도 1 / 상태: completed (PROJECT/SPEC/WORK 갱신 성공, 읽기 검토·해시로 인계).
- 변경 범위는 기존 PROJECT/SPEC/WORK만. 하네스·SUBMISSION·제품 코드·모델·설치·Git·원격 변경 없음.
- 24시간 배분은 3+12+5+4 유지. 구현 12시간 내부 제안은 임시 연결본·웹 3 / 기능 5 / 모델·GLB 3 / 통합 1시간이다.
- 실제 코드·Blender 모델·웹 출력 결과는 아직 없다. IMPLEMENTATION_READY 미완료이며 작성된 기술 설계는 구현 준비 증거를 대신하지 않는다.
- v2 독립 검증은 verify_planning에 인계한다. 이전 v1 검증 결과를 v2 완료 증거로 사용하지 않는다.

## 이전 첫 프로토타입 패킷 — 새 시작 계약으로 갱신

- 로컬 계획 ID: PROTO-001 (실제 GitHub 이슈가 아님). 목적: 임시 도형의 이동→단말기 배치→한 턴→위치 포함 복원→같은 턴 비교→웹 출력 연결본.
- 결과물 계획: SPEC의 main/station/player/terminal/HUD 씬, 순수 Simulation 및 snapshot, 단일 scenario, 웹 실행 증거. 제품 파일은 아직 없다.
- 예정 허용 경로: PROJECT_ROOT 아래 scenes/, scripts/, resources/, assets/ 및 Godot 프로젝트 설정. 이는 경로 계획이며 현재 쓰기 허가가 아니다. 하네스·다른 프로젝트·개인 설정은 금지.
- 사람 담당·Worker·독립 Verifier, 실제 이슈 URL, feature/HH-001-core-loop 브랜치(기존 PROTO-001 계획을 HH-001로 매핑), 기준 브랜치/커밋·명세 커밋은 모두 준비 전이다. 초안 작성 당시 Git 저장소·브랜치·HEAD 없음. 현재 docs 브랜치·커밋 상태는 최신 승인·실행 기록 참조. 제품 소스는 없다.
- 선행 조건: 실제 도구 실행·정확 버전 확인, 수치/인터페이스 검토, 데이터 표시, Git·담당·원격 범위, 승인 MVP 전체 실제 이슈, 명세 커밋, START의 준비 증거.
- 인터페이스: 단말기 slot_id와 월드 매핑 일치, Simulation은 프레임 시간과 독립, snapshot은 플레이어 위치·시선까지 복원. 모델은 임시 도형이며 후속 GLB 교체와 충돌 분리.
- 완료 조건: 같은 선택 결과 재현, 한 턴 계산 중복 없음, 복원 자원·시설·예산·위치 일치, velocity 초기화·안전 스폰, 같은 턴 비교, 목표 브라우저 출력·포인터·입력 확인.
- 검증 명령은 실제 Godot 실행 경로/버전·export preset·로컬 서버가 확정되면 기록한다. 실행되지 않은 명령·웹 검사를 통과로 표시하지 않는다.
- 이 초안 작성 당시 Git/원격 승인 범위 미정이었다. 최신 승인·실행 기록의 Git 준비 범위가 이를 갱신한다. 제품 코드·모델·설치는 여전히 이번 작업에서 금지하며 이 초안만으로 구현하지 않는다.

## 2026-11-14 저장소 읽기 확인 — PM 전달

- 사용자 제공: https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game.git 및 “둘 다 owner”라는 추정. 주소 제공을 Git/원격 쓰기 승인으로 확대하지 않는다.
- 실제 PM 확인: gh 활성 계정 dyhan0528, repo viewerPermission ADMIN, collaborators dyhan0528 admin·jsjavsj admin. 저장소 관리 권한과 조직 Owner 지위는 다르며 조직 Owner 여부는 미검증이다.
- 저장소는 public, size 0, default_branch main. branches 빈 목록, git ls-remote 성공·빈 출력으로 현재 공개 빈 저장소임을 확인했다. 원격 main 커밋이 존재한다는 뜻은 아니다.
- 추가 PM 읽기 확인: gh issue list --state all --limit 30의 JSON 결과 [] — 기존 이슈 없음.
- 제한 환경의 gh 실패는 네트워크 제한 밖 읽기 재확인 성공으로 해소됐다. 이를 인증 실패로 남기지 않는다.
- 로컬 유효 Git user.name/user.email 존재 확인. 개인 값은 기록하지 않는다. 현재 로컬 독립 저장소·브랜치·커밋은 없으며 origin 설정도 없다.
- 사람 매핑은 dyhan0528=현재 사용자 후보, jsjavsj=팀원 후보다. 직접 확인된 사람 담당 지정은 아직 없다.

## 승인 전 요청안 이력 — 아래 승인·실행 기록으로 갱신

대상 루트: C:\Users\USER\Desktop\나사 첼린지\Junior-Astronaut-Mission-Trainer
대상 repo: NASA-HACKATHON-Mis/Mismatch-3d-Training-Game
대상 URL: https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game.git

1. 기존 문서를 보존하고 상위 저장소 없음·정확 루트를 재확인한 뒤 이 루트만 독립 git init --initial-branch=main으로 준비한다.
2. 기존 유효 Git 신원을 본인 값인지 확인해 재사용한다. .user_info는 아직 만들지 않았고 토큰을 요청하거나 저장하지 않는다. 신원 변경이 필요하면 확인된 항목만 별도 범위에 포함한다.
3. origin을 위 URL로 연결하고 승인된 fetch로 실제 원격 상태를 재확인한다. 다른 origin이나 예상 밖 이력이 나타나면 덮어쓰지 않고 재검토한다.
4. 명세 작업 브랜치 docs/mission-spec-v2에서 검토된 문서만 명시적으로 stage·commit한다. 정확 커밋을 기록하고 이 docs 브랜치를 push·원격 대조한다. 로컬 main은 최초 init의 unborn 이름일 수 있으며 명세 브랜치 첫 커밋과 원격 main 생성은 구분한다.
5. 현재 MVP 전체 실제 이슈를 create/update하고 확인된 사람 담당을 매핑한다. 아래 계획 ID는 아직 실제 이슈가 아니다. 본문에 경로·인수 조건·의존·담당 Worker/Verifier·기준/명세 커밋을 채운 뒤 조회한다.

| 계획 ID | 작업·작업 브랜치 요청안 | 선행 |
| --- | --- | --- |
| HH-001 | 임시 3D 핵심 연결본·초기 웹 / feature/HH-001-core-loop | 명세·환경·전체 이슈 준비 |
| HH-002 | 5시설·자원·사건·7턴 / feature/HH-002-simulation | HH-001 인터페이스 |
| HH-003 | 복원·같은 턴 비교 확장 / feature/HH-003-rewind | HH-001 상태 계약 |
| HH-004 | Blender GLB 자산·충돌 통합 / feature/HH-004-assets | HH-001 슬롯·웹 검증 |
| HH-005 | NASA 자료·설명·접근성 / feature/HH-005-learning-ui | HH-001 UI 계약 |
| HH-006 | 독립 통합 검증 / feature/HH-006-validation | HH-002~005 통합 가능 상태 |
| HH-007 | 제출 자료 준비 / feature/HH-007-submission | HH-006 검증 결과 |

기존 PROTO-001은 HH-001로 매핑한다. 계획 의존은 HH-001 → HH-002/003/004/005 → HH-006 → HH-007이며 세부 인터페이스 명세 후 조정한다.

6. 요청할 원격 범위는 위 repo의 MVP 이슈 create/update/close, fetch, docs/mission-spec-v2 및 위 feature 작업 브랜치 push다. 필요한 fix 브랜치는 정확 이름·대상을 패킷에 추가하여 범위를 확인한다. 이슈 close는 실제 인수 조건과 필요한 통합·검증을 충족했을 때만 한다.
7. 각 작업의 기준 브랜치·정확 기준 커밋·명세 커밋은 생성 후 검증하여 기록한다. 초기 기준 후보는 docs/mission-spec-v2의 검토된 명세 커밋이며 후속 통합 기준은 담당 합의 뒤 확정한다. 기존 원격 이력에 대한 force/reset은 포함하지 않는다.
8. main 통합·main push, 배포·호스팅·실제 제출, 저장소 공개 변경은 이 요청안에 포함하지 않고 별도 범위를 정한다.

- operation ID: REPO-READ-RECORD-001 / 시도 1 / 상태: completed (WORK 기록 저장·읽기 확인). 부작용은 이 문서 갱신뿐이다.
- 승인 전 이력 당시 위 준비안의 당시 실행 상태: unrequested. 승인·Git init·origin·커밋·이슈 생성·fetch/push를 완료로 표시하지 않는다. 독립 구현 준비는 여전히 미완료다.


## 2026-11-14 Git·원격 준비 승인 및 실행

- 사용자 “해줘” 승인으로 위 구체 준비안을 실행한다. 사람 매핑: 현재 사용자 dyhan0528, 팀원 jsjavsj 확정. 기존 유효 Git 신원 재사용 승인.
- 이번 실행 Worker project_setup. 허용: 독립 로컬 Git, origin, docs/mission-spec-v2 문서 commit/push/fetch, HH-001~007 이슈 create/update. main 통합/push·배포·설치·제품 소스·모델은 금지. 조건 미충족 이슈 close 금지.
- 루트: C:\Users\USER\Desktop\나사 첼린지\Junior-Astronaut-Mission-Trainer. repo: NASA-HACKATHON-Mis/Mismatch-3d-Training-Game. origin URL은 위 승인 URL과 동일.
- 실행 전 확인: 상위 Git 없음, 기존 4문서 존재, git ls-remote 성공 빈 출력, repo ADMIN·defaultBranchRef 빈 이름. 원격 이력 없음.
- GIT-INIT-001: completed. 정확 명령 git init --initial-branch=main (위 루트), git switch -c docs/mission-spec-v2, git remote add origin https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game.git. 단계별 성공 후 진행.
- FETCH-001: completed. git fetch origin 성공. 실제 루트·docs 브랜치·승인 origin 확인. 기존 name/email·author/committer 유효·일치 확인, 값 비공개. 별도 신원 설정·.user_info 생성 없음.
- DOC-DRAFT-001: unrequested. 독립 검토 후 PROJECT.md SPEC.md WORK.md SUBMISSION.md .gitignore만 명시 stage·기획/기술 계약 초안 commit. 준비 완료 명세로 주장하지 않음.
- ISSUE-BATCH-001: unrequested. HH-001~007 모두 blocked로 생성·조회. 현재 주사용자 dyhan0528 배정으로 준비했으나 생성 전 사용자 확정으로 HH-004는 jsjavsj로 변경.
- IMPLEMENTATION_READY=false: 도구 실행·수치 확정·두 PC 준비·작업 claim 미완료. 제품 검사 명령 미정·미실행.

- 사전 검토 snapshot: PROJECT/SPEC은 이전 v2 해시 유지. WORK와 최소 .gitignore 추가를 verify_planning이 검토한 뒤 commit한다. .gitignore에 개인 신원·Godot 캐시·환경 비밀·키·빌드 임시 제외.



- DOC-DRAFT-001 결과: Verifier가 WORK 시점 표현 정정 후 5개 파일 검토 통과. git add -- PROJECT.md SPEC.md WORK.md SUBMISSION.md .gitignore 및 git commit -m 'docs: record reviewed mission planning and technical draft' 성공. 초안 기준 커밋 80ff557316d4204ae3729bcd09068430349e92e3, 준비 완료 명세 아님.
- PUSH-DRAFT-001 completed: git push -u origin docs/mission-spec-v2 성공, git ls-remote refs/heads/docs/mission-spec-v2가 같은 SHA를 반환. GitHub defaultBranchRef가 첫 push 후 docs/mission-spec-v2로 자동 관측됨; 별도 기본 브랜치 설정 변경 없음. main 생성/push 없음.
- 최신 사용자 결정: 모델링 담당 jsjavsj 확정. HH-004 assignee·브랜치 owner는 jsjavsj, HH-001/002/003/005/006/007은 dyhan0528. 두 PC 준비와 실제 claim은 아직 미완료.
- ISSUE-BATCH-001 executing: 임시 본문 파일 HH-001.md~HH-007.md 준비. 이슈별 ISSUE-HH-00N-001 operation으로 stable ID 검색→없으면 gh issue create --repo NASA-HACKATHON-Mis/Mismatch-3d-Training-Game --title '[HH-00N] <작업명>' --body-file <TEMP/mission-issue-batch-20261114/HH-00N.md> --assignee <확정계정>→gh issue view --json url,state,assignees,body 대조. 모두 blocked, Worker/Verifier·경로·의존·인수·초안 기준 SHA 기록. 정확 실행 검사 명령은 미정·미실행.

## 이전 초안 기준 이슈 배치 결과 — 새 계약 기준은 아래 최신 실행 기록

| 안정 ID / 실제 URL | 사람 / Worker / Verifier | 상태·확인일 | 선행·해제 조건 | 책임 경로 | 브랜치·기준·초안 커밋 | claim |
| --- | --- | --- | --- | --- | --- | --- |
| HH-001 / https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/1 | dyhan0528 / core_loop_worker / verify_planning | blocked (OPEN), 2026-11-14 KST 생성·본문 조회 | 명세 초안 보완·도구/버전·전체 이슈·두 PC 준비 | scenes/main.tscn, scenes/player/, scenes/world/, scenes/ui/terminal.tscn, scenes/ui/hud.tscn, scripts/player/, scripts/world/, scripts/ui/, scripts/simulation/의 최소 인터페이스, resources/scenarios/, project.godot, export_presets.cfg | feature/HH-001-core-loop (미생성), 기준 docs/mission-spec-v2 / 80ff557316d4204ae3729bcd09068430349e92e3 (초안) | claim 없음 |
| HH-002 / https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/2 | dyhan0528 / simulation_worker / verify_planning | blocked (OPEN), 2026-11-14 KST 생성·본문 조회 | HH-001 상태/시설 인터페이스 검증과 통합 기준 확정 | scripts/simulation/simulation.gd, resources/scenarios/, scenes/facilities/의 기능 규약 | feature/HH-002-simulation (미생성), 기준 docs/mission-spec-v2 / 80ff557316d4204ae3729bcd09068430349e92e3 (초안) | claim 없음 |
| HH-003 / https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/3 | dyhan0528 / rewind_worker / verify_planning | blocked (OPEN), 2026-11-14 KST 생성·본문 조회 | HH-001 snapshot/결과 인터페이스 검증; HH-002 상태필드 계약 협의 | scripts/simulation/snapshot_store.gd, scripts/ui/compare.gd, scenes/ui/compare.tscn | feature/HH-003-rewind (미생성), 기준 docs/mission-spec-v2 / 80ff557316d4204ae3729bcd09068430349e92e3 (초안) | claim 없음 |
| HH-004 / https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/4 | jsjavsj / assets_worker / verify_planning | blocked (OPEN), 2026-11-14 KST 생성·본문 조회 | HH-001 슬롯/피벗 계약 및 초기 웹 검증 | assets/source/, assets/models/, assets/textures/, scenes/facilities/의 시각·충돌 노드 | feature/HH-004-assets (미생성), 기준 docs/mission-spec-v2 / 80ff557316d4204ae3729bcd09068430349e92e3 (초안) | claim 없음 |
| HH-005 / https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/5 | dyhan0528 / learning_ui_worker / verify_planning | blocked (OPEN), 2026-11-14 KST 생성·본문 조회 | HH-001 UI/출처 인터페이스 검증 | resources/content/, scenes/ui/help.tscn, scripts/ui/help.gd, assets/data/ | feature/HH-005-learning-ui (미생성), 기준 docs/mission-spec-v2 / 80ff557316d4204ae3729bcd09068430349e92e3 (초안) | claim 없음 |
| HH-006 / https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/6 | dyhan0528 / validation_worker / verify_planning | blocked (OPEN), 2026-11-14 KST 생성·본문 조회 | HH-002/003/004/005 결과와 실제 통합 snapshot 확보 | 검증 기록 및 tests/ (필요성 검토 뒤), WORK.md; 제품 수정은 별도 fix 범위 확인 | feature/HH-006-validation (미생성), 기준 docs/mission-spec-v2 / 80ff557316d4204ae3729bcd09068430349e92e3 (초안) | claim 없음 |
| HH-007 / https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/7 | dyhan0528 / submission_worker / verify_planning | blocked (OPEN), 2026-11-14 KST 생성·본문 조회 | HH-006 통합 검증 결과 | SUBMISSION.md 및 제출 설명·시연 자료 경로(명세 확정 후) | feature/HH-007-submission (미생성), 기준 docs/mission-spec-v2 / 80ff557316d4204ae3729bcd09068430349e92e3 (초안) | claim 없음 |

- ISSUE-HH-001-001~ISSUE-HH-007-001 completed: 각 stable ID 사전 검색 결과 없음→생성→view의 본문 전체와 assignee 대조 성공. 원격 7개 OPEN, 본문 상태 blocked. HH-004만 jsjavsj, 나머지 dyhan0528. 아직 구현/claim/close 없음.
- 이슈별 정확 기준·초안 명세 커밋은 80ff557316d4204ae3729bcd09068430349e92e3. feature 브랜치는 계획이며 현재 생성하지 않았다. WORK의 후속 기록 커밋은 이 초안 기준과 별개다.
- 임시 본문 경로가 샌드박스 호출마다 달라 HH-004 로컬 임시본문 편집 실패를 관측했다. 그 시점 원격 쓰기는 없었고, 실제 생성 실행 안에서 각 TEMP 본문을 새로 작성해 같은 호출에서 사용했다. 중복 원격 생성/재시도 없음.
- ISSUE-BATCH-001 completed, 7개 배치 생성·본문/담당 확인 성공. 문서·코드 테스트 명령은 실행 도구/수치 미확정으로 미정·미실행. Git/원격 준비 결과만 완료다.
- LOG-COMMIT-001 당시 계획(이후 55de359 커밋·push 완료): Verifier가 이 WORK 변경을 읽기 검토한 뒤 git add -- WORK.md, git commit -m 'docs: link approved repository setup and MVP issues', git push origin docs/mission-spec-v2 수행 계획. 이후 원격 SHA와 clean 상태 독립 대조.
- 다음: 도구 실제 실행/버전, 세부 수치·인터페이스·자료·두 PC 준비를 채워 명세를 확정하고 각 이슈 기준을 갱신한다. IMPLEMENTATION_READY=false 유지. main 통합/push·배포·제품 코드·모델·설치 수행 없음.



## 최신 작업: START_SPEC v0.1와 역할별 워크플로

- 사용자 명시 요청: 지금 해야 할 워크플로와 시작할 수 있는 명세를 만들어 Git에 올리기. 기존 docs·이슈 갱신 권한 재사용. 본인 dyhan0528, 모델 담당 jsjavsj.
- DOC-WORKFLOW-001 completed: README.md, WORKFLOW.md, START_SPEC.md, ASSET_BRIEF.md 작성 및 PROJECT/SPEC/WORK 정합 수정. 제품 코드·모델·설치·main 생성/통합·배포 없음.
- 재개 기준: 55de35957a7f988315f9a9c6a82f8f743362690b, docs/mission-spec-v2 clean, fetch 후 같은 원격 확인.
- START_SPEC v0.1은 사용자 위임 범위의 교육용 설계 결정이다. 5×5/수치/턴/사건/환급/복원/비교/위치/입력 계약과 정상·실패·되돌림 예제를 고정했다. 실제 NASA 측정값이 아니다.
- rules_review가 메모리 계산으로 정상 7턴 및 무배터리 실패·절전 복원 경로를 검산했다. 제품 테스트·Godot/웹 검증은 미실행이다.
- 자산 경로 소유권 갱신: jsjavsj는 assets/source, assets/models, assets/textures, assets/ASSET_MANIFEST.md만 담당. source/.gdignore는 Godot 원본 import 제외용으로 Git 추적. core dyhan0528가 Godot 씬·wrapper·충돌·공유 파일을 담당한다.
- 첫 플레이 가능 통합 대상/책임: feature/HH-001-core-loop / dyhan0528. 모델과 후속 기능은 검토 뒤 core 대상으로 PR 통합하는 운영 계획. 이번 작업에서 PR 생성·merge는 하지 않는다. main 정식 승격·배포는 이후 별도 단계다.
- DOC-CONTRACT-COMMIT-001 completed: Verifier 문서 검토 후 7개 명시 문서만 stage/commit/push. 신규 docs 시작 계약 커밋을 기준으로 아래 두 feature refs를 준비한다.
- FEATURE-REFS-001 completed: feature/HH-001-core-loop, feature/HH-004-assets가 없을 때만 새 시작 계약 커밋에서 생성·push. 기존 ref가 있으면 덮어쓰지 않고 대조한다. 제품 파일 변화 없음. docs 후속 기록 커밋과 feature 기준을 구분한다.
- ISSUE-CONTRACT-001 completed: #1~7의 새 Contract-Commit·문서 링크·구체 선행/소유권을 갱신·재조회. #1/#4 먼저, #4 jsjavsj 및 나머지 dyhan0528 유지. 정확 브랜치 존재 여부 기록.
- 현재 완료: 독립 문서 검토·산술 검산·시작 계약 push·두 작업 브랜치·7개 이슈 계약 갱신. 현재 미완료: 각 PC 도구 실행·로컬 개인 준비·자료 검토·claim·제품 구현/검증.
- IMPLEMENTATION_READY=false. 두 사람의 실제 환경 증거는 각 PC에서 확보한다. HH-004 레퍼런스/치수 준비와 모델 제작·게임 통합 gate를 구분하며 공통 준비 요건을 면제하지 않는다.

## 워크플로 공개 반영 결과 — 2026-11-14

- 독립 Verifier: 7문서 검토 통과. 지적된 개인 신원 준비 절차와 stale attempt/turn 요청 거절을 반영하고 재검토 통과했다.
- 자체 검사: WORKFLOW의 PowerShell 6블록 parser 문법 오류0, git diff --check 통과. 이는 명령 전체 실행/제품 테스트가 아니다. 실제 GitHub #1 본문으로 Contract-Commit 정규식 추출 결과1개·정확 SHA 일치 확인.
- 시작 계약 커밋: 410063037ba62da61f9119b4ba8b10cbdadc9ccb. 명령 git add -- README.md WORKFLOW.md START_SPEC.md ASSET_BRIEF.md PROJECT.md SPEC.md WORK.md 및 git commit -m 'docs: add role workflows and playable rule contract v0.1'. docs push 후 원격 SHA 일치.
- FEATURE-REFS-001: 로컬·원격 기존 ref 부재 확인 후 git branch feature/HH-001-core-loop <계약SHA>, git branch feature/HH-004-assets <계약SHA>, git push origin feature/HH-001-core-loop feature/HH-004-assets 성공. 두 원격 ref가 모두 위 계약SHA. 기존 ref 덮어쓰기 없음, docs 작업 유지.
- ISSUE-CONTRACT-001: #1~7 각각 기존 OPEN/blocked 조회→gh issue edit --body-file→본문 전체/assignee 대조 성공. Contract-Commit 행과 pinned 문서 링크 추가. #4 assets 전용 소유권·독립 준비와 통합 선행 분리. #4 jsjavsj, 나머지dyhan0528 유지.
- 원격 main ref는 없다. PR 생성·merge·main 생성/push·배포·게임 코드·모델·설치 작업 없음.

| 실제 이슈 | 사람 | 작업 브랜치 | 준비·다음 행동 |
| --- | --- | --- | --- |
| [HH-001 #1](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/1) | dyhan0528 | feature/HH-001-core-loop (실제 존재) | in-progress; dyhan0528 / core_loop_worker claim, 임시 연결본 시작 |
| [HH-002 #2](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/2) | dyhan0528 | feature/HH-002-simulation (계획) | blocked; HH-001 계약/검증 후 7턴 규칙 |
| [HH-003 #3](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/3) | dyhan0528 | feature/HH-003-rewind (계획) | blocked; HH-001 상태 계약 후 복원 확장 |
| [HH-004 #4](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/4) | jsjavsj | feature/HH-004-assets (실제 존재) | in-progress; jsjavsj / assets_worker 기존 claim 유지, 첫 GLB 제작→core import |
| [HH-005 #5](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/5) | dyhan0528 | feature/HH-005-learning-ui (계획) | blocked; 자료/사용조건 검토·UI 계약 |
| [HH-006 #6](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/6) | dyhan0528 | feature/HH-006-validation (계획) | blocked; 구현자와 다른 Verifier의 통합 검사 |
| [HH-007 #7](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/7) | dyhan0528 | feature/HH-007-submission (계획) | blocked; 검증 결과를 제출 자료로 준비 |

모든 이슈의 현재 계약/초기 기준은 410063037ba62da61f9119b4ba8b10cbdadc9ccb다. #2~7의 실제 실행 기준은 필요한 core 통합 결과가 생기면 갱신한다. 이 후속 WORK 기록 커밋은 계약을 바꾸지 않는다.

- DOC-DELIVERY-LOG-001: 이 결과 기록을 독립 검토 후 docs에 명시 commit/push하고 최종 원격 대조한다. 작업 브랜치 기준은 시작 계약에 유지한다.
- 바로 다음 행동은 README의 본인/팀원 링크다. 두 PC의 실제 환경·준비 조건·claim을 AI가 채우며 사람에게 새 기획이나 동일 정보 재입력을 요구하지 않는다. IMPLEMENTATION_READY=false, 제품 검사는 미실행이다.

## 현재 PC 환경 준비 실행 — 2026-11-14

- 사용자 실제 진행 승인에 따라 environment Worker project_setup이 준비한다. 재개 docs HEAD 1fddcc5342431cbcb5aa72a7a616ed7836bad379 clean/fetch 대조. 계약 4100630 존재, #1 OPEN/blocked·dyhan0528 확인.
- ENV-PERSONAL-001: 기존 본인 Git 신원값을 비공개 재사용하여 .user_info 생성, 예제와 Windows 점검 도구 2개를 원본 그대로 복사. 기존 파일 부재 확인, 토큰·개인값 출력 없음. .user_info/.tools/logs Git 제외.
- GODOT-PORTABLE-001 executing: 공식 GitHub godotengine/godot 4.7.2-stable API에서 일반판 win64 및 동일 export templates 자산·SHA256 확인. 프로젝트 .tools 아래 다운로드·해시 대조·압축해제, _sc_ self-contained 모드로 전역 설정 변경 없이 실행 검증할 계획.
- 게임 코드·모델·project.godot 생성은 아직 금지, IMPLEMENTATION_READY=false. 팀원은 준비 중이며 실제 두 번째 PC 증거는 없다.

## 본인 환경·자료 준비 결과 — 현재 상태

- 현재 PC readiness: 준비 완료. Godot 4.7.2.stable.official.ed1daf0bf 실제 실행, 동일4.7.2.stable export templates35개·공식SHA256 일치, 기존 Git 신원 파일/검사·독립루트·로그인 dyhan0528/ADMIN, Edge157.0.4341.46·Chrome157.0.8103.78 파일버전 확인. 상세 명령·경로·예외는 docs/ENVIRONMENT.md.
- ENV-PERSONAL-001 completed: 원본 예제/Windows 점검2파일 복사·해시일치, 본인값 .user_info 비공개 준비. 원본 CMD 경로/OS 실행정책 실패를 기록하고 절대 PS1·단일프로세스 ExecutionPolicy로 재검사 exit0. 전역 정책/신원 설정 변경 없음.
- GODOT-PORTABLE-001 completed: 공식 자산 다운로드·해시검증·.tools 압축해제·_sc_ 구성·템플릿설치. 첫 headless 실행의 전역 user-data 접근 오류 후 자식 APPDATA만 로컬로 격리해 exit0/stderr없음. 실제 제품 프로젝트/렌더링/Web 검사는 수행하지 않았다.
- .tools/logs/.user_info는 Git 제외, .git/info/exclude에도 도구/로그 추가해 다른 작업 브랜치에서도 로컬설치 노출 방지. 설치 아카이브·실행파일·개인값은 stage하지 않는다.
- 자료 준비: data_prep의 docs/DATA_SOURCES.md, research/donki-sample.json 및 metadata를 verify_planning이 독립 API/원문 대조해 통과. 과거 DONKI M2.3 플레어1개와 CSA 교육 설명·사용조건 준비. 제품 규칙과 실측 자료를 분리하며 제품 적용은 미완료.
- 팀원 jsjavsj: 사용자 응답은 “하고 있어”(준비 중). 두 번째 PC의 실제 루트/버전/브랜치/계약 증거 없음. 본인 검사결과를 대신 사용하지 않음.
- 전체 IMPLEMENTATION_READY=false의 남은 사유: 팀원 PC 증거·해당 이슈의 실제 ready/claim·시작 패킷 대조. 현재 본인의 도구 미설치나 수치 미정을 blocker로 반복하지 않는다. 모델링 통합에는 HH-001 인터페이스·core import 검증이 별도 선행한다.
- ENV-DOCS-001: 환경 결과·필요 ignore·원본 점검 사본·자료파일을 독립 검토 후 docs에 명시 commit/push한다. 제품 코드·모델은 이번 Worker 범위에서 만들지 않았다.
- ENV-ISSUES-001 completed: #1/#4를 gh issue view로 조회 후 기존 body의 낡은 본인 환경 blocker를 갱신하고 환경/자료 링크를 추가했다. gh issue edit --body-file 후 body 전체·assignee 재조회 일치. #1 dyhan0528/#4 jsjavsj, OPEN/blocked 유지. 규칙 Contract-Commit은 변경하지 않았다.

## 최신 실행 준비 해제 및 HH-001 인계 — 2026-11-14

이 절은 이전 시점의 IMPLEMENTATION_READY=false·팀원 준비 중·claim 없음 기록을 대체한다. 사용자 “좋아 진행하자” 승인 범위에서 구현 시작 준비를 완료한다. 제품 소스는 아직 작성하지 않았다.

- IMPLEMENTATION_READY=true: HH-001 임시 연결본 범위. 본인 환경/자료 독립검증 docs 기준 `776205c21b12ab6369ad04e8b5b3481a71f6331b`, 규칙 계약 `410063037ba62da61f9119b4ba8b10cbdadc9ccb`.
- 팀원 증거: fresh fetch한 `4fa7e0ec923d529975ca5ec9a35f7fc748806b35`의 [ASSET_MANIFEST](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/blob/4fa7e0ec923d529975ca5ec9a35f7fc748806b35/assets/ASSET_MANIFEST.md)와 #4 최신 claim. jsjavsj 자신의 루트/origin/깨끗한 작업트리·Git 신원·인증·계약 확인, Blender5.3.0 background exit0 및 glTF exporter 보고를 대조했다. manifest의 당시 공통준비 blocked는 이전 시점이다. 상대 PC를 이 PC에서 직접 실행했다고 주장하지 않는다.
- 실제 역할: #1 dyhan0528 / core_loop_worker in-progress claim, 준비 기록 project_setup, 독립 검증 verify_planning. #4 jsjavsj / assets_worker의 이미 존재하는 in-progress claim은 변경하지 않았다. 완성 GLB는 HH-001 선행조건이 아니다.
- 실제 루트: C:\Users\USER\Desktop\나사 첼린지\Junior-Astronaut-Mission-Trainer. 시작 관측 docs/mission-spec-v2 HEAD776205c, clean. origin은 승인 저장소와 일치. 최신 준비 기록 커밋을 feature/HH-001-core-loop에 fast-forward하고 현재 브랜치/HEAD/clean 및 원격 SHA를 인계 직전 대조한다. 정확 인계 SHA는 Git 이력과 #1 Execution-Base 기록으로 확인한다.
- 전체 MVP 실제 작업판 #1~7 유지: #1/#4 실행 중, #2/3/5/6/7 연결본·통합 선행 대기. 공유 씬·project.godot·Godot 설정·충돌 wrapper는 dyhan/core; assets/source·models·textures·manifest는 js/assets. main 변경 및 타인 브랜치 변경 없음, local-only 예외 없음.
- 패킷 허용 경로: project.godot, export_presets.cfg, scenes/main.tscn, scenes/player/, scenes/world/, scenes/ui/terminal.tscn 및 hud.tscn, scripts/player/, scripts/world/, scripts/ui/, scripts/simulation/ 최소 인터페이스, resources/scenarios/. assets와 하네스·개인파일 변경 금지. 작업 전에 issue1 claim/branch/status 재확인.
- 첫 인수: 임시 도형 이동→단말기 한 시설 배치→1턴→위치/시선 포함 복원→동일 턴 비교→Web 출력. START_SPEC v0.1 수치·snapshot·이전 attempt 거절 계약 재사용. 최종 5시설 모델 요구 없음.
- 실행 도구: `.tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe` 실제4.7.2. 자식 프로세스 APPDATA만 `.tools/godot-4.7.2/editor_data/runtime_appdata`로 지정하는 docs/ENVIRONMENT 절차 재사용. 제품 생성 뒤 `--headless --path . --editor --import`; preset/템플릿 충족 뒤 `--headless --path . --export-release Web <출력경로>` 및 실제 브라우저 입력/복원 검증. 현재 제품 파일 없어 이 제품 검사들은 미실행.
- READY-001 completed: 사용자 승인에 따라 fresh fetch/manifest/#1/#4 읽기, #1 ready→in-progress claim 기록 및 #4 공통 증거만 추가, gh issue view 본문 재대조 일치. 런타임 escalation 승인 응답 확인, 별도 요청 ID 미제공.
- READY-002: 이 WORK 및 현재 상태 링크 2개를 독립 검토 후 명시 stage/commit, docs push, core branch fast-forward/push/switch 계획. force/reset/stash/main/제품 변경 금지. 최종 SHA·원격·clean 대조 후 core_loop_worker에게 인계하고 준비 Worker 쓰기 종료.

## HH-001 첫 플레이 구현과 검증 — 2026-11-14

- 대상: `feature/HH-001-core-loop`, 실행 기준 `397f33c9cd4b2fd1578c4295b6e8bb64833d1bfe`, 규칙 계약 `410063037ba62da61f9119b4ba8b10cbdadc9ccb`. [#1](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/1) dyhan0528 / core_loop_worker claim 유지, 독립 Verifier verify_planning. 작업 전 clean/브랜치/원격/claim 일치 확인.
- 결과: Compatibility 3D 기지·25칸·플레이어/단말기, 5시설 임시 도형 및 별도 충돌 wrapper, 초안 배치·환급, 7턴 규칙·고정 사건, 종료·안전 복원·두 시도의 같은 턴 비교, 단일 스레드 Web preset. 다른 브랜치/자산/하네스 변경 없음. 한국어 OS의 native UI는 한국어, Web은 시스템 한국어 글꼴을 이용할 수 없어 영어로 표시한다. 별도 글꼴·새 의존성 없음.
- 자체 검사: Godot `4.7.2.stable.official.ed1daf0bf`, Windows 25H2 build 26200.9711, 기존 portable exe와 프로젝트 내 APPDATA. `--headless --path . --editor --import`, `--headless --path . --quit-after 15` 둘 다 exit 0/빈 stderr. `--headless --path . --script res://scripts/simulation/tests/core_contract.gd`는 90개 확인, 실패 0/exit 0/빈 stderr. 정상 7턴, 무배터리 T3 중단, T2 절전 복원·재현·반복·T3 비교, 중복 명령·UI 재클릭, 배치/환급/배터리 clamp, 씬 위치·시선·속도·충돌 안전 스폰 검사를 포함한다.
- WEB-EXPORT-HH001-001 completed: 본인 PC에서 실제 동일 버전 템플릿으로 `--headless --path . --export-release Web build/web/index.html` exit 0/빈 stderr. 산출물은 HTML/JS/worklets/PNG/PCK/WASM 7개이며 `build/web/`는 Git 제외. 입력 매핑에 논리 키 대체를 추가한 뒤 다시 출력했다. Node 24.22.1 테스트용 로컬 서버는 127.0.0.1:8061 listen을 보고했으나 샌드박스에서 별도 HTTP HEAD는 소켓 접근 EACCES. 생성과 브라우저 실행을 구분한다.
- GUI-NATIVE-HH001-001 partial: Windows Intel UHD Graphics/OpenGL Compatibility 3.3에서 창, 한국어 시작 화면, 클릭 시작과 Esc 일시 정지를 PM이 관측했다. 초기 자동 입력 E는 단말기를 열지 않아 논리 키 바인딩을 추가했다. 최신 실행에서 GUI E/이동/단말기 전체 입력은 미재검증이다. headless 씬 검사는 실제 키보드·마우스 GUI 검사를 대신하지 않는다.
- GUI-WEB-HH001-001 unverified: Computer Use가 Windows의 현재 브라우저 URL을 충분히 확실히 확인할 수 없다는 정책 오류를 반환해 해당 도구를 중단했다. 목표 Edge/Chrome 실제 게임 로딩, WebGL2·포인터 캡처/E·되감기·비교 검증을 완료로 보지 않는다. #1 OPEN 유지; HH-002/003의 확장 인수, Blender 통합, main 통합·배포·제출은 이 기록의 완료 범위가 아니다.
- 독립 검증: verify_planning이 동일 Godot/APPDATA에서 계약 검사를 다시 실행해 90개 확인/실패 0/exit 0/빈 stderr를 확인했다. 정확 제품 스냅샷은 실행 기준 `397f33c`와 검토 파일 SHA-256으로 식별한다(검사 스크립트 `54daa90dee95f63c3682b8c8cd7e4fbfd4866024c4d3a2080d08577ca478bda5`).
- CORE-SOURCE-HH001-001: 실행 승인 범위는 dyhan0528 저장소의 `feature/HH-001-core-loop` 한 개다. 검토 파일만 명시 stage 후 `git commit -m "feat: add playable lunar rewind prototype"`; 같은 트리 확인 후 `git push origin feature/HH-001-core-loop` 및 `git ls-remote --heads origin refs/heads/feature/HH-001-core-loop` 계획. 실행·원격 결과는 이 명령의 실제 출력과 브랜치 이력으로 확인하며 GUI 검증이나 main 통합을 뜻하지 않는다.
- 사용자 직접 플레이: 제품 커밋 `dccfd11c0074866b2b0265be7e3a2c6305b853b3`의 시작 안내(화면 클릭 → WASD 이동 → E로 단말기 열기 → 시설 배치 → 다음 턴 → 되감기)에 사용자가 “다 작동함.”이라고 확인했다. 이 결과는 앞의 자동 검사 90개와 별도의 수동 확인이다. 실행 환경과 브라우저는 명시되지 않았다.
- 다음 검증: 목표 브라우저에서 게임 로딩·입력·되감기·같은 턴 비교를 확인한다. 그때까지 #1은 OPEN으로 유지한다. 팀원 Blender 모델 통합은 후속 작업이다.
- CORE-USER-PLAY-HH001-001: 승인된 `feature/HH-001-core-loop`에서 `WORK.md`만 검토 후 `git add -- WORK.md` → `git commit -m "docs: record HH-001 player verification"` → `git push origin feature/HH-001-core-loop`로 반영하고 원격 SHA를 대조한다. #1의 기존 assignee·OPEN 상태를 확인한 뒤 `gh issue edit 1 --repo NASA-HACKATHON-Mis/Mismatch-3d-Training-Game --body-file <진행 기록>`으로 사용자 직접 확인을 덧붙이고 재조회한다.

## 첫 모델 수령과 이슈 대조 — 2026-11-14

- 최신 원격 `feature/HH-004-assets`의 [자산 커밋 `5e3d0f4`](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/commit/5e3d0f4fa8804e8c8f8567c2fffe9deadb97a441)과 [manifest `1fc5f56`](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/blob/1fc5f5617750390dbd96d139be6bd64a1e453039/assets/ASSET_MANIFEST.md)를 받았다. 실제 Git 객체에 발전기·1m 기준 큐브 GLB 2개(252,068·2,884 B), Blender 원본 2개(136,414·89,523 B), manifest와 `.gdignore`가 있다. 두 GLB의 헤더·SHA-256·치수 메타데이터·삼각형 수(4,532·26)가 manifest와 일치했다.
- 팀원 PC의 격리 Godot 4.7.2 import·인스턴스화 통과는 manifest와 [#4](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/4)의 보고다. core 게임에서 외관·방향·슬롯·충돌·웹 출력을 확인하는 작업이 남았다.
- [#1](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/1)은 첫 플레이와 사용자 확인을 완료했고 목표 브라우저 검증이 남았다. [#2](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/2)·[#3](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/3)의 기본 규칙과 되감기·비교는 제품 `dccfd11`에 있고 계약 자동 검사 90개를 통과했다. 각각의 통합 기준·인터페이스 인수 검증은 남았다.
- [#5](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/5)는 UI/출처 인터페이스 검증, [#6](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/6)은 #2–5 통합 결과, [#7](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/7)은 #6 통합 검증을 기다린다. #4의 팀원 담당과 작업 기록을 보존한다. 이슈 7개는 각각의 인수 검증을 위해 OPEN을 유지한다.
- CORE-ASSET-RECEIPT-001: 승인된 저장소에서 `git fetch origin` 후 원격 자산과 이슈 #1–7을 읽었다. 기존 이슈 #1·2·3·5·6·7의 현재 상태를 `gh issue edit --body-file`로 맞추고 재조회한다. 기준 `b01c0c9`에서 검토한 `WORK.md`만 core 브랜치에 커밋·푸시하고 원격 SHA를 대조한다.

## 발전기 모델 통합 — 2026-11-14

- CORE-ASSET-INTEGRATION-001: 사용자 “좋아 승인할게 진행해봐”에 따라 dyhan0528/core_loop_worker가 담당하고 verify_planning이 독립 검증한다. 대상 `feature/HH-001-core-loop`의 기준은 `3398164f7987cd27346b110cfb76e452dbcb8433`(시작 시 clean 및 원격과 일치), 소스 `origin/feature/HH-004-assets`는 `1fc5f5617750390dbd96d139be6bd64a1e453039`, 공통 규칙 기준은 `410063037ba62da61f9119b4ba8b10cbdadc9ccb`이다. 두 원격 ref를 다시 가져와 확인했다. [#1](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/1)의 core 통합 작업에 기록하고 [#4](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/4)의 모델 제작 담당은 jsjavsj로 유지한다.
- `git merge --no-ff --no-commit 1fc5f5617750390dbd96d139be6bd64a1e453039`로 원본 이력을 보존한다. 소스 변경은 `assets/`의 신규 6개 파일뿐이다. 모델 파일과 manifest의 원본을 보존하고 core에서는 발전기 시각 노드, 발전기 충돌 높이, 통합 검사 및 기록만 변경한다. 1m 큐브는 단위와 방향 검증에 사용한다. 충돌·통로는 기존 가로/깊이 기준을 유지한다.
- Godot 4.7.2에서 실제 프로젝트 import와 headless 계약 검사, Web release 출력을 검증한 뒤 검토한 스냅샷으로 merge 커밋을 만들고 이 feature 브랜치에 push한다. #1·#4에는 실제 검사 결과와 남은 인수 항목을 기록한다.
- 실제 import: Windows Godot `4.7.2.stable.official.ed1daf0bf`에서 `--headless --path . --editor --import`가 두 GLB를 가져왔다(exit 0, 빈 stderr). 원본 GLB는 단위 변환 없이 슬롯 시각 노드에 붙였다. 발전기 치수는 3.6 × 3.2 × 2.593 m(가로 × 깊이 × 높이)이며 기존 가로 3.6 m와 깊이 3.4 m의 충돌 영역은 유지하고 높이만 2.6 m로 맞췄다. 나머지 시설은 임시 모델을 사용한다.
- 실제 게임 씬 검사: `--headless --path . --script res://scripts/simulation/tests/core_contract.gd` 90개, `--headless --path . --script res://scripts/simulation/tests/generator_integration.gd` 19개 모두 통과(exit 0, 빈 stderr). 1m 기준 큐브, 원점과 -Z 정면, 발전기 재질 3개, 슬롯 위치 및 별도 충돌체를 확인했다. 실제 플레이어 캡슐은 발전기 사이 2.4m 통로를 통과했고 발전기 앞에서는 충돌했다.
- 실제 Windows OpenGL Compatibility 렌더에서 인접 슬롯 두 개의 발전기와 통로, 패널 재질 및 앞면을 확인했다. PM도 1280×720 캡처 `logs/hh004-generator-preview.png`를 검토했다. 기존 플레이어 세션과 분리된 검사용 장면이었다.
- `--headless --path . --export-release Web build/web/index.html`로 발전기를 포함한 Web 파일을 갱신했다(exit 0, 빈 stderr). 최종 PCK SHA-256 `cad22b47c5618161993fe3f0bcccbdf943c853e9ecb94a643a52ad5294e0ccf6`. Web preset은 작업 로그와 이전 출력물을 제외하며 팀원 Blender 원본은 `.gdignore`로 제외한다. 브라우저에서의 포인터 캡처 및 전체 플레이는 확인이 남았다.
- 독립 검증: verify_planning이 기존 90개와 통합 19개 검사를 다시 실행해 모두 통과했다. 소스 파일이 없는 작업 폴더에서 최종 PCK를 단독으로 열어 실제 게임 씬의 슬롯에 발전기 GLB가 로드되는 것도 확인했다. PM은 갱신한 Web 빌드의 로딩을 관찰했다. 첫 발전기는 통합 검증을 통과했으며 #4의 나머지 시설과 로봇, 전체 Web 플레이 검증은 남았다.

## 후속 시설·안내 로봇 통합 — 2026-11-15

- CORE-ASSET-INTEGRATION-002. 사용자의 후속 통합 지시에 따라 dyhan0528/core_loop_worker가 [#4](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/4)의 게임 연결을 맡는다. 제작 담당 jsjavsj/assets_worker와 별도로 verify_planning이 검사를 재실행한다. 시작 브랜치는 `feature/HH-001-core-loop`, 기준 커밋은 `797e99008635bcad6e3d6802b7e9789c36a88d99`이고 작업 시작 시 원격과 일치하며 변경 사항이 없었다. 규칙 계약은 `410063037ba62da61f9119b4ba8b10cbdadc9ccb`이다.
- `feature/HH-004-model-integration`에 최신 [자산 커밋 `5e1278e`](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/commit/5e1278ed37e83161028b78d9729d1e5788fd1fb6)을 `git merge --no-ff --no-commit`으로 가져온다. 다섯 GLB와 Blender 원본의 SHA-256을 manifest와 대조했다. 원본을 보존하고 core의 시설 시각 노드, 별도 충돌 박스, 고정 안내 로봇, import 설정, 통합 검사와 문서만 갱신한다.
- 저장소 `NASA-HACKATHON-Mis/Mismatch-3d-Training-Game`의 통합 작업 브랜치로 push하고 `gh pr create --base feature/HH-001-core-loop --head feature/HH-004-model-integration --body-file <본문>`으로 PR을 만든다. 프로젝트 실행·독립 검사·Web 출력 확인 후 `gh pr merge --merge --match-head-commit <검증 SHA>`하고, 기존 core를 fetch하여 fast-forward한다. 사용자 지시에 따라 별도의 PR 리뷰 요청은 생략한다. #4의 실제 결과를 갱신할 때 제작 담당과 이력을 유지한다.
- Godot `4.7.2.stable.official.ed1daf0bf`의 `--headless --path . --editor --import`에서 후속 GLB 5종의 실제 프로젝트 import가 성공했다. 슬롯별로 Blender 원본과 같은 크기·방향·재질을 유지했다. 온실 유리의 알파 0.26을 확인했다. 별도 충돌 박스는 시설 외형을 감싸며 6m 격자 사이의 최소 2.2m 통로를 유지한다. 안내 로봇은 단말기 옆에서 입구를 바라보고, 별도 충돌과 복원 위치 검사로 플레이어가 로봇을 통과하거나 겹친 위치에 되감기지 않도록 했다.
- `--headless --path . --script res://scripts/simulation/tests/<이름>.gd`로 `core_contract` 90개, `generator_integration` 19개, `facility_integration` 52개를 자체·독립 실행했다. 합계 161개 모두 통과했다(exit 0, 빈 stderr). 실제 플레이어 캡슐의 시설 충돌·통로 보행, 단말기 접근, 시설 삭제·되감기 복원을 포함했다. Windows OpenGL에서 시설 전체와 로봇의 실제 외형을 렌더링했고 PM이 `logs/hh004-expanded-station.png`, `logs/hh004-guide-robot.png`를 확인했다.
- `--headless --path . --export-release Web build/web/index.html` 성공. PCK 629,248 B의 SHA-256은 `dc530de4912d061fbb82bf666caf983c45f27b7317f2c0a2b91552c0eb35579e`다. 독립 검사에서 프로젝트 소스 없이 PCK만 실행해 시설·로봇·기준 큐브의 모델 리소스 7개를 로드했고, 배포 패키지에서 원본 Blender 파일과 내부 기록이 빠진 것을 확인했다. 브라우저의 마우스 캡처와 전체 플레이는 별도 확인이 남았다.
- 검증한 통합 소스는 로컬 커밋 `b234e7653a7be98d29c62d3adbd91b03cb07a187`이다. [로컬 Web 빌드](http://127.0.0.1:8062/)의 HTML·WASM·PCK가 HTTP 200을 반환했고, 내려받은 PCK의 SHA-256이 위와 일치했다.
- CORE-ASSET-INTEGRATION-002 원격 작업은 자동 승인 검토에서 거절됐다. 이 검토는 이전 발전기 업로드 및 이슈 관리 승인이 이번 통합 파일의 같은 GitHub 저장소 업로드와 PR 생성까지 포괄하는지 명확하지 않다고 판단했다. 원격 push·PR 생성·merge는 실행되지 않았다. `logs/hh004-expanded-pr.md`에 검토할 PR 본문을 준비했다. 남은 단계는 이번 소스와 문서의 업로드 및 `feature/HH-004-model-integration → feature/HH-001-core-loop` PR 생성·merge 범위를 승인받는 것이다.
- 후속 결과: 사용자가 원격 작업을 명시적으로 승인했고 [PR #8](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/pull/8)이 core `f88cb62c50680db7011c1aaf05aaeb328afa9892`에 병합됐다. 사용자는 새 모델 배치·이동·되감기를 확인했다. 이 증거는 두 PC에서의 전체 브라우저 인수 검증을 대신하지 않는다.

## 한국어 안내서와 현재 문서 — 2026-11-15

- HH005-LEARNING-UI-001. 사용자 지시에 따라 [#5](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/5)를 dyhan0528/core_loop_worker가 `feature/HH-005-learning-ui`에서 작업했다. 시작 기준은 원격 core와 일치한 `f88cb62c50680db7011c1aaf05aaeb328afa9892`이며 변경 사항이 없는 상태에서 시작했다. 규칙 계약 `410063037ba62da61f9119b4ba8b10cbdadc9ccb`는 유지했다. 독립 검사는 verify_planning이 맡았다.
- 시작 화면과 단말기에 안내서를 연결했다. 한국어로 시설 역할, 사건 선택, 같은 턴 비교 및 출처를 보여 준다. Tab·Enter·Esc로 열고 닫을 수 있으며, 닫을 때 이전 초점으로 돌아간다. 실제 NASA DONKI 과거 관측 1건과 CSA 출처를 게임 자체 규칙과 구분했다. 기존 자료는 수정하지 않았다. [Noto Sans KR](resources/fonts/README.md)의 공식 원본과 OFL 1.1을 번들로 사용한다.
- DOC-ISSUE-CLEANUP-001. 사용자 요청에 따라 project_setup이 현황 문서 6개와 작업 이슈를 대조했다. PR #8, 검사 161개, 사용자의 새 모델 배치·이동·되감기 확인을 근거로 #1–4를 닫았다. #6·#7은 OPEN이다. #6에서 팀원 jsjavsj가 두 번째 Windows의 전체 7턴·실패 복원·같은 턴 비교·충돌·한국어를 확인한다. #7의 제출 조건 확인과 시연 준비는 별도로 진행한다.
- 같은 저장소의 `feature/HH-005-learning-ui`에서 `feature/HH-001-core-loop`로 PR을 만든다. 확인한 결과와 문서 변경을 함께 올리며 사용자 요청에 따라 리뷰 요청 없이 검증한 커밋을 병합한다.
- Godot `4.7.2.stable.official.ed1daf0bf`의 headless import와 기존 161개·새 안내서 검사 15개가 자체·독립 실행에서 통과했다. 별도 Windows 렌더에서 한국어 글자, 시설과 비교 화면, 출처 카드와 키보드 초점 표시를 확인했다. `--headless --path . --export-release Web build/web/index.html` 성공. 최종 PCK 7,378,664 B의 SHA-256은 `ca5193353dbbf7be3fa1a2579dad1727adbfc8ce11bf9bb1cd72fbbc28e0c3ac`이다. 두 PC의 전체 브라우저 플레이는 #6에서 확인한다.
- 독립 검사에서 최종 PCK만으로 실제 안내서 씬을 열어 한글 글리프, OFL 라이선스, DONKI 원자료와 metadata의 오프라인 로드를 확인했다.
- 최종 Web 빌드에서 한국어 시작 화면, 안내서 클릭, 실제 자료 탭의 NASA·CSA 카드, Esc로 시작 화면 복귀, H로 다시 열기와 Tab 키 초점 표시를 확인했다.

## 로컬 UX 명세 초안 — 2026-11-15 Asia/Seoul

- 사용자 “백로그에 있는것들을 명세에 올려서 보여줘”에 따라 ux_spec_worker가 [UX_REDESIGN_SPEC v1.0](UX_REDESIGN_SPEC.md)을 작성했다. 기준 HEAD `9907d51d54b0b3a638cd61a6c7de29f46ff46e49`, 브랜치 `docs/HH-007-submission-prep` 유지. UX-001~030의 관찰·목표·수용조건·검사·우선순위·규칙 영향을 연결한 로컬 검토 초안이다.
- 문서 구조 자체 확인: 30개 ID를 각각 1회 제목으로 포함하고 기존 START_SPEC v0.1 규칙과 예시를 대조했다. 이번 작업에서 게임 구현/실행 재현/사용자 테스트는 수행하지 않았으며 백로그 해결 확인도 하지 않았다. ux_spec_verify의 독립 문서 검토를 통과했고, 기존 게임과 구분되도록 변경이력의 상태를 “UX 개선 미구현/미검증”으로 명확히 했다.
- 기존 SUBMISSION.md 변경과 Git 제외 LOCAL_BACKLOG.md 원문을 보존한다. 제품 코드·규칙·모델·브랜치 변경, Git stage/commit/push, 이슈 생성·원격 공개는 수행하지 않았다. 다음은 사용자에게 초안 제시이며, 제품 구현 준비 완료를 선언하지 않는다.

## UX 리팩터링 작업판

**현재 역할(v1.2): dyhan0528는 디자인 검토만 담당합니다. 개선 구현 전체와 UX-R01~06 작업 브랜치 소유자는 jsjavsj입니다. 독립 검증은 구현자와 분리하여 착수 때 지정하며 AI는 필요시 보조합니다. 아래 v1.1 담당 기록은 당시 이력이며 이 역할 정정이 우선합니다.**

- 2026-11-15: 사용자 승인에 따라 refactor_docs_worker가 읽기 쉬운 명세 v1.1, 상세 수용 기준, 실제 GitHub 작업 이슈 6개를 준비한다. 사용자는 개발하지 않고 Codex가 구현과 별도 검증을 맡는다. dyhan0528는 제품 Owner이며 개발 assignee로 배정하지 않는다. jsjavsj의 추가 모델 작업도 배정하지 않는다.
- 현재 기준: `docs/HH-007-submission-prep` / `9907d51d54b0b3a638cd61a6c7de29f46ff46e49`. 기존 SUBMISSION.md dirty와 Git 제외 LOCAL_BACKLOG.md를 보존한다. #1~6 CLOSED, #7 OPEN/제출 보류를 실제 조회했다.
- UX-DOC-001 completed: UX_REDESIGN_SPEC.md를 쉬운 6묶음으로 개편하고 docs/UX_ACCEPTANCE.md에 상세30항목을 보존, README 진입점을 갱신한다. 독립 Verifier 검토 뒤 명시 파일만 commit한다. 제품 코드는 변경하지 않는다.
- UX-PUBLISH-001 completed: 승인 저장소 `NASA-HACKATHON-Mis/Mismatch-3d-Training-Game`, 문서 브랜치 `docs/UX-refactoring-plan` 생성 및 명시 문서 commit/push. main·기존 core·모델 브랜치·SUBMISSION·로컬 백로그는 게시 대상이 아니다. 요청 근거는 사용자의 문서 업데이트·이슈 작성 진행 승인이다.
- UX-ISSUES-001 completed: 같은 저장소에 UX-R01~06 중복 조회 후 create/update, 본문 파일은 logs/ux-refactor/UX-R01.md~UX-R06.md. 응답 후 실제 이슈를 재조회한다. 상태 불명확 시 조회로 대조하고 중복 생성하지 않는다. 기존 완료 이슈와 #7은 수정하지 않는다.
- 준비 상태: 문서 독립 검토·원격 게시와 이슈6개 등록 완료. 구현 준비 완료나 게임 검증 완료가 아니다. 순서는 R01→R02→R03→R04→R05→R06이며 선행 검증·core 통합 전 후속 이슈는 blocked다. 각 착수 때 실제 Worker/Verifier, claim 및 최신 실행 기준 SHA를 확정한다.

| 작업 | 범위 | 실제 이슈 | 구현 담당 | 상태 |
| --- | --- | --- | --- | --- |
| UX-R01 | 시작·단말기·재진입 | [UX-R01](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/11) | jsjavsj | in-progress / 수정·자동검사 완료, 실제 브라우저 인수·main 통합 대기 |
| UX-R02 | 첫 안내·화면 | [UX-R02](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/12) | jsjavsj | done / PR #19 검증·main 통합 |
| UX-R03 | 시설·자원 | [UX-R03](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/13) | jsjavsj | done / PR #20 검증·main 통합 |
| UX-R04 | 성공·실패 | [UX-R04](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/14) | jsjavsj | ready / UX-R03 완료, 착수 claim 전 |
| UX-R05 | 되감기·비교 | [UX-R05](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/15) | jsjavsj | blocked / UX-R04 통합 대기 |
| UX-R06 | 사용성·통합 검증 | [UX-R06](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/16) | jsjavsj | blocked / UX-R05 통합 대기 |

저장 UX-010, 미래 사건 예고 UX-022 및 새 보상·밸런스·이동 생략은 보류다. 이슈6개에는 현재 승인된 개선28항목을 연결하고, 보류2항목도 누락 없이 식별한다.

- refactor_docs_verify 독립 문서 검토 통과: 30 ID 보존, 28 실행+2 보류, 사용자 개발 없음, 규칙 유지, 검사 명령과 상대 링크 확인. 이번 작업은 문서 검사이며 게임 검사는 미실행이다. 게시 후 실제 커밋과 이슈를 다시 대조한다.

- 문서 명세 커밋: ff0b38052f7087e1c3010c558ce230c3a833d67c. docs/UX-refactoring-plan push와 원격 SHA 일치를 확인했다. 이슈 본문은 이 고정 명세 커밋을 참조한다. 이슈 생성 배치는 매 생성 직전 전체 조회로 중복 확인 후 create하고, 생성된 번호/본문/assignee를 조회한다. 런타임 승인 요청 식별자는 제공되지 않았다.

- UX-ISSUES-LINK-001 completed: 실제 생성한 #11~16의 본문을 logs/ux-refactor/UX-R01.md~UX-R06.md로 갱신해 선행 실제 링크와 상태를 맞춘 뒤 재조회한다. 모두 OPEN·assignee 없음이며 명세 ff0b38052f7087e1c3010c558ce230c3a833d67c를 참조한다. 문서 원격 브랜치는 docs/UX-refactoring-plan; 기존 제출 초안은 변경 없이 남아 있다.

- 이슈6개의 실제 본문을 로컬 검토 본문과 정규화해 대조했고 모두 일치했다. R01 ready(착수 claim 전), R02~06 blocked(직전 이슈 검증·core 통합 대기). 제품 수정·게임 검사·main/core 병합·배포·제출은 수행하지 않았다. 다음 작업은 Codex Worker/Verifier를 지정하고 #11에서 실제 환경 재현부터 시작하는 것이다.

- refactor_docs_verify의 원격 독립 대조 통과: #11~16 제목·본문·명세 SHA·assignee 없음·상태·선행 링크 일치, 명세 브랜치 원격 일치, 문서4개만 커밋 및 보호 파일 해시 유지 확인. UX-TRACK-001: 검토한 WORK 작업판만 추가 commit/push하여 최종 인계한다.

## UX 리팩터링 역할 정정 — v1.2

- 사용자 결정: “나는 이번에 디자인만 볼 거야, 나머지 개선사항은 전부 다 팀원이 작업할 거야.” dyhan0528는 디자인 검토만, jsjavsj는 개선 구현 전체와 이슈·작업 브랜치 담당으로 정정한다. 사용자에게 개발·기술 검증 작업을 배정하지 않는다. 구현자의 자체 검사와 별도 독립 검증은 유지하며 독립 담당은 착수 전에 지정한다.
- UX-ROLE-001 completed: refactor_docs_worker가 README.md, UX_REDESIGN_SPEC.md, docs/UX_ACCEPTANCE.md, WORK.md의 현재 역할을 정정한다. 상세 요구·검사·보류 항목·선행 순서는 유지하며 과거 담당 기록은 이력으로 보존한다. docs/UX-refactoring-plan 기준 e672f9c0a851e51c75c4d660791bb8a6ae040a2d, 기존 SUBMISSION dirty 및 LOCAL_BACKLOG 해시를 보존한다.
- UX-ROLE-PUBLISH-001 completed: 사용자 역할 정정 승인으로 독립 검토한 문서4개만 같은 문서 브랜치에 commit/push한다. GitHub #11~16 본문을 새 명세 커밋과 역할에 맞추고 실제 assignee를 jsjavsj로 설정한다. 코드·이전 완료 이슈·core/main·배포는 변경하지 않는다.
- 다음 행동: 팀원 jsjavsj가 자신의 복사본에서 명세·기준·브랜치를 확인하고 #11 claim 및 독립 검증 담당을 확정한 뒤 구현을 시작한다. 이 역할 문서 수정은 팀원의 실제 착수나 검사 완료를 뜻하지 않는다.

- refactor_docs_verify 역할 정정 초안 독립 검토 통과: 문서4개와 이슈6개에서 디자인 검토/팀원 구현/독립 검증 분리 일치. 보호 파일 해시 유지, 게임 검사는 수행하지 않음.

- UX-ROLE-ISSUES-001 completed: 명세 v1.2 커밋 5ccae7f023cc18495b1ba536442bff2be7bb95dc의 원격 반영을 확인했다. #11~16은 검토한 logs/ux-refactor 본문으로 gh issue edit --body-file 및 --add-assignee jsjavsj를 적용하고 각각 실제 본문·담당·상태를 재조회한다.

- 실제 대조 결과: #11~16 모두 OPEN, assignee는 jsjavsj 한 명, 본문은 검토한 v1.2 역할과 명세 5ccae7f023cc18495b1ba536442bff2be7bb95dc에 일치한다. R01 ready/착수 claim 전, R02~06 선행 통합 대기를 유지했다. 기존 SUBMISSION.md 및 LOCAL_BACKLOG.md 해시는 작업 전과 동일하며 제품 구현은 시작하지 않았다.

- refactor_docs_verify 원격 독립 검토 통과: 이슈6개 실제 담당 jsjavsj만, 본문·새 명세 SHA·OPEN 상태·원격 커밋 일치 및 보호 파일 유지. UX-ROLE-TRACK-001: 이 완료 기록만 WORK.md에 commit/push해 인계한다.

## main 통합 정책 — 2026-11-15

- MAIN-BASELINE-001. 사용자의 통합 브랜치 정리 요청에 따라 core_loop_worker가 `NASA-HACKATHON-Mis/Mismatch-3d-Training-Game`의 검증 기준 `9907d51d54b0b3a638cd61a6c7de29f46ff46e49`로 새 원격 `main`을 초기화한다. 원격 `feature/HH-001-core-loop`와 일치하고 `main`은 시작 시 없었다. 기존 기본 브랜치는 `docs/mission-spec-v2`였다.
- MAIN-UX-DOCS-001. 최신 `docs/UX-refactoring-plan`의 `3b014eb62488239bef1f78b4eb20f12b62362c3d`에서 분리한 `docs/main-integration-policy`를 사용한다. UX 문서 4개 변경과 해당 작업 커밋을 보존하고, README·WORKFLOW·WORK·UX 문서만 최신 상태에 맞춘다. 검증 기준과 실행 코드, 모델, 설정, 원자료의 트리가 같은지 검사한 뒤 `docs/main-integration-policy → main` PR을 일반 merge한다.
- MAIN-DEFAULT-001. 병합한 `main`과 작업 트리를 대응시킨 뒤 GitHub 기본 브랜치를 `main`으로 바꾼다. 이후 `작업 브랜치 → 검사 → PR → main` 순서로 통합한다. 기존 브랜치는 보존한다. 배포·실제 접수는 별도이며 #6 완료, #7 제출 보류를 유지한다. UX #11–16의 담당·선행 조건은 유지하고 통합 대상만 맞춘다.
- 현재 사용자 체크아웃 `docs/UX-refactoring-plan`의 미커밋 제출 초안과 로컬 전용 기록은 보존한다. 이번 정책·문서 변경에는 제품 코드나 모델 변경이 없다.

## UX-R01 진행 막힘 수정 — 2026-11-15

- 사용자 요청에 따라 jsjavsj의 복사본에서 원격을 갱신했다. 기준 `main`/`origin/main`은 `c5a95a9638f77b22a6df2557621ba7172814b347`, 시작 시 clean. `fix/UX-R01-navigation`에서 구현 보조 ux11_worker와 독립 ux11_verifier를 지정하고 #11 본문에 claim을 기록·재조회했다. 명세 `5ccae7f023cc18495b1ba536442bff2be7bb95dc`, 원계약 `410063037ba62da61f9119b4ba8b10cbdadc9ccb` 유지.
- 재현: 기존 deck 윗면 0m와 terrain -0.18m 사이의 턱에서 실제 CharacterBody `move_and_slide` 왕복 검사 8개 중 재진입 4개가 실패했다. 남쪽 z=21.277, 북쪽 z=-15.277, 동서 x=±17.284 부근에 멈췄다. 데크 네 변과 모서리에 폭 1m의 낮은 경사로를 시각·충돌 동일 형상으로 추가했다. 점프·순간이동·시설 원본·규칙 수치는 변경하지 않았다.
- 입력: Web의 비동기 마우스 잠금을 기다리는 상태를 추가했다. 대기 중 이동을 막고 2초 내 잠금이 오지 않으면 설명과 재시도 버튼을 보여 준다. Esc·포커스 상실·시간 초과 뒤 늦게 도착한 잠금은 일시정지를 해제하지 않는다. 새 드래그 조작이나 서버 설정은 추가하지 않았다.
- Godot `4.7.2.stable.official.ed1daf0bf`, 이 PC의 `../tools/godot-4.7.2`와 자식 프로세스 전용 `.tmp/runtime_appdata` 사용. headless import 및 기존 core 90 / generator 19 / facility 52 / learning UI 15 검사 모두 통과. 새 `navigation.gd` 70개도 통과: 실제 player 물리·WASD 입력으로 8방향 왕복을 초기/시설 배치/복원 후 반복, 정면·왼쪽 단말기 접근과 E 처리, 2m 밖 접근 거부, 잠금 대기·실패·재시도·취소 상태 검사. 합계 246개. 독립 검증도 기존 176개와 최종 navigation 70개를 통과했고 diff 검토를 마쳤다.
- headless DisplayServer는 실제 포인터 권한을 제공하지 않는다. 입력 상태 검사는 잠금 결과를 주입하며, E 검사는 실제 물리 ray 결과를 입력 처리기에 공급한다. 이 검사를 실제 브라우저 권한/입력 검사로 표시하지 않는다.
- PM은 변경 전 Native 화면에서 시작 클릭·E 단말기 열기·Esc 일시정지를 확인했다. Native 정상 시작 정지는 미재현이며 단말기 자체의 별도 충돌 결함도 확인되지 않았다. 최종 Native 화면 및 Chrome/Edge 직접 클릭·잠금 거부·Esc/포커스 복귀·iframe 입력 검사는 미실행이다. Windows Computer Use가 브라우저 URL 정책 확인 불가로 중단되어 추가 UI 조작을 하지 않았다.
- Web export 성공(exit 0), `build/web/index.pck` SHA-256 `5526aa8f6a61da6915aa0b3f7a7402c99f205ee8e14af86a0644a8fa5b47fba3`. 모델·폰트 import의 줄바꿈만 바뀐 부수 파일 8개는 내용 차이가 없음을 확인하고 작업 전 상태로 복구했다.
- 검증한 소스 커밋 `78a1affc49938eca9c771a94564f4d87430fcb64`를 작업 브랜치에 push하고 [PR #18](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/pull/18)을 `Refs #11`, OPEN/DRAFT로 생성했다. 독립 Verifier가 커밋과 검증 파일 해시의 일치를 확인했다. #11 본문에도 결과·PR·미실행 조건을 반영했다. #11은 OPEN이며 실제 브라우저 입력 인수 전 main 병합·이슈 종료를 보류한다. #12는 #11 검증·통합 대기 상태를 유지한다. 외부 terrain 위치 복원 시 기존 안전 위치 판정에 따른 spawn 복귀는 기존 계약 그대로다.

## UX-R01 사용자 확인·통합 및 UX-R02 착수 — 2026-11-15

- 사용자가 로컬 빌드에서 정상 동작을 확인하고 #11 병합 및 #12 진행을 요청했다. PR #18을 일반 merge하여 `main`에 `0f53621426e6342d389b9cdcc60fb6a8768477cf`로 반영했고 #11 CLOSED(completed)를 재조회했다. 사용자 확인은 안내한 시작/E/기지 출입/Esc 재시작 흐름의 인수이며, 브라우저 종류·버전 및 잠금 거부/iframe 전체 행렬 검사로 확대해 기록하지 않는다.
- #12 시작 패킷: `feature/UX-R02-guidance`, 위 최신 main과 같은 HEAD·clean에서 생성. 명세 `5ccae7f023cc18495b1ba536442bff2be7bb95dc`, 원계약 유지. 사람 담당 jsjavsj, 구현 보조 ux12_worker, 독립 ux11_verifier. 실제 #12 본문 claim/in-progress를 갱신·재조회했고 기존 IMPLEMENTATION_READY=true와 선행 통합을 확인했다.
- 허용: UI/안내·시작 구도·관련 검사·현재 문서. UX-012의 실제 픽셀 반응형을 위해 project.godot의 stretch mode 한 줄 변경을 PM이 확인했다. 규칙 수치·원본 모델·저장/미래사건/보상·제출은 변경하지 않는다.

- UX-R02 구현: 시작 전 PC 입력 요구와 한 행동 안내, 시작/단말기의 안내 건너뛰기·다시보기 동기화, 시설→사건 선택→턴 진행 안내를 추가했다. 안내 표시만 바뀌며 state/draft/attempt_id는 유지한다. 과거 기록은 완료 기록 전 설명을 보이고 기록이 생기면 열어 되감기·비교를 사용한다. 25칸과 모든 기존 배치 기능은 유지했다.
- 넓은 화면은 지도/시설 2열, 1100px 미만은 시설 선택부터 세로로 배치하고 스크롤·키보드 초점 추적을 사용한다. 전체 화면 축소 대신 실제 픽셀 레이아웃으로 전환했다. 본문18px·보조16px 이상, 공통 글자색/비활성 글자색의 카드 배경 대비4.5:1 검사를 추가했다. 한글 테마와 영어 NORTH 표기 등 실제 글리프를 검사했고 별도 영문 모드를 새로 구현하지 않았다.
- 시작 전용 카메라로 로봇의 주요 형태와 안내 패널을 분리했다. 최초 탐색 때 기존 플레이어 카메라로 복귀하며 플레이어 위치/시점 기록은 바꾸지 않는다. 그 뒤 일시정지에서도 탐색 카메라를 유지한다. 모델 원본은 수정하지 않았다.
- 용어는 ‘이번 턴 진행’, ‘이번 변경 취소’, ‘전력 생산/소비’, ‘식량 수확/보급’으로 표시한다. 계산 전에 중단한 수확/보급을 0으로 표현하지 않는다. README의 실제 버튼·과거 기록 열기 절차를 함께 갱신했다.
- Godot4.7.2 자체·독립 headless 검증: 기존246 + guidance_ui615 = 861개, exit0/실패0. 새 검사는 네 화면크기의 UI 너비·스크롤 프레임·글자크기/글리프/대비, T1/T2·안내skip/reopen·과거기록·복원·결과 문구·시작카메라 전환과 상태 불변을 확인한다. 실제 어린이의 이해도/사용성 관찰로 대체하지 않는다.
- 실제 OpenGL 렌더링에서 1920×1080·1280×720·1024×768·800×900의 시작/단말기/T2사건/안내서 PNG16개를 생성했다. 당시624개 검사 통과(이후 대비7개 검사만 추가, 제품 동일). 로컬 증거 `logs/ux12/`는 Git 제외. PM이 로봇 전체·시작 버튼·단말기 안내/사건·안내서 화면을 검토했다.
- Web export exit0, PCK SHA256 `60f8723c1b62410977ff3deb36d58f5fc9542bcea5c46daddc3e36380cb69b7d`. 기존 로컬 서버8072에서 새 빌드를 제공한다. 실제 브라우저 입력 및 디자인 검토 결과는 후속 기록에 구분해 추가한다.

- 최종 검증 소스 `12f7f962ce04f5b2ec9b88c498d7b57bd446a200`. PM의 실제 Native 검사: 시작→플레이어 카메라/E 안내→단말기→01 발전기(토큰12→9)→이번 턴 진행(T2, E20/O62/F30)→사건 대응 안내→첫 안내 건너뛰기/다시보기(자원 불변)→H/Esc 안내서 복귀→절전 선택→다음 행동 안내를 확인했다. 스크롤·과거 기록 펼침·T1 비교/되감기 버튼 접근도 확인했다.
- IAB Web에서 첫 안내 건너뛰기/다시보기와 H/Esc 안내서가 동작했다. IAB Chromium은 pointer lock UnknownError를 반환했고 게임은 대기 후 실패 안내로 정상 복구했다. 일반 Chrome/Edge의 전체 권한/입력 행렬 통과라고 기록하지 않는다. 실제 아동 이해도 관찰·영문 런타임·터치 전용 게임 지원도 주장하지 않는다.
- PM은 네 크기 렌더, 자체·독립861개 검사와 실제 Native 흐름을 근거로 #12의 구현 인수를 확인하고 일반 merge를 진행하도록 했다. 다음 #13은 최신 main에서 착수 준비만 하며 이번 작업에서 코딩하지 않는다.

- UX-R02 PR [#19](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/pull/19)을 `main` 대상으로 생성했다. 검증 소스는 위 `12f7f96`이며 이후 커밋은 문서만 바꾼다. 이 완료 작업판은 PR #19의 일반 merge와 함께 main에 반영한다. 실제 merge SHA와 #12 CLOSED 확인은 해당 이슈에 기록한다. #13은 ready/미착수이고 제품 코딩은 진행하지 않았다.


## UX-R03 시설·자원 설명 — 2026-11-15

- 시작 패킷: 최신 main `37c8db173065dbb10046e559a3063cfdcb073a3f` clean에서 `feature/UX-R03-preview` 생성. 실제 #13과 UX006/007/008/013/014/021/023을 확인하고 claim/in-progress를 기록·재조회했다. 사람 담당 jsjavsj, Worker ux12_worker, 독립 Verifier ux11_verifier.
- 현재 턴 snapshot·draft의 깊은 사본에 기존 simulate_turn을 적용하는 읽기 전용 preview를 추가했다. 현재 E/용량, 배치 후 용량, 확정 때 초과 전력 감소, 이번 턴 진행 후 예상은 분리한다. 사건 미선택은 선택별 조건부 결과이며 다음 미공개 턴은 계산하지 않는다.
- 시설 카드에 비용·효과·대가, 선택 칸의 대피소 할인과 예산 부족량을 표시한다. 부족해도 설명 선택은 가능하며 실제 배치 대상 칸으로 비용을 판단한다. 필수 사건 대응은 진행 버튼 옆에서 안내하고 선택·취소 때 오래된 알림을 해소한다.
- 산소 생산/소비/실제 증가/상한, 가동 횟수 기준 재배·정지·수확, 공개된 보급의 1회 여부를 표시한다. 안전/전력 중단의 미계산 항목은 0과 구분하며 전력 중단에서는 소비 대신 필요 전력으로 표시한다. 계산 규칙·수치·원본 모델은 변경하지 않았다.
- 독립 검사 2,070개 통과: 기존 246 + 현재 턴 preview 635 + guidance UI 1,189. 실제 commit 결과 대조, 깊은 반환값 변형·반복 조회 불변성, 배터리 추가/철거/취소, 사건 조건부, 재배 가동/정지, 산소 상한, 보급 중복, 예산 3에서 차폐 칸 대피소 배치 경계를 확인했다.
- 실제 렌더 1,219개 검사 통과. 1920×1080, 1280×720, 1024×768, 800×900 및 경계 1100×720/1152×720의 시작·단말기·사건·미리보기·안내서 PNG 30개는 로컬 logs/ux13에 보존한다. 펼친 예상 높이가 지도 셀을 늘리지 않는 검사도 포함한다. Godot 4.7.2 Windows/OpenGL, 격리 APPDATA를 사용했다.
- Web export 성공. 최종 Native·Web GUI 인수 결과와 검사 소스 SHA는 다음 기록에 추가한다. 실제 아동 이해도 관찰·영문 런타임·Chrome/Edge 전체 환경 행렬은 이번 자동 검사에 포함하지 않는다. #14 구현은 시작하지 않았다.

- 검사 소스 `c47ac0677918a26243faed15f951136e62160746`. PM은 최종 Native PID9724에서 시작/E, 배터리12 배치(현재20/20·배치용량40)와 취소, 발전기01+배터리12+재배실14의 T1 예상28/40·O62·F30 및 확정 실제값 일치를 확인했다. T2 조건부 재배 유지18/40·절전22/40, 절전 선택의 단일 예상22/40·O64·F24와 확정 실제값, T3까지 지속되는 정지 안내를 확인했다. 미리보기·지도·스크롤도 정상이다.
- PM은 독립2,070개 및 실제 GUI로 #13 인수 충족을 확인했다. Web export와 HTTP200/PCK 확인을 완료했으며 실제 Chrome/Edge 전체 행렬은 이번에 실행하지 않았다. [PR #20](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/pull/20)을 일반 merge하며 이 완료 작업판을 함께 반영한다. 이후 실제 merge SHA·#13 CLOSED 재조회는 이슈에 기록한다. #14는 ready/미착수이며 구현하지 않았다.
