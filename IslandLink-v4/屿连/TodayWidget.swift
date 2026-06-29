import WidgetKit

import SwiftUI

import SwiftData

struct TodayTimelineProvider: AppIntentTimelineProvider {

typealias Entry = TodayEntry

typealias Intent = TodayWidgetIntent

func placeholder(in context: Context) -> TodayEntry {

TodayEntry(date: Date(), events: [])

}

func snapshot(for configuration: TodayWidgetIntent, in context: Context) async -> TodayEntry {

TodayEntry(date: Date(), events: fetchTodayEvents())

}

func timeline(for configuration: TodayWidgetIntent, in context: Context) async -> Timeline {

let entry = TodayEntry(date: Date(), events: fetchTodayEvents())

return Timeline(

entries: [entry],

policy: .after(Calendar.current.date(byAdding: .hour, value: 1, to: Date())!)

)

}

private func fetchTodayEvents() -> [WidgetEvent] {

guard let container = try? ModelContainer(for: Event.self) else { return [] }

let descriptor = FetchDescriptor(predicate: #Predicate {

$0.statusRaw == "planned" || $0.statusRaw == "confirmed"

})

let events = (try? container.mainContext.fetch(descriptor)) ?? []

return events.compactMap { e in

guard let date = e.date, Calendar.current.isDateInToday(date) else { return nil }

return WidgetEvent(title: e.title, date: date, eventType: e.eventType.rawValue)

}

}

}

struct TodayEntry: TimelineEntry {

let date: Date

let events: [WidgetEvent]

}

struct WidgetEvent: Identifiable {

let id = UUID()

let title: String

let date: Date

let eventType: String

}

struct TodayWidgetEntryView: View {

var entry: TodayEntry

@Environment(.widgetFamily) var family

var body: some View {

VStack(alignment: .leading, spacing: 4) {

Text("今日安排")

.font(.caption)

.foregroundColor(.secondary)

if entry.events.isEmpty {

Text("今天没有事项")

.font(.caption2)

.foregroundColor(.tertiary)

}

ForEach(entry.events.prefix(family == .systemSmall ? 2 : 4)) { e in

HStack {

Circle().fill(Color.tealLink).frame(width: 6, height: 6)

Text(e.title).font(.caption2).lineLimit(1)

}

}

}

.padding()

}

}

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

.supportedFamilies([

.systemSmall, .systemMedium,

.accessoryInline, .accessoryCircular, .accessoryRectangular

])

}

}

struct TodayWidgetIntent: WidgetConfigurationIntent {

static var title: LocalizedStringResource = "今日安排"

}
