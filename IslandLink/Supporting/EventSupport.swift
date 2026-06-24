import SwiftUI

struct EventCard: View {
    let event: Event
    var showCaseLink: Bool = true
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: event.eventType.systemImage).font(.system(size: 14, weight: .medium)).foregroundColor(event.eventType.swiftUIColor)
                if let date = event.date { Text(date.formatted(date: .abbreviated, time: event.isAllDay ? .omitted : .shortened)).font(.cnSubhead).foregroundColor(.textSecondary) }
                else { Text("日期待定").font(.cnSubhead).foregroundColor(.textTertiary) }
                Spacer()
                EventStatusBadge(status: event.status)
            }
            Text(event.title).font(.cnHeadline).foregroundColor(.textPrimary).lineLimit(2)
            if let summary = event.summary, !summary.isEmpty { Text(summary).font(.cnCaption1).foregroundColor(.textSecondary).lineLimit(1) }
        }
        .padding(16).cardStyleSolid()
    }
}

@MainActor
final class FocusFilterObserver: ObservableObject {
    @Published var activeFilterName: String? = nil
    func filterEvents(_ events: [Event]) -> [Event] { return events }
}

struct FocusFilterIndicator: View {
    @ObservedObject var filterObserver: FocusFilterObserver
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
            Text(filterObserver.activeFilterName ?? "全部范围")
        }
        .font(.cnCaption1).foregroundColor(.textSecondary)
        .padding(.horizontal, 12).padding(.vertical, 4)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

extension EventStatus {
    var isActive: Bool { self != .cancelled && self != .completed }
}

func eventShareText(_ event: Event) -> String {
    var parts = ["📅 \(event.title)", "类型：\(event.eventType.rawValue)"]
    if let date = event.date { parts.append("时间：\(date.formatted(.dateTime.year().month(.abbreviated).day().hour().minute()))") }
    if let loc = event.location, !loc.isEmpty { parts.append("地点：\(loc)") }
    if let summary = event.summary, !summary.isEmpty { parts.append("备注：\(summary)") }
    return parts.joined(separator: "\n")
}
