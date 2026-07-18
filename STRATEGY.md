# agent-leak-guard — 产品定位与演进策略 (Strategy)

> 本文档记录项目的定位演进逻辑，非功能说明。面向贡献者与长期维护者。
> 内容源于项目讨论中对 "Origin ≠ Identity" 与 "Engine ≠ Asset" 的梳理。

---

## 1. Origin ≠ Identity（起源 ≠ 身份）

每个优秀项目都有一个"起源事件"，但项目的长期身份独立于它。

| 项目 | Origin（起源事件） | Identity（长期身份） |
|------|-------------------|---------------------|
| Git | Linux 内核开发的分支管理之争 | 分布式版本控制系统 |
| Kubernetes | Google 内部 Borg 经验 | 容器编排平台 |
| YARA | 恶意软件分析需求 | 模式匹配规则语言 |

**本项目的对应：**
- **Origin** = Grok CLI 上传事件（2026-07，cereblab 线级流量分析）。
- **Identity** = AI Agent 本地安全基线（AI Agent Local Security Baseline）。

README 已显式分离两者：Grok 事件作为"起源事实"保留在信息来源段，但定位段（README commit `509ce181`）将项目定义为基线工具，而非厂商 exposé。读者读完应记住的是"这是一个帮我查 AI Agent 本地安全风险的工具"，而不是"这是一个骂某厂商的仓库"。

---

## 2. 价值主体：用户今天能获得什么

> **一次本地自查 > 一篇厂商黑料。**

价值锚点从「别人做错了什么」迁移到「用户今天能获得什么」。对产品而言，这是更稳固的价值基础——它不随单家厂商事件的热度消退而失效。

---

## 3. Engine ≠ Asset（架构哲学，已落地）

项目里存在两类性质完全不同的东西：

- **Engine（执行器）= 脚本**（`.ps1` / `.sh`）：可替换、可移植、随平台变化。
- **Asset（资产）= 规则库**（`rule-object` + 治理元数据）：这是项目真正长期沉淀的部分。

这一区分不是愿景，而是已经在架构中实现的：
- `rules/exfil_signatures.json` 采用 **v0.2 Rule-Object schema**（`rule_id` + `confidence` + `evidence` + `references` + `platforms` + `introduced` + `last_updated`）。
- `rules/SCHEMA.md` 定义了规则如何进入系统（提交 PR = 提交一个规则对象）。
- CI（`validate-rules.yml`）校验的是**规则契约**，不是脚本逻辑。

**未来可消费同一份规则的多类载体：**
- 操作系统：Windows / Linux / macOS 原生 Guard
- IDE 插件：VS Code / JetBrains
- 企业：SIEM / EDR

当规则可被多载体消费时，项目核心就从 `agent-leak-guard`（某个执行器）迁移到 `AI Agent Security Rules`（规则生态）。脚本只是引擎，规则库才是资产。

---

## 4. North Star（未来定位）

- **当前**：AI Agent Local Security Baseline
- **未来（若社区成型）**：Open Rule Framework for AI Agent Local Security

这一迁移的标志是：外部贡献者提交的是 `Rule / Metadata / Evidence / Confidence`，而不是 `PowerShell`。

---

## 5. 社区演化阶段（热点驱动项目的普遍路径）

```
热点 → 围观 → 质疑 → 筛选 → 留下真正用户
```

README 的职责不是阻止第一印象（热点引流不可避免），而是帮助认真阅读的人在 2–3 分钟内理解：**这个项目最终想解决的问题是什么**。

---

## 6. 运营重心迁移

- **工程阶段**：规则 / JSON / CI / 脚本 / Workflow
- **运营阶段**：Positioning / Governance / Identity / Community / Narrative

代码好但无社区的项目很多；定位清晰、治理明确、叙事一致的项目更易形成生态。生态是否成立，最终取决于社区是否认可与持续参与——此点不能仅凭当前阶段下结论。
