import SwiftUI

import SwiftData

/// 人脉列表页 — 搜索框 + 角色胶囊筛选 + 排序切换 + 简化联系人卡片 

struct PersonListView: View {

@Environment(.modelContext) private var modelContext

@Query(sort: [SortDescriptor(\Person.importance, order: .reverse), SortDescriptor(\Person.name)])

private var allPersons: [Person]

@State private var searchText = ""

@State private var selectedRole: PersonRoleType? = nil

@State private var sortMode: PersonSortMode = .connection

@State private var starFeedbackTrigger = false

@Environment(.isSearching) private var isSearching

@State private var editMode: EditMode = .inactive

@State private var selectedPersons: Set = []

@State private var undoPayload: (person: Person, action: UndoAction)?

@State private var showUndoBanner = false

enum UndoAction { case delete, archive }

enum PersonSortMode: String, CaseIterable {

case connection = "连接", name = "姓名"

var systemImage: String { switch self { case .connection: return "bolt.horizontal.fill"; case .name: return "textformat.abc" } }

}

var body: some View {

NavigationStack {

VStack(spacing: 0) {

if isSearching || selectedRole != nil { roleFilterBar.transition(.move(edge: .top).combined(with: .opacity)) }

sortToggleBar

ScrollView {

LazyVStack(spacing: Spacing.md) {

if !importantPersons.isEmpty {

sectionHeader("★ 重要")

ForEach(Array(importantPersons.enumerated()), id: .element.id) { index, person in

NavigationLink { PersonDetailPlaceholderView(person: person) } label: { PersonRow(person: person) }.buttonStyle(.plain).staggerEntrance(index: index)

.swipeActions(edge: .trailing) {

Button { withAnimation(.easeInOut(duration: 0.2)) { toggleStar(person) } } label: { Label(person.importance >= 5 ? "取消星标" : "星标", systemImage: person.importance >= 5 ? "star.slash" : "star.fill") }.tint(.coralWarm)

Button { withAnimation(.easeInOut(duration: 0.2)) { person.isArchived.toggle() } } label: { Label("归档", systemImage: "archivebox.fill") }.tint(.textTertiary)

}

.contextMenu { contactContextMenu(for: person) }

#if os(iOS)

.sensoryFeedback(.impact(.light), trigger: starFeedbackTrigger)

#endif

}

}

if !regularPersons.isEmpty {

sectionHeader(searchText.isEmpty && selectedRole == nil ? "你的网络" : "匹配结果")

ForEach(Array(regularPersons.enumerated()), id: .element.id) { index, person in

NavigationLink { PersonDetailPlaceholderView(person: person) } label: { PersonRow(person: person) }.buttonStyle(.plain).staggerEntrance(index: index)

.swipeActions(edge: .trailing) {

Button { withAnimation(.easeInOut(duration: 0.2)) { toggleStar(person) } } label: { Label(person.importance >= 5 ? "取消星标" : "星标", systemImage: person.importance >= 5 ? "star.slash" : "star.fill") }.tint(.coralWarm)

Button { withAnimation(.easeInOut(duration: 0.2)) { person.isArchived.toggle() } } label: { Label("归档", systemImage: "archivebox.fill") }.tint(.textTertiary)

}

.contextMenu { contactContextMenu(for: person) }

#if os(iOS)

.sensoryFeedback(.impact(.light), trigger: starFeedbackTrigger)

#endif

}

}

if filteredPersons.isEmpty { emptyStateView }

}.padding(.horizontal, Spacing.base).padding(.vertical, Spacing.md)

}.background(Color.surfaceLight)

}.background(Color.surfaceLight).syncAware().refreshable { await refreshSync() }.navigationTitle("人脉")

.searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "搜索你网络里的任何人...")

.toolbar {

ToolbarItem(placement: .navigationBarLeading) { if !filteredPersons.isEmpty { EditButton().environment(.editMode, $editMode) } }

ToolbarItem(placement: .primaryAction) {

if editMode == .active { Button(role: .destructive) { deleteSelected() } label: { Text("删除 ((selectedPersons.count))").font(.cnSubhead) } }

else { NavigationLink { PersonEditPlaceholderView() } label: { Image(systemName: "plus.circle.fill").font(.system(size: 22)).foregroundColor(.tealLink) } }

}

}

}

}

@ViewBuilder

private var roleFilterBar: some View {

if isSearchFocused || !searchText.isEmpty || selectedRole != nil {

ScrollView(.horizontal, showsIndicators: false) {

HStack(spacing: Spacing.sm) {

roleFilterChip(label: "全部", systemImage: "person.2", color: .oceanDeep, isSelected: selectedRole == nil) { withAnimation(.easeInOut(duration: 0.2)) { selectedRole = nil } }

ForEach(PersonRoleType.allCases) { roleType in

roleFilterChip(label: "(roleType.rawValue)", systemImage: roleType.systemImage, color: roleType.swiftUIColor, isSelected: selectedRole == roleType) { withAnimation(.easeInOut(duration: 0.2)) { selectedRole = (selectedRole == roleType) ? nil : roleType } }

}

}.padding(.horizontal, Spacing.base).padding(.bottom, Spacing.sm)

}

}

}

private func roleFilterChip(label: String, systemImage: String, color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {

Button(action: action) {

HStack(spacing: Spacing.xs) { Image(systemName: systemImage).font(.system(size: 12, weight: .medium)); Text(label).font(.cnCaption1) }

.foregroundColor(isSelected ? .white : color).padding(.horizontal, Spacing.md).padding(.vertical, Spacing.sm)

.background(Capsule(style: .continuous).fill(isSelected ? color : color.opacity(0.12)))

}.buttonStyle(.plain)

}

@ViewBuilder

private func sectionHeader(_ title: String) -> some View {

HStack { Text(title).font(.cnTitle3).foregroundColor(.textPrimary); Spacer() }.padding(.top, Spacing.lg)

}

@ViewBuilder

private var sortToggleBar: some View {

HStack(spacing: Spacing.sm) {

Spacer()

ForEach(PersonSortMode.allCases, id: .self) { mode in

Button { withAnimation(.easeInOut(duration: 0.2)) { sortMode = mode } } label: {

HStack(spacing: 3) { Image(systemName: mode.systemImage).font(.system(size: 10, weight: .medium)); Text(mode.rawValue).font(.cnCaption2) }

.foregroundColor(sortMode == mode ? .white : .textSecondary).padding(.horizontal, Spacing.sm).padding(.vertical, Spacing.xs)

.background(Capsule(style: .continuous).fill(sortMode == mode ? Color.tealLink : Color.surfaceCard))

.overlay(Capsule(style: .continuous).stroke(sortMode == mode ? Color.clear : Color.divider, lineWidth: 1))

}.buttonStyle(.plain)

}

}.padding(.horizontal, Spacing.base).padding(.bottom, Spacing.sm)

}

@ViewBuilder

private var emptyStateView: some View {

if searchText.isEmpty && selectedRole == nil {

ContentUnavailableView { Label("还没有联系人", systemImage: "person.2.slash") } description: { Text("每个案件背后都有人。从第一个人开始。") } actions: { NavigationLink { PersonEditPlaceholderView() } label: { Text("添加第一位联系人") } }

} else { ContentUnavailableView.search }

}

private var filteredPersons: [Person] {

var result = allPersons.filter { !$0.isArchived }

if let role = selectedRole { result = result.filter { $0.roleTypes.contains(role) } }

if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {

let q = searchText.lowercased()

result = result.filter { $0.name.localizedStandardContains(q) || $0.pinyin.contains(q) || $0.pinyinInitials.contains(q) || $0.orgUnits.contains(where: { $0.name.localizedStandardContains(q) }) }

}

result = applySort(result)

return result

}

private func applySort(_ persons: [Person]) -> [Person] {

switch sortMode {

case .connection:

return persons.sorted { a, b in

let aDate = a.lastActiveDate ?? Date.distantPast

let bDate = b.lastActiveDate ?? Date.distantPast

if aDate != bDate { return aDate > bDate }

return a.importance > b.importance

}

case .name: return persons.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }

}

}

private var importantPersons: [Person] { filteredPersons.filter { $0.importance >= 4 } }

private var regularPersons: [Person] { filteredPersons.filter { $0.importance < 4 } }

private func toggleStar(_ person: Person) { person.importance = person.importance >= 5 ? 3 : 5; starFeedbackTrigger.toggle() }

private func deleteSelected() {

let peopleToDelete = allPersons.filter { selectedPersons.contains($0.uniqueKey) }

for person in peopleToDelete { modelContext.delete(person) }

try? modelContext.save(); selectedPersons.removeAll(); editMode = .inactive

}

private func deletePerson(_ person: Person) {

let backup = person; modelContext.delete(person); try? modelContext.save()

undoPayload = (person: backup, action: .delete); showUndoBanner = true

}

private func performUndo() {

guard let payload = undoPayload else { return }

switch payload.action {

case .delete:

let restored = Person(name: payload.person.name, roleTypes: payload.person.roleTypes, title: payload.person.title, phone: payload.person.phone, email: payload.person.email)

restored.importance = payload.person.importance; modelContext.insert(restored)

case .archive: payload.person.isArchived = false

}

try? modelContext.save(); undoPayload = nil; showUndoBanner = false

}

private func refreshSync() async { CloudSyncObserver.shared.refreshTrigger.send(); try? await Task.sleep(nanoseconds: 500_000_000) }

private func contactShareText(_ person: Person) -> String {

var parts: [String] = [person.name]

parts.append(person.roleTypes.map(.rawValue).joined(separator: "、"))

let orgNames = person.orgUnits.map { $0.name }

if !orgNames.isEmpty {
parts.append(person.title.map { "\($0) · \(orgNames.joined(separator: "、"))" } ?? orgNames.joined(separator: "、"))
}

if let phone = person.phone { parts.append("电话 \(phone)") }

if let email = person.email { parts.append("邮箱 \(email)") }

return parts.joined(separator: "\n")

}

@ViewBuilder

private func contactContextMenu(for person: Person) -> some View {

if let phone = person.phone, !phone.isEmpty {

Button { if let url = URL(string: "tel://\(phone.filter { $0.isNumber })"), UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) } } label: { Label("呼叫", systemImage: "phone.fill") }

Button { if let url = URL(string: "sms://\(phone.filter { $0.isNumber })"), UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) } } label: { Label("发短信", systemImage: "message.fill") }

}

if let email = person.email, !email.isEmpty {

Button { if let url = URL(string: "mailto:\(email)"), UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) } } label: { Label("发邮件", systemImage: "envelope.fill") }

}

Divider()

if let phone = person.phone, !phone.isEmpty { Button { Clipboard.copy(phone) } label: { Label("复制电话", systemImage: "phone.badge.plus") } }

if let email = person.email, !email.isEmpty { Button { Clipboard.copy(email) } label: { Label("复制邮箱", systemImage: "envelope.badge") } }

ShareLink(item: contactShareText(person), subject: Text(person.name)) { Label("分享名片", systemImage: "square.and.arrow.up") }

Divider()

NavigationLink { PersonEditPlaceholderView() } label: { Label("编辑", systemImage: "pencil") }

Button { withAnimation(.easeInOut(duration: 0.2)) { toggleStar(person) } } label: { Label(person.importance >= 5 ? "取消星标" : "星标", systemImage: person.importance >= 5 ? "star.slash" : "star.fill") }

}

}

// MARK: - 人脉详情占位

struct PersonDetailPlaceholderView: View {

let person: Person

@AppStorage("caseModuleEnabled") private var caseModuleEnabled: Bool = true

var body: some View {

ScrollView {

VStack(spacing: Spacing.base) {

VStack(spacing: Spacing.sm) {

if let primaryRole = person.roleTypes.first { LargeAvatarPlaceholder(roleType: primaryRole) }

Text(person.name).font(.cnTitle1).foregroundColor(.textPrimary)

HStack(spacing: Spacing.xs) { ForEach(person.roleTypes, id: .self) { roleType in RoleTypeTag(roleType: roleType) } }

let orgUnits = person.orgUnits.sorted { $0.sortOrder < $1.sortOrder }

if !orgUnits.isEmpty { ForEach(orgUnits, id: .id) { unit in OrgUnitBadge(orgUnit: unit) } }

if let title = person.title { Text(title).font(.cnSubhead).foregroundColor(.textSecondary) }

}.padding(Spacing.base).cardStyleSolid()

if hasContactInfo { contactCard }

if caseModuleEnabled && !person.casesByRole.isEmpty { linkedCasesCard }

}.padding(.horizontal, Spacing.base).padding(.vertical, Spacing.md)

}.background(Color.surfaceLight).navigationTitle("人脉详情").navigationBarTitleDisplayMode(.inline)

}

private var hasContactInfo: Bool { person.phone != nil || person.email != nil || person.wechat != nil || person.address != nil }

private var contactCard: some View {

VStack(alignment: .leading, spacing: Spacing.sm) {

Text("联系方式").font(.cnTitle3).foregroundColor(.textPrimary)

if let phone = person.phone { contactRow(icon: "phone.fill", text: phone) }

if let email = person.email { contactRow(icon: "envelope.fill", text: email) }

if let wechat = person.wechat { contactRow(icon: "message.fill", text: wechat) }

if let address = person.address { contactRow(icon: "mappin.and.ellipse", text: address) }

}.padding(Spacing.base).cardStyleSolid()

}

private func contactRow(icon: String, text: String) -> some View {

HStack(spacing: Spacing.md) { Image(systemName: icon).font(.system(size: 16)).foregroundColor(.tealLink).frame(width: 24); Text(text).font(.cnBody).foregroundColor(.textPrimary) }

}

private var linkedCasesCard: some View {

VStack(alignment: .leading, spacing: 0) {

HStack { Label { Text("参与的案件") } icon: { Image(systemName: "folder.fill").foregroundColor(.tealLink) }.font(.cnTitle3).foregroundColor(.textPrimary); Spacer(); Text("\(person.caseCount) 件").font(.cnSubhead).foregroundColor(.textTertiary) }.padding(.horizontal, Spacing.base).padding(.vertical, Spacing.md)

Divider().background(Color.divider)

ForEach(person.casesByRole, id: \.0.rawValue) { roleType, casePersons in

ForEach(Array(casePersons.enumerated()), id: .element.id) { index, cp in

if let c = cp.`case` {

caseSummaryRow(case_: c, casePerson: cp)

if index < casePersons.count - 1 || roleType != person.casesByRole.last?.0 { Divider().background(Color.divider).padding(.leading, Spacing.base) }

}

}

}

}.background(Color.surfaceCard).clipShape(RoundedRectangle(cornerRadius: CornerRadius.card)).cardShadow()

}

@ViewBuilder

private func caseSummaryRow(case_ caseItem: Case, casePerson cp: CasePerson) -> some View {

VStack(alignment: .leading, spacing: Spacing.xs) {

HStack { Text(caseItem.name).font(.cnHeadline).foregroundColor(.textPrimary).lineLimit(1); Spacer(); if let number = caseItem.caseNumber { Text(number).font(.cnCaption2).foregroundColor(.textTertiary) } }

HStack(spacing: Spacing.sm) {

Text(cp.role).font(.cnCaption1).foregroundColor(.textSecondary)

if let entrustDate = caseItem.entrustmentDate { Text("·").foregroundColor(.textTertiary); Text("委托于 (entrustDate.formatted(.dateTime.month(.abbreviated).day().year()))").font(.cnCaption2).foregroundColor(.textTertiary) }

}

}.padding(.horizontal, Spacing.base).padding(.vertical, Spacing.md)

}

}

// MARK: - 新建人脉占位

struct PersonEditPlaceholderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subManager: SubscriptionManager

    @State private var name = ""
    @State private var title = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var organization = ""
    @State private var department = ""
    @State private var referrer = ""
    @State private var notes = ""
    @State private var role: PersonRoleType = .other
    @State private var relationship: RelationshipType = .other

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("姓名（必填）", text: $name)
                        .textContentType(.name)
                    Picker("角色", selection: $role) {
                        ForEach(PersonRoleType.allCases) { roleType in
                            Text(roleType.rawValue).tag(roleType)
                        }
                    }
                    Picker("关系", selection: $relationship) {
                        ForEach(RelationshipType.allCases) { item in
                            Label(item.rawValue, systemImage: item.systemImage).tag(item)
                        }
                    }
                }

                Section("单位与职务") {
                    TextField("单位名称", text: $organization)
                        .textContentType(.organizationName)
                    TextField("部门（选填）", text: $department)
                    TextField("职务/职称", text: $title)
                        .textContentType(.jobTitle)
                }

                Section("联系方式") {
                    TextField("电话", text: $phone)
                        .textContentType(.telephoneNumber)
                    TextField("邮箱", text: $email)
                        .textContentType(.emailAddress)
                }

                Section("来源与备注") {
                    TextField("谁介绍的", text: $referrer)
                        .textContentType(.name)
                    TextField("备注", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.surfaceLight)
            .navigationTitle("新建联系人")
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
            title: cleaned(title),
            phone: cleaned(phone),
            email: cleaned(email),
            notes: cleaned(notes),
            importance: 3
        )
        person._relationshipRaw = relationship.rawValue
        person.referrer = cleaned(referrer)
        modelContext.insert(person)

        if let orgName = cleaned(organization) {
            let unit = OrgUnit(name: orgName, department: cleaned(department))
            unit.person = person
            modelContext.insert(unit)
        }

        try? modelContext.save()
        dismiss()
    }

    private func cleaned(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
