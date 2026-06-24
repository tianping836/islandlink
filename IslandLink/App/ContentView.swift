import SwiftUI
import SwiftData

/// App 根导航 — 3 Tab 布局
/// 人脉 | 事项 | 设置
/// 「事项」Tab 内嵌分段选择器切换事件/案件
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("caseModuleEnabled") private var caseModuleEnabled: Bool = true
    @SceneStorage("selectedTab") private var selectedTab = 0
    @SceneStorage("lastViewedPersonID") private var lastViewedPersonID: String?
    @SceneStorage("lastViewedCaseID") private var lastViewedCaseID: String?
    @SceneStorage("lastViewedEventID") private var lastViewedEventID: String?
    @SceneStorage("recentItemsJSON") private var recentItemsJSON: String = "[]"
    @State private var mattersSegment: MattersSegment = .events

    // MARK: 最近查看
    @State private var recentItems: [RecentItem] = []

    struct RecentItem: Codable, Identifiable, Equatable {
        let id: String
        let type: ItemType
        let title: String
        let subtitle: String
        let timestamp: Date

        enum ItemType: String, Codable {
            case person, caseItem, event
        }
    }

    // MARK: iPad 键盘快捷键
    @State private var showNewEventSheet = false
    @State private var showNewPersonSheet = false

    /// 跨平台宽屏判断：iPad 和 Mac 走侧栏布局，iPhone 走 TabView
    private var isPadOrMac: Bool {
        #if os(macOS)
        return true
        #else
        return UIDevice.current.userInterfaceIdiom == .pad
            || UIDevice.current.userInterfaceIdiom == .mac
        #endif
    }

    enum MattersSegment: String, CaseIterable {
        case events = "事件"
        case cases = "案件"
    }

    var body: some View {
        Group {
            if isPadOrMac {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .onAppear {
            Task { await NotificationManager.shared.requestAuthorization() }
            SpotlightIndexManager.shared.rebuildAllIndices(modelContext: modelContext)

            // 加载最近查看
            loadRecentItems()
        }
        // Quick Actions 处理
        .onOpenURL { url in
            handleQuickAction(url: url)
        }
        // MARK: iPad 键盘快捷键 — 等待适配新 onKeyPress API，暂时禁用
        // 新建事件 sheet
        .sheet(isPresented: $showNewEventSheet) {
            EventEditView()
        }
        // 新建人脉 sheet
        .sheet(isPresented: $showNewPersonSheet) {
            PersonEditPlaceholderView()
        }
    }

    // MARK: - Keyboard shortcut support: search focus notification
    /// 键盘快捷键 Cmd+F 触发，由 PersonListView / EventListView 监听并聚焦搜索栏
    static let focusSearchNotification = Notification.Name("islandLinkFocusSearch")

    // MARK: - iPhone 布局（TabView）

    private var iPhoneLayout: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: 人脉
            PersonListView()
                .tabItem {
                    Label("人脉", systemImage: "person.2.fill")
                        .environment(\.symbolVariants, .none)
                }
                .tag(0)

            // Tab 2: 事项（内嵌分段选择器）
            mattersTab
                .tabItem {
                    Label("事项", systemImage: "list.bullet.rectangle.fill")
                        .environment(\.symbolVariants, .none)
                }
                .tag(1)

            // Tab 3: 设置
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                        .environment(\.symbolVariants, .none)
                }
                .tag(2)
        }
        .tint(.tealLink)
        .toolbarBackground(.regularMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }

    // MARK: - iPad 布局（NavigationSplitView 侧栏）

    private var iPadLayout: some View {
        NavigationSplitView {
            // 侧栏
            sidebarContent
                .navigationSplitViewColumnWidth(220)
        } content: {
            // 内容列表列
            sidebarDetailContent
                .navigationSplitViewColumnWidth(320)
        } detail: {
            // 详情列
            Text("选择一项查看详情")
                .font(.cnBody)
                .foregroundColor(.textTertiary)
        }
        .navigationSplitViewStyle(.balanced)
    }

    // MARK: 侧栏内容

    private var sidebarContent: some View {
        List {
            Section {
                Label("人脉", systemImage: "person.2.fill")
                    .tag(0)
                Label("事项", systemImage: "list.bullet.rectangle.fill")
                    .tag(1)
                Label("设置", systemImage: "gearshape.fill")
                    .tag(2)
            } header: {
                Label("连接", systemImage: "dolphin.fill")
                    .font(.cnTitle2)
                    .foregroundColor(.oceanDeep)
                    .textCase(nil)
                    .padding(.bottom, Spacing.sm)
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .background(.regularMaterial)
    }

    // MARK: 侧栏对应的内容

    @ViewBuilder
    private var sidebarDetailContent: some View {
        switch selectedTab {
        case 0: PersonListView()
        case 1: mattersContent
        case 2: SettingsView()
        default: PersonListView()
        }
    }

    // MARK: - 「事项」Tab

    private var mattersTab: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 分段选择器
                mattersSegmentPicker
                    .padding(.horizontal, Spacing.base)
                    .padding(.top, Spacing.sm)
                    .padding(.bottom, Spacing.sm)

                // 内容区
                mattersContent
            }
            .background(Color.surfaceLight)
            .navigationTitle("事项")
        }
    }

    /// 分段选择器：显示案件选项仅当模块开关开启
    private var mattersSegmentPicker: some View {
        let segments = caseModuleEnabled
            ? MattersSegment.allCases
            : [MattersSegment.events]

        return HStack(spacing: 0) {
            ForEach(segments, id: \.self) { segment in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        mattersSegment = segment
                    }
                } label: {
                    Text(segment.rawValue)
                        .font(.cnSubhead)
                        .fontWeight(mattersSegment == segment ? .semibold : .regular)
                        .foregroundColor(mattersSegment == segment ? .white : .textSecondary)
                        .padding(.vertical, Spacing.sm)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.button)
                                .fill(mattersSegment == segment ? Color.tealLink : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.xs)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.button))
    }

    /// 分段内容
    @ViewBuilder
    private var mattersContent: some View {
        if matterSegmentsVisible.count > 1 {
            // 两个分段时用 TabView 切换
            TabView(selection: $mattersSegment) {
                EventListView()
                    .tag(MattersSegment.events)

                if caseModuleEnabled {
                    CaseListView()
                        .tag(MattersSegment.cases)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        } else {
            EventListView()
        }
    }

    private var matterSegmentsVisible: [MattersSegment] {
        caseModuleEnabled ? MattersSegment.allCases : [.events]
    }
}

// MARK: - 案件列表页（内嵌到事项 Tab）

/// 案件列表 — 极简：搜索 + 平铺列表，无状态筛选
struct CaseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Case.updatedAt, order: .reverse)
    private var allCases: [Case]

    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            // 搜索栏
            SearchBar(text: $searchText, placeholder: "搜索案件名称、案号...")
                .padding(.horizontal, Spacing.base)
                .padding(.vertical, Spacing.sm)

            // 案件列表
            ScrollView {
                LazyVStack(spacing: Spacing.md) {
                    ForEach(Array(filteredCases.enumerated()), id: \.element.id) { index, caseItem in
                        NavigationLink {
                            CaseDetailPlaceholderView(caseItem: caseItem)
                        } label: {
                            CaseCard(caseItem: caseItem)
                        }
                        .buttonStyle(.plain)
                        .staggerEntrance(index: index)
                    }

                    if filteredCases.isEmpty {
                        emptyStateView
                    }
                }
                .padding(.horizontal, Spacing.base)
                .padding(.vertical, Spacing.md)
            }
            .background(Color.surfaceLight)
        }
        .background(Color.surfaceLight)
    }

    // MARK: - 数据

    private var filteredCases: [Case] {
        var result = allCases.filter { !$0.isArchived }

        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = searchText.lowercased()
            result = result.filter {
                $0.name.localizedStandardContains(q) ||
                ($0.caseNumber?.localizedStandardContains(q) ?? false) ||
                $0.customFields.contains(where: { $0.value.localizedStandardContains(q) })
            }
        }

        return result
    }

    @ViewBuilder
    private var emptyStateView: some View {
        if searchText.isEmpty {
            ContentUnavailableView {
                Label("还没有案件", systemImage: "folder.fill")
            } description: {
                Text("添加你的第一个案件，开始管理人脉关联。")
            } actions: {
                Button("添加案件") { /* TODO: 新建案件 */ }
            }
        } else {
            ContentUnavailableView.search
        }
    }
}

// MARK: - 案件详情页（灵活字段展示）

struct CaseDetailPlaceholderView: View {
    let caseItem: Case

    @State private var showNewEventSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.base) {
                // 基本信息卡片
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(caseItem.name)
                        .font(.cnTitle2)
                        .foregroundColor(.textPrimary)
                    if let caseNumber = caseItem.caseNumber {
                        Text(caseNumber)
                            .font(.cnMonoFootnote)
                            .foregroundColor(.textSecondary)
                    }
                    if let entrustDate = caseItem.entrustmentDate {
                        Label {
                            Text("委托于 \(entrustDate.formatted(.dateTime.year().month(.abbreviated).day()))")
                        } icon: {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(.textTertiary)
                        }
                        .font(.cnCaption1)
                        .foregroundColor(.textSecondary)
                        .padding(.top, Spacing.xs)
                    }

                    // 灵活字段展示（类型感知）
                    let labels = caseItem.allFieldLabels
                    if !labels.isEmpty {
                        Divider()
                        ForEach(labels, id: \.self) { label in
                            let values = caseItem.fieldValues(for: label)
                            HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
                                Text(label)
                                    .font(.cnSubhead)
                                    .foregroundColor(.textTertiary)
                                    .frame(minWidth: 72, alignment: .leading)
                                Text(values.joined(separator: "、"))
                                    .font(.cnBody)
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }

                    // 备注
                    if let notes = caseItem.notes, !notes.isEmpty {
                        Divider()
                        Text(notes)
                            .font(.cnBody)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(Spacing.base)
                .cardStyleSolid()

                // 参与人
                if !caseItem.personsByRole.isEmpty {
                    RoleGroupSection(groupedPersons: caseItem.personsByRole)
                }
            }
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.md)
        }
        .background(Color.surfaceLight)
        .navigationTitle("案件详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showNewEventSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.tealLink)
                }
                .accessibilityLabel("添加事件")
            }
        }
        .sheet(isPresented: $showNewEventSheet) {
            EventEditView(defaultCase: caseItem)
        }
    }

}

// MARK: - ContentView 扩展方法

extension ContentView {

    // MARK: - 最近查看

    private func loadRecentItems() {
        guard let data = recentItemsJSON.data(using: .utf8),
              let items = try? JSONDecoder().decode([RecentItem].self, from: data) else { return }
        recentItems = items.sorted(by: { $0.timestamp > $1.timestamp }).prefix(10).map { $0 }
    }

    private func trackRecentItem(type: RecentItem.ItemType, id: String, title: String, subtitle: String) {
        let item = RecentItem(id: id, type: type, title: title, subtitle: subtitle, timestamp: Date())
        var items = recentItems.filter { $0.id != id }
        items.insert(item, at: 0)
        recentItems = Array(items.prefix(10))
        if let data = try? JSONEncoder().encode(recentItems),
           let json = String(data: data, encoding: .utf8) {
            recentItemsJSON = json
        }
    }

    // MARK: - Quick Actions

    private func handleQuickAction(url: URL) {
        guard let host = url.host else { return }
        switch host {
        case "newPerson":
            selectedTab = 1  // 人脉 Tab
            showNewPersonSheet = true
        case "newEvent":
            selectedTab = 2  // 事项 Tab
            showNewEventSheet = true
        case "search":
            // 触发当前 Tab 搜索聚焦
            NotificationCenter.default.post(name: .islandLinkFocusSearch, object: nil)
        default:
            break
        }
    }
}