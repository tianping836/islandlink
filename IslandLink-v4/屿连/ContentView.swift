import SwiftUI

import SwiftData

/// App 根导航 — 3 Tab 布局

/// 人脉 | 事项 | 设置

/// 「事项」Tab 内嵌分段选择器切换事件/案件 

struct ContentView: View {

@Environment(.modelContext) private var modelContext

@AppStorage("caseModuleEnabled") private var caseModuleEnabled: Bool = true

@SceneStorage("selectedTab") private var selectedTab = 0

@SceneStorage("lastViewedPersonID") private var lastViewedPersonID: String?

@SceneStorage("lastViewedCaseID") private var lastViewedCaseID: String?

@SceneStorage("lastViewedEventID") private var lastViewedEventID: String?

@SceneStorage("recentItemsJSON") private var recentItemsJSON: String = "[]"

@State private var mattersSegment: MattersSegment = .events

@State private var recentItems: [RecentItem] = []

struct RecentItem: Codable, Identifiable, Equatable {

let id: String

let type: ItemType

let title: String

let subtitle: String

let timestamp: Date

enum ItemType: String, Codable { case person, caseItem, event }

}

@State private var showNewEventSheet = false

@State private var showNewPersonSheet = false

private var isPadOrMac: Bool {

#if os(macOS)

return true

#else

return UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac

#endif

}

enum MattersSegment: String, CaseIterable { case events = "事件", cases = "案件" }

var body: some View {

Group {

if isPadOrMac { iPadLayout } else { iPhoneLayout }

}

.onAppear {

NotificationManager.shared.requestAuthorization()

SpotlightIndexManager.shared.rebuildAllIndices(modelContext: modelContext)

loadRecentItems()

}

.onOpenURL { url in handleQuickAction(url: url) }

.onKeyPress(.tab, modifiers: .command) { return .ignored }

.onKeyPress(keys: ["1", "2", "3"], phases: .down) { press in

guard press.modifiers == .command else { return .ignored }

switch press.characters {

case "1": selectedTab = 0

case "2": selectedTab = 1

case "3": selectedTab = 2

default: break

}

return .handled

}

.onKeyPress("n", modifiers: .command) {

switch selectedTab {

case 0: showNewPersonSheet = true

case 1: showNewEventSheet = true

default: showNewEventSheet = true

}

return .handled

}

.onKeyPress("f", modifiers: .command) {

NotificationCenter.default.post(name: .islandLinkFocusSearch, object: nil)

return .handled

}

.sheet(isPresented: $showNewEventSheet) { EventEditView() }

.sheet(isPresented: $showNewPersonSheet) { PersonEditPlaceholderView() }

}

static let focusSearchNotification = Notification.Name("islandLinkFocusSearch")

private var iPhoneLayout: some View {

TabView(selection: $selectedTab) {

PersonListView()

.tabItem { Label("人脉", systemImage: "person.2.fill").environment(.symbolVariants, .none) }

.tag(0)

mattersTab

.tabItem { Label("事项", systemImage: "list.bullet.rectangle.fill").environment(.symbolVariants, .none) }

.tag(1)

SettingsView()

.tabItem { Label("设置", systemImage: "gearshape.fill").environment(.symbolVariants, .none) }

.tag(2)

}

.tint(.tealLink)

.toolbarBackground(.regularMaterial, for: .tabBar)

.toolbarBackground(.visible, for: .tabBar)

}

private var iPadLayout: some View {

NavigationSplitView {

sidebarContent.navigationSplitViewColumnWidth(220)

} content: {

sidebarDetailContent.navigationSplitViewColumnWidth(320)

} detail: {

Text("选择一项查看详情").font(.cnBody).foregroundColor(.textTertiary)

}

.navigationSplitViewStyle(.balanced)

}

private var sidebarContent: some View {

List(selection: $selectedTab) {

Section {

Label("人脉", systemImage: "person.2.fill").tag(0)

Label("事项", systemImage: "list.bullet.rectangle.fill").tag(1)

Label("设置", systemImage: "gearshape.fill").tag(2)

} header: {

Label("连接", systemImage: "dolphin.fill").font(.cnTitle2).foregroundColor(.oceanDeep).textCase(nil).padding(.bottom, Spacing.sm)

}

}

.listStyle(.sidebar).scrollContentBackground(.hidden).background(.regularMaterial)

}

@ViewBuilder

private var sidebarDetailContent: some View {

switch selectedTab {

case 0: PersonListView()

case 1: mattersContent

case 2: SettingsView()

default: PersonListView()

}

}

private var mattersTab: some View {

NavigationStack {

VStack(spacing: 0) {

mattersSegmentPicker.padding(.horizontal, Spacing.base).padding(.top, Spacing.sm).padding(.bottom, Spacing.sm)

mattersContent

}

.background(Color.surfaceLight).navigationTitle("事项")

}

}

private var mattersSegmentPicker: some View {

let segments = caseModuleEnabled ? MattersSegment.allCases : [MattersSegment.events]

return HStack(spacing: 0) {

ForEach(segments, id: .self) { segment in

Button {

withAnimation(.easeInOut(duration: 0.2)) { mattersSegment = segment }

} label: {

Text(segment.rawValue).font(.cnSubhead).fontWeight(mattersSegment == segment ? .semibold : .regular).foregroundColor(mattersSegment == segment ? .white : .textSecondary).padding(.vertical, Spacing.sm).frame(maxWidth: .infinity).background(RoundedRectangle(cornerRadius: CornerRadius.button).fill(mattersSegment == segment ? Color.tealLink : Color.clear))

}.buttonStyle(.plain)

}

}.padding(Spacing.xs).background(Color.surfaceCard).clipShape(RoundedRectangle(cornerRadius: CornerRadius.button))

}

@ViewBuilder

private var mattersContent: some View {

if matterSegmentsVisible.count > 1 {

TabView(selection: $mattersSegment) {

EventListView().tag(MattersSegment.events)

if caseModuleEnabled { CaseListView().tag(MattersSegment.cases) }

}.tabViewStyle(.page(indexDisplayMode: .never))

} else { EventListView() }

}

private var matterSegmentsVisible: [MattersSegment] { caseModuleEnabled ? MattersSegment.allCases : [.events] }

private func loadRecentItems() {

guard let data = recentItemsJSON.data(using: .utf8), let items = try? JSONDecoder().decode([RecentItem].self, from: data) else { return }

recentItems = items.sorted(by: { $0.timestamp > $1.timestamp }).prefix(10).map { $0 }

}

private func trackRecentItem(type: RecentItem.ItemType, id: String, title: String, subtitle: String) {

let item = RecentItem(id: id, type: type, title: title, subtitle: subtitle, timestamp: Date())

var items = recentItems.filter { $0.id != id }

items.insert(item, at: 0)

recentItems = Array(items.prefix(10))

if let data = try? JSONEncoder().encode(recentItems), let json = String(data: data, encoding: .utf8) { recentItemsJSON = json }

}

private func handleQuickAction(url: URL) {

guard let host = url.host else { return }

switch host {

case "newPerson": selectedTab = 1; showNewPersonSheet = true

case "newEvent": selectedTab = 2; showNewEventSheet = true

case "search": NotificationCenter.default.post(name: .islandLinkFocusSearch, object: nil)

default: break

}

}

}

// MARK: - 案件列表页（内嵌到事项 Tab）

struct CaseListView: View {

@Environment(.modelContext) private var modelContext

@Query(sort: \Case.updatedAt, order: .reverse) private var allCases: [Case]

@State private var searchText = ""

var body: some View {

VStack(spacing: 0) {

SearchBar(text: $searchText, placeholder: "搜索案件名称、案号...").padding(.horizontal, Spacing.base).padding(.vertical, Spacing.sm)

ScrollView {

LazyVStack(spacing: Spacing.md) {

ForEach(Array(filteredCases.enumerated()), id: .element.id) { index, caseItem in

NavigationLink { CaseDetailPlaceholderView(caseItem: caseItem) } label: { CaseCard(caseItem: caseItem) }.buttonStyle(.plain).staggerEntrance(index: index)

}

if filteredCases.isEmpty { emptyStateView }

}.padding(.horizontal, Spacing.base).padding(.vertical, Spacing.md)

}.background(Color.surfaceLight)

}.background(Color.surfaceLight)

}

private var filteredCases: [Case] {

var result = allCases.filter { !$0.isArchived }

if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {

let q = searchText.lowercased()

result = result.filter { $0.name.localizedStandardContains(q) || ($0.caseNumber?.localizedStandardContains(q) ?? false) || $0.customFields.contains(where: { $0.value.localizedStandardContains(q) }) }

}

return result

}

@ViewBuilder

private var emptyStateView: some View {

if searchText.isEmpty {

ContentUnavailableView { Label("还没有案件", systemImage: "folder.fill") } description: { Text("添加你的第一个案件，开始管理人脉关联。") } actions: { Button("添加案件") {} }

} else { ContentUnavailableView.search }

}

}

// MARK: - 案件详情页

struct CaseDetailPlaceholderView: View {

let caseItem: Case

@State private var showNewEventSheet = false

var body: some View {

ScrollView {

VStack(spacing: Spacing.base) {

VStack(alignment: .leading, spacing: Spacing.sm) {

Text(caseItem.name).font(.cnTitle2).foregroundColor(.textPrimary)

if let caseNumber = caseItem.caseNumber { Text(caseNumber).font(.cnMonoFootnote).foregroundColor(.textSecondary) }

if let entrustDate = caseItem.entrustmentDate { Label { Text("委托于 (entrustDate.formatted(.dateTime.year().month(.abbreviated).day()))") } icon: { Image(systemName: "calendar.badge.clock").foregroundColor(.textTertiary) }.font(.cnCaption1).foregroundColor(.textSecondary).padding(.top, Spacing.xs) }

let labels = caseItem.allFieldLabels

if !labels.isEmpty {

Divider()

ForEach(labels, id: .self) { label in

let values = caseItem.fieldValues(for: label)

HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) { Text(label).font(.cnSubhead).foregroundColor(.textTertiary).frame(minWidth: 72, alignment: .leading); Text(values.joined(separator: "、")).font(.cnBody).foregroundColor(.textPrimary) }

}

}

if let notes = caseItem.notes, !notes.isEmpty { Divider(); Text(notes).font(.cnBody).foregroundColor(.textSecondary) }

}.padding(Spacing.base).cardStyleSolid()

if !caseItem.personsByRole.isEmpty { RoleGroupSection(groupedPersons: caseItem.personsByRole) }

}.padding(.horizontal, Spacing.base).padding(.vertical, Spacing.md)

}.background(Color.surfaceLight).navigationTitle("案件详情").navigationBarTitleDisplayMode(.inline)

.toolbar { ToolbarItem(placement: .primaryAction) { Button { showNewEventSheet = true } label: { Image(systemName: "plus").font(.system(size: 18, weight: .semibold)).foregroundColor(.tealLink) }.accessibilityLabel("添加事件") } }

.sheet(isPresented: $showNewEventSheet) { EventEditView(defaultCase: caseItem) }

}

}
