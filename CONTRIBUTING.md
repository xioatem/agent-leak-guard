# 贡献指南 (Contributing)

本项目起点是一次具体的 AI Agent 数据安全事件，目标是成长为一个**通用的 AI Agent 本地安全检查框架**。欢迎社区参与，尤其欢迎规则特征的补充与纠错。

## 三种贡献入口（已配 Issue 模板）

| 你想做 | 用哪个模板 | 说明 |
|--------|-----------|------|
| 提交新泄露特征 | `new_signature` | 新增端点 / URI 指标 / 二进制字符串 / AI CLI 条目 |
| 报告误报 (False Positive) | `false_positive` | 某良性文件/字符串被错误命中 → 帮我们降噪 |
| 报告漏报 (False Negative) | `false_negative` | 已知泄露模式未被检出 → 帮我们补检测 |
| 提 Bug / 增强 | `bug_report` / `enhancement` | 程序逻辑、兼容性、体验 |

## 提交新特征 (new_signature) 规范

1. **必须附公开来源**：链接到公开报告 / 官方文档 / 可复现的流量/配置审计。本仓库**不做任何未经证实的法律定性**。
2. **字段对齐** `rules/exfil_signatures.json`（v0.2 Rule-Object，详见 `rules/SCHEMA.md`）：
   - `exfil_endpoints`：FQDN（`rule_id` 形如 `ALG-E###`，标注 `resolve: true` 用于运行时 DNS 监控）
   - `exfil_indicators`：不可解析的 URI / 二进制字符串（`rule_id` 形如 `ALG-I###`）
   - `ai_cli_list`：二进制名 + 配置文件路径 + 明文密钥字段（`rule_id` 形如 `ALG-C###`）
   - **每条规则必须携带治理字段**：`rule_id` / `confidence` / `evidence` / `references` / `platforms` / `introduced` / `last_updated`
3. **提交规则对象**：往对应数组 append 一个完整 Rule Object（含 `rule_id` + 治理字段），**无需改代码**。CI 会自动校验 schema（见 `validate-rules.yml`）。
4. **同步** `rules/changelog.md` 与 `rules/VERSION`（规则集独立版本号）。

> 设计哲学：提交 PR = 提交一个**规则对象**，而不是简单改 JSON。把"规则如何进入系统"制度化，是本项目从 Tool 走向 Framework 的核心。

## 本地验证

```bash
# Scan 自检（期望：clean）
./agent-leak-guard.sh scan --fixture tests/benign/sample_config.json
# 检测校验（期望：>=1 hit）
./agent-leak-guard.sh scan --fixture tests/malicious/sample_leak.json
```

## 行为准则

- 以证据为准，理性讨论；
- 不在 Issue / PR 中粘贴真实密钥（fixture 用明显占位符如 `xai-XXXXFAKE`）；
- 对已披露厂商保持中立自查立场，不煽动、不造谣。

维护者会优先响应误报 / 漏报 —— 这类反馈正是工具价值的来源。
