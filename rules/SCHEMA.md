# 规则对象 Schema (v0.2)

> 从 v0.2 起，每一条签名不再只是数组元素，而是一个**带治理元数据的规则对象 (Rule Object)**。
> 提交 PR = 提交一个规则对象，而不是简单改 JSON。这是把"规则如何进入系统"制度化的核心。

## Rule ID 命名

```
ALG-<type><seq>
  type: E = exfil_endpoints | I = exfil_indicators | C = ai_cli_list
  seq : 三位零填充 (001, 002, ...)
例: ALG-E001, ALG-I004, ALG-C002
```

## 所有规则对象共享的治理字段

| 字段 | 必填 | 含义 |
|------|------|------|
| `rule_id` | ✅ | 全局唯一稳定 ID（PR 合并后不可改） |
| `confidence` | ✅ | `confirmed` / `observed` / `community` |
| `evidence` | ✅ | 来源类型数组（Public report / Packet capture / Config audit / Community report） |
| `references` | ✅ | 公开可查链接（HN/文档/论文）；无则空数组 |
| `platforms` | ✅ | 适用平台（Windows / Linux / macOS） |
| `introduced` | ✅ | 引入的版本（如 v0.1.0） |
| `last_updated` | ✅ | 最后更新日期 (YYYY-MM-DD) |

## confidence 等级定义

- **confirmed** — 有公开线级证据（如 cereblab 流量分析 + HN 讨论）；可写"已公开证实"。
- **observed** — 基于配置审计 / 厂商文档 / 社区复现；写"观察/待独立验证"。
- **community** — 社区报告，尚未独立核实；在 UI/报告中标注"社区反馈，待验"。

## 三类规则对象的专属字段

### exfil_endpoints (ALG-E###)
- `name`, `pattern` (FQDN), `resolve` (bool, 可 DNS 监控?), `severity`, `description`

### exfil_indicators (ALG-I###)
- `name`, `pattern` (URI / 二进制字符串), `severity`, `description`

### ai_cli_list (ALG-C###)
- `name`, `binary_win`, `binary_unix`, `config_win`, `config_unix`, `key_fields[]`

## 提交一个新规则（PR 流程）

1. 选下一个 `ALG-<type>###`（查 rules/changelog.md 取最大 seq +1）。
2. 填齐 7 个治理字段，**必须**在 `evidence` / `references` 给公开来源。
3. JSON 校验：`exfil_signatures.json` schema 已在 CI（待 Web UI 启用 `validate-rules.yml`）自动检查。
4. 同步 `rules/VERSION` 与 `rules/changelog.md`。
5. 用 `new_signature` Issue 模板发起，或直接提 PR。

## 为什么这样设计

成熟的安全规则生态（YARA / Sigma / Suricata）长期存活的原因，不是规则多，而是围绕"规则"建立了完整元数据与治理流。
`agent-leak-guard` 规模小，但借一次真实事件，先把**规则进入机制**制度化，未来扩展的是规则，而不是代码。
