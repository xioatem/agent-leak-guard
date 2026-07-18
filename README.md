# agent-leak-guard

### Never let your AI coder ship your `~/.ssh` to a cloud bucket.

跨平台 AI 代码助手数据泄露防护工具 —— 一键扫描本地 AI CLI 明文密钥、实时监控并阻断可疑代码库外发。

---

## 🔥 为什么你需要这个

近期多款主流 AI 编码助手被曝出**静默上传 / 明文存密钥**行为：

- **Grok CLI**（`@xai-official/grok`）：被证实存在旁路代码会话上传至 Google Cloud Storage（`gs://grok-code-session-traces`），无需用户确认；暴露后由服务端静默关闭 `trace_upload_enabled`，但二进制中仍保留完整 `repo_state.upload` 管线。
- **Claude Code / Cursor / Copilot**：配置文件普遍明文存储 API 密钥，CI/本地 Agent 默认扫描 `cwd` 作上下文，客观上构成密钥暴露面。
- 普通开发者缺乏低成本的**自查 + 主动防护**手段。

本工具零依赖、一键运行，面向普通开发者提供 AI Agent 泄露自查与主动防护能力。

> ⚠️ 立场声明：本工具基于**已公开的安全事件**与**配置审计**，不做对任何厂商的未经证实指控。威胁矩阵中标注「报告/待验」项，请以官方公告为准。

---

## 📊 AI Agent 威胁矩阵（自查对照表）

| AI 工具 | 读本地文件范围 | 旁路上传代码库 | 配置明文存密钥 | 默认遥测 | 威胁等级 |
|--------|----------------|----|----|----|----|
| Grok CLI | 全项目 + 全局配置 | 🔴 已证实 (GCS) | 🟠 是 | 🟠 是 | 🔴 极高 |
| Claude Code | 全项目 + 系统可读 | 🟡 报告/待验 | 🟠 是 | 🟡 待验 | 🟠 高 |
| Cursor | 打开的项目全量 | 🟡 部分上下文 | 🟠 是 | 🟠 是 | 🟡 中 |
| GitHub Copilot | 当前代码片段 | 🟢 否 | 🟠 是 | 🟠 是 | 🟡 中 |

---

## 🚀 快速开始

### Windows (PowerShell)
```powershell
# 1. 扫描本机 AI CLI 明文密钥
.\agent-leak-guard.ps1 -Mode Scan

# 2. 实时监控 + 自动防火墙阻断（管理员运行）
.\agent-leak-guard.ps1 -Mode Guard
```

### Linux / macOS
```bash
chmod +x agent-leak-guard.sh

# 1. 扫描明文密钥
./agent-leak-guard.sh scan

# 2. 实时防护（阻断需 root）
sudo ./agent-leak-guard.sh guard
```

---

## ✨ 功能特性

1. **Scan 模式**：一键审计本机 Grok / Claude Code / Cursor 配置，检测明文 API 密钥。
2. **Guard 模式**：实时监控出网连接，命中已知泄露端点（FQDN 可解析）立即告警并注入防火墙规则（Windows `New-NetFirewallRule` / Linux `iptables` / macOS `pfctl`）。
3. **可扩展规则库**：`rules/exfil_signatures.json` 内置 Grok / Claude / Cursor 泄露特征，支持自定义新增端点、URI 指标、二进制字符串特征。
4. **跨平台零依赖**：Windows PowerShell + Linux/macOS Shell 双版本，无需第三方运行时。

---

## 🧩 规则库结构 (`rules/exfil_signatures.json`)

- `exfil_endpoints`：FQDN 泄露端点（`resolve: true` 表示运行时 DNS 解析并监控 IP）。
- `exfil_indicators`：不可解析的 URI / 二进制字符串特征（用于配置与进程内存扫描）。
- `ai_cli_list`：主流 AI CLI 的二进制名、配置文件路径、明文密钥字段。

新增规则只需往对应数组追加 JSON 对象，无需改代码。

---

## ⚠️ 免责声明

本工具仅用于**个人设备自查与防护**，不保证 100% 拦截所有泄露行为，请勿用于非法用途。规则库持续更新，欢迎 PR 补充新的泄露特征。

#AISecurity #AgentLeak #Grok #ClaudeCode #Cursor #数据泄露 #开发者工具 #代码安全

## Roadmap (v0.2)

- **进程内存扫描**：枚举本地 AI Agent 进程，扫描 `repo_state.upload` / `before_codebase` 等泄露特征字符串
- **macOS 完整阻断**：Guard 模式补 pfctl 自动规则注入（当前 Windows/Linux 已支持）
- **规则库众包**：新增 Gemini CLI / Codex / Aider 等端点特征
- **Scan 增强**：除配置 key 字段外，扩展到 env / shell history / .netrc
- **CI 自检**：本仓库 GitHub Action 自动校验规则库 JSON 合法性（已上线 `validate-rules.yml`）
