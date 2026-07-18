#!/bin/bash
# agent-leak-guard v0.1 — AI 代码助手数据泄露防护 (Linux/macOS)
# 用法:  ./agent-leak-guard.sh scan
#        sudo ./agent-leak-guard.sh guard
set -euo pipefail

RULE_FILE="$(dirname "$(realpath "$0")")/rules/exfil_signatures.json"
MODE="${1:-}"

# ---- 明文密钥扫描 (Scan) ----
scan_mode() {
  echo -e "\n=== AI Agent 明文密钥扫描 ==="
  RISK_COUNT=0

  # 名称|配置路径|字段列表 (无 eval, 直用字面量)
  CONFIGS=(
    "Grok CLI|${HOME}/.config/grok/config.json|api_key,auth_token,xai_api_key"
    "Claude Code|${HOME}/.config/claude/claude.json|anthropic_api_key,apiKey,session_key"
    "Cursor|${HOME}/.config/Cursor/User/settings.json|cursor.apiKey,auth.token,access_token"
  )

  for entry in "${CONFIGS[@]}"; do
    IFS='|' read -r NAME PATH FIELDS <<< "$entry"
    if [ -f "$PATH" ]; then
      echo -e "\n[OK] 检测到 $NAME，配置：$PATH"
      IFS=',' read -ra FIELD_ARR <<< "$FIELDS"
      for field in "${FIELD_ARR[@]}"; do
        if grep -qE "$field"'.*[:=].*["'"'"'][A-Za-z0-9_-]{20,}["'"'"']' "$PATH" 2>/dev/null; then
          echo "  [WARN] 明文密钥字段：$field"
          RISK_COUNT=$((RISK_COUNT + 1))
        fi
      done
    fi
  done

  echo -e "\n=== 扫描结果 ==="
  if [ "$RISK_COUNT" -eq 0 ]; then
    echo "OK 未检测到常见 AI CLI 明文密钥"
  else
    echo "RED 共发现 $RISK_COUNT 项明文密钥风险，建议迁移至环境变量存储"
  fi
}

# ---- 实时监控 + 阻断 (Guard) ----
guard_mode() {
  echo -e "\n=== AI Agent 泄露防护已启动 ==="
  echo "实时监控出网连接，命中已知泄露端点将告警并阻断"
  echo "阻断需要 root：Linux 用 iptables，macOS 用 pfctl/Little Snitch"

  # 启动时缓存高风险域名 IP
  declare -A BLOCKED
  HIGH_RISK_DOMAINS=("grok-code-session-traces.storage.googleapis.com")
  declare -A CACHED_IPS
  for domain in "${HIGH_RISK_DOMAINS[@]}"; do
    ips=$(dig +short "$domain" 2>/dev/null || true)
    for ip in $ips; do CACHED_IPS["$ip"]=1; done
    echo "  [cached] $domain -> $(echo "$ips" | tr '\n' ' ')"
  done

  while true; do
    if command -v ss >/dev/null 2>&1; then
      CONNS=$(ss -tn state established 2>/dev/null | awk 'NR>1 {print $5}' | sed 's/:.*//')
    else
      CONNS=$(lsof -iTCP -sTCP:ESTABLISHED -n 2>/dev/null | awk 'NR>1 {print $9}' | sed 's/:.*//')
    fi
    for ip in "${!CACHED_IPS[@]}"; do
      if echo "$CONNS" | grep -qx "$ip" && [ -z "${BLOCKED[$ip]:-}" ]; then
        echo -e "\n[RED] 高危告警！可疑泄露连接：$ip"
        if command -v iptables >/dev/null 2>&1; then
          iptables -A OUTPUT -d "$ip" -j DROP 2>/dev/null && echo "  [OK] 已添加 iptables 阻断规则" || echo "  [FAIL] iptables 写入被拒（需 root）"
        else
          echo "  [WARN] macOS 请手动 pfctl 规则或 Little Snitch 阻断 $ip"
        fi
        BLOCKED[$ip]=1
      fi
    done
    sleep 5
  done
}

case "$MODE" in
  scan) scan_mode ;;
  guard) guard_mode ;;
  *) echo "用法：./agent-leak-guard.sh [scan|guard]"; exit 1 ;;
esac
