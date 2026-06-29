import SwiftUI
import SwiftData

struct EventListView: View {
    @Query(sort: \Event.date, order: .forward) private var allEvents: [Event]

    @State private var searchText = ""
    @State private var selectedType: EventType?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                typeFilterBar

                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        if filteredEvents.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(filteredEvents, id: \.id) { event in
                                NavigationLink {
                                    EventDetailView(event: event)
                                } label: {
                                    EventCard(event: event)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(Spacing.base)
                }
            }
            .background(Color.surfaceLight)
            .navigationTitle("事件")
            .searchable(text: $searchText, prompt: "搜索共同经历")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        EventEditView()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.tealLink)
                    }
                }
            }
        }
    }

    private var typeFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                FilterChip(label: "全部", isSelected: selectedType == nil) {
                    selectedType = nil
                }

                ForEach(EventType.allCases, id: \.self) { type in
                    FilterChip(label: type.rawValue, isSelected: selectedType == type) {
                        selectedType = selectedType == type ? nil : type
                    }
                }
            }
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.sm)
        }
        .background(Color.surfaceLight)
    }

    private var filteredEvents: [Event] {
        var result = allEvents

        if let selectedType {
            result = result.filter { $0.eventType == selectedType }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            result = result.filter { event in
                event.title.localizedStandardContains(query)
                    || (event.location?.localizedStandardContains(query) ?? false)
                    || (event.summary?.localizedStandardContains(query) ?? false)
                    || event.participants.contains { $0.name.localizedStandardContains(query) }
            }
        }

        return result
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "暂无事件",
            systemImage: "calendar.badge.plus",
            description: Text("先记录真实共同经历，再让它成为人脉之间的连接证据。")
        )
        .padding(.top, Spacing.xxl)
    }
}

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.cnCaption1)
                .foregroundColor(isSelected ? .white : .textSecondary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    Capsule().fill(isSelected ? Color.tealLink : Color.surfaceCard)
                )
        }
        .buttonStyle(.plain)
    }
}
