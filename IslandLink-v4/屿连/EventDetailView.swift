import SwiftUI
import SwiftData

struct EventDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let event: Event

    @State private var showEditSheet = false
    @State private var showDeleteConfirm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.base) {
                headerCard

                if !event.participants.isEmpty {
                    participantsCard
                }

                if !event.associatedCases.isEmpty {
                    associatedCasesCard
                }

                if let summary = event.summary, !summary.isEmpty {
                    textCard(title: "记录", systemImage: "text.alignleft", text: summary)
                }

                if let location = event.location, !location.isEmpty {
                    textCard(title: "地点", systemImage: "mappin.and.ellipse", text: location)
                }

                deleteButton
            }
            .padding(Spacing.base)
        }
        .background(Color.surfaceLight)
        .navigationTitle("事件详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                }
                .accessibilityLabel("编辑事件")
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EventEditView(existingEvent: event)
        }
        .alert("删除事件", isPresented: $showDeleteConfirm) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                deleteEvent()
            }
        } message: {
            Text("删除后，这条共同经历将不再作为连接证据。")
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                EventStatusBadge(status: event.status)
                EventTypeTag(eventType: event.eventType)
                Spacer()
            }

            Text(event.title)
                .font(.cnTitle2)
                .foregroundColor(.textPrimary)

            Label(dateText, systemImage: "calendar")
                .font(.cnSubhead)
                .foregroundColor(.textSecondary)
        }
        .padding(Spacing.base)
        .cardStyleSolid()
    }

    private var participantsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Label("参与人", systemImage: "person.2.fill")
                .font(.cnHeadline)
                .foregroundColor(.textPrimary)

            ForEach(event.participants, id: \.id) { person in
                HStack(spacing: Spacing.md) {
                    AvatarPlaceholder(roleType: person.roleTypes.first ?? .other, size: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(person.name)
                            .font(.cnBody)
                            .foregroundColor(.textPrimary)
                        Text(person.roleTypes.map(\.rawValue).joined(separator: "、"))
                            .font(.cnCaption1)
                            .foregroundColor(.textTertiary)
                    }
                    Spacer()
                }
            }
        }
        .padding(Spacing.base)
        .cardStyleSolid()
    }

    private var associatedCasesCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Label("关联事项", systemImage: "folder.fill")
                .font(.cnHeadline)
                .foregroundColor(.textPrimary)

            ForEach(event.associatedCases, id: \.id) { caseItem in
                VStack(alignment: .leading, spacing: 2) {
                    Text(caseItem.name)
                        .font(.cnBody)
                        .foregroundColor(.textPrimary)
                    if let caseNumber = caseItem.caseNumber {
                        Text(caseNumber)
                            .font(.cnCaption1)
                            .foregroundColor(.textTertiary)
                    }
                }
            }
        }
        .padding(Spacing.base)
        .cardStyleSolid()
    }

    private func textCard(title: String, systemImage: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Label(title, systemImage: systemImage)
                .font(.cnHeadline)
                .foregroundColor(.textPrimary)
            Text(text)
                .font(.cnBody)
                .foregroundColor(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Spacing.base)
        .cardStyleSolid()
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            Label("删除事件", systemImage: "trash")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }

    private var dateText: String {
        guard let date = event.date else { return "日期待定" }
        return event.isAllDay
            ? date.formatted(date: .long, time: .omitted)
            : date.formatted(date: .long, time: .shortened)
    }

    private func deleteEvent() {
        modelContext.delete(event)
        try? modelContext.save()
        dismiss()
    }
}
