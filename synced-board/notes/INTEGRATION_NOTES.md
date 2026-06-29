# Integration Notes

Recovered from local YouMind board text. These excerpts are intentionally local-first so future development does not depend on reopening YouMind.

## Excerpt 1

```text
link.backup.$(date +%Y%m%d%H%M%S)"

echo "===="

echo " 屿连 IslandLink — 全量源码同步"

echo " 目标目录: $TARGETDIR"

echo "===="

if [ -d "$TARGETDIR" ]; then

echo "→ 正在备份现有目录到 $BACKUPDIR ..."

屿连 IslandLink

屿连 IslandLink — 日历/通讯录集成 · 缺失分析与设计方案

2026-06-21 基于 YouMind v3 源码 ↔ GitHub 仓库对比

一、GitHub 仓库现状

https://github.com/tianping836/islandlink 当前仅包含 Phase 0/1 原型阶段的文件：

文件 内容 analysis.md 竞品、需求、数据模型分析

DataModel.swift 早期 SwiftData 原型（无事件系统、无连接、无体验纵深）

ui-screens.md 页面级 UI 描述

roadmap.md 7 个 Phase 路线图

YouMind v3 源码中至少 24 个核心源文件完全没有同步到 GitHub，包括全部事件系统、连接功能、可调节人格、Focus Filter、渐进式引导、设计系统、日历同步管理器等。

二、日历集成 — 现有能力 vs 缺失

2.1 已有能力（写入方向）

屿连 IslandLink v3 iOS原型

屿连 IslandLink — 当前 App vs YouMind v3 设计差异分析

基于 2026-06-21 iOS 端截图对比 v3 设计文档与源码

一、当前 App 现状（来自截图）

页面 截图内容 状态 搜索 搜索框 + 4 个快捷操作入口（全部人脉/全部案件/查找关系路径/去重检查），全部为 0 空状态

人脉 空状态：「还没有人脉」+ 添加按钮 空状态

案件 空状态：「还没有案件」+ 添加按钮 空状态

日历 月视图 + 统计（0/0/0）+「暂无即将到来的事件」 空状态

设置 应用锁（关）、iCloud 同步（关）、数据导入导出 功能入口

底部导航 搜索 / 人脉 / 案件 / 日历 / 设置（5 Tab） ✅

二、YouMind v3 有、但当前 App 缺失的功能（按梯队）

🔴 第二梯队 — 事件板块（完全缺失）

屿连 IslandLink Mac原型

屿连 IslandLink App 原型

屿连/upload.py

!/usr/bin/env python3

"""屿连 IslandLink — 全量源码上传到 GitHub 仓库

使用方法：

python3 upload.py

前提：

已安装 git

GitHub 仓库 https://github.com/tianping836/islandlink 已创建（空仓库）

"""

import subprocess

import os

Xcode 工程配置与编译验证 · 操作清单

创建时间：2026-06-21

前提：全部 Swift 源文件已编写完成，以下 4 项需在本地 Xcode 手动完成。

一、将 4 个新文件加入工程

在 Xcode 左侧 Project Navigator 中，找到对应 group（不存在则右键新建），将以下文件从 Finder 拖入：

文件 建议 Group 说明 CaseTimelineView.swift Views 案件时间线

AppToneManager.swift Managers 可调节人格 UX 写作

FocusFilterManager.swift Managers iOS 16+ Focus Filter

OnboardingManager.swift Managers 渐进式引导系统

操作要点：

拖入时勾选 ☑️ Copy items if needed

专业，但不冷
1 周前
不是又一个效率工具
1 周前
下一步
1 周前
理解每段关系
1 周前
六大核心能力
1 周前
看见你的网络
1 周前
三个设计信念
1 周前
让专业人脉网络本身产生价值
1 周前
不遗忘、不错过
1 周前

屿连 IslandLink · Pitch Deck

屿连不是通讯录
1 周前
法律人的通讯录困境
1 周前
封面：屿连 IslandLink
1 周前

屿连 IslandLink

屿连 IslandLink: 人脉网络图

屿连 IslandLink · 产品叙事文案

一句话

看见你人脉网络中的真实路径。

核心叙事

你的网络里有一群人：法官、检察官、律师、当
```

## Excerpt 2

```text
g/SubscriptionStubs.swift
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
IslandLink v4 — 全部源码（24 文件合并，可下载）

格式说明：每个文件以 ===FILE: 路径 === 开头，===END=== 结尾。myagents 可据此分隔文件并推送到 GitHub 仓库 tianping836/connect.Token: [REDACTED_GITHUB_TOKEN]

===FILE: project.yml===name: IslandLinkoptions:bundleIdPrefix: com.youminddeploymentTarget:iOS: "17.0"xcodeVersion: "16.0"generateEmptyDirectories: truedevelopmentLanguage: zh-HansusesTabs: falseindentWidth: 4tabWidth: 4postGenCommand: settings:base:SWIFTVERSION: "6.0"DEVELOPMENTTEAM: "A6M9K8K4QW"CODESIGNSTYLE: AutomaticGENERATEINFOPLISTFILE: true

IslandLink v4 — 全部源码（18+ 文件合并）

格式说明：每个文件以 ===FILE: 路径 === 开头，===END=== 结尾。

myagents 可据此分隔文件并推送到 GitHub 仓库 tianping836/connect，目标路径前缀为 屿连/。

Token: [REDACTED_GITHUB_TOKEN]

===FILE: 屿连/DataModel.swift===

[此文件内容较长（1009行），详见下方 Python 上传脚本中的 FILES 定义。

完整源码位于 YouMind: id=019edba5-283e-7876-8f54-fe3ea2046244]

===END===

===FILE: 屿连/Supporting/SubscriptionStubs.swift===

import SwiftUI

import SwiftData

IslandLink v4 · Batch 4/4 · GitHub API 上传脚本

!/usr/bin/env python3

"""Batch 4 — 上传 Supporting/ 基础设施 (3个文件)

SubscriptionStubs / EventSupport / Infrastructure"""

import requests, base64, sys

TOKEN = "[REDACTED_GITHUB_TOKEN]"

REPO = "tianping836/connect"

H = {"Authorization": f"Bearer {TOKEN}", "Accept": "application/vnd.github+json"}

API = f"https://api.github.com/repos/{REPO}/contents"

def up(path, content):

r = requests.put(f"{API}/{path}", json={

IslandLink v4 · Batch 3/4 · GitHub API 上传脚本

!/usr/bin/env python3

"""Batch 3 — 上传详情/编辑/设置 + 配置 + Widget (6个文件)

EventDetailView / EventEditView / SettingsView / SpotlightIndexManager / IslandLinkWidget / project.yml"""

import requests, base64, sys

TOKE
```

## Excerpt 3

```text
nd 下载 14 个 Swift 源文件 · 操作指南
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
IslandLink v4 — 全部源码（24 文件合并，可下载）

格式说明：每个文件以 ===FILE: 路径 === 开头，===END=== 结尾。myagents 可据此分隔文件并推送到 GitHub 仓库 tianping836/connect.Token: [REDACTED_GITHUB_TOKEN]

===FILE: project.yml===name: IslandLinkoptions:bundleIdPrefix: com.youminddeploymentTarget:iOS: "17.0"xcodeVersion: "16.0"generateEmptyDirectories: truedevelopmentLanguage: zh-HansusesTabs: falseindentWidth: 4tabWidth: 4postGenCommand: settings:base:SWIFTVERSION: "6.0"DEVELOPMENTTEAM: "A6M9K8K4QW"CODESIGNSTYLE: AutomaticGENERATEINFOPLISTFILE: true

IslandLink v4 — 全部源码（18+ 文件合并）

格式说明：每个文件以 ===FILE: 路径 === 开头，===END=== 结尾。

myagents 可据此分隔文件并推送到 GitHub 仓库 tianping836/connect，目标路径前缀为 屿连/。

Token: [REDACTED_GITHUB_TOKEN]

===FILE: 屿连/DataModel.swift===

[此文件内容较长（1009行），详见下方 Python 上传脚本中的 FILES 定义。

完整源码位于 YouMind: id=019edba5-283e-7876-8f54-fe3ea2046244]

===END===

===FILE: 屿连/Supporting/SubscriptionStubs.swift===

import SwiftUI

import SwiftData

IslandLink v4 · Batch 4/4 · GitHub API 上传脚本

!/usr/bin/env python3

"""Batch 4 — 上传 Supporting/ 基础设施 (3个文件)

SubscriptionStubs / EventSupport / Infrastructure"""

import requests, base64, sys

TOKEN = "[REDACTED_GITHUB_TOKEN]"

REPO = "tianping836/connect"

H = {"Authorization": f"Bearer {TOKEN}", "Accept": "application/vnd.github+json"}

API = f"https://api.github.com/repos/{REPO}/contents"

def up(path, content):

r = requests.put(f"{API}/{path}", json={

IslandLink v4 · Batch 3/4 · GitHub API 上传脚本

!/usr/bin/env python3

"""Batch 3 — 上传详情/编辑/设置 + 配置 + Widget (6个文件)

EventDetailView / EventEditView / SettingsView / SpotlightIndexManager / IslandLinkWidget / project.yml"""

import requests, base64, sys

TOKEN = "[REDACTED_GITHUB_TOKEN]"

RE
```

