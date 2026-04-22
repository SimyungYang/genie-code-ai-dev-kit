#!/bin/bash
#
# Genie Code + AI Dev Kit 삭제 스크립트
#
# 사용법:
#   ./uninstall.sh                                          # 기본 앱 이름으로 삭제
#   ./uninstall.sh --app-name mcp-simyung                   # 앱 이름 지정
#   ./uninstall.sh --app-name mcp-simyung --profile DEFAULT # 프로필 지정
#
set -e

# Python 자동 감지
PYTHON=""
for candidate in python3.13 python3.12 python3.11 python3.10 python3 python; do
  if command -v "$candidate" &> /dev/null; then
    PY_MINOR=$($candidate -c "import sys; print(sys.version_info.minor)" 2>/dev/null || echo "0")
    if [ "$PY_MINOR" -ge 10 ] 2>/dev/null; then
      PYTHON="$candidate"
      break
    fi
  fi
done

if [ -z "$PYTHON" ]; then
  echo "❌ Python 3.10 이상이 필요합니다."
  exit 1
fi

PROFILE="${PROFILE:-}"
APP_NAME="${APP_NAME:-mcp-ai-dev-kit}"

# 인자 파싱
while [[ $# -gt 0 ]]; do
  case $1 in
    --profile) PROFILE="$2"; shift 2 ;;
    --app-name) APP_NAME="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# 프로필 옵션 설정
DBX_PROFILE=""
if [ -n "$PROFILE" ]; then
  DBX_PROFILE="--profile $PROFILE"
fi

# Databricks CLI 확인
if ! command -v databricks &> /dev/null; then
  echo "❌ Databricks CLI가 설치되어 있지 않습니다."
  exit 1
fi

# 인증 확인
if ! databricks $DBX_PROFILE current-user me &> /dev/null; then
  if [ -z "$DBX_PROFILE" ] && databricks --profile DEFAULT current-user me &> /dev/null; then
    DBX_PROFILE="--profile DEFAULT"
    PROFILE="DEFAULT"
  else
    echo "❌ Databricks 인증이 필요합니다."
    echo "   실행: databricks auth login --host <워크스페이스 URL>"
    exit 1
  fi
fi

USER=$(databricks $DBX_PROFILE current-user me --output json 2>/dev/null | $PYTHON -c "import json,sys; print(json.load(sys.stdin).get('userName','unknown'))" 2>/dev/null || echo "unknown")

echo "================================================"
echo "  Genie Code + AI Dev Kit 삭제"
echo "================================================"
echo "  앱 이름:  $APP_NAME"
echo "  사용자:   $USER"
if [ -n "$PROFILE" ]; then
  echo "  프로필:   $PROFILE"
fi
echo ""

# 확인 프롬프트
read -p "⚠️  정말 삭제하시겠습니까? (y/N): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "취소되었습니다."
  exit 0
fi

# 1. 앱 삭제
echo ""
echo "🗑️  앱 삭제 중..."
if databricks $DBX_PROFILE apps get "$APP_NAME" &> /dev/null; then
  databricks $DBX_PROFILE apps delete "$APP_NAME" && \
    echo "   ✅ 앱 '$APP_NAME' 삭제 완료" || \
    echo "   ❌ 앱 삭제 실패"
else
  echo "   ⏭️  앱 '$APP_NAME'이 존재하지 않습니다 (건너뜀)"
fi

# 2. 워크스페이스 소스 코드 삭제
echo ""
echo "🗑️  워크스페이스 소스 코드 삭제 중..."
WS_SOURCE_PATH="/Workspace/Users/$USER/apps/$APP_NAME"
if databricks $DBX_PROFILE workspace get-status "$WS_SOURCE_PATH" &> /dev/null; then
  databricks $DBX_PROFILE workspace delete "$WS_SOURCE_PATH" --recursive && \
    echo "   ✅ 소스 코드 삭제: $WS_SOURCE_PATH" || \
    echo "   ❌ 소스 코드 삭제 실패"
else
  echo "   ⏭️  소스 코드 경로가 존재하지 않습니다 (건너뜀)"
fi

# 3. Skills 삭제
echo ""
echo "🗑️  Skills 삭제 중..."
SKILLS_PATH="/Workspace/.assistant/skills/ai-dev-kit"
if databricks $DBX_PROFILE workspace get-status "$SKILLS_PATH" &> /dev/null; then
  databricks $DBX_PROFILE workspace delete "$SKILLS_PATH" --recursive && \
    echo "   ✅ Skills 삭제: $SKILLS_PATH" || \
    echo "   ❌ Skills 삭제 실패"
else
  echo "   ⏭️  Skills 경로가 존재하지 않습니다 (건너뜀)"
fi

# 완료
echo ""
echo "================================================"
echo "  삭제 완료!"
echo "================================================"
echo ""
echo "  참고: Genie Code의 MCP Servers 설정에서"
echo "  '$APP_NAME'을 수동으로 제거해주세요."
echo "================================================"
