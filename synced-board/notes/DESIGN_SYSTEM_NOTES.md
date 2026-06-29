# Design System Notes

Recovered from local YouMind board text. These excerpts are intentionally local-first so future development does not depend on reopening YouMind.

## Excerpt 1

```text
、动效。原版见 ui-screens.md（v1 迭代参考）。

一、导航架构

iOS (TabView — 底部四标签):

📅 日历 👥 人脉 🗂 事项 ⚙️ 设置

│ │ │ │

事件列表/创建 人脉详情页 案件列表/详情 设置表单

│ │

新建事件弹窗 / 新建联系人弹窗

iPad / Mac (NavigationSplitView 三栏):

侧栏 内容列表 详情

屿连 IslandLink — 设计系统 v2

基于「连接」的品牌理念重建：海豚双游，人案相连。专业而温暖，精准而流动。

一、设计哲学

三条原则贯穿整个设计系统：

连接可见。 每到一个页面，用户应该一眼看到当前实体（人/案）的全部关联。关联不是藏在菜单里的功能，而是页面结构的一级公民。海豚头尾相接的意象落实为具体设计语言：每个实体的关联区域用环绕式布局，视觉上形成"相连"的闭环。

专业但不冷。 法律工具天然需要权威感和信任感，但"连接"的核心是人——法官、当事人、同行律师。色彩体系在传统法律蓝的基础上注入暖调，让每个角色类型有体温，让案件列表有呼吸感。不是冷冰冰的数据库，而是一个律师愿意每天打开的工作伴侣。

精准流动。 交互的节奏像海豚游泳——平滑、连续、不打断。导航转场用共享元素过渡，搜索补全用渐入而非弹跳，列表加载用淡入序列。每一个像素的运动都服务于"连接"这个核心隐喻：从一个实体到另一个实体的跳转，是游泳，不是跳跃。

二、色彩体系

2.1 品牌主色

以海豚双游为灵感，主色从深海蓝渐变到暖珊瑚，覆盖专业感和人情味两极。

色板 色值 用途

DataModel.swift

1 周前

屿连app开发
任务
文件
分享
你的文件
IslandLink v4 — 全部源码（24 文件合并，可下载）
IslandLink v4 — 全部源码（18+ 文件合并）
IslandLink v4 · Batch 4/4 · GitHub API 上传脚本
IslandLink v4 · Batch 3/4 · GitHub API 上传脚本
IslandLink v4 · Batch 2/4 · GitHub API 上传脚本
IslandLink v4 · Batch 1/4 · GitHub API 上传脚本
IslandLink v4 — GitHub API 上传脚本
IslandLink v4 源码推送脚本
屿连 IslandLink — 完整源码包 v4（供 ChatGPT 使用）
屿连 IslandLink — 源码更新包 v4
屿连 IslandLink — 项目上下文（供 AI 编程助手使用）
屿连/DataModel.swift
屿连/Supporting/Infrastructure.swift
屿连/Supporting/EventSupport.swift
屿连/Supporting/SubscriptionStubs.swift
从 YouMind 下载 14 个 Swift 源文件 · 操作指南
推送到 GitHub — 操作清单
.gitignore — 屿连 IslandLink
新建文档
屿连/IslandLinkApp.swift
屿连/project.yml
屿连 IslandLink — iOS / macOS 真机安装测试指南
全项目源代码审计报告 v9
飞书多维表格 → 岛连 IslandLink：契合功能与借鉴方案
飞书多维表格字段系统研究 — 对岛连 IslandLink 的启示
屿连/TodayWidget.swift
屿连/AppIntents.swift
屿连/HandoffManager.swift
屿连/CloudSyncObserver.swift
义军 周
添加封面
生成标题
IslandLink v4 — 全部源码（24 文件合并，可下载）

格式说明：每个文件以 ===FILE: 路径 === 开头，===END=== 结尾。


myagents 可据此分隔文件并推送到 GitHub 仓库 tianping836/connect，目标路径前缀为 屿连/。


.Token: [REDACTED_GITHUB_TOKEN]

=FILE: project.yml=


name: IslandLink


options:


bundleIdPrefix: com.youmind


deploymentTarget:


iOS: "17.0"


xcodeVersion: "16.0"


generateEmptyDirectories: true


developmentLanguage: zh-Hans


usesTabs: false
```

## Excerpt 2

```text
文字

static let oceanDeep = Color(hex: "0D2137")

/// 青绿连接色 · 链接、关联指示、选中态

static let tealLink = Color(hex: "00897B")

连接 App 图标 - 温暖水彩版
1 周前
连接 App 图标 - 极简线条版
1 周前
连接 App 图标 - 海豚头尾相连
1 周前
UI 页面设计 v2

按「屿连 IslandLink 设计系统 v2」重新设计的全部页面。每个页面标注了使用的组件、色彩、动效。原版见 ui-screens.md（v1 迭代参考）。

一、导航架构

iOS (TabView — 底部四标签):

📅 日历 👥 人脉 🗂 事项 ⚙️ 设置

│ │ │ │

事件列表/创建 人脉详情页 案件列表/详情 设置表单

│ │

新建事件弹窗 / 新建联系人弹窗

iPad / Mac (NavigationSplitView 三栏):

侧栏 内容列表 详情

屿连 IslandLink — 设计系统 v2

基于「连接」的品牌理念重建：海豚双游，人案相连。专业而温暖，精准而流动。

一、设计哲学

三条原则贯穿整个设计系统：

连接可见。 每到一个页面，用户应该一眼看到当前实体（人/案）的全部关联。关联不是藏在菜单里的功能，而是页面结构的一级公民。海豚头尾相接的意象落实为具体设计语言：每个实体的关联区域用环绕式布局，视觉上形成"相连"的闭环。

专业但不冷。 法律工具天然需要权威感和信任感，但"连接"的核心是人——法官、当事人、同行律师。色彩体系在传统法律蓝的基础上注入暖调，让每个角色类型有体温，让案件列表有呼吸感。不是冷冰冰的数据库，而是一个律师愿意每天打开的工作伴侣。

精准流动。 交互的节奏像海豚游泳——平滑、连续、不打断。导航转场用共享元素过渡，搜索补全用渐入而非弹跳，列表加载用淡入序列。每一个像素的运动都服务于"连接"这个核心隐喻：从一个实体到另一个实体的跳转，是游泳，不是跳跃。

二、色彩体系

2.1 品牌主色

以海豚双游为灵感，主色从深海蓝渐变到暖珊瑚，覆盖专业感和人情味两极。

色板 色值 用途

DataModel.swift

1 周前

屿连app开发
任务
文件
分享
你的文件
IslandLink v4 — 全部源码（24 文件合并，可下载）
IslandLink v4 — 全部源码（18+ 文件合并）
IslandLink v4 · Batch 4/4 · GitHub API 上传脚本
IslandLink v4 · Batch 3/4 · GitHub API 上传脚本
IslandLink v4 · Batch 2/4 · GitHub API 上传脚本
IslandLink v4 · Batch 1/4 · GitHub API 上传脚本
IslandLink v4 — GitHub API 上传脚本
IslandLink v4 源码推送脚本
屿连 IslandLink — 完整源码包 v4（供 ChatGPT 使用）
屿连 IslandLink — 源码更新包 v4
屿连 IslandLink — 项目上下文（供 AI 编程助手使用）
屿连/DataModel.swift
屿连/Supporting/Infrastructure.swift
屿连/Supporting/EventSupport.swift
屿连/Supporting/SubscriptionStubs.swift
从 YouMind 下载 14 个 Swift 源文件 · 操作指南
推送到 GitHub — 操作清单
.gitignore — 屿连 IslandLink
新建文档
屿连/IslandLinkApp.swift
屿连/project.yml
屿连 IslandLink — iOS / macOS 真机安装测试指南
全项目源代码审计报告 v9
飞书多维表格 → 岛连 IslandLink：契合功能与借鉴方案
飞书多维表格字段系统研究 — 对岛连 IslandLink 的启示
屿连/TodayWidget.swift
屿连/AppIntents.swift
屿连/HandoffManager.swift
屿连/CloudSyncObserver.swift
义军 周
添加封面
生成标题
IslandLink v4 — 全部源码（24 文件合并，可下载）

格式说明：每个文件以 ===FILE: 路径 === 开头，===END=== 结尾。


myagents 可据此分隔文件并推送到 GitHub 仓库 tianping836/connect，目标路径前缀为 屿连/。


.Tok
```

