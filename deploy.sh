#!/bin/bash
#
# Genie Code + AI Dev Kit 간편 배포 스크립트
#
# 사용법:
#   ./deploy.sh                          # 기본 배포 (lge_smart_tv 카탈로그)
#   ./deploy.sh --catalog lge_appliance  # 가전 IoT 카탈로그
#
set -e

CATALOG="${CATALOG:-lge_smart_tv}"

# 인자 파싱
while [[ $# -gt 0 ]]; do
  case $1 in
    --catalog) CATALOG="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

echo "================================================"
echo "  Genie Code + AI Dev Kit 간편 배포"
echo "================================================"
echo ""

# 1. Databricks CLI 확인
if ! command -v databricks &> /dev/null; then
  echo "❌ Databricks CLI가 설치되어 있지 않습니다."
  echo "   설치: brew install databricks (macOS)"
  echo "   또는: pip install databricks-cli"
  exit 1
fi
echo "✅ Databricks CLI: $(databricks --version)"

# 2. 인증 확인
if ! databricks current-user me &> /dev/null; then
  echo "❌ Databricks 인증이 필요합니다."
  echo "   실행: databricks auth login --host <워크스페이스 URL>"
  exit 1
fi
USER=$(databricks current-user me --output json 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('userName','unknown'))" 2>/dev/null || echo "authenticated")
echo "✅ 인증: $USER"

# 3. MCP 앱 생성 + 배포
echo ""
echo "📦 MCP 앱 배포 중..."
APP_NAME="mcp-ai-dev-kit"

# 앱이 이미 있는지 확인
if databricks apps get "$APP_NAME" &> /dev/null; then
  echo "   앱이 이미 존재합니다. 소스 코드를 업데이트합니다..."
  databricks apps deploy "$APP_NAME" --source-code-path ./app
else
  echo "   새 앱을 생성하고 배포합니다..."
  databricks apps create "$APP_NAME" --description "AI Dev Kit MCP Server for Genie Code"
  databricks apps deploy "$APP_NAME" --source-code-path ./app
fi

# 4. 배포 완료 대기
echo ""
echo "⏳ 앱 시작 대기 중 (최대 2분)..."
for i in $(seq 1 24); do
  STATUS=$(databricks apps get "$APP_NAME" --output json 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('status',{}).get('state','UNKNOWN'))" 2>/dev/null || echo "UNKNOWN")
  if [ "$STATUS" = "RUNNING" ]; then
    echo "✅ 앱 상태: RUNNING"
    break
  fi
  echo "   상태: $STATUS ($((i*5))초 경과)"
  sleep 5
done

if [ "$STATUS" != "RUNNING" ]; then
  echo "⚠️  앱이 아직 시작되지 않았습니다. 잠시 후 다시 확인하세요:"
  echo "   databricks apps get $APP_NAME"
fi

# 5. SP 권한 자동 부여
echo ""
echo "🔐 서비스 프린시펄 권한 설정 중..."

SP_CLIENT_ID=$(databricks apps get "$APP_NAME" --output json 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('service_principal_client_id',''))" 2>/dev/null)

if [ -n "$SP_CLIENT_ID" ]; then
  TOKEN=$(databricks auth token 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('access_token',''))" 2>/dev/null || echo "")
  HOST=$(databricks auth env 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('env',{}).get('DATABRICKS_HOST',''))" 2>/dev/null || echo "")

  if [ -n "$TOKEN" ] && [ -n "$HOST" ]; then
    # SP Databricks ID 조회
    SP_ID=$(curl -s "$HOST/api/2.0/preview/scim/v2/ServicePrincipals?filter=applicationId+eq+%22$SP_CLIENT_ID%22" \
      -H "Authorization: Bearer $TOKEN" | python3 -c "import json,sys; print(json.load(sys.stdin).get('Resources',[{}])[0].get('id',''))" 2>/dev/null)

    if [ -n "$SP_ID" ]; then
      # Workspace + SQL 접근 권한
      curl -s -X PATCH "$HOST/api/2.0/preview/scim/v2/ServicePrincipals/$SP_ID" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
          "schemas": ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
          "Operations": [{
            "op": "add",
            "path": "entitlements",
            "value": [
              {"value": "workspace-access"},
              {"value": "databricks-sql-access"}
            ]
          }]
        }' > /dev/null 2>&1
      echo "   ✅ Workspace + SQL 접근 권한 부여"

      # SQL Warehouse 권한
      WH_ID=$(databricks warehouses list --output json 2>/dev/null | python3 -c "import json,sys; whs=json.load(sys.stdin); print(whs[0]['id'] if whs else '')" 2>/dev/null)
      if [ -n "$WH_ID" ]; then
        curl -s -X PATCH "$HOST/api/2.0/permissions/sql/warehouses/$WH_ID" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d "{\"access_control_list\": [{
            \"service_principal_name\": \"$SP_CLIENT_ID\",
            \"permission_level\": \"CAN_USE\"
          }]}" > /dev/null 2>&1
        echo "   ✅ SQL Warehouse 접근 권한 부여"
      fi
    fi
  fi

  # 카탈로그 권한 (SQL로 부여)
  echo ""
  echo "📋 아래 SQL을 Databricks 노트북에서 실행하여 카탈로그 권한을 부여하세요:"
  echo ""
  echo "   GRANT USE CATALOG ON CATALOG $CATALOG TO \`$SP_CLIENT_ID\`;"
  echo "   GRANT USE SCHEMA ON CATALOG $CATALOG TO \`$SP_CLIENT_ID\`;"
  echo "   GRANT SELECT ON CATALOG $CATALOG TO \`$SP_CLIENT_ID\`;"
  echo "   GRANT CREATE TABLE ON CATALOG $CATALOG TO \`$SP_CLIENT_ID\`;"
  echo "   GRANT CREATE SCHEMA ON CATALOG $CATALOG TO \`$SP_CLIENT_ID\`;"
  echo ""
else
  echo "   ⚠️ SP Client ID를 가져올 수 없습니다. 수동으로 권한을 설정하세요."
fi

# 6. Skills 배포
echo ""
echo "📚 Skills 배포..."
if command -v databricks &> /dev/null; then
  # AI Dev Kit 공식 Skills 배포
  if [ -d "/tmp/ai-dev-kit/skills" ]; then
    rm -rf /tmp/ai-dev-kit
  fi
  git clone --depth 1 https://github.com/databricks-solutions/ai-dev-kit.git /tmp/ai-dev-kit 2>/dev/null
  databricks workspace import-dir /tmp/ai-dev-kit/skills /Workspace/.assistant/skills/ai-dev-kit --overwrite 2>/dev/null && \
    echo "   ✅ Skills 배포 완료" || echo "   ⚠️ Skills 배포 실패 (수동 배포 필요)"
  rm -rf /tmp/ai-dev-kit
fi

# 완료
echo ""
echo "================================================"
echo "  배포 완료! 다음 단계:"
echo "================================================"
echo ""
echo "  1. Databricks 노트북 열기"
echo "  2. Genie Code (✨) → Settings → MCP Servers"
echo "  3. '+ Add Server' → '$APP_NAME' 선택 → Save"
echo "  4. 필요한 도구만 ON (권장: 15개)"
echo ""
echo "  SP Client ID: $SP_CLIENT_ID"
echo "================================================"
