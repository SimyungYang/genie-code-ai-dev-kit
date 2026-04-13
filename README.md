# Genie Code + AI Dev Kit MCP 구성 가이드

## 왜 이 구성이 필요한가?

Genie Code는 최신 LLM 모델 기반의 강력한 AI 어시스턴트입니다. 노트북에서 코드를 생성하고, 대시보드 UI에서 차트를 만들고, Pipeline Editor에서 ETL 파이프라인을 작성하는 등 **각 제품 영역 안에서는** 이미 훌륭하게 동작합니다.

하지만 실제 데이터 엔지니어링 업무에서는 이런 요청이 자주 나옵니다:

> "이 테이블들로 Genie Space 하나 만들어줘"  
> "방금 분석한 데이터로 대시보드 만들고, 매일 리프레시 Job까지 걸어줘"  
> "Knowledge Assistant 만들어서 Supervisor Agent에 연결해줘"

Genie Code만으로는 이런 작업을 처리할 수 없습니다. Genie Space 질의는 되지만 **생성**은 안 되고, 대시보드도 대시보드 UI 안에서만 만들 수 있을 뿐 **노트북에서 한 대화로 대시보드 + Job을 동시에** 만드는 건 불가능합니다. Supervisor Agent, Knowledge Assistant, Apps 배포, Lakebase, Model Serving 같은 기능은 아예 Genie Code에 없습니다.

[Databricks AI Dev Kit](https://github.com/databricks-solutions/ai-dev-kit)은 이런 빈 영역을 44개 이상의 MCP 도구와 25개 Skills로 채워줍니다. AI Dev Kit MCP 서버를 Databricks App으로 배포하고 Genie Code에 연결하면, Genie Code가 기존에 할 수 없던 크로스 프로덕트 작업을 하나의 대화에서 수행할 수 있게 됩니다.

다만 Genie Code에는 **MCP 도구 15개 제한**이 있습니다. AI Dev Kit이 제공하는 44개 도구를 모두 켤 수 없기 때문에, Genie Code가 이미 잘 처리하는 기능(SQL 실행, Genie 질의 등)은 OOB에 맡기고, **Genie Code에 없는 기능 위주로 15개를 선택하여 활성화하는 것을 권장합니다.**

이 레포는 그 전체 과정을 Step-by-Step으로 정리한 가이드입니다.

---

## 목차

1. [Genie Code vs AI Dev Kit — 무엇이 다른가?](#1-genie-code-vs-ai-dev-kit--무엇이-다른가)
2. [구성 아키텍처](#2-구성-아키텍처)
3. [Step-by-Step 구성 가이드](#3-step-by-step-구성-가이드)
4. [권장 MCP 도구 선택](#4-권장-mcp-도구-선택)
5. [테스트 시나리오](#5-테스트-시나리오)
6. [트러블슈팅](#6-트러블슈팅)
7. [참고 자료](#7-참고-자료)

---

## 1. Genie Code vs AI Dev Kit — 무엇이 다른가?

### Genie Code Agent Mode 내장 기능

Genie Code Agent Mode는 **각 제품 UI 안에서** 이미 다양한 작업을 수행합니다:

| 제품 영역 | 내장 기능 | 작동 방식 |
|----------|----------|----------|
| 노트북 | EDA, 모델 학습, 코드 생성/수정/디버깅 | 노트북 안에서 셀 단위 실행 |
| AI/BI 대시보드 | **대시보드 생성**, 데이터 분석 | 대시보드 UI에서 위젯/쿼리 생성 |
| Lakeflow 파이프라인 | **Spark Declarative Pipeline 생성** | Pipeline Editor에서 코드 생성 |
| SQL Editor | SQL 생성, 최적화, 실행 | SQL Editor 안에서 실행 |
| MLflow | GenAI 앱 디버깅, 트레이스 분석 | MLflow UI 연동 |
| Jobs | 코드 수정, 에러 진단 | Jobs 페이지에서 |

**Managed MCP (설정 없이 사용 가능):**

| MCP 서버 | 기능 |
|----------|------|
| DBSQL | 자연어 → SQL 실행 |
| Genie Space | Genie Space 질의 (Read-only) |
| Vector Search | 벡터 검색 |
| UC Functions | Unity Catalog 함수 실행 |

### Genie Code의 한계 — AI Dev Kit으로 해결

Genie Code의 핵심 제약은 **"단일 제품 영역 안에서만 작동"** 한다는 점입니다.

> **핵심 비교:**
> - **Genie Code** = "Single product area" — 한 제품 안에서 코드/분석
> - **AI Dev Kit** = "Across products" — 파이프라인 + 대시보드 + Job을 한번에 오케스트레이션

### Genie Code에 완전히 없는 기능 (AI Dev Kit 고유)

| 기능 | AI Dev Kit 도구 | 설명 |
|------|----------------|------|
| **Genie Space 생성/관리** | `manage_genie` | Space 생성, 수정, 테이블 연결, 마이그레이션 |
| **Supervisor Agent (MAS)** | `manage_mas` | Multi-Agent Supervisor 생성/관리 |
| **Knowledge Assistant (KA)** | `manage_ka` | 문서 기반 QA 에이전트 생성/관리 |
| **Apps 배포** | `manage_app` | Databricks App 생성/배포/관리 |
| **Lakebase** | `manage_lakebase_database` | PostgreSQL 호환 DB 생성/관리 |
| **Model Serving** | `manage_serving_endpoint` | 서빙 엔드포인트 배포/관리 |
| **UC 권한 관리** | `manage_uc_grants` | GRANT/REVOKE 권한 관리 |
| **UC 오브젝트 관리** | `manage_uc_objects` | 카탈로그/스키마/테이블 CRUD |
| **Vector Search 인덱스 생성** | `manage_vs_index` | 인덱스/엔드포인트 생성 (OOB는 검색만) |
| **워크스페이스 파일 관리** | `manage_workspace_files` | 파일 업로드/다운로드/관리 |
| **원격 코드 실행** | `execute_code` | 클러스터에서 Python/Scala 실행 |

### Genie Code가 UI에서 하지만, 크로스 프로덕트로는 못하는 기능

| 기능 | Genie Code (UI 내) | AI Dev Kit MCP (크로스 프로덕트) |
|------|-------------------|-------------------------------|
| 대시보드 생성 | 대시보드 UI에서 가능 | **어디서든** API로 생성 |
| 파이프라인 생성 | Pipeline Editor에서 가능 | **어디서든** API로 생성 |
| Job 생성 | Jobs 페이지에서 코드 수정 수준 | Job **정의/스케줄/실행** 전체 |

### 크로스 프로덕트 오케스트레이션 — AI Dev Kit만 가능

Genie Code에서 "노트북에서 대시보드 만들어줘"라고 하면 대시보드 UI로 이동해야 합니다.
AI Dev Kit MCP를 연결하면 **하나의 대화에서** 전체 워크플로우를 실행할 수 있습니다:

> "gold 스키마 테이블로 Genie Space 만들고 → 대시보드 생성하고 → 매일 리프레시 Job 설정해줘"

---

## 2. 구성 아키텍처

```mermaid
graph TB
    subgraph WS["Databricks Workspace"]
        GC["Genie Code<br/>(Agent Mode)"]

        GC --> BUILTIN
        GC --> MCP
        GC -.->|"자동 로딩<br/>(설정 불필요)"| SKILLS

        subgraph BUILTIN["내장 기능"]
            B1["Notebook 코드 생성"]
            B2["SQL 실행 (DBSQL MCP)"]
            B3["Dashboard 생성 (UI 내)"]
            B4["Pipeline 생성 (UI 내)"]
            B5["Genie Space 질의 (Read-only)"]
            B6["Vector Search"]
            B7["UC Functions"]
        end

        subgraph MCP["mcp-ai-dev-kit App"]
            M0["/mcp endpoint<br/>Streamable HTTP"]
            M1["44 MCP tools<br/>(15개 활성화)"]
            M2["26 skills<br/>(MCP prompts)"]
        end

        subgraph SKILLS["Workspace Skills"]
            S1["/.assistant/skills/<br/>25개 Databricks skills"]
        end
    end

    style GC fill:#1B3A5C,color:#fff,stroke:#4A90D9
    style BUILTIN fill:#E8F0FE,stroke:#4A90D9
    style MCP fill:#FFF3E0,stroke:#F57C00
    style SKILLS fill:#E8F5E9,stroke:#43A047
    style WS fill:#FAFAFA,stroke:#999
```

**두 가지 경로로 Genie Code가 확장됩니다:**

1. **Skills (자동)**: `/Workspace/.assistant/skills/`에 배포 → Genie Code가 문맥에 맞게 자동 로딩 (설정 불필요)
2. **MCP Tools (수동)**: `mcp-ai-dev-kit` Databricks App 배포 → Genie Code Settings에서 서버 추가

---

## 3. Step-by-Step 구성 가이드

### 사전 요구사항

- [Databricks CLI](https://docs.databricks.com/dev-tools/cli/install.html) 설치
- Workspace admin 또는 앱 생성 권한
- `jq` 설치 (`brew install jq` 또는 `apt install jq`)

### Step 1: Databricks CLI 인증

```bash
databricks auth login --host https://<your-workspace-url>

# 인증 확인
databricks current-user me
```

### Step 2: 이 레포 클론

```bash
git clone https://github.com/SimyungYang/genie-code-ai-dev-kit.git
cd genie-code-ai-dev-kit
```

### Step 3: 앱 생성

> **중요**: 앱 이름은 반드시 `mcp-`로 시작해야 Genie Code에서 인식됩니다.

```bash
databricks apps create mcp-ai-dev-kit \
  --description "AI Dev Kit MCP Server for Genie Code"
```

### Step 4: 앱 소스 코드 업로드 및 배포

```bash
DBUSER=$(databricks current-user me | jq -r .userName)
APP_PATH="/Workspace/Users/$DBUSER/mcp-ai-dev-kit-app"

# 업로드
databricks workspace mkdirs "$APP_PATH"
for f in app/main.py app/app.yaml app/requirements.txt; do
  databricks workspace import "$APP_PATH/$(basename $f)" \
    --file "$f" --format RAW --overwrite
done

# 배포
databricks apps deploy mcp-ai-dev-kit --source-code-path "$APP_PATH"

# 배포 확인 (state: SUCCEEDED 될 때까지)
databricks apps get mcp-ai-dev-kit
```

배포에는 2-3분이 소요됩니다. `state: SUCCEEDED`가 확인되면 다음 단계로 진행합니다.

### Step 5: 앱 서비스 프린시펄 권한 부여

앱이 생성되면 자동으로 서비스 프린시펄(SP)이 할당됩니다.

```bash
# SP 정보 확인
SP_CLIENT_ID=$(databricks apps get mcp-ai-dev-kit -o json | jq -r .service_principal_client_id)
SP_ID=$(databricks apps get mcp-ai-dev-kit -o json | jq -r .service_principal_id)
echo "SP Client ID: $SP_CLIENT_ID"
echo "SP ID: $SP_ID"
```

#### 5-1. 엔타이틀먼트 부여

```bash
databricks api patch /api/2.0/preview/scim/v2/ServicePrincipals/$SP_ID --json '{
  "schemas": ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
  "Operations": [{"op": "add", "value": {
    "entitlements": [
      {"value": "allow-cluster-create"},
      {"value": "workspace-access"},
      {"value": "databricks-sql-access"}
    ]
  }}]
}'
```

#### 5-2. 카탈로그 권한 부여 (SQL Warehouse에서 실행)

```sql
-- <sp_client_id>를 위에서 확인한 SP Client ID로 교체
GRANT ALL PRIVILEGES ON CATALOG <your_catalog> TO `<sp_client_id>`;
```

#### 5-3. SQL Warehouse 사용 권한

```bash
WH_ID="<your_warehouse_id>"
TOKEN=$(databricks auth token | jq -r .access_token)
HOST=$(databricks auth env | jq -r .env.DATABRICKS_HOST)

curl -X PATCH "$HOST/api/2.0/permissions/warehouses/$WH_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"access_control_list\": [{
    \"service_principal_name\": \"$SP_CLIENT_ID\",
    \"permission_level\": \"CAN_USE\"
  }]}"
```

#### 5-4. Genie Space 접근 권한 (Space별로)

```bash
SPACE_ID="<genie_space_id>"
curl -X PATCH "$HOST/api/2.0/permissions/genie/$SPACE_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"access_control_list\": [{
    \"service_principal_name\": \"$SP_CLIENT_ID\",
    \"permission_level\": \"CAN_RUN\"
  }]}"
```

> **팁**: 테스트 환경에서는 SP를 admins 그룹에 추가하면 모든 권한이 한번에 해결됩니다.

### Step 6: Skills를 Workspace에 배포

앱이 시작 시 자동으로 skills를 업로드하지만, SP 권한이 부족하면 수동 배포합니다:

```bash
# AI Dev Kit 클론
git clone --depth 1 https://github.com/databricks-solutions/ai-dev-kit.git /tmp/ai-dev-kit

# Skills 일괄 업로드
TARGET="/Workspace/.assistant/skills"
for skill_dir in /tmp/ai-dev-kit/databricks-skills/*/; do
  skill_name=$(basename "$skill_dir")
  [ "$skill_name" = "TEMPLATE" ] && continue

  databricks workspace mkdirs "$TARGET/$skill_name"
  for f in "$skill_dir"*; do
    [ -f "$f" ] || continue
    databricks workspace import "$TARGET/$skill_name/$(basename $f)" \
      --file "$f" --format RAW --overwrite
  done
  echo "✓ $skill_name"
done

# 확인
databricks workspace list /Workspace/.assistant/skills/
```

Skills는 Genie Code Agent Mode에서 **자동으로 contextually 로딩**됩니다. 추가 설정 불필요.

### Step 7: Genie Code에서 MCP 서버 연결

1. Databricks Workspace 접속
2. 우측 상단 **Genie Code 아이콘** 클릭
3. 우측 하단에서 **Agent** 모드 확인
4. **Settings** (⚙️) 클릭
5. **MCP Servers** → **+ Add Server**
6. **Custom MCP Server** 드롭다운에서 **`mcp-ai-dev-kit`** 선택
7. **Save**

![MCP Server 추가 화면](docs/add-mcp-server.png)

### Step 8: MCP 도구 활성화

서버 추가 후 "15개 도구 제한 초과" 경고가 표시됩니다.

1. Settings의 `mcp-ai-dev-kit` 항목 클릭
2. 도구 목록에서 필요한 15개만 ON으로 활성화 (다음 섹션 참조)
3. **Close** → 메인 토글 **ON** 확인

![도구 활성화 화면](docs/enable-tools.png)

---

## 4. 권장 MCP 도구 선택

15개 제한이 있으므로, **Genie Code OOB와 중복을 피하고 AI Dev Kit 고유 기능에 집중**합니다.

### 활성화 권장 도구 (15개)

| # | 도구 | 이유 | Genie Code OOB |
|---|------|------|---------------|
| 1 | `manage_genie` | Genie Space **생성/수정/마이그레이션** | OOB는 질의만 |
| 2 | `manage_mas` | Supervisor Agent 생성/관리 | 없음 |
| 3 | `manage_ka` | Knowledge Assistant 생성/관리 | 없음 |
| 4 | `manage_dashboard` | 크로스 프로덕트 대시보드 생성 | UI 안에서만 |
| 5 | `manage_jobs` | Job 정의/스케줄/관리 | 없음 |
| 6 | `manage_job_runs` | Job 실행/모니터링 | 없음 |
| 7 | `manage_pipeline` | 파이프라인 관리 | UI 안에서만 |
| 8 | `manage_pipeline_run` | 파이프라인 실행 | 없음 |
| 9 | `manage_app` | Apps 배포/관리 | 없음 |
| 10 | `manage_lakebase_database` | Lakebase 생성/관리 | 없음 |
| 11 | `manage_serving_endpoint` | Model Serving 관리 | 없음 |
| 12 | `execute_code` | 원격 코드 실행 | 없음 |
| 13 | `manage_uc_objects` | UC 오브젝트 관리 (OOB보다 넓음) | 제한적 |
| 14 | `manage_uc_grants` | 권한 관리 | 없음 |
| 15 | `manage_workspace_files` | 파일 관리 | 없음 |

### 비활성화 권장 도구 (OOB와 중복)

| 도구 | 이유 |
|------|------|
| `execute_sql` | Genie Code OOB DBSQL MCP가 이미 처리 |
| `ask_genie` | Genie Code OOB Genie Space MCP가 이미 처리 |
| `query_vs_index` | Genie Code OOB Vector Search MCP가 이미 처리 |
| `execute_sql_multi` | DBSQL과 중복 |

---

## 5. 테스트 시나리오

### Skills 자동 로딩 확인

Genie Code에 입력:
```
Spark Declarative Pipeline으로 medallion 아키텍처를 구성하려면 어떻게 해야돼?
```
→ `databricks-spark-declarative-pipelines` skill이 자동 로딩되어 best practices 기반 응답

### MCP 도구: Genie Space 생성 (OOB에 없는 기능)

```
gold 스키마의 regional_kpis, customer_360_v2 테이블로 새 Genie Space를 만들어줘
```
→ `manage_genie` 호출

### MCP 도구: 크로스 프로덕트 대시보드 생성

```
regional_kpis 테이블로 지역별 매출 추이 대시보드를 만들어줘.
카탈로그는 my_catalog, 스키마는 gold.
```
→ `manage_dashboard` 호출

### MCP 도구: Job 스케줄링

```
매일 오전 9시(KST)에 gold 테이블을 refresh하는 Job을 만들어줘
```
→ `manage_jobs` 호출

### 통합 시나리오 (크로스 프로덕트 오케스트레이션)

```
1. gold 스키마 테이블들로 Genie Space 생성해줘
2. 같은 데이터로 매출 추이 대시보드 만들어줘
3. 매일 데이터를 리프레시하는 Job도 설정해줘
```
→ `manage_genie` → `manage_dashboard` → `manage_jobs` 순차 호출

---

## 6. 트러블슈팅

### MCP 서버가 드롭다운 목록에 안 보임
- 앱 이름이 **`mcp-`로 시작**하는지 확인 (필수)
- 앱이 **동일 workspace**에 배포되었는지 확인
- 앱 상태 확인: `databricks apps get mcp-ai-dev-kit`

### "Could not enable server" / "exceeds the limit of 15 tools"
- 44개 도구 전체 활성화 불가 → 수동으로 15개만 선택

### 도구 호출 시 권한 오류
- Step 5의 SP 권한 부여 확인
- 테스트 환경: SP를 admins 그룹에 추가

### Skills가 로딩되지 않음
- `/Workspace/.assistant/skills/` 경로에 파일이 있는지 확인
- Genie Code가 **Agent 모드**인지 확인 (Chat 모드에서는 skills 미지원)
- Settings > Workspace Skills 경로가 `/.assistant/skills`인지 확인

### 앱 재배포 (최신 AI Dev Kit 반영)
```bash
databricks apps deploy mcp-ai-dev-kit --source-code-path "$APP_PATH"
```
매 배포 시 GitHub에서 최신 AI Dev Kit을 clone하므로 새 도구/스킬이 자동 반영됩니다.

---

## 7. 참고 자료

| 자료 | URL |
|------|-----|
| AI Dev Kit GitHub | https://github.com/databricks-solutions/ai-dev-kit |
| Custom MCP Server 공식 문서 | https://docs.databricks.com/aws/en/generative-ai/mcp/custom-mcp |
| Genie Code MCP 공식 문서 | https://docs.databricks.com/aws/en/genie-code/mcp |
| Skills 공식 스펙 | https://agentskills.io/specification |

---

## 프로젝트 구조

```
.
├── README.md                  # 이 가이드
├── app/                       # MCP 서버 앱 소스 코드
│   ├── main.py                # 앱 엔트리포인트
│   ├── app.yaml               # Databricks App 설정
│   └── requirements.txt       # Python 의존성
└── docs/                      # 스크린샷 등
    ├── add-mcp-server.png
    └── enable-tools.png
```
