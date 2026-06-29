# Project Context From YouMind

Recovered from local YouMind board text. These excerpts are intentionally local-first so future development does not depend on reopening YouMind.

## Excerpt 1

```text
dLink v4 · Batch 2/4 · GitHub API 上传脚本
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

API = f"https://api.github.com/repos/{REPO}
```

## Excerpt 2

```text
局

4 IslandLink/EventEditView.swift 完整替换 移除提醒/日历同步 UI 5 IslandLink/IslandLinkWidget.swift 完整替换 totalCaseCount + 灵活字段适配

屿连 IslandLink — 项目上下文（供 AI 编程助手使用）

更新时间：2026-06-23源代码仓库：YouMind 项目板：屿连 app 开发

一、项目概述

屿连（IslandLink） —— 律师专属的人脉优先管理 Apple 全平台应用。

平台：iOS 17.0+ / iPadOS / macOS / watchOS

架构：SwiftUI + SwiftData + Swift Concurrency

核心隐喻：海豚双游、头尾相接

3 个主 Tab：人脉 / 事项 / 设置（日历板块已移除）

iCloud 同步 + Spotlight 索引 + Handoff + Siri 快捷指令 + Widget

二、数据模型现状（DataModel.swift）

已彻底移除

屿连/DataModel.swift

import Foundation

import SwiftData

// MARK: - 枚举定义

/// 人员角色大类（可多选：一个人可以同时是法官和前律师等）

enum PersonRoleType: String, Codable, CaseIterable, Identifiable {

case judge = "法官"

case prosecutor = "检察官"

case lawyer = "律师"

case party = "当事人"

case police = "公安民警"

屿连/Supporting/Infrastructure.swift

import Foundation

import SwiftUI

import SwiftData

import UserNotifications

// MARK: - NotificationManager 存根

/// 通知管理器存根 — 满足编译所需，实际通知逻辑待完善

@MainActor

final class NotificationManager: ObservableObject {

static let shared = NotificationManager()

private init() {}

屿连/Supporting/EventSupport.swift

import SwiftUI

import SwiftData

// MARK: - 事件卡片

/// 事件列表项卡片 — 三信息层：【图标+日期】 标题 描述（一行） 【状态标签】

struct EventCard: View {

let event: Event

var showCaseLink: Bool = true

var body: some View {

VStack(alignment: .leading, spacing: Spacing.xs) {

// 第一行：日期 + 类型图标 + 状态

屿连/Supporting/SubscriptionStubs.swift

import SwiftUI

import SwiftData

// MARK: - SubscriptionManager 最小存根

/// 订阅管理器存根 — 满足 IslandLink/ 15 文件编译所需

/// 完整版（含 StoreKit）在 CaseNetwork/SubscriptionManager.swift

/// 部署时替换此存根即可

@MainActor

final class SubscriptionManager: ObservableObject {

static let shared = SubscriptionManager()

static let freePersonLimit = 50

从 YouMind 下载 14 个 Swift 源文件 · 操作指南

目标：把 YouMind 上的源代码同步到 Mac 本地 /Desktop/connect/ 目录

前置准备：创建本地文件夹结构

打开 Mac 终端（Terminal），复制粘贴以下命令一次性创建全部文件夹：

cd /Desktop/connect

mkdir -p IslandLink/App

mkdir -p IslandLink/Models

mkdir -p IslandLink/Design

mkdir -p IslandLin
```

## Excerpt 3

```text
e 全平台应用。

平台：iOS 17.0+ / iPadOS / macOS / watchOS

架构：SwiftUI + SwiftData + Swift Concurrency

核心隐喻：海豚双游、头尾相接

3 个主 Tab：人脉 / 事项 / 设置（日历板块已移除）

iCloud 同步 + Spotlight 索引 + Handoff + Siri 快捷指令 + Widget

二、数据模型现状（DataModel.swift）

已彻底移除

屿连/DataModel.swift

import Foundation

import SwiftData

// MARK: - 枚举定义

/// 人员角色大类（可多选：一个人可以同时是法官和前律师等）

enum PersonRoleType: String, Codable, CaseIterable, Identifiable {

case judge = "法官"

case prosecutor = "检察官"

case lawyer = "律师"

case party = "当事人"

case police = "公安民警"

屿连/Supporting/Infrastructure.swift

import Foundation

import SwiftUI

import SwiftData

import UserNotifications

// MARK: - NotificationManager 存根

/// 通知管理器存根 — 满足编译所需，实际通知逻辑待完善

@MainActor

final class NotificationManager: ObservableObject {

static let shared = NotificationManager()

private init() {}

屿连/Supporting/EventSupport.swift

import SwiftUI

import SwiftData

// MARK: - 事件卡片

/// 事件列表项卡片 — 三信息层：【图标+日期】 标题 描述（一行） 【状态标签】

struct EventCard: View {

let event: Event

var showCaseLink: Bool = true

var body: some View {

VStack(alignment: .leading, spacing: Spacing.xs) {

// 第一行：日期 + 类型图标 + 状态

屿连/Supporting/SubscriptionStubs.swift

import SwiftUI

import SwiftData

// MARK: - SubscriptionManager 最小存根

/// 订阅管理器存根 — 满足 IslandLink/ 15 文件编译所需

/// 完整版（含 StoreKit）在 CaseNetwork/SubscriptionManager.swift

/// 部署时替换此存根即可

@MainActor

final class SubscriptionManager: ObservableObject {

static let shared = SubscriptionManager()

static let freePersonLimit = 50

从 YouMind 下载 14 个 Swift 源文件 · 操作指南

目标：把 YouMind 上的源代码同步到 Mac 本地 /Desktop/connect/ 目录

前置准备：创建本地文件夹结构

打开 Mac 终端（Terminal），复制粘贴以下命令一次性创建全部文件夹：

cd /Desktop/connect

mkdir -p IslandLink/App

mkdir -p IslandLink/Models

mkdir -p IslandLink/Design

mkdir -p IslandLink/Views

mkdir -p IslandLink/Managers

mkdir -p IslandLink/Intents

推送到 GitHub — 操作清单

将 Xcode 工程配置文件推送到 https://github.com/tianping836/connect

最终文件清单（需推送的全部新增/修改文件）

connect/

├── 📄 project.yml ← 新增：XcodeGen 工程规格

├── 📄 setup.sh ← 新增：一键配置
```

