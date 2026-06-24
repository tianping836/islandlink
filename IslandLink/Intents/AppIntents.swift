import AppIntents
import SwiftData
import SwiftUI
import Foundation

// MARK: - ─── 岛连 App Intents ───

// MARK: - 搜索人脉 Intent

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
        let descriptor = FetchDescriptor<Person>(
            sortBy: [SortDescriptor(\.name)]
        )

        let allResults = try context.fetch(descriptor)
        let results = allResults.filter {
            $0.name.localizedStandardContains(query) ||
            $0.pinyin.localizedStandardContains(query)
        }

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

        let eventDescriptor = FetchDescriptor<Event>(
            sortBy: [SortDescriptor(\.date)]
        )
        let allEvents = try context.fetch(eventDescriptor)
        var todayEvents: [Event] = []
        for event in allEvents {
            if let d = event.date, (event.status == .planned || event.status == .confirmed),
               d >= todayStart && d < todayEnd {
                todayEvents.append(event)
            }
        }

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
        return .result(
            dialog: "正在添加「\(title)」事件。"
        )
    }
}

// MARK: - 辅助类型

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

// MARK: - Snippet Views

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

