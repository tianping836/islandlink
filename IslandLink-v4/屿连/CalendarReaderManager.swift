import EventKit

import SwiftUI

@MainActor

final class CalendarReaderManager: ObservableObject {

static let shared = CalendarReaderManager()

private let eventStore = EKEventStore()

@Published var systemEvents: [EKEvent] = []

@Published var isAuthorized: Bool = false

@Published var selectedCalendars: Set<String> = []

@Published var availableCalendars: [EKCalendar] = []

func requestAccess() async -> Bool {

do { return try await eventStore.requestFullAccessToEvents() } catch { return false }

}

func fetchEvents(from start: Date, to end: Date) {

let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)

systemEvents = eventStore.events(matching: predicate)

}

func calendarInfo(for identifier: String) -> (name: String, color: Color)? {

guard let cal = eventStore.calendar(withIdentifier: identifier) else { return nil }

return (cal.title, Color(cgColor: cal.cgColor))

}

struct UnifiedCalendarEntry: Identifiable {

let id: String

let date: Date

let title: String

let source: Source

let color: Color

let icon: String

enum Source { case systemCalendar(EKEvent), appEvent(Event) }

}

enum CalendarSourceFilter: String, CaseIterable {

case all = "全部"

case islandLink = "屿连"

case system = "系统日历"

}

}
