# UX-R06 구현과 남은 인수 검증 — 2026-11-15

## 상태

#16 구현·자동 검사와 실제 렌더 검토를 진행했다. 최종 Chrome/Edge 실제 입력·Alt-Tab·브라우저 cold load는 **미실행**이며 이슈는 OPEN 검증 대기로 유지한다. #7 제출은 보류다. 배포 서버 설정·압축 적용·배포를 수행하지 않았다.

## 환경과 범위

- Windows, Godot 4.7.2.stable.official.ed1daf0bf, OpenGL Compatibility, 프로젝트 격리 APPDATA.
- 구현 Worker ux12_worker, 독립 Verifier ux11_verifier, PM root.
- 규칙/simulation/snapshot_store 및 원본 모델은 변경하지 않았다.
- 코드로 만든 실제 시설 배치/실행 결과와 UI 신호·InputEvent·focus_exited 신호를 검사했다. 이는 OS의 물리 키보드·Alt-Tab 시험이 아니다.
- PM이 실제 렌더 이미지에서 4크기(1920×1080,1280×720,1024×768,800×900)의 강조/관찰/안내 가독성을 확인했다. 초기 synthetic 위치 안내 이미지는 실제 playerpose와 camera 위치에 일치하는 먼곳 렌더로 교체했다.

## 기능 확인

- 지도 01/05/13/21/25 및 빈칸과 world slot_position 매핑, 별도 테두리·번호/시설명. 원본 모델/충돌 변경 없음.
- 미확정 배치 포함 여부를 명시하고 관찰 카메라만 이동한다. 선택해제/취소/철거/턴완료/복원에서 이전 건물 강조 잔상을 남기지 않는다.
- 관찰→H안내서→Esc관찰→Esc단말기, 포커스 상실→pause 및 원래 카메라, 이후 탐색→플레이어 카메라. 초기 카메라/플레이어 카메라 양쪽 복귀와 pose 불변 검사.
- 성공/3종중단에서 읽기 전용 선택·관찰, 종료된 턴의 배치·추가 진행 금지.
- 로봇은 모델과 충돌을 가진 위치 표식이며 별도 대화/퀘스트/로봇E 상호작용은 미제공이다. E 상호작용은 기존 2m ray가 단말기를 보는 조건을 유지한다.
- 복귀 안내는 현재위치와 플레이어 방향을 사용한다. 시설 사이/바깥 통로를 따라 남쪽 입구의 로봇 옆 단말기로 돌아오며 이동 중 턴·자원은 변하지 않는다.

## 실제 브라우저 미실행 범위

Computer Use에서 Edge의 현재 브라우저 URL을 확신할 수 없어 해당 turn의 컴퓨터 조작을 종료했다. 우회 도구를 쓰지 않았다. Chrome의 이전 T7 화면과 Edge의 로딩 화면 관찰은 최종 후보 검증으로 계산하지 않는다.

남은 인수: 최종 소스의 정상7턴·전력/생명유지/안전 중단·복원·동일턴 비교를 실제 Chrome/Edge에서 확인하고 탐색/단말기/안내서/관찰의 Esc·Alt-Tab·재개, 캐시를 비운 cold load의 전송량과 초기화 완료시간을 기록한다. 설치/도구 실패와 기능 실패를 구분한다. 실제 아동 이해도·영문 런타임 지원도 검사하지 않았다.

## 로딩 측정

이 저장소 문서에서는 실제 배포 URL을 확인하지 못했다. 기존 `http://127.0.0.1:8072/` 로컬 서버만 읽기 전용 HTTP GET으로 측정했다. 원본 파일과 받은 본문 바이트/SHA256을 대조했다. 브라우저 cache/cold load/wasm 초기화 시간이나 네트워크 전체 wire 바이트 측정이 아니다. GET 소요시간은 로컬 단일 HTTP 요청의 참고값이며 사용자 체감 로딩으로 사용하지 않는다.

최종 파일 수치·해시는 후속 측정 표에 기록한다. Content-Encoding이 없는 환경에서 gzip/Brotli 전송 검토는 가능하지만 실제 채택 시 MIME·중복압축·브라우저 로딩을 별도 검증해야 한다. 이 작업에서는 서버 설정을 바꾸지 않았다.

### 최종 로컬 HTTP 측정

측정 UTC: Sun, 15 Nov 2026 07:35:08 GMT. 모든 파일 HTTP200, `Cache-Control: no-store`, `Transfer-Encoding: chunked`, Content-Encoding과 Content-Length 헤더는 없음. 수신 본문과 로컬 파일 SHA256이 일치했다.

| 파일 | 원본/수신 본문 바이트 | MIME | 단일 GET 초 | SHA256 |
| --- | ---: | --- | ---: | --- |
| index.html | 5303 | text/html | 0.0585 | `5580d66ba9f75617ad8f5deef0b8b470afd6169afaa844ccaf09296ea705711d` |
| index.js | 279815 | text/javascript | 0.003 | `33c94cb3175f3333b82e2a3be5e8e86f77986f0aa2042b1631f6367a4e5bb6ba` |
| index.wasm | 39514754 | application/wasm | 0.0711 | `fc74679e3b97f76878947fcd4fbe1268cbfa6188182a2e33bbc3f5dc9bfa57d0` |
| index.pck | 7409668 | application/octet-stream | 0.0204 | `0536f1b2d1ef0240e9605dcdc34e5d4e144cacd5c8ef34801615f25bce7f9bd0` |

wasm 39,514,754 bytes는 약39.5 MB(10진 단위)로 기존 보고값과 규모가 같지만 이번 **로컬 서버 실측**이다. 배포 환경의 압축/캐시/체감 로딩 결과로 확대하지 않는다.

## 자동 검사와 렌더 결과

최종 독립4,338 checks/0fail: 기존 core/generator/facility/learning/navigation246 + guidance1,273 + preview635 + outcome1,117 + rewind583 + world484. 종료4종 readonly 선택/관찰/advance금지 및 최신 종료안내 문구를 포함한다.

실제 world 렌더는484 checks/0fail(당시 world452+PNG32), 이후 초기카메라/방향/종료조회32 assertions를 추가해 최종 headless484를 통과했다. 같은 제품의 종료4종 outcome 렌더1,149 checks/0fail 및 별도 관찰PNG16개를 생성했다. 로컬 logs/ux16에는 총48 PNG가 있으며, 로그·스크린샷은 로컬 증거로 보존한다. 수동 OS 입력 검증과 구분한다.
