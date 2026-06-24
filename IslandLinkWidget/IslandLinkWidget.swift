import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// MARK: - App Groups 共享容器标识

private let appGroupIdentifier = "group.com.youmind.islandlink"

// MARK: - Widget 共享数据模型容器

@MainActor
func widgetModelContainer() -> ModelContainer {
    let sharedDirectory = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)!
    let storeURL = sharedDirectory.appendingPathComponent("IslandLink.sqlite")

    let config = ModelConfiguration(url: storeURL)

    do {
        return try ModelContainer(
            for: Person.self, OrgUnit.self, ContactLog.self,
            Case.self, CasePerson.self, FieldTemplate.self, CaseFieldValue.self,
            Tag.self, CaseNote.self, Event.self, EventPerson.self, EventCase.self,
            RedeemCode.self,
            configurations: config
        )
    } catch {
        fatalError("Widget ModelContainer 初始化失败: \(error)")
    }
}

// MARK: - 共享数据查询

@MainActor
struct WidgetDataProvider {
    private let container: ModelContainer
    private let context: ModelContext
    private let calendar = Calendar.current

    init() {
        container = widgetModelContainer()
        context = container.mainContext
    }

    func todayEventCount() -> Int {
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let descriptor = FetchDescriptor<Event>(
            predicate: #Predicate { event in
                (event.statusRaw == "planned" || event.statusRaw == "confirmed") &&
                (event.date != nil) &&
                (event.date! >= today && event.date! < tomorrow)
            }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    func tomorrowHearingCount() -> Int {
        let today = calendar.startOfDay(for: Date())
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.date(byAdding: .day, value: 1, to: today)!)!

        let descriptor = FetchDescriptor<Event>(
            predicate: #Predicate { event in
                (event.statusRaw == "planned" || event.statusRaw == "confirmed") &&
                (event.date != nil) &&
                (event.date! >= calendar.date(byAdding: .day, value: 1, to: today)!) &&
                (event.date! < dayAfterTomorrow) &&
                (event.eventTypeRaw == "hearing" || event.eventTypeRaw == "开庭")
            }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    func tomorrowEventCount() -> Int {
        let today = calendar.startOfDay(for: Date())
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let descriptor = FetchDescriptor<Event>(
            predicate: #Predicate { event in
                (event.statusRaw == "planned" || event.statusRaw == "confirmed") &&
                (event.date != nil) &&
                (event.date! >= tomorrow && event.date! < dayAfterTomorrow)
            }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    func thisWeekHearingCount() -> Int {
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        let daysToMonday = (weekday + 5) % 7
        let monday = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -daysToMonday, to: now)!)
        let nextMonday = calendar.date(byAdding: .day, value: 7, to: monday)!

        let descriptor = FetchDescriptor<Event>(
            predicate: #Predicate { event in
                event.date != nil && event.date! >= monday && event.date! < nextMonday &&
                (event.eventTypeRaw == "hearing" || event.eventTypeRaw == "开庭")
            }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    func thisMonthEventCount() -> Int {
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!

        let descriptor = FetchDescriptor<Event>(
            predicate: #Predicate { event in
                event.date != nil && event.date! >= startOfMonth && event.date! < startOfNextMonth
            }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    func thisWeekEventCount() -> Int {
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        let daysToMonday = (weekday + 5) % 7
        let monday = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -daysToMonday, to: now)!)
        let nextMonday = calendar.date(byAdding: .day, value: 7, to: monday)!

        let descriptor = FetchDescriptor<Event>(
            predicate: #Predicate { event in
                event.date != nil && event.date! >= monday && event.date! < nextMonday
            }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    func totalCaseCount() -> Int {
        let descriptor = FetchDescriptor<Case>(
            predicate: #Predicate { c in
                !c.isArchived
            }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    func nextHearing() -> (title: String, date: Date)? {
        let now = Date()
        var descriptor = FetchDescriptor<Event>(
            predicate: #Predicate { event in
                (event.eventTypeRaw == "hearing" || event.eventTypeRaw == "开庭") &&
                event.date != nil && event.date! >= now
            },
            sortBy: [SortDescriptor(\.date)]
        )
        descriptor.fetchLimit = 1
        guard let result = try? context.fetch(descriptor).first,
              let date = result.date else { return nil }
        return (result.title, date)
    }
}

// MARK: - Timeline Entry

struct WidgetEntry: TimelineEntry {
    let date: Date
    let todayEventCount: Int
    let tomorrowEventCount: Int
    let tomorrowHearingCount: Int
    let totalCaseCount: Int
    let nextHearing: (title: String, date: Date)?
    let thisWeekEventCount: Int
    let thisWeekHearingCount: Int
    let thisMonthEventCount: Int
}

// MARK: - Timeline Provider

struct IslandLinkProvider: @preconcurrency TimelineProvider {
    typealias Entry = WidgetEntry

    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(
            date: Date(),
            todayEventCount: 3,
            tomorrowEventCount: 2,
            tomorrowHearingCount: 1,
            totalCaseCount: 5,
            nextHearing: ("XX公司股权纠纷案开庭", Date().addingTimeInterval(86400)),
            thisWeekEventCount: 8,
            thisWeekHearingCount: 2,
            thisMonthEventCount: 15
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        let provider = WidgetDataProvider()
        let entry = WidgetEntry(
            date: Date(),
            todayEventCount: provider.todayEventCount(),
            tomorrowEventCount: provider.tomorrowEventCount(),
            tomorrowHearingCount: provider.tomorrowHearingCount(),
            totalCaseCount: provider.totalCaseCount(),
            nextHearing: provider.nextHearing(),
            thisWeekEventCount: provider.thisWeekEventCount(),
            thisWeekHearingCount: provider.thisWeekHearingCount(),
            thisMonthEventCount: provider.thisMonthEventCount()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let provider = WidgetDataProvider()
        let entry = WidgetEntry(
            date: Date(),
            todayEventCount: provider.todayEventCount(),
            tomorrowEventCount: provider.tomorrowEventCount(),
            tomorrowHearingCount: provider.tomorrowHearingCount(),
            totalCaseCount: provider.totalCaseCount(),
            nextHearing: provider.nextHearing(),
            thisWeekEventCount: provider.thisWeekEventCount(),
            thisWeekHearingCount: provider.thisWeekHearingCount(),
            thisMonthEventCount: provider.thisMonthEventCount()
        )
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }
}

// MARK: - ─── Widget 定义 ───

struct TodayEventsCircularWidget: Widget {
    let kind = "TodayEventsCircular"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: IslandLinkProvider()) { entry in
            TodayEventsAccessoryWidget(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("今日事件")
        .description("显示今天有几个待办事件")
        .supportedFamilies([.accessoryCircular])
    }
}

struct TodayEventsInlineWidget_: Widget {
    let kind = "TodayEventsInline"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: IslandLinkProvider()) { entry in
            TodayEventsInlineWidget(entry: entry)
        }
        .configurationDisplayName("今日摘要")
        .description("在锁屏顶部显示今日事项摘要")
        .supportedFamilies([.accessoryInline])
    }
}

struct TodayEventsRectangularWidget_: Widget {
    let kind = "TodayEventsRectangular"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: IslandLinkProvider()) { entry in
            TodayEventsRectangularWidget(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("今日/明日")
        .description("对比今天事项和明天开庭数")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct QuickActionsSmallWidget_: Widget {
    let kind = "QuickActionsSmall"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: IslandLinkProvider()) { entry in
            QuickActionsSmallWidget(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("快捷操作")
        .description("快速新建事件、联系人、案件")
        .supportedFamilies([.systemSmall])
    }
}

struct CaseOverviewMediumWidget_: Widget {
    let kind = "CaseOverviewMedium"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: IslandLinkProvider()) { entry in
            CaseOverviewMediumWidget(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("案件概览")
        .description("进行中案件数及状态分布")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Widget Bundle

@main
struct IslandLinkWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayEventsCircularWidget()
        TodayEventsInlineWidget_()
        TodayEventsRectangularWidget_()
        QuickActionsSmallWidget_()
        CaseOverviewMediumWidget_()
    }
}