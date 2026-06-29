import SwiftUI
import SwiftData

struct PersonListView: View {
    @Query(sort: [SortDescriptor(\Person.importance, order: .reverse), SortDescriptor(\Person.name)])
    private var allPersons: [Person]

    @State private var searchText = ""
    @State private var selectedRole: PersonRoleType?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                roleFilterBar

                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        if filteredPersons.isEmpty {
                            emptyState
                        } else {
                            ForEach(filteredPersons, id: \.id) { person in
                                NavigationLink {
                                    PersonDetailPlaceholderView(person: person)
                                } label: {
                                    PersonRow(person: person)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(Spacing.base)
                }
                .background(Color.surfaceLight)
            }
            .background(Color.surfaceLight)
            .navigationTitle("人脉")
            .searchable(text: $searchText, prompt: "搜索人脉、单位、角色")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        PersonEditPlaceholderView()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.tealLink)
                    }
                    .accessibilityLabel("添加联系人")
                }
            }
        }
    }

    private var roleFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                roleFilterChip(
                    label: "全部",
                    systemImage: "person.2.fill",
                    color: .oceanDeep,
                    isSelected: selectedRole == nil
                ) {
                    selectedRole = nil
                }

                ForEach(PersonRoleType.allCases) { role in
                    roleFilterChip(
                        label: role.rawValue,
                        systemImage: role.systemImage,
                        color: role.swiftUIColor,
                        isSelected: selectedRole == role
                    ) {
                        selectedRole = selectedRole == role ? nil : role
                    }
                }
            }
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.sm)
        }
        .background(Color.surfaceLight)
    }

    private var filteredPersons: [Person] {
        var result = allPersons.filter { !$0.isArchived }

        if let selectedRole {
            result = result.filter { $0.roleTypes.contains(selectedRole) }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            result = result.filter { person in
                person.name.localizedStandardContains(query)
                    || person.pinyin.localizedStandardContains(query)
                    || person.pinyinInitials.localizedStandardContains(query)
                    || person.roleTypes.contains { $0.rawValue.localizedStandardContains(query) }
                    || person.orgUnits.contains { $0.name.localizedStandardContains(query) }
            }
        }

        return result.sorted { lhs, rhs in
            if lhs.importance != rhs.importance {
                return lhs.importance > rhs.importance
            }
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "还没有人脉",
            systemImage: "person.2.slash",
            description: Text("先添加第一位真实联系人，连接网络才会开始生长。")
        )
        .padding(.top, Spacing.xxl)
    }

    private func roleFilterChip(
        label: String,
        systemImage: String,
        color: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(label, systemImage: systemImage)
                .font(.cnCaption1)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(Capsule().fill(isSelected ? color : color.opacity(0.12)))
        }
        .buttonStyle(.plain)
    }
}

struct PersonDetailPlaceholderView: View {
    let person: Person

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    HStack(spacing: Spacing.md) {
                        LargeAvatarPlaceholder(roleType: person.roleTypes.first ?? .other)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(person.name)
                                .font(.cnTitle2)
                                .foregroundColor(.textPrimary)

                            if let title = person.title {
                                Text(title)
                                    .font(.cnSubhead)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }

                    if !person.roleTypes.isEmpty {
                        HStack {
                            ForEach(person.roleTypes, id: \.self) { role in
                                RoleTypeTag(roleType: role)
                            }
                        }
                    }
                }
                .padding(.vertical, Spacing.sm)
            }

            if let phone = person.phone, !phone.isEmpty {
                Section("联系方式") {
                    Label(phone, systemImage: "phone.fill")
                }
            }

            if !person.orgUnits.isEmpty {
                Section("机构") {
                    ForEach(person.orgUnits.sorted { $0.sortOrder < $1.sortOrder }, id: \.id) { org in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(org.name)
                            if let department = org.department {
                                Text(department)
                                    .font(.cnCaption1)
                                    .foregroundColor(.textTertiary)
                            }
                        }
                    }
                }
            }

            Section("连接") {
                NavigationLink {
                    PersonNetworkView(focalPerson: person)
                } label: {
                    Label("查看人脉网络", systemImage: "point.3.connected.trianglepath.dotted")
                }

                Text("这里优先展示真实共同经历、共同事项和共同联系人。")
                    .font(.cnCaption1)
                    .foregroundColor(.textTertiary)
            }
        }
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PersonEditPlaceholderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subManager: SubscriptionManager

    @State private var name = ""
    @State private var role: PersonRoleType = .other
    @State private var relationship: RelationshipType = .other
    @State private var title = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var organization = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("姓名", text: $name)

                    Picker("角色", selection: $role) {
                        ForEach(PersonRoleType.allCases) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }

                    Picker("关系", selection: $relationship) {
                        ForEach(RelationshipType.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }

                    TextField("职务（选填）", text: $title)
                }

                Section("联系方式") {
                    TextField("电话（选填）", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("邮箱（选填）", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }

                Section("机构") {
                    TextField("单位/机构（选填）", text: $organization)
                }

                Section("备注") {
                    TextField("备注（选填）", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("添加联系人")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { savePerson() }
                        .fontWeight(.semibold)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func savePerson() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        guard subManager.canAddPerson else {
            subManager.showUpgradeSheet = true
            return
        }

        let person = Person(
            name: trimmedName,
            roleTypes: [role],
            title: title.nilIfBlank,
            phone: phone.nilIfBlank,
            email: email.nilIfBlank,
            notes: notes.nilIfBlank
        )
        person.relationship = relationship

        if let organization = organization.nilIfBlank {
            let org = OrgUnit(name: organization)
            org.person = person
            person.orgUnits.append(org)
            modelContext.insert(org)
        }

        modelContext.insert(person)
        try? modelContext.save()
        dismiss()
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
