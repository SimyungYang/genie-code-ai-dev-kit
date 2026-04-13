---
marp: true
theme: default
paginate: true
backgroundColor: #fff
style: |
  section {
    font-family: 'Noto Sans KR', 'Helvetica Neue', Arial, sans-serif;
    font-size: 26px;
  }
  h1 { color: #FF3621; font-size: 38px; }
  h2 { color: #1B3A5C; font-size: 32px; }
  table { font-size: 20px; }
  code { font-size: 20px; }
  blockquote { border-left: 4px solid #FF3621; padding-left: 16px; color: #555; }
---

# Genie Code 활용 가이드
## AI Dev Kit MCP로 Genie Code 확장하기

<br>

Genie Code Agent Mode의 기능과 한계를 이해하고,
AI Dev Kit MCP를 연결하여 크로스 프로덕트 작업을 수행하는 방법

---

## Genie Code란?

Databricks에 내장된 **AI 파트너**로, 데이터 작업을 자연어로 수행합니다.

| 영역 | 할 수 있는 것 |
|------|-------------|
| **노트북** | EDA, 모델 학습, 코드 생성/수정/디버깅 |
| **대시보드** | 대시보드 생성 및 데이터 분석 |
| **파이프라인** | Spark Declarative Pipeline 생성 |
| **SQL Editor** | SQL 생성, 최적화, 실행 |
| **MLflow** | GenAI 앱 디버깅, 트레이스 분석 |

> Agent 모드에서 **자율적으로 계획 → 실행 → 수정**하는 멀티스텝 워크플로우 수행

---

## Genie Code의 한계

### "단일 제품 영역 안에서만" 작동

Genie Code에게 이런 요청을 하면?

> "이 테이블들로 **Genie Space 만들어줘**"

→ **안 됩니다.** 질의는 되지만 생성은 불가.

> "분석한 데이터로 **대시보드 만들고 매일 리프레시 Job 걸어줘**"

→ **안 됩니다.** 제품 경계를 넘는 작업은 불가.

---

## Genie Code에 없는 기능들

| 기능 | Genie Code | AI Dev Kit MCP |
|------|:----------:|:--------------:|
| Genie Space **생성** | - | **manage_genie** |
| Supervisor Agent | - | **manage_mas** |
| Knowledge Assistant | - | **manage_ka** |
| Job **스케줄링** | - | **manage_jobs** |
| Apps **배포** | - | **manage_app** |
| Lakebase | - | **manage_lakebase_database** |
| Model Serving | - | **manage_serving_endpoint** |
| UC 권한 관리 | - | **manage_uc_grants** |
| Vector Search 인덱스 **생성** | - | **manage_vs_index** |
| 원격 코드 실행 | - | **execute_code** |

---

## 해결책: AI Dev Kit MCP 연결

AI Dev Kit의 MCP 서버를 Databricks App으로 배포하고,
Genie Code에 Custom MCP Server로 연결합니다.

**44개 MCP 도구 + 25개 Skills** 추가

```
┌─────────────┐          ┌──────────────────┐
│ Genie Code  │──MCP────▶│ mcp-ai-dev-kit   │
│ Agent Mode  │          │ Databricks App   │
│             │          │ /mcp endpoint    │
│             │──auto───▶│ 44 tools         │
│             │          └──────────────────┘
│             │
│             │──auto───▶ /.assistant/skills/ (25 skills)
└─────────────┘
```

---

## 하나의 대화에서 크로스 프로덕트 작업

**Before (Genie Code만):**
노트북 → 대시보드 UI 이동 → Jobs 페이지 이동 → 각각 별도 작업

**After (AI Dev Kit MCP 연결):**

> "gold 스키마 테이블로 **Genie Space 만들고**
> → **대시보드 생성하고**
> → **매일 리프레시 Job 설정해줘**"

하나의 대화에서 `manage_genie` → `manage_dashboard` → `manage_jobs` 순차 호출

---

## 구성 방법 요약

### Step 1-4: 앱 배포
```bash
# 앱 생성 (mcp- 접두사 필수!)
databricks apps create mcp-ai-dev-kit

# 소스 업로드 & 배포
databricks apps deploy mcp-ai-dev-kit --source-code-path "$APP_PATH"
```

### Step 5-6: Skills 배포 + 서버 연결
- Skills → `/Workspace/.assistant/skills/`에 업로드 (자동 로딩)
- Genie Code Settings → Custom MCP Server → `mcp-ai-dev-kit` 선택

### Step 7: 도구 활성화
- 15개 제한 → 역할에 맞는 도구 선택

---

## MCP 도구 15개 제한 — 어떻게 선택할까?

### 원칙: Genie Code OOB와 겹치는 건 빼고, 고유 기능에 집중

| 비활성화 (OOB 중복) | 활성화 (AI Dev Kit 고유) |
|:---:|:---:|
| `ask_genie` | `manage_genie` |
| `query_vs_index` | `manage_mas`, `manage_ka` |
| | `manage_dashboard`, `manage_jobs` |
| | `manage_pipeline`, `manage_app` |
| | `execute_code`, `manage_uc_grants` |

### 어떤 도구를 켜야 할지 모르면?

Genie Code에게 직접 물어보세요:
```
SDP 파이프라인 생성을 위해서 활성화하면 도움 될 MCP 도구 알려줘.
```

---

## 역할별 권장 도구 프로필

| Profile | 대상 | 핵심 도구 |
|---------|------|----------|
| **A** | 데이터 엔지니어 | pipeline, jobs, execute_code, execute_sql |
| **B** | AI/ML 엔지니어 | mas, ka, serving_endpoint, vs_index |
| **C** | 데이터 분석가 | dashboard, genie, execute_sql, table_stats |
| **D** | 플랫폼 관리자 | uc_objects, uc_grants, cluster, app |
| **E** | 올라운드 | genie, mas, ka, dashboard, jobs, pipeline |

상세 도구 목록은 GitHub 가이드 참조:
https://github.com/SimyungYang/genie-code-ai-dev-kit

---

## Skills — 설정 없이 자동으로 똑똑해지기

`/Workspace/.assistant/skills/`에 배포하면 Genie Code가 **문맥에 맞게 자동 로딩**

| Skill | Genie Code가 배우는 것 |
|-------|---------------------|
| databricks-aibi-dashboards | AI/BI 대시보드 best practices |
| databricks-spark-declarative-pipelines | SDP 파이프라인 패턴 |
| databricks-genie | Genie Space 구성 가이드 |
| databricks-model-serving | 모델 서빙 배포 |
| databricks-vector-search | RAG 구현 패턴 |
| databricks-jobs | Job 스케줄링 best practices |
| ... | 총 25개 Databricks + 8개 MLflow skills |

---

## 트러블슈팅

### "Failed to fetch" 에러
→ 앱 cold start. **10-30초 후 재시도**하면 됩니다.
→ 작업 전 `"현재 사용자 정보 알려줘"`로 warm-up 권장

### 도구가 15개 초과
→ 수동으로 필요한 도구만 선택

### MCP 서버가 목록에 안 보임
→ 앱 이름이 `mcp-`로 시작하는지 확인

### 권한 오류
→ 앱 서비스 프린시펄에 카탈로그/warehouse 권한 부여

---

## 정리

| | Genie Code 단독 | + AI Dev Kit MCP |
|---|:---:|:---:|
| 노트북 코드 생성 | O | O |
| 대시보드 (UI 내) | O | O |
| 파이프라인 (UI 내) | O | O |
| SQL 실행 | O | O |
| **Genie Space 생성** | **X** | **O** |
| **Job 스케줄링** | **X** | **O** |
| **Agent Bricks (MAS/KA)** | **X** | **O** |
| **Apps/Lakebase/Serving** | **X** | **O** |
| **크로스 프로덕트 오케스트레이션** | **X** | **O** |

---

## 시작하기

### GitHub 가이드 (Step-by-Step)
https://github.com/SimyungYang/genie-code-ai-dev-kit

### 구성 소요 시간
- 앱 배포: ~5분
- Skills 배포: ~2분
- Genie Code 연결: ~1분
- **총 ~10분이면 완료**

### 질문이나 피드백
편하게 말씀해주세요!
