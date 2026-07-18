<#
.SYNOPSIS
  agent-leak-guard v0.1 — AI 代码助手数据泄露防护 (Windows)
.DESCRIPTION
  Scan  : 审计本机主流 AI CLI 配置中的明文密钥
  Guard : 实时监控出网连接，命中已知泄露端点自动告警 + 防火墙阻断
.NOTES
  零依赖。Guard 阻断需管理员权限 (New-NetFirewallRule)。
#>
param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("Scan", "Guard")]
  [string]$Mode
)

$ErrorActionPreference = "SilentlyContinue"
$RulePath = Join-Path $PSScriptRoot "rules\exfil_signatures.json"
$Rules = Get-Content $RulePath -Raw | ConvertFrom-Json

# ========== Scan 模式 ==========
if ($Mode -eq "Scan") {
  Write-Host "`n=== AI Agent 明文密钥扫描 ===" -ForegroundColor Cyan
  $foundRisks = @()

  foreach ($cli in $Rules.ai_cli_list) {
    $configPath = [Environment]::ExpandEnvironmentVariables($cli.config_win)
    if (Test-Path $configPath) {
      Write-Host "`n[OK] 检测到 $($cli.name)，配置：$configPath" -ForegroundColor Green
      $configContent = Get-Content $configPath -Raw
      foreach ($field in $cli.key_fields) {
        # 修正后的正则：匹配 field: ">=20位可见字符"
        if ($configContent -match "(?i)$field\s*[:=]\s*['""]([A-Za-z0-9_\-]{20,})['""]") {
          $foundRisks += [PSCustomObject]@{ Tool = $cli.name; Risk = "明文API密钥"; Field = $field; Config = $configPath }
          Write-Host "  [WARN] 明文密钥字段：$field" -ForegroundColor Yellow
        }
      }
    }
  }

  Write-Host "`n=== 扫描结果 ===" -ForegroundColor Cyan
  if ($foundRisks.Count -eq 0) {
    Write-Host "OK 未检测到常见 AI CLI 明文密钥" -ForegroundColor Green
  }
  else {
    Write-Host "RED 共 $($foundRisks.Count) 项明文密钥风险，建议迁移至环境变量存储" -ForegroundColor Red
  }
  exit 0
}

# ========== Guard 模式 ==========
if ($Mode -eq "Guard") {
  Write-Host "`n=== AI Agent 泄露防护已启动 ===" -ForegroundColor Cyan
  Write-Host "实时监控出网连接，命中泄露端点将告警并注入防火墙阻断`n" -ForegroundColor Gray

  # 启动时解析可解析端点，缓存 IP 集合（避免每条连接重复 DNS）
  $resolvedEndpoints = @{}
  foreach ($rule in $Rules.exfil_endpoints) {
    if ($rule.resolve -eq $true) {
      try {
        $addrs = [System.Net.Dns]::GetHostAddresses($rule.pattern) | Select-Object -ExpandProperty IPAddressToString
        $resolvedEndpoints[$rule.name] = $addrs
        Write-Host ("  [cached] " + $rule.name + " -> " + ($addrs -join ", ")) -ForegroundColor DarkGray
      }
      catch {
        Write-Host ("  [warn] 无法解析 " + $rule.pattern + " (离线/域名失效)") -ForegroundColor DarkYellow
      }
    }
  }

  $blockedIPs = @{}
  while ($true) {
    $connections = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue
    foreach ($conn in $connections) {
      foreach ($ruleName in $resolvedEndpoints.Keys) {
        $ips = $resolvedEndpoints[$ruleName]
        if ($conn.RemoteAddress -in $ips -and $conn.RemoteAddress -notin $blockedIPs.Keys) {
          Write-Host "`n[RED] 高危告警！检测到可疑泄露连接" -ForegroundColor Red
          Write-Host ("  规则：" + $ruleName)
          Write-Host ("  远端：" + $conn.RemoteAddress + ":" + $conn.RemotePort)
          Write-Host ("  本地PID：" + $conn.OwningProcess)
          try {
            New-NetFirewallRule -DisplayName ("Block AI Exfil: " + $ruleName) `
              -Direction Outbound -Action Block -RemoteAddress $conn.RemoteAddress | Out-Null
            $blockedIPs[$conn.RemoteAddress] = $true
            Write-Host "  [OK] 已注入防火墙阻断规则" -ForegroundColor Green
          }
          catch {
            Write-Host "  [FAIL] 防火墙写入被拒（需管理员权限）" -ForegroundColor Red
          }
        }
      }
    }
    Start-Sleep -Seconds 5
  }
}
