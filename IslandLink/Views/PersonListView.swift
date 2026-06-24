import SwiftUI
import SwiftData
import Combine

/// 人脉列表 — 全量 fetch + Swift filter，无 #Predicate
struct PersonListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\Person.importance, order: .reverse), SortDescriptor(\Person.name)])
    private var allPersons: [Person]

    @State private var searchText = ""
    @State private var selectedRole: PersonRoleType? = nil
    @State private var sortMode: PersonSortMode = .connection
    @State private var starFeedbackTrigger = false
    @Environment(\.isSearching) private var isSearching

    @State private var selectedPersons: Set<String> = []
    @State private var searchFocusToken: AnyCancellable?
    @State private var isSearchFocused = false

    private var filteredPersons: [Person] {
        var result = allPersons.filter { !$0.isArchived }
        if let role = selectedRole {
            result = result.filter { $0.roleTypes.contains(role) }
        }
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = searchText.lowercased()
            result = result.filter {
                $0.name.localizedStandardContains(q) ||
                $0.pinyin.contains(q) ||
                $0.pinyinInitials.contains(q) ||
                $0.orgUnits.contains(where: { $0.name.localizedStandardContains(q) })
            }
        }
        return applySort(result)
    }

    private func applySort(_ persons: [Person]) -> [Person] {
        switch sortMode {
        case .connection:
            return persons.sorted { $0.importance != $1.importance ? $0.importance > $1.importance : $0.name < $1.name }
        case .name:
            return persons.sorted { $0.name < $1.name }
        case .recent:
            return persons.sorted { $0.updatedAt > $1.updatedAt }
        }
    }

    private var importantPersons: [Person] { filteredPersons.filter { $0.importance >= 5 } }
    private var regularPersons: [Person] { filteredPersons.filter { $0.importance < 5 } }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                roleFilterBar
                if filteredPersons.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: Spacing.md) {
                            if !importantPersons.isEmpty { sectionHeader("★ 重要"); personRows(importantPersons) }
                            if !regularPersons.isEmpty { sectionHeader(searchText.isEmpty && selectedRole == nil ? "你的网络" : "匹配结果"); personRows(regularPersons) }
                        }
                        .padding(.horizontal, Spacing.base).padding(.bottom, 100)
                    }
                }
            }
            .background(Color.surfaceLight)
            .navigationTitle("人脉")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onAppear {
                searchFocusToken = NotificationCenter.default.publisher(for: .islandLinkFocusSearch).sink { _ in isSearchFocused = true }
            }
        }
    }

    @ViewBuilder
    private func personRows(_ persons: [Person]) -> some View {
        ForEach(Array(persons.enumerated()), id: \.element.uniqueKey) { _, person in
            NavigationLink { PersonDetailPlaceholderView(person: person) } label: { PersonRow(person: person) }.buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var roleFilterBar: some View {
        if isSearchFocused || !searchText.isEmpty || selectedRole != nil {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    Button { selectedRole = nil } label: {
                        Text("全部").font(.cnCaption1).foregroundColor(selectedRole == nil ? .white : .textSecondary)
                            .padding(.horizontal, Spacing.md).padding(.vertical, Spacing.xs)
                            .background(selectedRole == nil ? Color.tealLink : Color.surfaceCard)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.tag))
                    }
                    ForEach(PersonRoleType.allCases) { role in
                        Button { selectedRole = (selectedRole == role) ? nil : role } label: {
                            HStack(spacing: 4) {
                                Image(systemName: role.systemImage).font(.system(size: 10)); Text(role.rawValue)
                            }
                            .font(.cnCaption1).foregroundColor(selectedRole == role ? .white : .textSecondary)
                            .padding(.horizontal, Spacing.md).padding(.vertical, Spacing.xs)
                            .background(selectedRole == role ? Color(hex: role.colorHex) : Color.surfaceCard)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.tag))
                        }
                    }
                }
                .padding(.horizontal, Spacing.base).padding(.vertical, Spacing.sm)
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title).font(.cnCaption1).foregroundColor(.textTertiary).padding(.top, Spacing.base)
    }

    private var emptyStateView: some View {
        VStack(spacing: Spacing.base) {
            Image(systemName: "person.2.slash").font(.system(size: 40)).foregroundColor(.textTertiary)
            Text("暂无联系人").font(.cnTitle3).foregroundColor(.textSecondary)
        }.padding(.top, 80)
    }
}

enum PersonSortMode: String, CaseIterable {
    case connection = "关联度"; case name = "姓名"; case recent = "最近"
    var label: String { rawValue }
}

struct PersonDetailPlaceholderView: View {
    let person: Person
    var body: some View { Text(person.name).font(.cnTitle1) }
}

struct PersonEditPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Text("新建联系人").font(.cnTitle2)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                }
        }
    }
}
