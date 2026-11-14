# 두 사람이 바로 시작하는 워크플로 v1

**현재 `project.godot`와 게임·모델 파일은 없습니다. 아래 환경 확인은 가능하지만 게임 실행은 제품 파일을 만든 뒤에만 가능합니다.**

담당은 dyhan0528=게임, jsjavsj=Blender 모델링입니다. AI가 체크·명세·이슈 상태·인계를 관리합니다. 사람이 매번 새 계획을 만들 필요는 없습니다. 각 사람이 직접 해야 하는 것은 자기 PC에서 실행·로그인·설치가 필요한 경우 그 화면을 처리하고 실제 결과를 AI에 제공하는 일입니다.

## 오늘의 순서

| 순서 | dyhan0528 | jsjavsj | 완료 증거 / 다음 전달물 |
| --- | --- | --- | --- |
| 1 | 기존 폴더 확인·Godot 환경 점검 | 새 복사본·Blender 환경 점검 | 각 PC의 루트/계정/버전/브랜치/HEAD 증거 |
| 2 | START_SPEC·HH-001 계약 확인 | ASSET_BRIEF·HH-004 규격/레퍼런스 정리 | AI가 미충족 준비 조건을 목록화 |
| 3 | 준비 완료 후 임시 3D 연결본·웹 검증 | 준비 완료 후 발전기·1m 큐브 제작 | core 인터페이스/웹 증거 + 첫 GLB |
| 4 | 규칙·복원·설명 확장, GLB import 확인 | 확인된 규격으로 나머지 자산 제작 | feature 커밋·자산 manifest·검사 결과 |
| 5 | 독립 검증·제출 자료 준비 | 모델 결함 수정·재현 보조 | 통합 snapshot·시연·출처·접근 증거 |

현재 공통 준비 상태는 **IMPLEMENTATION_READY=false**입니다. 문서와 실제 이슈 7개는 있으나 도구 실행·두 PC 증거·데이터 검토·작업 claim은 미완료입니다. 숫자 규칙은 START_SPEC v0.1로 설계했지만 문서 산술 검산을 제품 테스트로 간주하지 않습니다.

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

본인은 dyhan0528, 팀원은 jsjavsj 계정으로 접속한다. 로그인하지 않았다면 자기 PC에서 `gh auth login`을 진행한다. 토큰·비밀번호를 채팅이나 파일에 보내지 않는다. Git 이름/이메일은 커밋에 공개되는 정보이므로 기존 값이 본인인지 비공개 확인하며 상대방 값을 복사하지 않는다. AI가 이미 승인된 본인 Git 설정을 재사용해 START D에 따른 개인 파일 준비·검사를 진행한다. 같은 이름·이메일을 다시 입력하는 숙제를 사람에게 주지 않는다. 각 PC에서 본인 값만 사용하고 `.user_info`에 토큰 저장·타인 파일 복사·Git 추적을 금지한다. 현재 개인 파일과 점검 도구 사본 준비는 미수행이며 완료로 표시하지 않는다.

## 프로그램 준비

- [Godot Windows 공식 다운로드](https://godotengine.org/download/windows/): 일반판 x86_64 **4.7.2**와 같은 버전 export templates가 현재 고정 후보다. 기존 설치가 있으면 먼저 경로·버전을 확인한다. 실제 실행 검증은 아직 미완료다. C#/.NET판은 웹 목표에 사용하지 않는다.
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

## 본인 dyhan0528

현재 본인 폴더는 `C:\Users\USER\Desktop\나사 첼린지\Junior-Astronaut-Mission-Trainer`다. **이미 저장소가 있으므로 재clone하거나 init하지 않는다.**

1. 위 공통 확인과 Godot 버전 확인을 실행하고 [HH-001](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/1)을 읽는다.
2. AI가 아래 브랜치 절차로 `feature/HH-001-core-loop`를 재사용한다. docs 브랜치에 제품을 만들지 않는다.
3. START_SPEC의 상태·슬롯·턴·복원 계약과 아래 준비 체크를 맞춘다. 필요한 자료·버전 증거는 AI가 정리한다.
4. ready/claim 확인 후 임시 도형 이동→단말기 한 시설 배치→한 턴→위치 복원→비교→웹 출력을 만든다. 첫 결과물은 예쁜 모델이 아니라 끝까지 작동하는 작은 연결본이다.
5. 연결본의 인터페이스·커밋·실제 웹 결과를 HH-001에 남긴다. 그 뒤 HH-002/003/005를 진행하고 팀원 GLB를 wrapper에 붙인다.

## 팀원 jsjavsj

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

## 작업 브랜치와 계약 커밋 확인

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

기존 local/remote가 갈라졌거나 예상 밖 변경이 있으면 자동 merge하지 않는다. AI가 두 이력과 담당을 확인한다. 현재 `main`은 없으며 main 생성·merge·push·배포·실제 제출은 지금 자동 실행 범위가 아니다.

## 준비 완료 체크 — AI가 갱신

| 확인 | 누가 실제 증거를 제공하나 | 현재 미충족이면 할 일 |
| --- | --- | --- |
| 프로젝트 루트·계정·브랜치·신원·dirty | 각 PC의 담당자/그 PC AI | 공통 명령 실행, 비밀 값 제외 기록 |
| Godot·templates·브라우저 / Blender | 해당 도구를 사용하는 PC | 실제 버전·경로·실행 결과 기록 |
| 검토된 수치·인터페이스·계약 커밋 | PM/Worker/Verifier | START_SPEC 규칙·검산·미확인 자료 대조 |
| 실제 이슈 7개·담당·허용 경로·의존 | AI가 GitHub 조회 | blocked 사유별 증거와 해제 조건 갱신 |
| 두 사람의 별도 복사본·같은 원격·기준 커밋 | 두 PC 각각 | 한 PC 결과로 다른 PC 완료 표시 금지 |
| source·자료 사용 조건과 교육용 표시 | 자료 담당 AI | 실제 추출/라이선스 미완료를 채움 |
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

jsjavsj는 GLB·원본·manifest를, dyhan0528는 인터페이스·wrapper·실행/웹 증거를 넘긴다. 첫 플레이 가능한 통합 대상은 feature/HH-001-core-loop이고 책임은 dyhan0528이다. 모델과 후속 게임 기능의 PR 대상도 이 core 브랜치로 계획한다. 공유 씬·wrapper·충돌은 core 담당이 해결한다. 이번 준비 작업은 PR 작성·merge를 실행하지 않으며, 실제 source/target 커밋·검증 범위를 기록한 뒤 진행한다. main은 최종 정식 승격 단계로 남긴다. 인수 조건·필요 통합 검증 전 이슈를 닫지 않는다.

## 새 AI 채팅에 붙일 요청문

**본인 PC / dyhan0528**

> 이 저장소의 README, WORKFLOW, START_SPEC, SPEC, WORK와 GitHub HH-001 이슈를 읽어 줘. 나는 dyhan0528이고 게임 구현 담당이다. 현재 루트·계정·브랜치·dirty·계약 커밋과 실제 도구 버전을 확인하고, 이미 확인된 결정은 반복 질문하지 말아 줘. PM/Worker/독립 Verifier 역할로 준비 상태를 관리하고 필요한 질문은 한 번에 묶어 줘. 구현 준비 조건과 실제 claim이 충족되기 전 코딩하지 말고, 그동안 환경 확인·자료 검토·명세 정리를 진행해 줘. 준비되면 승인된 feature/HH-001-core-loop에서 임시 도형 연결본과 초기 웹 검증부터 진행해 줘. 기존 변경·main·다른 담당 경로는 건드리지 마.

**팀원 PC / jsjavsj**

> 이 저장소의 README, WORKFLOW, ASSET_BRIEF, START_SPEC, WORK와 GitHub HH-004 이슈를 읽어 줘. 나는 jsjavsj이고 모델링 담당이다. 내 PC의 Blender 버전·Git 신원·계정·브랜치·계약 커밋을 실제 확인해 줘. 다른 PC가 준비됐다고 추정하지 말고, 부족한 공통 준비 조건을 AI가 정리해 줘. 준비 전에는 레퍼런스·치수표·체크리스트만 정리하고, 준비와 claim 확인 뒤 feature/HH-004-assets에서 발전기+1m 큐브를 먼저 제작해 줘. 자산 경로만 맡고 Godot 씬·충돌·코드는 core 담당에게 남겨 줘. GLB·원본·manifest·검사 결과·커밋을 이슈로 인계해 줘. 기존 승인과 결정을 반복 질문하지 마.
