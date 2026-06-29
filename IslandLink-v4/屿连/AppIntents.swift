import AppIntents
import Foundation

struct SearchPeopleIntent: AppIntent {
    static var title: LocalizedStringResource = "搜索人脉"
    static var description = IntentDescription("打开屿连并搜索专业人脉。")
    static var openAppWhenRun = true

    @Parameter(title: "搜索关键词")
    var query: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: "正在打开屿连搜索「\(query)」。")
    }
}

struct TodayScheduleIntent: AppIntent {
    static var title: LocalizedStringResource = "今日安排"
    static var description = IntentDescription("打开屿连查看今日共同经历和事项。")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: "正在打开屿连查看今日安排。")
    }
}

struct QuickAddEventIntent: AppIntent {
    static var title: LocalizedStringResource = "添加事件"
    static var description = IntentDescription("打开屿连记录一条可作为连接证据的共同经历。")
    static var openAppWhenRun = true

    @Parameter(title: "事件标题")
    var title: String

    @Parameter(title: "事件类型", default: .meeting)
    var eventType: EventTypeOption

    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: "正在打开屿连记录「\(title)」。")
    }
}

enum EventTypeOption: String, AppEnum {
    case meeting = "会议"
    case deadline = "截止日"
    case hearing = "开庭"
    case filing = "立案/递交"
    case research = "调研"
    case travel = "出差"
    case social = "社交"
    case other = "其他"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "事件类型")
    static var caseDisplayRepresentations: [EventTypeOption: DisplayRepresentation] = [
        .meeting: "会议",
        .deadline: "截止日",
        .hearing: "开庭",
        .filing: "立案/递交",
        .research: "调研",
        .travel: "出差",
        .social: "社交",
        .other: "其他"
    ]
}

struct IslandLinkAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SearchPeopleIntent(),
            phrases: [
                "在\(.applicationName)搜索人脉",
                "用\(.applicationName)查找\(\.$query)"
            ],
            shortTitle: "搜索人脉",
            systemImageName: "person.2.fill"
        )

        AppShortcut(
            intent: TodayScheduleIntent(),
            phrases: [
                "\(.applicationName)今日安排",
                "查看\(.applicationName)今天的安排"
            ],
            shortTitle: "今日安排",
            systemImageName: "calendar"
        )

        AppShortcut(
            intent: QuickAddEventIntent(),
            phrases: [
                "在\(.applicationName)添加事件",
                "用\(.applicationName)记录\(\.$title)"
            ],
            shortTitle: "添加事件",
            systemImageName: "plus.circle.fill"
        )
    }

    static var shortcutTileColor: ShortcutTileColor = .teal
}
