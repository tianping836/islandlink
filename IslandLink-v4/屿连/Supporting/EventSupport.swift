import SwiftUI

struct EventCard: View {

let event: Event

var body: some View {

VStack(alignment: .leading, spacing: Spacing.sm) {

HStack {

Image(systemName: event.eventType.systemImage)

.foregroundColor(event.eventType.swiftUIColor)

Text(event.title)

.font(.cnHeadline)

.foregroundColor(.textPrimary)

Spacer()

EventStatusBadge(status: event.status)

}

if let date = event.date {

Text(date.formatted(date: .abbreviated, time: event.isAllDay ? .omitted : .shortened))

.font(.cnCaption1)

.foregroundColor(.textSecondary)

}

}

.padding(Spacing.base)

.cardStyleSolid()

}

}

struct FocusFilterIndicator: View {

let filterObserver: Any

var body: some View { EmptyView() }

}

func syncAware(_ block: @escaping () -> T) -> T { block() }

func refreshSync() {}

func eventShareText(for event: Event) -> String {

"\(event.title) - \(event.date?.formatted() ?? "未定")"

}
