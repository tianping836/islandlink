import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// MARK: - ─── 岛连「今日安排」Widget ───

// MARK: - Timeline Entry

struct TodayEntry: TimelineEntry {
    let date: Date
    let events: [EventSummary]
    let totalCount: Int

    struct EventSummary: Identifiable {
        let id: String
        let title: String
        let type: String
        let systemImage: String
        let time: Date?
        let color: Color
    }
}

// MARK: - Timeline Provider

struct TodayTimelineProvider: AppIntentTimelineProvider {
    typealias Entry = TodayEntry
    typealias Intent = TodayWidgetIntent

    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(
            date: Date(),
            events: [
                .init(id: "1", title: "案件讨论会", type: "会议", systemImage: "person.2.fill", time: Date(), color: .blue),
                .init(id: "2", title: "证据材料截止", type: "截止日", systemImage: "clock.badge.exclamationmark", time: Date().addingTimeInterval(7200), color: .red)
            ],
            totalCount: 2
        )
    }

    func snapshot(for configuration: TodayWidgetIntent, in context: Context) async -> TodayEntry {
        await fetchTodayData()
    }

    func timeline(for configuration: TodayWidgetIntent, in context: Context) async -> Timeline<TodayEntry> {
        let entry = await fetchTodayData()
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        return Timeline(entries: [entry], policy: .after(nextRefresh))
    }

    // MARK: - 数据获取

    private func fetchTodayData() async -> TodayEntry {
        guard let container = try? ModelContainer(for: Event.self, Case.self) else {
            return TodayEntry(date: Date(), events: [], totalCount: 0)
        }

        let context = ModelContext(container)
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)!

        let eventDescriptor = FetchDescriptor<Event>(
            predicate: #Predicate { event in
                (event.statusRaw == "planned" || event.statusRaw == "confirmed") &&
                event.date >= todayStart && event.date < todayEnd
            },
            sortBy: [SortDescriptor(\.date)]
        )
        let todayEvents = (try? context.fetch(eventDescriptor)) ?? []

        let events = todayEvents.map { event in
            TodayEntry.EventSummary(
                id: event.id,
                title: event.title,
                type: event.eventType.rawValue,
                systemImage: event.eventType.systemImage,
                time: event.date,
                color: event.eventType.swiftUIColor
            )
        }

        return TodayEntry(date: Date(), events: events, totalCount: events.count)
    }
}

// MARK: - Widget Intent

struct TodayWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "今日安排"
    static var description = IntentDescription("在桌面显示今日事件安排。")
}

// MARK: - Widget 入口视图

struct TodayWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: TodayEntry

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .accessoryInline:
            inlineWidget
        case .accessoryCircular:
            circularWidget
        case .accessoryRectangular:
            rectangularWidget
        default:
            mediumWidget
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Label("今日", systemImage: "calendar")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.tealLink)
                Spacer()
                if entry.totalCount > 0 {
                    Text("\(entry.totalCount)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.tealLink)
                        .clipShape(Capsule())
                }
            }

            Spacer(minLength: 4)

            if entry.totalCount == 0 {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("今日无安排")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ForEach(entry.events.prefix(3), id: \.id) { event in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(event.color)
                            .frame(width: 4, height: 4)
                        Text(event.title)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(12)
        .containerBackground(.regularMaterial, for: .widget)
    }

    private var mediumWidget: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("今日安排", systemImage: "calendar")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.tealLink)
                    Spacer()
                    Text(entry.date.formatted(.dateTime.month(.abbreviated).day()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if entry.totalCount == 0 {
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.circle")
                            .font(.title2)
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("今日无安排")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Label("事件", systemImage: "list.bullet")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        ForEach(entry.events.prefix(4), id: \.id) { event in
                            HStack {
                                Image(systemName: event.systemImage)
                                    .font(.system(size: 9))
                                    .foregroundColor(event.color)
                                Text(event.title)
                                    .font(.caption2)
                                    .lineLimit(1)
                                if let time = event.time {
                                    Spacer()
                                    Text(time.formatted(.dateTime.hour().minute()))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(16)
        .containerBackground(.regularMaterial, for: .widget)
    }

    private var inlineWidget: some View {
        if entry.totalCount == 0 {
            Text("今日无安排 ☕️")
        } else {
            Text("今日 \(entry.totalCount) 项 · \(entry.events.first?.title ?? "")")
        }
    }

    private var circularWidget: some View {
        ZStack {
            if #available(iOS 18.0, *) {
                AccessoryWidgetBackground()
            }
            VStack(spacing: 0) {
                Image(systemName: entry.totalCount > 0 ? "calendar.badge.clock" : "calendar")
                    .font(.title3)
                Text(entry.totalCount > 0 ? "\(entry.totalCount)" : "0")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
        }
    }

    private var rectangularWidget: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                Text("今日安排")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            if entry.totalCount == 0 {
                Text("无安排")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                ForEach(
                    entry.events.map { ($0.systemImage, $0.title) }.prefix(2),
                    id: \.1
                ) { icon, title in
                    HStack {
                        Image(systemName: icon)
                            .font(.system(size: 8))
                        Text(title)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                }
                if entry.totalCount > 2 {
                    Text("还有 \(entry.totalCount - 2) 项...")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Widget 定义

struct TodayWidget: Widget {
    let kind: String = "com.youmind.islandlink.today"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: TodayWidgetIntent.self,
            provider: TodayTimelineProvider()
        ) { entry in
            TodayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("今日安排")
        .description("在桌面和锁屏显示今日事件")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryInline,
            .accessoryCircular,
            .accessoryRectangular
        ])
        .contentMarginsDisabled()
    }
}