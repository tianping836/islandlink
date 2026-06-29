import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("caseModuleEnabled") private var caseModuleEnabled = true
    @SceneStorage("selectedTab") private var selectedTab = 0

    @State private var mattersSegment: MattersSegment = .events
    @State private var showNewEventSheet = false

    enum MattersSegment: String, CaseIterable, Identifiable {
        case events = "事件"
        case cases = "事项"

        var id: String { rawValue }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            PersonListView()
                .tabItem {
                    Label("人脉", systemImage: "person.2.fill")
                }
                .tag(0)

            mattersTab
                .tabItem {
                    Label("事项", systemImage: "list.bullet.rectangle.fill")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(.tealLink)
        .onAppear {
            Task {
                _ = await NotificationManager.shared.requestAuthorization()
            }
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
        .sheet(isPresented: $showNewEventSheet) {
            EventEditView()
        }
    }

    private var mattersTab: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("事项类型", selection: $mattersSegment) {
                    ForEach(MattersSegment.allCases) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.base)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)

                Group {
                    switch mattersSegment {
                    case .events:
                        EventListView()
                    case .cases:
                        if caseModuleEnabled {
                            CaseListView()
                        } else {
                            EmptyMattersView()
                        }
                    }
                }
            }
            .background(Color.surfaceLight)
            .navigationTitle("事项")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewEventSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel("新建事件")
                }
            }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "islandlink" else { return }

        switch url.host {
        case "new-event":
            selectedTab = 1
            mattersSegment = .events
            showNewEventSheet = true
        case "matters":
            selectedTab = 1
        default:
            break
        }
    }
}

private struct EmptyMattersView: View {
    var body: some View {
        ContentUnavailableView(
            "事项板块已隐藏",
            systemImage: "eye.slash",
            description: Text("设置中可以重新打开。事项只作为连接证据来源。")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CaseListView: View {
    @Query(sort: \Case.updatedAt, order: .reverse) private var allCases: [Case]

    private var activeCases: [Case] {
        allCases.filter { !$0.isArchived }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                if activeCases.isEmpty {
                    ContentUnavailableView(
                        "还没有事项",
                        systemImage: "folder",
                        description: Text("事项先保持轻量，用来承载真实连接证据。")
                    )
                    .padding(.top, Spacing.xxl)
                } else {
                    ForEach(activeCases, id: \.id) { caseItem in
                        NavigationLink {
                            CaseDetailPlaceholderView(caseItem: caseItem)
                        } label: {
                            CaseSummaryCard(caseItem: caseItem)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(Spacing.base)
        }
        .background(Color.surfaceLight)
    }
}

private struct CaseSummaryCard: View {
    let caseItem: Case

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.tealLink)
                Text(caseItem.name)
                    .font(.cnHeadline)
                    .foregroundColor(.textPrimary)
                Spacer()
            }

            if let caseNumber = caseItem.caseNumber {
                Text(caseNumber)
                    .font(.cnCaption1)
                    .foregroundColor(.textTertiary)
            }

            Text("作为连接证据来源，而不是复杂案件管理。")
                .font(.cnCaption1)
                .foregroundColor(.textSecondary)
        }
        .padding(Spacing.base)
        .cardStyleSolid()
    }
}

private struct CaseDetailPlaceholderView: View {
    let caseItem: Case

    var body: some View {
        List {
            Section("事项") {
                Text(caseItem.name)
                if let caseNumber = caseItem.caseNumber {
                    Text(caseNumber)
                        .foregroundColor(.textSecondary)
                }
            }

            Section("产品边界") {
                Text("这里先展示事项摘要。后续只补充能支持人脉连接判断的字段。")
                    .foregroundColor(.textSecondary)
            }
        }
        .navigationTitle("事项详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
