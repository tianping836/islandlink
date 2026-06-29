import SwiftUI
import SwiftData

struct EventEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subManager: SubscriptionManager

    var existingEvent: Event?
    var defaultCase: Case?

    @State private var title = ""
    @State private var eventType: EventType = .other
    @State private var status: EventStatus = .planned
    @State private var date = Date()
    @State private var hasDate = true
    @State private var isAllDay = true
    @State private var location = ""
    @State private var summary = ""
    @State private var selectedPersons: [Person] = []
    @State private var selectedCases: [Case] = []
    @State private var showPersonPicker = false
    @State private var showCasePicker = false

    @Query(sort: \Person.name) private var allPersons: [Person]
    @Query(sort: \Case.name) private var allCases: [Case]
    @AppStorage("caseModuleEnabled") private var caseModuleEnabled = true

    private var isEditing: Bool { existingEvent != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("共同经历") {
                    TextField("标题", text: $title)

                    Picker("类型", selection: $eventType) {
                        ForEach(EventType.allCases) { type in
                            Label(type.rawValue, systemImage: type.systemImage).tag(type)
                        }
                    }

                    Picker("状态", selection: $status) {
                        ForEach(EventStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }

                Section("时间地点") {
                    Toggle("记录日期", isOn: $hasDate)
                    if hasDate {
                        DatePicker(
                            "日期",
                            selection: $date,
                            displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                        )
                        Toggle("全天", isOn: $isAllDay)
                    }

                    TextField("地点（选填）", text: $location)
                }

                Section("参与人") {
                    ForEach(selectedPersons, id: \.id) { person in
                        Label(person.name, systemImage: person.roleTypes.first?.systemImage ?? "person.fill")
                    }
                    .onDelete { selectedPersons.remove(atOffsets: $0) }

                    Button {
                        showPersonPicker = true
                    } label: {
                        Label("添加参与人", systemImage: "person.badge.plus")
                    }
                }

                if caseModuleEnabled {
                    Section("关联事项") {
                        ForEach(selectedCases, id: \.id) { caseItem in
                            Label(caseItem.name, systemImage: "folder.fill")
                        }
                        .onDelete { selectedCases.remove(atOffsets: $0) }

                        Button {
                            showCasePicker = true
                        } label: {
                            Label("关联事项", systemImage: "link")
                        }
                    }
                }

                Section("记录") {
                    TextField("这次共同经历说明了什么？", text: $summary, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.surfaceLight)
            .navigationTitle(isEditing ? "编辑事件" : "新建事件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { saveEvent() }
                        .fontWeight(.semibold)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showPersonPicker) {
                personPickerSheet
            }
            .sheet(isPresented: $showCasePicker) {
                casePickerSheet
            }
            .onAppear {
                loadInitialValues()
            }
        }
    }

    private var personPickerSheet: some View {
        NavigationStack {
            List(allPersons, id: \.id) { person in
                Button {
                    if !selectedPersons.contains(where: { $0.id == person.id }) {
                        selectedPersons.append(person)
                    }
                } label: {
                    HStack {
                        AvatarPlaceholder(roleType: person.roleTypes.first ?? .other, size: 32)
                        Text(person.name)
                            .foregroundColor(.textPrimary)
                        Spacer()
                        if selectedPersons.contains(where: { $0.id == person.id }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.tealLink)
                        }
                    }
                }
            }
            .navigationTitle("选择参与人")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { showPersonPicker = false }
                }
            }
        }
    }

    private var casePickerSheet: some View {
        NavigationStack {
            List(allCases.filter { !$0.isArchived }, id: \.id) { caseItem in
                Button {
                    if !selectedCases.contains(where: { $0.id == caseItem.id }) {
                        selectedCases.append(caseItem)
                    }
                } label: {
                    HStack {
                        Text(caseItem.name)
                            .foregroundColor(.textPrimary)
                        Spacer()
                        if selectedCases.contains(where: { $0.id == caseItem.id }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.tealLink)
                        }
                    }
                }
            }
            .navigationTitle("选择事项")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { showCasePicker = false }
                }
            }
        }
    }

    private func loadInitialValues() {
        guard title.isEmpty else { return }

        if let event = existingEvent {
            title = event.title
            eventType = event.eventType
            status = event.status
            hasDate = event.date != nil
            date = event.date ?? Date()
            isAllDay = event.isAllDay
            location = event.location ?? ""
            summary = event.summary ?? ""
            selectedPersons = event.participants
            selectedCases = event.associatedCases
            return
        }

        if let defaultCase {
            selectedCases = [defaultCase]
            eventType = .hearing
        }
    }

    private func saveEvent() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        if !isEditing && !subManager.canAddCaseOrEvent {
            subManager.showUpgradeSheet = true
            return
        }

        let event = existingEvent ?? Event(title: trimmedTitle)
        event.title = trimmedTitle
        event.eventType = eventType
        event.status = status
        event.date = hasDate ? date : nil
        event.isAllDay = isAllDay
        event.location = location.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        event.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        event.updatedAt = Date()

        if existingEvent == nil {
            modelContext.insert(event)
        }

        replaceParticipants(for: event)
        replaceCases(for: event)

        try? modelContext.save()
        dismiss()
    }

    private func replaceParticipants(for event: Event) {
        event.eventPersons.forEach { modelContext.delete($0) }
        event.eventPersons.removeAll()

        for (index, person) in selectedPersons.enumerated() {
            let link = EventPerson(person: person, event: event, role: "参与者", sortOrder: index)
            modelContext.insert(link)
            event.eventPersons.append(link)
        }
    }

    private func replaceCases(for event: Event) {
        event.eventCases.forEach { modelContext.delete($0) }
        event.eventCases.removeAll()

        for (index, caseItem) in selectedCases.enumerated() {
            let link = EventCase(event: event, case: caseItem, sortOrder: index)
            modelContext.insert(link)
            event.eventCases.append(link)
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
