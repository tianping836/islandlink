import SwiftUI
import SwiftData
import Combine

/// 事件列表页 — 「事项」Tab 的事件子页
/// 搜索栏 + 类型筛选胶囊 + 即将到来/已完成分组
struct EventListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Event.date, order: .forward)
    private var allEvents: [Event]

    @State private var searchText = ""
    @State private var selectedType: EventType? = nil
    @State private var completionFeedbackTrigger = false
    @Environment(\.isSearching) private var isSearching

    // 撤销
    @State private var undoEvent: Event?
    @State private var showUndoBanner = false
    @State private var searchFocusToken: AnyCancellable?
    @State private var isSearchFocused = false
    @ObservedObject private var focusFilter = FocusFilterObserver()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Focus Filter 指示器
                FocusFilterIndicator(filterObserver: focusFilter)
                    .padding(.top, Spacing.sm)

                // 事件类型筛选胶囊（搜索时展示）
                if isSearching || selectedType != nil {
                    typeFilterBar
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // 事件列表
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        // 即将到来
                        if !upcomingEvents.isEmpty {
                            sectionHeader("即将到来")

                            ForEach(Array(upcomingEvents.enumerated()), id: \.element.id) { index, event in
                                NavigationLink {
                                    EventDetailView(event: event)
                                } label: {
                                    EventCard(event: event)
                                }
                                .buttonStyle(.plain)
                                .staggerEntrance(index: index)
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            toggleEventCompletion(event)
                                        }
                                    } label: {
                                        Label("标记完成", systemImage: "checkmark.circle")
                                    }
                                    .tint(.tealLink)

                                    Button(role: .destructive) {
                                        deleteEvent(event)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                    .tint(.statusError)
                                }
                                .contextMenu {
                                    ShareLink(
                                        item: eventShareText(event),
                                        subject: Text(event.title)
                                    ) {
                                        Label("分享事件", systemImage: "square.and.arrow.up")
                                    }

                                    Divider()

                                    Button {
                                            Clipboard.copy(event.title)
                                    } label: {
                                        Label("复制标题", systemImage: "doc.on.doc")
                                    }
                                    NavigationLink {
                                        EventEditView(existingEvent: event)
                                    } label: {
                                        Label("编辑", systemImage: "pencil")
                                    }
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            toggleEventCompletion(event)
                                        }
                                    } label: {
                                        Label("取消完成", systemImage: "arrow.uturn.backward")
                                    }
                                }
                                #if os(iOS)
                                .sensoryFeedback(.success, trigger: completionFeedbackTrigger)
                                #endif
                            }
                        }

                        // 空状态
                        if filteredEvents.isEmpty {
                            emptyStateView
                        }
                    }
                    .padding(.horizontal, Spacing.base)
                    .padding(.vertical, Spacing.md)
                }
                .background(Color.surfaceLight)
            }
            .background(Color.surfaceLight)
            .syncAware()
            .refreshable {
                await refreshSync()
            }
            .navigationTitle("事项")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        EventEditView()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.tealLink)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if showUndoBanner, let event = undoEvent {
                    UndoBanner(
                        message: "已删除「\(event.title)」",
                        onUndo: { performUndo() },
                        onDismiss: { undoEvent = nil; showUndoBanner = false }
                    )
                }
            }
        }
        .onAppear {
            // 监听 Cmd+F 键盘快捷键，聚焦搜索栏
            searchFocusToken = NotificationCenter.default.publisher(for: .islandLinkFocusSearch)
                .sink { _ in
                    isSearchFocused = true
                }
        }
        .onDisappear {
            if let token = searchFocusToken {
                NotificationCenter.default.removeObserver(token)
            }
        }
    }

    // MARK: - 类型筛选栏

    @ViewBuilder
    private var typeFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                // 全部按钮
                typeFilterChip(
                    label: "全部",
                    systemImage: "tray.full",
                    color: .oceanDeep,
                    isSelected: selectedType == nil
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedType = nil
                    }
                }

                ForEach(EventType.allCases) { eventType in
                    typeFilterChip(
                        label: eventType.rawValue,
                        systemImage: eventType.systemImage,
                        color: eventType.swiftUIColor,
                        isSelected: selectedType == eventType
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedType = (selectedType == eventType) ? nil : eventType
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.sm)
        }
    }

    private func typeFilterChip(
        label: String,
        systemImage: String,
        color: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .medium))
                Text(label)
                    .font(.cnCaption1)
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? color : color.opacity(0.12))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 分组标题

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.cnTitle3)
                .foregroundColor(.textPrimary)
            Spacer()
            Text("\(title == "即将到来" ? upcomingEvents.count : pastEvents.count)")
                .font(.cnSubhead)
                .foregroundColor(.textTertiary)
        }
        .padding(.top, Spacing.lg)
    }

    // MARK: - 空状态

    @ViewBuilder
    private var emptyStateView: some View {
        if searchText.isEmpty && selectedType == nil {
            ContentUnavailableView {
                Label("还没有事件", systemImage: "calendar.badge.plus")
            } description: {
                Text("记录一次互动，从这里开始。")
            } actions: {
                NavigationLink {
                    EventEditView()
                } label: {
                    Text("添加事件")
                }
            }
        } else {
            ContentUnavailableView.search
        }
    }

    // MARK: - 数据过滤

    private var filteredEvents: [Event] {
        var result = allEvents

        // 类型筛选
        if let type = selectedType {
            result = result.filter { $0.eventType == type }
        }

        // 搜索过滤
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = searchText.lowercased()
            result = result.filter {
                $0.title.localizedStandardContains(q) ||
                ($0.location?.localizedStandardContains(q) ?? false) ||
                ($0.summary?.localizedStandardContains(q) ?? false) ||
                $0.participants.contains { $0.name.localizedStandardContains(q) }
            }
        }

        // Focus Filter：专注模式下进一步过滤
        result = focusFilter.filterEvents(result)

        return result
    }

    private var upcomingEvents: [Event] {
        filteredEvents
            .filter { $0.status.isActive }
    }

    private var pastEvents: [Event] {
        filteredEvents
            .filter { !$0.status.isActive }
    }

    // MARK: - 快捷操作

    private func toggleEventCompletion(_ event: Event) {
        if event.status == .completed {
            event.status = .planned
        } else {
            event.status = .completed
        }
        completionFeedbackTrigger.toggle()
    }

    private func deleteEvent(_ event: Event) {
        // 保存一份引用用于撤销
        undoEvent = event

        // 取消关联通知
        NotificationManager.shared.cancelReminder(for: event)
        // 删除关联枢纽
        event.eventPersons.forEach { modelContext.delete($0) }
        event.eventCases.forEach { modelContext.delete($0) }
        modelContext.delete(event)
        try? modelContext.save()

        showUndoBanner = true
    }

    private func performUndo() {
        guard let event = undoEvent else { return }

        // 重新创建事件
        let restored = Event(
            title: event.title,
            eventType: event.eventType,
            status: event.status,
            date: event.date
        )
        restored.location = event.location
        restored.summary = event.summary
        restored.status = event.status

        // 恢复参与人和案件关联
        for ep in event.eventPersons {
            if let person = ep.person {
                let newEP = EventPerson(person: person, event: restored, role: ep.role)
                modelContext.insert(newEP)
                restored.eventPersons.append(newEP)
            }
        }
        for ec in event.eventCases {
            if let c = ec.case {
                let newEC = EventCase(event: restored, case: c)
                modelContext.insert(newEC)
                restored.eventCases.append(newEC)
            }
        }

        modelContext.insert(restored)
        try? modelContext.save()

        // 重新注册通知
        NotificationManager.shared.scheduleReminder(for: restored)

        undoEvent = nil
        showUndoBanner = false
    }

    private func refreshSync() async {
        CloudSyncObserver.shared.refreshTrigger.send()
        try? await Task.sleep(nanoseconds: 500_000_000)
    }

    // MARK: - 分享事件

    /// 生成可分享的事件文本，供 ShareLink 使用
    private func eventShareText(_ event: Event) -> String {
        var parts: [String] = ["📅 \(event.title)"]
        parts.append("类型：\(event.eventType.rawValue)")
        if let date = event.date {
            parts.append("时间：\(date.formatted(.dateTime.year().month(.abbreviated).day().hour().minute()))")
        }
        if let location = event.location, !location.isEmpty {
            parts.append("地点：\(location)")
        }
        if let summary = event.summary, !summary.isEmpty {
            parts.append("备注：\(summary)")
        }
        return parts.joined(separator: "\n")
    }
}