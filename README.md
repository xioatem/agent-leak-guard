# agent-leak-guard

### Never let your AI coder ship your `~/.ssh` to a cloud bucket.

跨平台 AI 代码助手数据泄露防护工具 —— 一键扫描本地 AI CLI 明文密钥、实时监控并阻断可疑代码库外发。

---

## 🎯 项目定位：AI Agent 的本地安全基线，而非厂商 exposé

本项目的长期价值**不是曝光某一家厂商**，而是为使用 AI 编码助手的开发者建立一道**可自查、可防护的本地安全基线**。

- **我们揭示的是「风险」，不是「秘密」**。明文密钥存储、默认将 `cwd` 纳入上下文、旁路通道上传——这些是 AI Agent 工作模式的**结构性暴露面**，与具体厂商无关。
- **影响对象是人（开发者），不是厂商**。一个开发者在 `git push` 前用本工具扫一遍本地配置，价值远高于一篇厂商黑料。
- **价值锚点在「基线」，不随时间失效**。单家厂商的泄露事件是时间有界的；「AI Agent 本地安全基线」是持续、可泛化的能力。
- 因此，规则库以**通用泄露特征**（端点 / URI / 二进制字符串 / 明文密钥字段）组织，而非以厂商丑闻组织。新增规则 = 提交一个规则对象（见 `rules/SCHEMA.md`），与具体厂商无关。

> 本工具与文档基于**已公开的安全报告**与**用户设备配置审计**，对所涉厂商**不做任何未经证实的法律定性**。

---

## 🧩 核心资产：规则契约（Rule Contract）

> 本项目的长期资产**不是脚本，而是规则契约**——一份可独立存在、可被多引擎消费的泄露特征库。
> 即使明天删除所有 `.ps1` / `.sh`，`rules/exfil_signatures.json` 仍是一份完整、可被读取、可被校验、可被其他工具消费的规则资产。

规则库采用 **v0.2 Rule-Object schema**（详见 [rules/SCHEMA.md](rules/SCHEMA.md)）：

- `exfil_endpoints`：FQDN 泄露端点（`resolve: true` 表示运行时 DNS 解析并监控 IP）。
- `exfil_indicators`：不可解析的 URI / 二进制字符串特征（用于配置与进程内存扫描）。
- `ai_cli_list`：主流 AI CLI 的二进制名、配置文件路径、明文密钥字段。
- 每条规则携带治理元数据：`rule_id`（`ALG-EXXX`）/ `confidence` / `evidence` / `references` / `platforms` / `introduced` / `last_updated`。

**引擎无关性（Engine-Independence）是本设计的核心约束**：规则库不内嵌任何特定引擎的私有逻辑；脚本只是契约的一个解释器。CI（[validate-rules.yml](../../.github/workflows/validate-rules.yml)）校验的是**契约合法性**，而非某个脚本的行为。任何第三方工具——IDE 插件、企业 SIEM、EDR——都可以直接读取同一份 JSON，无需依赖本仓库的执行器。

新增规则 = 提交一个 Rule Object（见 [CONTRIBUTING.md](CONTRIBUTING.md)），无需改代码。

## 🔥 为什么你需要这个

近期多款主流 AI 编码助手被曝出**静默上传 / 明文存密钥**相关争议：

- **Grok CLI（v0.2.93）**：2026-07 独立安全研究者发布线级（wire-level）流量分析，报告其将工作目录打包经旁路通道上传至 xAI 的 Google Cloud Storage 桶（`grok-code-session-traces`），且关闭「改进模型」选项未能阻止。（详见下方「信息来源」）
- **Claude Code / Cursor / Copilot**：配置文件普遍以明文存储 API 密钥；本地 Agent 默认将 `cwd` 纳入上下文，客观上构成密钥暴露面（用户侧配置自查结论）。
- 普通开发者缺乏低成本的**自查 + 主动防护**手段。

本工具零依赖、一键运行，面向普通开发者提供 AI Agent 泄露自查与主动防护能力。

> ⚠️ 立场声明：本工具与文档基于**已公开的安全报告**与**用户设备配置审计**，对所涉厂商**不做任何未经证实的法律定性**。标注「待验 / 社区反馈」的项，请以官方公告与您自身验证为准。

---

## 📚 信息来源（公开报告）

- **Grok CLI 上传事件**：2026-07，独立安全研究者（社区代号 cereblab）对 Grok CLI v0.2.93 的线级流量分析，在 Hacker News 与开发者社区引发广泛讨论。结论为：该工具会将工作目录打包经旁路通道静默上传至 xAI 的 Google Cloud Storage 桶（`grok-code-session-traces`），上传内容包含 `.env` 生产密钥；关闭「改进模型」选项未能阻止。
- **其他厂商项**：Claude Code / Cursor / Copilot 的明文密钥存储与遥测行为，基于社区反馈与配置审计整理，**待独立验证**，不构成对厂商的最终定性。

---

## 📊 AI Agent 自查对照表（公开事件 + 配置审计汇总）

> 本表为**公开事件与配置审计的汇总自查参考**，**非厂商官方声明**。🔴=已公开证实；🟡=社区报告 / 待验；🟢=否 / 未见报告。**威胁等级为启发式自查参考，不构成法律定性**，请以官方公告为准。

| AI 工具 | 明文存密钥(配置自查) | 旁路上传代码库 | 威胁等级(自查参考) |
|--------|----|----|----|
| Grok CLI (v0.2.93) | 🟠 是 | 🔴 已公开证实 (GCS) | 🔴 极高 |
| Claude Code | 🟠 是 | 🟡 社区报告/待验 | 🟠 高 |
| Cursor | 🟠 是 | 🟡 社区报告/待验 | 🟡 中 |
| GitHub Copilot | 🟠 是 | 🟢 否 | 🟡 中 |

---

---

## 🚀 参考引擎（Reference Engine）：agent-leak-guard

> 下面的脚本只是规则契约的一个**参考实现（Reference Engine）**——可替换、可移植。真正的资产是上方「规则契约」。你可以只用规则库，也可以把规则库接入你自己的工具链。

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

## ⚖️ 法律与安全声明

1. **非法律意见**：本工具与文档**不构成法律意见**，也**未对任何厂商作出最终法律定性**。所有结论基于公开报告与用户设备自查，可能随版本/时间变化。
2. **以官方为准**：🔴 以外的标注项均为待验或社区反馈；涉及具体厂商行为的定性，请以官方公告与您自身验证为准。
3. **特征可能误报/漏报**：规则库为社区整理，Guard 模式网络操作需管理员/root 权限，请知悉相关风险并自行评估。
4. **禁止滥用**：严禁将本工具用于未授权扫描、攻击他人系统或任何违法用途。
5. **风险自担**：使用本工具即表示您已知悉并自担风险；作者对任何直接或间接损失不承担责任。

---

---

## 📄 许可证与商业边界（Phase 1）

本项目采用 **Apache License 2.0**（见 [LICENSE](LICENSE)）。

**明确边界（回答"希望别人如何使用"）：**
- **个人与企业均可免费使用**，包括将 `rules/` 规则契约集成进**闭源商业产品**——这正是本项目的设计目标（引擎无关、可被 SIEM/EDR/IDE 等任何载体消费）。
- **规则库可修改、再分发**：但请在派生版本中保留 `rule_id` / `evidence` / `confidence` 等治理元数据，避免共享基线被静默降级。
- **不含自创的"禁止商业使用"条款**：那会与开源许可证冲突并降低采用率。

**商业化的保留空间：**
- 当前所有代码与规则**完全免费、可商用**。
- 未来若出现集中管理、规则同步、审计、团队协作等**企业级能力**，将作为**独立专有层**消费这套开放规则——绝不反向限制规则资产本身的开放性。

> 商业模式暂不设计。许可证清晰 > 提前设计收费。企业集成 / 厂商合作需求出现时，再据实际场景决定下一步。

#AISecurity #AgentLeak #Grok #ClaudeCode #Cursor #数据泄露 #开发者工具 #代码安全

## Roadmap (v0.2)

### 工程方向
- **进程内存扫描**：枚举本地 AI Agent 进程，扫描 `repo_state.upload` / `before_codebase` 等泄露特征字符串
- **macOS 完整阻断**：Guard 模式补 pfctl 自动规则注入（当前 Windows/Linux 已支持）
- **规则库众包**：新增 Gemini CLI / Codex / Aider 等端点特征
- **Scan 增强**：除配置 key 字段外，扩展到 env / shell history / .netrc
- **CI 自检**：本仓库 GitHub Action 自动校验规则库 JSON 合法性（已上线 `validate-rules.yml`）

### 长期北极星（North Star）
- **当前定位**：AI Agent 本地安全基线（AI Agent Local Security Baseline）。
- **未来形态**：若社区成型，演进为 **AI Agent 本地安全的开放规则框架（Open Rule Framework）**——核心从执行脚本（`agent-leak-guard`）迁移到可被多载体消费的规则生态（OS 原生 Guard / IDE 插件 / 企业 SIEM·EDR 共用同一份规则库）。**这是社区演化的可能方向，不是自封标准；能否成立取决于外部采用。**
- 该迁移的标志：外部贡献者提交的是 `Rule / Metadata / Evidence / Confidence`，而不是 `PowerShell`。
- 详见 [STRATEGY.md](STRATEGY.md)（含 Origin≠Identity、Engine≠Asset 定位逻辑）。
