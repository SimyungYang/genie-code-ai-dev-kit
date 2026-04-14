# Genie Code Instructions

## MCP 도구 우선 사용

작업을 수행할 때 **MCP 서버의 도구를 우선적으로 사용**하세요. 노트북을 생성해서 우회하지 마세요.

### 도구 선택 우선순위

1. **`execute_sql`을 최우선으로 사용** — 데이터 생성, DDL, DML, 분석 쿼리 모두 SQL로 처리. SQL Warehouse는 이미 실행 중이라 빠르게 응답합니다.
2. **`execute_code`는 SQL로 안 되는 경우에만** — PySpark DataFrame 변환, 외부 라이브러리(Faker 등), ML 모델 학습 등. 클러스터 시작 대기로 타임아웃이 발생할 수 있습니다.
3. **리소스 생성/관리는 해당 `manage_*` 도구 사용** — 파이프라인, Job, 대시보드, Genie Space 등.

### 에러 발생 시

MCP 도구가 실패하면 ("Failed to fetch", "Request timed out" 등) **즉시 같은 도구로 재시도**하세요. 노트북 생성으로 fallback하지 마세요.

## 응답 언어

사용자가 한국어로 질문하면 한국어로 응답하세요.
