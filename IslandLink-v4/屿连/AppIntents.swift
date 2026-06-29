import AppIntents
import SwiftData
import Foundation

// MARK: - ─── 岛连 App Intents ───
/// 供 Siri 和快捷指令 App 调用的核心意图。
/// 对标 Apple 自带 App（如通讯录、日历、备忘录）的 Shortcuts 集成体验。
///
/// 使用方式：
/// - Siri："嘿 Siri，用岛连搜索联系人张三"
/// - 快捷指令：在快捷指令 App 中搜索「岛连」即可看到所有可用操作

// MARK: - 搜索人脉 Intent

/// 在岛连中搜索联系人
/// Siri 触发词示例：「用岛连搜索联系人张三」「在岛连里找李律师」
struct SearchPeopleIntent: AppIntent {
    static var title: LocalizedStringResource = "搜索人脉"
    static var description = IntentDescription(
        "在岛连中按姓名、单位或角色搜索联系人。支持 Siri 语音触发。",
        categoryName: "人脉",
        searchKeywords: ["搜索", "查找", "联系人", "人脉", "律师", "法官", "当事人"]
    )
    static var openAppWhenRun: Bool = false
    static var isDiscoverable: Bool = true

    @Parameter(
        title: "搜索关键词",
        description: "联系人的姓名、单位或角色",
        inputOptions: .init(
            keyboardType: .default,
            capitalizationType: .words
        )
    )
    var query: String

    @Dependency
    private var modelContainer: ModelContainer

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<person>(
            predicate: #Predicate { person in
                person.name.localizedStandardContains(query) ||
                person.pinyin.localizedStandardContains(query)
            },
            sortBy: [SortDescriptor(\.name)]
        )

        let results = try context.fetch(descriptor)

        if results.isEmpty {
            return .result(dialog: "没有找到与「\(query)」相关的联系人。")
        }

        let names = results.prefix(5).map { $0.name }
        let count = results.count
        let nameList = names.joined(separator: "、")

        let dialog: IntentDialog = count == 1
            ? "找到 1 位联系人：\(nameList)"
            : "找到 \(count) 位联系人，包括 \(nameList)"

        return .result(
            dialog: dialog,
            view: SearchPeopleResultView(results: results)
        )
    }
}

// MARK: - 今日安排 Intent

/// 查看今日开庭、会议和截止日
/// Siri 触发词示例：「今天有什么安排」「今天开庭吗」
struct TodayScheduleIntent: AppIntent {
    static var title: LocalizedStringResource = "今日安排"
    static var description = IntentDescription(
        "查看今日的开庭、会议和截止日安排。支持 Siri 语音触发和在快捷指令中自动化。",
        categoryName: "日历",
        searchKeywords: ["今天", "今日", "安排", "开庭", "会议", "截止", "日程"]
    )
    static var openAppWhenRun: Bool = false
    static var isDiscoverable: Bool = true

    @Dependency
    private var modelContainer: ModelContainer

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let context = ModelContext(modelContainer)

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)!

        // 查询今日事件
        let eventDescriptor = FetchDescriptor<event>(
            predicate: #Predicate { event in
                (event.statusRaw == "planned" || event.statusRaw == "confirmed") &&
                event.date >= todayStart && event.date < todayEnd
            },
            sortBy: [SortDescriptor(\.date)]
        )
        let todayEvents = try context.fetch(eventDescriptor)

        let totalCount = todayEvents.count

        if totalCount == 0 {
            return .result(
                dialog: "今天没有安排的事件。",
                view: TodayEmptyView()
            )
        }

        return .result(
            dialog: "今天共有 \(totalCount) 项安排。",
            view: TodayScheduleResultView(events: todayEvents)
        )
    }
}

// MARK: - 添加快捷事件 Intent

/// 快速在岛连中创建事件
/// Siri 触发词示例：「在岛连里添加一个会议」「记录明天的开庭」
struct QuickAddEventIntent: AppIntent {
    static var title: LocalizedStringResource = "添加事件"
    static var description = IntentDescription(
        "快速在岛连中添加一个新事件。支持 Siri 语音输入标题和类型。",
        categoryName: "日历",
        searchKeywords: ["添加", "新建", "创建", "事件", "会议", "开庭", "截止日"]
    )
    static var openAppWhenRun: Bool = true
    static var isDiscoverable: Bool = true

    @Parameter(
        title: "事件标题",
        description: "事件的简短名称",
        inputOptions: .init(
            keyboardType: .default,
            capitalizationType: .sentences
        )
    )
    var title: String

    @Parameter(
        title: "事件类型",
        description: "事件的分类",
        default: .meeting
    )
    var eventType: EventTypeOption

    @Parameter(
        title: "日期",
        description: "事件的日期（默认今天）",
        default: Date()
    )
    var date: Date

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // openAppWhenRun = true，因此系统会打开 App 并传递参数
        // App 层在 AppDelegate 中通过 userInfo 接收并打开新建事件页
        return .result(
            dialog: "正在添加「\(title)」事件。"
        )
    }
}

// MARK: - 辅助类型

/// App Intents 用的事件类型枚举（桥接 EventType）
enum EventTypeOption: String, AppEnum {
    case meeting  = "会议"
    case deadline = "截止日"
    case hearing  = "开庭"
    case filing   = "立案/递交"
    case research = "调研"
    case travel   = "出差"
    case social   = "社交"
    case other    = "其他"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "事件类型")
    static var caseDisplayRepresentations: [EventTypeOption: DisplayRepresentation] = [
        .meeting:  "会议",
        .deadline: "截止日",
        .hearing:  "开庭",
        .filing:   "立案/递交",
        .research: "调研",
        .travel:   "出差",
        .social:   "社交",
        .other:    "其他"
    ]
}

// MARK: - Snippet Views（Siri / Spotlight 结果卡片）

/// 搜索人脉结果卡片
struct SearchPeopleResultView: View {
    let results: [Person]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(results.prefix(5), id: \.id) { person in
                HStack(spacing: 12) {
                    AvatarPlaceholder(roleType: person.roleTypes.first ?? .other, size: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(person.name)
                            .font(.headline)
                        Text(person.roleTypes.map(\.rawValue).joined(separator: "、"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                if person.id != results.prefix(5).last?.id {
                    Divider()
                }
            }
            if results.count > 5 {
                Text("还有 \(results.count - 5) 位更多结果...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

/// 今日安排结果卡片
struct TodayScheduleResultView: View {
    let events: [Event]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !events.isEmpty {
                Label("事件 (\(events.count))", systemImage: "calendar")
                    .font(.headline)
                ForEach(events, id: \.id) { event in
                    HStack {
                        Image(systemName: event.eventType.systemImage)
                            .font(.caption)
                        Text(event.title)
                            .font(.body)
                        Spacer()
                        if let date = event.date {
                            Text(date.formatted(.dateTime.hour().minute()))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

/// 今日无安排占位卡片
struct TodayEmptyView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("今天没有安排")
                .font(.headline)
            Text("享受清闲的一天 ☕️")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - App Shortcuts Provider

/// 自动注册到快捷指令 App 的 Shortcuts 结构体
struct IslandLinkAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SearchPeopleIntent(),
            phrases: [
                "在\(.applicationName)中搜索联系人",
                "用\(.applicationName)查找\(\.$query)",
                "\(.applicationName)搜索人脉",
                "Search contacts in \(.applicationName)",
                "Find \(\.$query) in \(.applicationName)"
            ],
            shortTitle: "搜索人脉",
            systemImageName: "person.2.fill"
        )

        AppShortcut(
            intent: TodayScheduleIntent(),
            phrases: [
                "\(.applicationName)今日安排",
                "查看\(.applicationName)今天的日程",
                "今天\(.applicationName)有什么",
                "\(.applicationName) today schedule",
                "What's on \(.applicationName) today"
            ],
            shortTitle: "今日安排",
            systemImageName: "calendar"
        )

        AppShortcut(
            intent: QuickAddEventIntent(),
            phrases: [
                "在\(.applicationName)中添加事件",
                "用\(.applicationName)记录\(\.$title)",
                "\(.applicationName)添加\(\.$eventType)",
                "Add event in \(.applicationName)",
                "Record \(\.$title) in \(.applicationName)"
            ],
            shortTitle: "添加事件",
            systemImageName: "plus.circle.fill"
        )
    }

    static var shortcutTileColor: ShortcutTileColor = .teal
}
