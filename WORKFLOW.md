# 두 사람이 이어서 진행하는 워크플로 — 2026-11-15

## 필수 NASA 활용 보완 — 현재 우선 작업

PR #62의 FLR 수집/표시만으로 필수 자료 활용을 완료한 판단을 정정하고 #58/#61을 재개했다. #58은 FLR/SEP/CME 실제자료, #63은 자료 기반 훈련 규칙, #64는 원인·선택·결과 화면을 각각 별도 worktree로 병렬 구현하며 #61이 통합한다. 현재 명세는 [NASA_GAMEPLAY_FIX](docs/NASA_GAMEPLAY_FIX.md)다. 아래 v0.2 완료 기록보다 이 수정의 연결 PR/이슈 상태와 인수 결과를 우선한다.

## 최신 feed 픽스 통합

사용자가 승인한 [feed 우선 픽스 명세](docs/FEED_FIX_SPEC.md)에 따라 #58 NASA 자료 / #59 통신 규칙 / #60 화면을 별도 worktree에서 병렬 구현하고 #61에서 통합했다. 검사 제품 SHA `9ff9639`: Godot import 성공, 핵심 headless 997/0, 실제 OpenGL 렌더 144/0 및 두 해상도 PNG 확인. 실제 NASA API/Godot 요청 성공과 모의 실패 대체를 구분해 기록했다.

이 변경의 main 병합·#58~#61 종료는 연결 PR/이슈의 상태를 기준으로 확인한다. 완료된 기능을 다시 구현할 필요는 없다. #29는 사용자 Native/Web/iframe 및 브라우저 자료 조회 확인, #47은 기존 현장 조작의 사용자 인수를 계속 추적한다. #7 제출은 보류이고 기존 Web 빌드/서버는 갱신하지 않았다. 아래 과거 절의 열린 이슈 개수·현재 작업보다 이 절을 우선한다.

## 최신 이슈 정리 — 2026-11-15

완료된 구현 이슈 #26/#27/#28/#38/#39를 CLOSED로 정리했다. 남은 실제 플레이·환경별 확인은 #29 한 곳에서 추적하며 미실행 검사를 PASS 처리한 것은 아니다. A~D #43~#46도 CLOSED다.

열린 이슈는 3개: #47 실제 기능 연결·최소 인수, #29 기존 구현 기능의 최종 플레이 확인, #7 보류 중인 제출 준비. 따라서 8개 기능을 새로 구현해야 하는 상황이 아니다. 이하 과거 이력의 개별 OPEN/사용자 확인 대기 표현보다 이 최신 상태를 우선한다.

게임과 시설 5종·안내 로봇·한국어 안내서를 구현했다. 검증한 게임 기준은 `9907d51d54b0b3a638cd61a6c7de29f46ff46e49`이며 모델과 한국어 안내서는 PR #8·#9에서 통합했다. 자동 검사 176개가 통과했다. [#6](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/6)은 팀원 Native 및 사용자 Chrome·Edge 결과로 승인된 MVP 검증을 완료했다. 환경별 미실행 항목은 이슈에 보존했다. [#7 제출](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/7)은 보류 중이다.

앞으로 통합된 제품을 보거나 같은 빌드를 검사할 때는 `origin/main`의 정확한 커밋을 기준으로 한다. 이전 `feature/HH-001-core-loop`는 MVP 통합 이력이다. 승인된 규칙 원계약 `410063037ba62da61f9119b4ba8b10cbdadc9ccb`을 유지한다.


현재 추가 작업은 [현장 조작·어린이용 운영 화면 명세](docs/OPERATIONS_UI_PARALLEL_SPEC.md)를 따른다. 본인 dyhan0528는 #43 현장 대상 감지 / #44 단말기 화면 / #45 자원 그래프를 각각 별도 worktree·세션으로 병렬 수행한다. 팀원 jsjavsj는 #46 독립 시설 정보 카드 1개를 맡는다. #47은 본인 통합 담당이며 공통 연결은 앞선 작업 인계 후 수행한다. A/B/C는 PR #50/#51/#49로 구현·검사·main 통합 완료했으며 #43/#44/#45를 CLOSED 처리했다. 최종 연결·사용자 인수는 #47에서 별도로 추적한다. #47에 API와 terminal 소유권을 반환했으며 #46 카드도 PR #53 병합·인계 완료로 CLOSED이며 #47 현장 E·그래프·시설 카드 연결 구현과 핵심 검사가 완료됐다. #47은 사용자 최종 확인 대기다. 상세 검사·미실행 범위는 운영 화면 명세의 A/B/C 인계 절을 따른다. #39는 PR42 코드 통합 완료·사용자 인수 대기이고, PPT·영상은 이번 범위에서 제외한다. 각 세션의 공용 문서 변경은 #47에서 모은다.

## 지금 할 일

| 담당 | 지금 | 다음 전달물 |
| --- | --- | --- |
| dyhan0528 | 게이지 #25 완료; #38 수정 통합, #29 최종 인수 대기 | #39 통합 후 사용자 플레이 및 환경별 미검증 확인 |
| jsjavsj | PE-02/03 통합·PR #37 교차 검사 완료; #39 수정·독립2895검사 완료 | 수정 PR 인계 및 사용자 직접 플레이 인수 대기 |
| 독립 검증 담당 | 각 리팩터링 착수 때 구현자와 별도로 지정 | 검사 커밋·환경·결과 |
| 제출 담당 | #7 보류. 작업 변화에 맞추어 로컬 문서 갱신 | 제출 재개 시 최종 빌드·접근 확인 |

기존 UX-R01~06은 완료했다. 이번 PE 추가 작업은 [플레이 경험 개선 명세](docs/PLAY_EXPERIENCE_SPEC.md)의 파일 소유권과 의존성을 따른다. 본인 게이지/팀원 캐릭터, 이어서 본인 마우스/팀원 점프를 병렬 진행한다. player.gd의 마우스 입력 연결과 player.tscn 장착은 팀원 점프 작업 종료 뒤 본인이 통합한다. 사용자 최신 요청에 따라 이번 범위는 두 사람이 구현을 나누며 기존 디자인 전담 역할을 적용하지 않는다.

## 팀원 jsjavsj가 할 검사

아래 흐름은 관련 리팩터링의 회귀 검사용이다. 검증이 끝난 #6은 근거 기록으로 두고, 새 결과와 결함은 해당 UX 이슈에 남긴다. 진행 중인 작업 폴더는 보존하고 검사가 필요하면 깨끗한 별도 복사본을 사용한다.

1. 기준이 되는 `origin/main`과 실제로 실행한 기능 브랜치 또는 병합 커밋의 SHA를 기록한다.
2. 정상 배치: 발전기01·배터리12·재배실14·대피소25, T2 재배 유지·T4 대피·T5 확인으로 7턴을 끝낸다.
3. 배터리 없이 T3 전력 중단→T2 시작으로 복원→절전 선택. 같은 T3의 중단/완료와 E/O/F 차이를 비교한다.
4. 시설별 충돌·통로, 로봇 앞 단말기 E, Esc/마우스 캡처, 배치 취소·되감기 이후 위치를 확인한다.
5. #5 통합 뒤 한국어 글자 누락/잘림, 키보드 초점, 도움말·출처·사건 설명을 확인한다. 현재 설치된 Edge와 Chrome 결과를 각각 기록하며 설치되지 않은 브라우저는 미실행으로 적는다.

결과는 해당 UX 이슈에 `PC/OS, commit SHA, Godot·브라우저 버전, native/Web, 단계, 기대/실제, pass/fail/미실행, 화면·로그 위치`로 남긴다. 각자 실제 확인한 범위만 적는다.

## main에 통합하는 방법

`git fetch origin`으로 최신 `origin/main`을 확인하고 해당 이슈의 작업 브랜치를 만든다. 기능·수정·문서 변경은 작업 브랜치에서 검사한 뒤 `main` 대상 PR을 만들고 일반 merge 커밋으로 병합한다. 리뷰 응답을 기다리지 않는다. GitHub의 통합 브랜치와 실제 배포는 별개이며, 배포는 명시적으로 결정한 뒤 진행한다.

### 이슈와 PR을 함께 갱신하는 규칙

1. 시작할 실제 이슈의 담당·범위·인수 조건을 확인하고 작업 브랜치·claim·실행 기준 SHA를 이슈에 기록한다.
2. PR 본문은 해당 이슈를 `Refs #번호`로 연결한다. `main`으로 병합되고 모든 인수 조건을 해결하는 PR만 `Closes #번호`를 사용한다.
3. 검사한 source SHA·검사 결과·미실행 범위를 PR에 기록하고, 이슈에도 PR 링크와 현재 상태를 반영한다. 사용자 요청대로 사람/AI의 PR 리뷰 응답을 기다리지 않는다.
4. 검사 통과 후 일반 merge하고 원격 `main` SHA와 PR의 실제 MERGED 상태를 확인한다. 별도 작업이 남아 있으면 이슈를 OPEN으로 두고 남은 작업과 담당을 적는다.
5. 인수 완료 이슈만 실제 close하고 다시 조회한다. PR 병합·이슈 종료·문서의 현재 상태를 같은 작업에서 갱신한다. 테스트만 통과하거나 PR만 병합됐다는 이유로 미완료 인수 조건을 숨기지 않는다.

완료 보고에는 **로컬/원격 SHA, PR 번호·상태, 연결 이슈 번호·상태, 남은 다음 작업**이 서로 일치해야 한다. 로컬 전용 기록은 Git에 포함하지 않는다.
아래는 환경 재현이 필요할 때 사용하는 기존 상세 절차다. 이미 완료된 최초 준비·첫 모델 작업을 다시 할 목록이 아니다. 현재 담당 작업은 위 표와 최신 이슈를 우선한다.
## 준비 단계에서 AI가 맡을 일

- 기존 결정·Git 권한을 반복 질문하지 않고 재사용한다. PM은 읽기·계획·조정, 이름 있는 Worker는 쓰기, 자신이 구현하지 않은 Verifier는 독립 검사를 맡는다.
- 현재 파일·이슈를 읽고 담당·경로·기준 커밋을 대조한다. 이미 준비된 작업을 반복하지 않는다.
- 각 PC의 결과만 기록한다. 상대 PC가 아직 확인되지 않았다면 정확히 미확인으로 남긴다.
- 설치가 필요하면 공식 링크와 필요한 도구 하나를 안내하고 정확 실행 버전을 기록한다. 예전 프로그램 탐색 실패를 시스템 전체 미설치로 단정하지 않는다.
- 준비 체크가 모두 맞으면 이슈의 blocked→ready→실제 claim/in-progress를 조회·갱신·재조회하고 해당 Worker에게 작업을 넘긴다. 준비가 빠지면 구현 대신 독립적인 읽기·자료 조사·규격 정리를 계속한다.
- 모호한 신규 범위·비용·권한이나 충돌만 사람에게 묶어 묻는다. 기존 승인 범위의 반복 검사·문서 정정·이슈 갱신은 계속 수행한다.

## 공통 PowerShell 확인 — AI가 실행·해석할 상세 절차

먼저 자기 프로젝트 폴더에서 PowerShell을 연다. 아래 블록은 비밀 값을 출력하지 않는다.

```powershell
$RepoRoot = (Get-Location).Path
$Repo = 'NASA-HACKATHON-Mis/Mismatch-3d-Training-Game'
$ExpectedOrigin = 'https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game.git'
git --version
gh --version
$ActualRoot = git rev-parse --show-toplevel
if ($LASTEXITCODE -ne 0) { throw '저장소가 아닙니다. 본인/팀원 절차를 먼저 확인하세요.' }
if ([IO.Path]::GetFullPath($ActualRoot) -ne [IO.Path]::GetFullPath($RepoRoot)) { throw '상위 저장소입니다. AI에게 루트 확인을 요청하세요.' }
if ((git remote get-url origin) -ne $ExpectedOrigin) { throw 'origin이 다릅니다. 덮어쓰지 마세요.' }
git status --short --branch
git rev-parse HEAD
gh api user --jq .login
$HasName = -not [string]::IsNullOrWhiteSpace((git config --get user.name))
$HasEmail = -not [string]::IsNullOrWhiteSpace((git config --get user.email))
"Git 신원 존재: name=$HasName email=$HasEmail"
```

본인은 dyhan0528, 팀원은 jsjavsj 계정으로 접속한다. 로그인하지 않았다면 자기 PC에서 `gh auth login`을 진행한다. 토큰·비밀번호를 채팅이나 파일에 보내지 않는다. Git 이름/이메일은 커밋에 공개되는 정보이므로 기존 값이 본인인지 비공개 확인하며 상대방 값을 복사하지 않는다. AI가 이미 승인된 본인 Git 설정을 재사용해 START D에 따른 개인 파일 준비·검사를 진행한다. 같은 이름·이메일을 다시 입력하는 숙제를 사람에게 주지 않는다. 각 PC에서 본인 값만 사용하고 `.user_info`에 토큰 저장·타인 파일 복사·Git 추적을 금지한다. 본인 PC의 개인 파일·점검 도구 준비와 실행은 완료했다(환경 기록 참조). 팀원 PC는 별도로 실제 확인하며 본인 결과를 복사하지 않는다.

## 프로그램 준비

- [Godot Windows 공식 다운로드](https://godotengine.org/download/windows/): 일반판 x86_64 **4.7.2**와 같은 버전 export templates가 현재 고정 후보다. 기존 설치가 있으면 먼저 경로·버전을 확인한다. 본인 PC는 4.7.2.stable.official.ed1daf0bf와 동일 템플릿 실행 준비를 완료했다. 경로·격리 실행법은 docs/ENVIRONMENT.md를 따른다. 팀원 PC는 별도 확인한다. C#/.NET판은 웹 목표에 사용하지 않는다.
- [Blender 공식 다운로드](https://www.blender.org/download/) 또는 [공식 LTS](https://www.blender.org/download/lts/): 설치된 버전을 우선 확인한다. 없다면 공식 LTS를 설치하고 실제 버전을 기록한다. 최신 번호를 추측하거나 재설치를 강제하지 않는다.
- [Git Windows](https://git-scm.com/downloads/win), [GitHub CLI](https://cli.github.com/): 명령이 없다면 해당 도구만 준비한다.

이미 설치된 프로그램이 PATH에 없다면 실제 exe 경로를 사용한다. 아래는 값 입력용 예시이며 존재하지 않는 경로를 그대로 실행하지 않는다.

```powershell
$GodotExe = 'C:\실제설치경로\Godot.exe'
if (-not (Test-Path -LiteralPath $GodotExe -PathType Leaf)) { throw '실제 Godot exe 경로로 바꾸세요.' }
& $GodotExe --version
# 모델링 PC에서만 같은 방식으로 실행
$BlenderExe = 'C:\실제설치경로\blender.exe'
if (Test-Path -LiteralPath $BlenderExe -PathType Leaf) { & $BlenderExe --version }
```

Godot Compatibility 렌더러, GDScript, 단일스레드 Web export를 사용한다. Blender는 GLB와 1m 큐브 import로 호환성을 확인한다. 설치는 각 PC에서 실제 수행 여부와 결과를 기록하며 이 문서 작성 자체를 설치 완료로 처리하지 않는다.

## 본인 dyhan0528의 초기 준비 기록

현재 본인 폴더는 `C:\Users\USER\Desktop\나사 첼린지\Junior-Astronaut-Mission-Trainer`다. **이미 저장소가 있으므로 재clone하거나 init하지 않는다.**

1. 위 공통 확인과 Godot 버전 확인을 실행하고 [HH-001](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/1)을 읽는다.
2. AI가 아래 브랜치 절차로 `feature/HH-001-core-loop`를 재사용한다. docs 브랜치에 제품을 만들지 않는다.
3. START_SPEC의 상태·슬롯·턴·복원 계약과 아래 준비 체크를 맞춘다. 필요한 자료·버전 증거는 AI가 정리한다.
4. ready/claim 확인 후 임시 도형 이동→단말기 한 시설 배치→한 턴→위치 복원→비교→웹 출력을 만든다. 첫 결과물은 예쁜 모델이 아니라 끝까지 작동하는 작은 연결본이다.
5. 연결본의 인터페이스·커밋·실제 웹 결과를 HH-001에 남긴다. 그 뒤 HH-002/003/005를 진행하고 팀원 GLB를 wrapper에 붙인다.

## 팀원 jsjavsj의 초기 준비 기록

새 복사본이 아직 없을 때만 아래를 실행한다. `source` 위치는 자기 PC에서 쓰기 가능한 폴더로 바꿀 수 있다. 대상 폴더가 이미 있으면 clone하지 말고 기존 폴더를 확인한다.

```powershell
$ParentDir = Join-Path $env:USERPROFILE 'source'
$TeamRoot = Join-Path $ParentDir 'Mismatch-3d-Training-Game'
if (Test-Path -LiteralPath $TeamRoot) { throw '기존 폴더가 있습니다. 덮어쓰지 말고 그 폴더를 확인하세요.' }
New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
git clone --branch feature/HH-004-assets 'https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game.git' $TeamRoot
if ($LASTEXITCODE -ne 0) { throw 'clone 실패. 실제 오류를 AI에 전달하세요.' }
Set-Location -LiteralPath $TeamRoot
```

1. 자기 복사본에서 공통 확인·Blender 실제 버전·Git 신원을 확인한다. 본인 PC 검사 결과를 복사해 쓰지 않는다.
2. [HH-004](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/4)와 ASSET_BRIEF를 읽고 레퍼런스·치수·파일 목록을 정리한다. 이 준비는 게임 실행 파일이 없어도 가능하다.
3. **모델 제작도 공통 구현 준비 조건을 확인한 뒤 시작한다.** 레퍼런스 준비가 가능하다는 이유로 준비 gate를 면제하지 않는다. HH-004는 준비 활동과 제작/통합 완료를 따로 기록한다.
4. 첫 제작은 발전기+1m 큐브다. 원본·GLB·manifest를 feature 브랜치로 인계한다. Godot 씬·충돌 wrapper·게임 코드는 편집하지 않는다.
5. core 담당의 import/슬롯/웹 확인을 받은 뒤 시설 5종·안내 로봇으로 확장한다. 모델 제작 준비와 게임 통합은 별개이며 최종 HH-004 완료는 통합 검증까지 포함한다.

## 초기 작업 브랜치와 계약 커밋 확인 기록

최초 `feature/HH-001-core-loop`, `feature/HH-004-assets`는 이 문서의 시작 계약 커밋에서 준비한다. 정확 기준은 이슈 본문의 `Contract-Commit:` 행이다. docs의 뒤따르는 진행 기록 커밋과 제품 기준을 혼동하지 않는다. 원격 브랜치를 이미 사용 중이면 강제로 새 기준으로 되돌리지 않는다.

아래에서 본인은 IssueNo=1, 팀원은 IssueNo=4를 사용한다. dirty 상태면 즉시 멈춰 기존 변경 소유자와 처리 방법을 AI가 확인한다. 삭제·reset·stash로 치우지 않는다.

```powershell
$IssueNo = 1 # 모델링 담당은 4
$TaskBranch = if ($IssueNo -eq 4) { 'feature/HH-004-assets' } else { 'feature/HH-001-core-loop' }
$Dirty = @(git status --porcelain)
if ($Dirty.Count -gt 0) { throw '기존 변경이 있습니다. 보존하고 AI에게 보여주세요.' }
git fetch origin
if ($LASTEXITCODE -ne 0) { throw 'fetch 실패' }
$IssueBody = gh issue view $IssueNo --repo $Repo --json body --jq .body
if ($LASTEXITCODE -ne 0) { throw '이슈 조회 실패' }
$ContractMatches = [regex]::Matches(($IssueBody -join "`n"), '(?m)^Contract-Commit: ([0-9a-f]{40})\s*$')
if ($ContractMatches.Count -ne 1) { throw '명세 커밋 표기가 모호합니다. AI가 이슈를 대조해야 합니다.' }
$ContractCommit = $ContractMatches[0].Groups[1].Value
git cat-file -e "$ContractCommit^{commit}"
if ($LASTEXITCODE -ne 0) { throw '계약 커밋이 없습니다.' }
git merge-base --is-ancestor $ContractCommit origin/docs/mission-spec-v2
if ($LASTEXITCODE -ne 0) { throw 'docs 이력과 계약 기준이 다릅니다.' }
git show-ref --verify --quiet "refs/heads/$TaskBranch"
if ($LASTEXITCODE -eq 0) {
    git switch $TaskBranch
} else {
    git show-ref --verify --quiet "refs/remotes/origin/$TaskBranch"
    if ($LASTEXITCODE -ne 0) { throw '준비된 원격 작업 브랜치가 없습니다. 임의 생성 대신 AI가 상태를 확인합니다.' }
    git switch --track -c $TaskBranch "origin/$TaskBranch"
}
if ($LASTEXITCODE -ne 0) { throw '브랜치 전환 실패' }
git merge-base --is-ancestor $ContractCommit HEAD
if ($LASTEXITCODE -ne 0) { throw '작업 브랜치가 계약 커밋을 포함하지 않습니다.' }
git status --short --branch
git rev-parse HEAD
```

기존 local/remote가 갈라졌거나 예상 밖 변경이 있으면 두 이력과 담당을 먼저 확인한다. 위 명령은 MVP 시작 시점의 기록이다. 현재 이슈는 [main에 통합하는 방법](#main에-통합하는-방법)을 따른다.

## 준비 완료 체크 — AI가 갱신

| 확인 | 누가 실제 증거를 제공하나 | 현재 미충족이면 할 일 |
| --- | --- | --- |
| 프로젝트 루트·계정·브랜치·신원·dirty | 각 PC의 담당자/그 PC AI | 공통 명령 실행, 비밀 값 제외 기록 |
| Godot·templates·브라우저 / Blender | 해당 도구를 사용하는 PC | 실제 버전·경로·실행 결과 기록 |
| 검토된 수치·인터페이스·계약 커밋 | PM/Worker/Verifier | START_SPEC 규칙·검산·미확인 자료 대조 |
| 실제 이슈 7개·담당·허용 경로·의존 | AI가 GitHub 조회 | blocked 사유별 증거와 해제 조건 갱신 |
| 두 사람의 별도 복사본·같은 원격·기준 커밋 | 두 PC 각각 | 한 PC 결과로 다른 PC 완료 표시 금지 |
| source·자료 사용 조건과 교육용 표시 | 자료 담당 AI | DATA_SOURCES의 완료 자료와 새 자료 사용 조건을 대조 |
| 해당 ready 이슈의 실제 claim·충돌 없음 | 해당 Worker와 PM | 이슈 조회→in-progress 기록→재조회 |

모든 준비 조건을 WORK와 이슈에 근거로 연결하기 전 제품 코딩·모델 제작을 시작하지 않는다. 미충족 항목을 숨기거나 local-only 예외를 추정하지 않는다. 환경 확인·독립 자료 조사·레퍼런스 정리는 계속할 수 있다.

## 제품이 생긴 뒤 실행·검사

아래는 공식 CLI에 따른 **조건부 명령**이다. 아직 실행하지 않았고 현재는 파일 guard에서 멈추는 것이 정상이다. Godot exe는 위에서 확인한 실제 경로를 사용한다.

```powershell
if (-not (Test-Path -LiteralPath './project.godot')) { throw '아직 게임 프로젝트가 없습니다. HH-001 준비부터 진행하세요.' }
if (-not (Test-Path -LiteralPath $GodotExe -PathType Leaf)) { throw 'Godot 실행 경로를 먼저 확인하세요.' }
& $GodotExe --headless --path . --editor --import
if ($LASTEXITCODE -ne 0) { throw 'import 실패' }
# 화면·입력 검증은 GUI 실행 후 수행
& $GodotExe --path .
```

Web export는 일치하는 export templates와 이름이 정확히 `Web`인 preset을 확인한 뒤에만 실행한다. preset 존재 파일만으로 템플릿 설치 완료를 추정하지 않는다.

```powershell
if (-not (Test-Path -LiteralPath './project.godot')) { throw '제품 프로젝트 없음' }
if (-not (Test-Path -LiteralPath './export_presets.cfg')) { throw 'Web preset 없음' }
# AI/담당자가 Godot UI에서 Web preset과 동일 버전 templates를 실제 확인한 다음 실행
New-Item -ItemType Directory -Path './build/web' -Force | Out-Null
& $GodotExe --headless --path . --export-release 'Web' './build/web/index.html'
if ($LASTEXITCODE -ne 0) { throw 'Web export 실패' }
```

Godot 편집기의 로컬 Web 실행 기능이나 확인된 로컬 정적 서버로 열고 정확 브라우저 버전·GPU·로딩·입력·복원을 기록한다. `file://` 더블클릭을 웹 검증으로 대체하지 않는다. Python이 이미 있다면 `python -m http.server 8000 --directory build/web`를 사용할 수 있으나 설치 여부를 확인하고, 이를 위한 새 런타임 설치를 자동 전제하지 않는다.

`--check-only`는 `--script`와 함께 쓸 때 스크립트 문법 검사이며 게임·씬·웹 통합 검증을 대신하지 않는다. [Godot 공식 CLI](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html), [웹 export 조건](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)을 기준으로 한다.

## 작업 결과를 넘기는 방법

Worker는 바뀐 명시 파일만 검토·stage하고 해당 feature 브랜치로 commit/push한 뒤 원격 SHA를 대조한다. 사람에게 “다 됐는지 알아서 확인”을 맡기지 않고 다음 내용을 이슈에 남긴다: 결과물 경로, 정확 커밋, 실제 검사 명령/버전/결과, 미실행 영향, 다음 담당과 선행 해제 조건.

MVP 자산·wrapper 통합은 `feature/HH-001-core-loop`에 기록되어 있다. 현재 UX 리팩터링은 대상 이슈와 검사한 정확한 커밋을 연결한 뒤 `main`에 PR을 만든다. 배포와 제출은 별도 결정이다.

## MVP 초기 인계 요청문 기록

**본인 PC / dyhan0528**

> 이 저장소의 README, WORKFLOW, START_SPEC, SPEC, WORK와 GitHub HH-001 이슈를 읽어 줘. 나는 dyhan0528이고 게임 구현 담당이다. 현재 루트·계정·브랜치·dirty·계약 커밋과 실제 도구 버전을 확인하고, 이미 확인된 결정은 반복 질문하지 말아 줘. PM/Worker/독립 Verifier 역할로 준비 상태를 관리하고 필요한 질문은 한 번에 묶어 줘. 구현 준비 조건과 실제 claim이 충족되기 전 코딩하지 말고, 그동안 환경 확인·자료 검토·명세 정리를 진행해 줘. 준비되면 승인된 feature/HH-001-core-loop에서 임시 도형 연결본과 초기 웹 검증부터 진행해 줘. 기존 변경·main·다른 담당 경로는 건드리지 마.

**팀원 PC / jsjavsj**

> 이 저장소의 README, WORKFLOW, ASSET_BRIEF, START_SPEC, WORK와 GitHub HH-004 이슈를 읽어 줘. 나는 jsjavsj이고 모델링 담당이다. 내 PC의 Blender 버전·Git 신원·계정·브랜치·계약 커밋을 실제 확인해 줘. 다른 PC가 준비됐다고 추정하지 말고, 부족한 공통 준비 조건을 AI가 정리해 줘. 준비 전에는 레퍼런스·치수표·체크리스트만 정리하고, 준비와 claim 확인 뒤 feature/HH-004-assets에서 발전기+1m 큐브를 먼저 제작해 줘. 자산 경로만 맡고 Godot 씬·충돌·코드는 core 담당에게 남겨 줘. GLB·원본·manifest·검사 결과·커밋을 이슈로 인계해 줘. 기존 승인과 결정을 반복 질문하지 마.

이번 NASA 후속 구현은 실제 자료 조건에 따라 게임 결과가 달라지는 것까지 확인했다. 검사 제품 `4ec6b79`: 핵심 headless1041/0, OpenGL 두 해상도82/0, 실제 Godot FLR/SEP/CME 조회 성공. #58/#63/#64/#61은 연결 PR이 main에 병합되면 구현 완료로 종료한다. 사용자의 Native/Web/iframe 인수 #29/#47 및 제출 보류 #7은 유지한다. 원문/규칙/검사 근거는 NASA 게임 연결 명세를 따른다.
