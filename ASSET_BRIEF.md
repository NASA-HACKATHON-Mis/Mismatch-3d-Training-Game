# Blender 자산 제작·인계 규격 v0.1

담당: **jsjavsj**, 이슈 [HH-004 #4](https://github.com/NASA-HACKATHON-Mis/Mismatch-3d-Training-Game/issues/4), 브랜치 `feature/HH-004-assets`.
현재 모델은 없습니다. 이 문서는 제작 계약이며 import·웹 검증 완료 증거가 아닙니다. 환경·공통 준비 조건을 채우기 전에는 레퍼런스·치수표·체크리스트 준비만 수행합니다. 진행 순서는 [WORKFLOW](WORKFLOW.md#팀원-jsjavsj)를 따릅니다.

## 무엇을 만들고 무엇을 넘기는가

첫 마일스톤은 **발전기 한 개 + 1m 기준 큐브**의 GLB import 검증입니다. 첫 모델이 규격을 통과하면 나머지 시설과 안내 로봇을 같은 규격으로 만듭니다. 전신 우주인·복잡한 리깅은 후순위입니다.

| 자산 이름 | 역할 | 시각 크기 상한(너비×깊이×높이, m) | 우선 |
| --- | --- | --- | --- |
| facility_generator | 태양 발전기 | 4×4×3 | 첫 모델 |
| facility_battery | 배터리 모듈 | 4×4×3 | 필수 |
| facility_habitat | 거주실 외형 | 4×4×4 | 필수 |
| facility_greenhouse | 재배실 외형 | 4×4×4 | 필수 |
| facility_shelter | 수동 차폐 대피소 | 4×4×4 | 필수 |
| guide_robot | 안내 캐릭터 한 개 | 0.8×0.8×1.5 | 시설 후 |
| player_wrist | 장갑·손목 장치 | 0.3×0.4×0.25 | 여유 있을 때 |
| scale_reference_1m | 기준 큐브 | 1×1×1 | 첫 모델과 함께 |

슬롯 간격은 6m이고 시설은 4m 정사각형 안에 들어갑니다. 가장자리 장식·패널·애니메이션도 이 범위를 넘지 않습니다. 남는 2m는 통로입니다. 거주실 내부 탐색·문 열림·차폐의 물리 계산은 MVP에 필요하지 않습니다.

## Blender 제작 규칙

1. 단위는 Metric, Unit Scale 1.0으로 하고 1 Blender unit=1m 기준으로 제작합니다.
2. 메시의 원점은 **바닥 중심**입니다. 바닥은 Z=0, 오브젝트 위치는 원점으로 둡니다. scale/rotation을 적용한 뒤 내보냅니다.
3. 이름은 표의 ASCII snake_case를 사용합니다. 시설 모델에 slot_id·게임 상태를 박아 넣지 않습니다.
4. Godot에서 정면은 **-Z**, 위는 +Y입니다. Blender 내부 축을 억지로 그대로 맞추기보다 GLB의 축 변환 후 기준 화살표와 1m 큐브를 import해 방향·크기를 확인합니다.
5. 불필요한 카메라·조명·숨긴 테스트 메시·백업 오브젝트는 export하지 않습니다.
6. 재질은 단순한 metallic/roughness 기반으로 구성합니다. 이름을 붙이고 가능한 한 공유합니다. 복잡한 Blender 전용 노드에 의존하지 않습니다.
7. 애니메이션은 없어도 됩니다. 필요하면 guide_robot의 짧은 idle만 포함하고 루트 이동·게임 자원 변화는 넣지 않습니다.

## 경로와 소유권

- 제작 단계에 `assets/source/.gdignore` 빈 파일을 만들고 Git에 추적한다. 이는 Godot가 `.blend` 원본을 자동 import하지 않도록 하는 파일이며 Git에서 원본을 제외하는 규칙이 아니다. `assets/models/`에는 `.gdignore`를 놓지 않는다. 이번 문서 단계에는 자산 파일·폴더를 만들지 않는다.
- jsjavsj 소유: `assets/source/<name>.blend`, `assets/models/<name>.glb`, `assets/textures/`, `assets/ASSET_MANIFEST.md`.
- `ASSET_MANIFEST.md`에는 파일·Blender 버전·export 날짜·치수·정면·삼각형 수·텍스처 크기·용량·출처/라이선스·import 결과를 기록합니다. 이 파일은 제작 단계에서 생성하며 현재는 없습니다.
- dyhan0528/core 측 소유: Godot의 `scenes/facilities/` wrapper, `CollisionShape3D`, 슬롯 생성, `project.godot`, import 설정·게임 코드.
- 모델링 담당은 Godot 씬·코드·공유 WORK를 동시에 편집하지 않습니다. 검증 결과는 HH-004 본문/댓글 또는 자산 manifest로 인계하고 통합 담당 AI가 WORK에 반영합니다.
- 충돌은 GLB 메시와 분리합니다. core 담당이 단순 box/capsule wrapper를 만듭니다. 모든 삼각형을 충돌체로 쓰지 않습니다.

## 작게 유지할 제작 예산

시설별 2천~5천 삼각형, 로봇 5천 이하를 목표로 합니다. 텍스처는 512~1024px 중심, 공유 atlas 권장, 자산당 재질 1~3개를 목표로 합니다. 이는 성능 목표이며 실제 WebGL2 측정으로 조정합니다.

GLB 하나는 가능하면 5MB 이하, `.blend` 하나는 20MB 이하, 전체 전달 묶음은 50MB 이하를 목표로 합니다. **개별 파일은 100MB 미만**이어야 합니다. 초과 시 폴리곤·텍스처·미사용 데이터를 줄이고 다시 확인합니다. Git LFS 설치나 설정은 현재 승인되지 않았으므로 자동 도입하지 않습니다.

## export와 import 확인

1. 원본 `.blend`를 저장한 후 필요한 오브젝트만 선택합니다.
2. glTF 2.0 export에서 GLB를 선택하고 `assets/models/<name>.glb`로 내보냅니다.
3. 실제 설치 Blender 버전을 기록합니다. 버전 번호를 추측하거나 최신판을 강제하지 않습니다.
4. core 담당은 Godot 준비 후 GLB를 import해 1m 큐브·피벗·-Z 정면·치수·재질을 확인합니다. 초기에는 임시 도형 wrapper에 GLB를 자식으로 교체합니다.
5. 실제 슬롯의 보행 통로·플레이어 캡슐과 충돌하지 않는지 확인하고 웹 출력에서 같은 자산을 확인합니다.

공식 근거: [Godot 3D import 형식](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html). glTF 2.0을 권장하며 `.blend` 직접 import는 Blender 설치에 의존하므로 팀 전달 형식은 GLB로 고정합니다. [Godot 프로젝트 조직](https://docs.godotengine.org/en/4.4/tutorials/best_practices/project_organization.html)의 `.gdignore` 방식으로 원본만 import에서 제외해 core PC가 Blender 없이 GLB를 사용할 수 있게 합니다.

## 완료 조건과 다음 사람에게 넘길 것

- [ ] 원본과 GLB, 파일 이름·피벗·정면·치수·용량이 계약과 일치한다.
- [ ] 외부 자산은 출처·사용 조건이 있고 직접 제작 자산은 직접 제작으로 표시했다.
- [ ] 기준 큐브와 발전기 import를 core 담당이 실제 확인했다.
- [ ] 최종 자산 5종·로봇과 manifest, 정확한 feature 브랜치 커밋을 전달했다.
- [ ] core 담당이 wrapper·충돌·웹 검증 결과를 별도로 기록했다.

준비 작업과 제작물 완료는 다릅니다. 문서·레퍼런스만 작성했다고 모델 완성으로 표시하지 않고, 한 PC의 import 확인으로 다른 PC·브라우저 검증을 대신하지 않습니다.
