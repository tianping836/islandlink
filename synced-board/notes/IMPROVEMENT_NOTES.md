# Improvement Notes

Recovered from local YouMind board text. These excerpts are intentionally local-first so future development does not depend on reopening YouMind.

## Excerpt 1

```text
图谱，而是专业人脉的真实网络——谁和谁真的在案子里碰过

AllTrails（2023 iPhone 年度应用）

获奖理由：「帮助用户找到通往户外的路径」。6000 万+用户验证了人需要工具帮自己看清眼前的地图

Weixin

这 12 个 App 拿了今年的 Apple 设计奖：3 支中国团队，居然还有你用过的它……

2025 Apple 设计奖正式揭晓，三支中国团队脱颖而出

1 周前
屿连 IslandLink · 第四梯队：连接落地计划

核心原则：一切以连接为中心。 人 > 案件。网络 > 节点。

不做案件管理，不做时间线。做人与人之间的桥梁。

一、UX 写作全量改写（立即做，零风险）

原则

主语是人，不是案件

动词是连接，不是管理

空状态是邀请，不是报错

温度是自然的，不是煽情的

改写清单

位置 当前 改为 人脉空状态 「暂无联系人」 「还没有联系人。加第一位？」

屿连 IslandLink · 第三轮深度改进分析

本轮超越之前两轮的分析范围（Things 3 / Fantastical / Bear / Structured / Craft），引入此前未覆盖的十年标杆 App，聚焦「用户体验纵深」而非功能清单。

前两轮已实现的：触觉反馈、系统日历同步、Widget、Siri 指令、Spotlight、滑动操作、键盘快捷键、Apple Watch、概览卡片、通知管道、无障碍标注 —— 这些不再重复。

本轮学习对象

App 获奖/荣誉 本轮启示 Flighty 2023 ADA 交互类 Live Activity 的 15 种上下文感知状态

Agenda 2018 ADA 笔记与日历事件的时间线融合

Due 8 年持续付费榜前列 关键事项「不死」提醒哲学

Gentler Streak 2024 ADA 社会影响类 情感化设计 + 对高压用户的 UX 写作

CARROT Weather 2021 ADA 可调节人格的 App 差异化

iOS App 技术栈选型

决策日期：2026-06-16 状态：已确定

决策

SwiftUI 纯原生。不做跨平台，不用 Flutter / React Native。

约束条件

目标平台：仅 iOS，无 Android 需求

App 类型：工具 / 效率类

开发背景：非技术背景，依赖 AI 辅助

为什么是 SwiftUI

不需要跨平台，就没有理由承担跨平台的代价。 Flutter 和 React Native 的价值是"写一次双端运行"。只做 iOS 时，它们带来的性能折扣、原生能力受限、调试复杂度、苹果新特性滞后全是净损失。

SwiftUI 是所有 LLM 生成 Swift 代码的最佳目标。 学术评测和开发者实战一致确认：SwiftUI（声明式）的 AI 生成质量远高于 UIKit（命令式）。声明式框架与 AI 的"描述-生成"模式天然吻合——你描述界面长什么样，它直接渲染。UIKit 需要手动管理生命周期、约束和代理，AI 生成的代码编译通过率低，往往需要反复修 3-5 轮。

YouMind - AI Creation Studio

https://youmind.com/board-files/019edeae-8213-786f-a5c0-4f2b51694e8d

YouMind - AI Creation Studio

https://youmind.com/board-files/019edeae-0f81-71fa-bea3-fb073f7fbe46

屿连/PersonNetworkView.swift

import SwiftUI

import SwiftData

// MARK: - 以人为节点的关系网络可视化

/// 人脉网络图 — 连接第五梯队核心视图

///

/// 设计理念：参考 Apple「查找」App 的网络图风格——克制、干净、以人为中心。

/// 中心节点是焦点人物，周围环绕与之有共享案件/事件的人。

/// 人与人之间若有共同的案件，以纤细半透明连线相连，连线粗细反映连接强度。

///

/// 布局：简单放射状排列（非力导向算法），节点沿圆周分布。

屿连/PersonConnectionView.swift

import SwiftUI

import SwiftData

/// 「你们之间」视图 — 连接第四梯队核心页面

/// 展示两个人的连接全景：共享案件、共同事件、互动时间线、共同认识的人

///

/// 设计理念：以连接为中心，不展示案件管理功能。

/// 每一个共享节点都是两人关系的证据 —— 从案件到事件再到人，层层展开。

///
```

## Excerpt 2

```text
ndLink · 第四梯队：连接落地计划

核心原则：一切以连接为中心。 人 > 案件。网络 > 节点。

不做案件管理，不做时间线。做人与人之间的桥梁。

一、UX 写作全量改写（立即做，零风险）

原则

主语是人，不是案件

动词是连接，不是管理

空状态是邀请，不是报错

温度是自然的，不是煽情的

改写清单

位置 当前 改为 人脉空状态 「暂无联系人」 「还没有联系人。加第一位？」

屿连 IslandLink · 第三轮深度改进分析

本轮超越之前两轮的分析范围（Things 3 / Fantastical / Bear / Structured / Craft），引入此前未覆盖的十年标杆 App，聚焦「用户体验纵深」而非功能清单。

前两轮已实现的：触觉反馈、系统日历同步、Widget、Siri 指令、Spotlight、滑动操作、键盘快捷键、Apple Watch、概览卡片、通知管道、无障碍标注 —— 这些不再重复。

本轮学习对象

App 获奖/荣誉 本轮启示 Flighty 2023 ADA 交互类 Live Activity 的 15 种上下文感知状态

Agenda 2018 ADA 笔记与日历事件的时间线融合

Due 8 年持续付费榜前列 关键事项「不死」提醒哲学

Gentler Streak 2024 ADA 社会影响类 情感化设计 + 对高压用户的 UX 写作

CARROT Weather 2021 ADA 可调节人格的 App 差异化

iOS App 技术栈选型

决策日期：2026-06-16 状态：已确定

决策

SwiftUI 纯原生。不做跨平台，不用 Flutter / React Native。

约束条件

目标平台：仅 iOS，无 Android 需求

App 类型：工具 / 效率类

开发背景：非技术背景，依赖 AI 辅助

为什么是 SwiftUI

不需要跨平台，就没有理由承担跨平台的代价。 Flutter 和 React Native 的价值是"写一次双端运行"。只做 iOS 时，它们带来的性能折扣、原生能力受限、调试复杂度、苹果新特性滞后全是净损失。

SwiftUI 是所有 LLM 生成 Swift 代码的最佳目标。 学术评测和开发者实战一致确认：SwiftUI（声明式）的 AI 生成质量远高于 UIKit（命令式）。声明式框架与 AI 的"描述-生成"模式天然吻合——你描述界面长什么样，它直接渲染。UIKit 需要手动管理生命周期、约束和代理，AI 生成的代码编译通过率低，往往需要反复修 3-5 轮。

YouMind - AI Creation Studio

https://youmind.com/board-files/019edeae-8213-786f-a5c0-4f2b51694e8d

YouMind - AI Creation Studio

https://youmind.com/board-files/019edeae-0f81-71fa-bea3-fb073f7fbe46

屿连/PersonNetworkView.swift

import SwiftUI

import SwiftData

// MARK: - 以人为节点的关系网络可视化

/// 人脉网络图 — 连接第五梯队核心视图

///

/// 设计理念：参考 Apple「查找」App 的网络图风格——克制、干净、以人为中心。

/// 中心节点是焦点人物，周围环绕与之有共享案件/事件的人。

/// 人与人之间若有共同的案件，以纤细半透明连线相连，连线粗细反映连接强度。

///

/// 布局：简单放射状排列（非力导向算法），节点沿圆周分布。

屿连/PersonConnectionView.swift

import SwiftUI

import SwiftData

/// 「你们之间」视图 — 连接第四梯队核心页面

/// 展示两个人的连接全景：共享案件、共同事件、互动时间线、共同认识的人

///

/// 设计理念：以连接为中心，不展示案件管理功能。

/// 每一个共享节点都是两人关系的证据 —— 从案件到事件再到人，层层展开。

///

/// Obsidian 启发增强：

/// - 「他们也连接着…」横向滚动面板：展示 B 的 Top 5 其他人脉（#4）

Swift 文件写入完成 ✅

生成时间： 2026-06-19

用法： bash sync.sh

将自动备份现有目录，然后写出全部 19 个 Swift 文件到 /.myagents/projects/islandlink/

!/usr/bin/env bashset -
```

## Excerpt 3

```text
时间默认在事件前 15 分钟（全天事件在前一天 21:00 提醒）

@MainActor

final class NotificationManager: ObservableObject {

static let shared = NotificationManager()

private let center = UNUserNotificationCenter.current()

屿连 IslandLink · 第二轮深度改进分析

对比对象：2026 Apple Design Award 获奖作品 + Things 3 / Fantastical / Bear / Structured

对照基准：第一轮美化方案 + 事件板块架构 + 当前代码实现状态

对比表格速览

维度 Things 3 Fantastical Structured Bear 连接（当前） 连接（差距） 触觉反馈 ✅ ✅ ✅ — ❌ 完全缺失

系统日历同步 — ✅ 核心 ✅ — ❌ 核心缺失

Siri / 快捷指令 ✅ ✅ ✅ ✅ ❌ 完全缺失

通知提醒 ✅ ✅ ✅ — ❌ 完全缺失

Widget 小组件 ✅ ✅ ✅ ✅ ❌ 完全缺失

Spotlight 搜索 — ✅ — ✅ ❌ 完全缺失 手势滑动操作 ✅ ✅ ✅ ✅ ❌

屿连/CodeGeneratorSheet.swift

import SwiftUI

import SwiftData

/// 作者专用邀请码生成器

/// 入口：在设置页长按「连接 v1.0 · 构建于 SwiftUI」3 秒

struct CodeGeneratorSheet: View {

@Environment(\.modelContext) private var modelContext

@Environment(\.dismiss) private var dismiss

@State private var generatedCodes: [RedeemCode] = []

@State private var note: String = ""

@State private var count: Int = 1

屿连/RedeemCodeManager.swift

import SwiftUI

import SwiftData

/// 邀请码管理：生成、兑换、验证

/// 用法：生成码由作者在专用界面操作；普通用户仅调用 redeem(\:)

@MainActor

final class RedeemCodeManager: ObservableObject {

static let shared = RedeemCodeManager()

/// 码前缀

static let codePrefix = "CNET"

// 已发布状态

屿连/RedeemSheet.swift

import SwiftUI

/// 邀请码兑换页

struct RedeemSheet: View {

@EnvironmentObject private var subManager: SubscriptionManager

@Environment(\.modelContext) private var modelContext

@Environment(\.dismiss) private var dismiss

@State private var codeBlocks: [String] = ["", ""]

@FocusState private var focusedBlock: Int?

private let blockLength = 4

var body: some View {

屿连/SubscriptionManager.swift

import SwiftUI

import StoreKit

// MARK: - 订阅管理

/// 连接 CaseNetwork 订阅管理

/// 免费版上限：人脉 50 + 案件/事件合计 50

/// Pro 年费订阅：¥99/年，无上限

@MainActor

final class SubscriptionManager: ObservableObject {

static let shared = SubscriptionManager()

// ── 订阅产品 ID ──

屿连/UpgradeSheet.swift

import SwiftUI

/// Pro 升级页 — Apple 风格

/// 触发场景：免费用户超额时自动弹出，或从设置页手动唤起
```

