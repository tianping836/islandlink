import SwiftUI
import SwiftData

// MARK: - 键盘快捷键通知

extension Notification.Name {
    /// Cmd+F 键盘快捷键触发搜索聚焦
    static let islandLinkFocusSearch = Notification.Name("islandLinkFocusSearch")
}


// MARK: - 跨平台剪贴板

/// 三端统一的剪贴板操作（iOS / iPad / Mac）
/// Mac (Designed for iPad) 上 UIPasteboard 可用，但为原生 macOS 做准备。
enum Clipboard {
    static func copy(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }
}

// MARK: - iPad 拖拽传输数据

/// Person 拖拽传输数据（用于 iPad 跨窗口拖拽）
struct PersonTransferData: Codable, Transferable {
    let personID: String
    let name: String

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .utf8PlainText)
    }
}

// MARK: - 语义色定义

/// 连接 IslandLink 设计系统 v2 — 语义色
/// 直接用于 Xcode 项目，所有颜色支持深色模式自动切换
extension Color {
    // ── 品牌主色 ──
    /// 深海蓝黑 · 导航栏、主按钮、强调文字
    static let oceanDeep = Color(hex: "0D2137")

    /// 青绿连接色 · 链接、关联指示、选中态
    static let tealLink = Color(hex: "00897B")

    /// 暖调珊瑚 · 重要标记、提醒徽章、收藏
    static let coralWarm = Color(hex: "E07B5A")

    // ── 表面色 ──
    /// 页面背景（浅色 #F7F9FC / 深色 #121820）
    static let surfaceLight = Color("SurfaceLight")

    /// 卡片背景（浅色 #FFFFFF / 深色 #1A2332）
    static let surfaceCard = Color("SurfaceCard")

    /// 分割线（浅色 #E8ECF1 / 深色 #263040）
    static let divider = Color("Divider")

    // ── 功能色 ──
    static let statusSuccess = Color(hex: "2E7D32")   // 已结案、完成
    static let statusWarning = Color(hex: "ED6C02")   // 举证截止、待办提醒
    static let statusError = Color(hex: "D32F2F")     // 删除、错误
    static let statusInfo = Color(hex: "1565C0")      // 一般提示

    // ── 文字色 ──
    static let textPrimary = Color("TextPrimary")       // 浅色 #0D2137 / 深色 #E3ECF4
    static let textSecondary = Color("TextSecondary")   // 浅色 #546E7A / 深色 #B0BEC5
    static let textTertiary = Color("TextTertiary")     // 浅色 #90A4AE / 深色 #78909C
}

// MARK: - Hex 初始化器

extension Color {
    /// 支持 6 位 Hex 字符串（`#RRGGBB` 或 `RRGGBB`）
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - PersonRoleType 颜色映射

extension PersonRoleType {
    /// SwiftUI Color（按设计系统 v2 角色色谱，已降饱和）
    var swiftUIColor: Color {
        Color(hex: colorHex)
    }

    /// 浅色变体（背景用，不透明度 12%）
    var swiftUIBackground: Color {
        swiftUIColor.opacity(0.12)
    }
}

// MARK: - EventStatus 颜色映射

extension EventStatus {
    var swiftUIColor: Color {
        switch self {
        case .planned:    return .statusInfo
        case .confirmed:  return .tealLink
        case .completed:  return .statusSuccess
        case .cancelled:  return .textTertiary
        }
    }

    var dotColor: Color { swiftUIColor }

    var backgroundColor: Color { swiftUIColor.opacity(0.12) }
}

// MARK: - EventType 颜色映射

extension EventType {
    var swiftUIColor: Color {
        Color(hex: colorHex)
    }

    var swiftUIBackground: Color {
        swiftUIColor.opacity(0.12)
    }
}

// MARK: - ActivitySignal 颜色映射

extension ActivitySignal {
    /// 信号显示色
    var displayColor: Color {
        switch self {
        case .active: return .statusSuccess
        case .recent, .inactive: return .textTertiary
        }
    }

    /// 背景浅色
    var displayBackground: Color {
        switch self {
        case .active: return .statusSuccess.opacity(0.12)
        case .recent, .inactive: return .textTertiary.opacity(0.08)
        }
    }

    /// 圆点色（所有状态均显示，不单靠颜色区分）
    var dotColor: Color {
        switch self {
        case .active: return .statusSuccess
        case .recent, .inactive: return .textTertiary
        }
    }
}

// MARK: - 字体扩展

extension Font {
    /// Large Title — 34pt Bold
    static let cnLargeTitle = Font.system(size: 34, weight: .bold)

    /// Title 1 — 28pt Bold
    static let cnTitle1 = Font.system(size: 28, weight: .bold)

    /// Title 2 — 22pt Semibold
    static let cnTitle2 = Font.system(size: 22, weight: .semibold)

    /// Title 3 — 20pt Medium
    static let cnTitle3 = Font.system(size: 20, weight: .medium)

    /// Headline — 17pt Semibold（列表项标题）
    static let cnHeadline = Font.system(size: 17, weight: .semibold)

    /// Body — 17pt Regular
    static let cnBody = Font.system(size: 17)

    /// Callout — 16pt Regular
    static let cnCallout = Font.system(size: 16)

    /// Subhead — 15pt Regular
    static let cnSubhead = Font.system(size: 15)

    /// Footnote — 13pt Regular（案号、辅助信息）
    static let cnFootnote = Font.system(size: 13)

    /// Caption 1 — 12pt Regular
    static let cnCaption1 = Font.system(size: 12)

    /// Caption 2 — 11pt Medium（小标签、徽章）
    static let cnCaption2 = Font.system(size: 11, weight: .medium)

    /// 等宽 Footnote（案号、金额对齐）
    static let cnMonoFootnote = Font.system(size: 13).monospacedDigit()

    /// 等宽 Subhead（金额）
    static let cnMonoSubhead = Font.system(size: 15).monospacedDigit()
}


// MARK: - 间距常量

/// 8pt 网格基础间距
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let base: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}


// MARK: - 圆角常量

enum CornerRadius {
    static let card: CGFloat = 16
    static let nestedCard: CGFloat = 12
    static let button: CGFloat = 12
    static let tag: CGFloat = 6
    static let searchBar: CGFloat = 12
    static let sheet: CGFloat = 24    // 从 20 改为 24
    static let modal: CGFloat = 32    // 新增：大弹窗
    static let capsule: CGFloat = 20  // 新增：胶囊圆角
    static let search: CGFloat = 12   // 搜索栏
}


// MARK: - 阴影 & 卡片样式（Apple 风格）

extension View {
    /// Apple 风格毛玻璃卡片：极浅投影 + material 背景
    func cardStyle() -> some View {
        self
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.card))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    /// Apple 风格纯色卡片：surfaceCard 背景 + 微投影
    func cardStyleSolid() -> some View {
        self
            .background(Color.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.card))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 1)
    }

    /// 旧版兼容别名（逐步迁移到 cardStyleSolid）
    func cardShadow() -> some View {
        cardStyleSolid()
    }
}


// MARK: - ─── 可复用组件 ───


// MARK: 事件状态徽章

/// 事件状态徽章
struct EventStatusBadge: View {
    let status: EventStatus

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Circle()
                .fill(status.dotColor)
                .frame(width: 6, height: 6)
            Text(status.rawValue)
                .font(.cnCaption2)
                .foregroundColor(status.swiftUIColor)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(status.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.tag))
        .accessibilityLabel("事件状态：\(status.rawValue)")
    }
}


// MARK: 角色标签

/// 角色类型胶囊标签（降饱和色）
struct RoleTypeTag: View {
    let roleType: PersonRoleType

    var body: some View {
        Label {
            Text(roleType.rawValue)
                .font(.cnCaption2)
        } icon: {
            Image(systemName: roleType.systemImage)
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(roleType.swiftUIColor)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(roleType.swiftUIBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.tag))
        .accessibilityValue(roleType.rawValue)
    }
}


// MARK: 事件类型标签

/// 事件类型胶囊标签
struct EventTypeTag: View {
    let eventType: EventType

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: eventType.systemImage)
                .font(.system(size: 10, weight: .bold))
            Text(eventType.rawValue)
                .font(.cnCaption2)
        }
        .foregroundColor(eventType.swiftUIColor)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(eventType.swiftUIBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.tag))
        .accessibilityValue(eventType.rawValue)
    }
}


// MARK: 头像占位

/// 圆形头像占位符（无头像时展示角色图标 + 角色色背景）
struct AvatarPlaceholder: View {
    let roleType: PersonRoleType
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(roleType.swiftUIBackground)
                .frame(width: size, height: size)
            Image(systemName: roleType.systemImage)
                .font(.system(size: size * 0.45))
                .foregroundColor(roleType.swiftUIColor)
        }
        .accessibilityLabel(roleType.rawValue)
    }
}

/// 大号头像占位（详情页用）
struct LargeAvatarPlaceholder: View {
    let roleType: PersonRoleType

    var body: some View {
        ZStack {
            Circle()
                .fill(roleType.swiftUIBackground)
                .frame(width: 120, height: 120)
            Image(systemName: roleType.systemImage)
                .font(.system(size: 48))
                .foregroundColor(roleType.swiftUIColor)
        }
    }
}


// MARK: 信任指示器

/// 列表行左侧竖线指示器，替代行内文字标签
/// 绿色 = 信任，蓝色 = 熟悉，无竖线 = 无标记
struct TrustIndicator: View {
    let trustLevel: Int  // 0 = 无, 1 = 熟悉, 2 = 信任

    var body: some View {
        Group {
            if trustLevel > 0 {
                RoundedRectangle(cornerRadius: 2)
                    .fill(trustLevel == 2 ? Color.statusSuccess : Color.statusInfo)
                    .frame(width: 3)
            } else {
                Color.clear.frame(width: 3)
            }
        }
        .accessibilityLabel(trustLevel == 2 ? "信任" : (trustLevel == 1 ? "熟悉" : "一般"))
    }
}


// MARK: 活跃度信号指示器

/// 人脉活跃度信号 — 轻量不催促
/// 绿色小圆点 + 「活跃」表示 30 天内活跃，灰色「N月」表示 30-180 天，「N月+」表示超过 180 天
struct ActivitySignalView: View {
    let signal: ActivitySignal?

    var body: some View {
        Group {
            if let signal = signal {
                HStack(spacing: 3) {
                    if case .active = signal {
                        Circle()
                            .fill(Color.statusSuccess)
                            .frame(width: 6, height: 6)
                    }
                    Text(signal.label)
                        .font(.cnCaption2)
                        .foregroundColor(signal.displayColor)
                }
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, 2)
                .background(signal.displayBackground)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.tag))
            }
        }
    }
}


// MARK: 搜索栏

/// 全局搜索 / 页面搜索栏
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "搜索..."
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(.textTertiary)

            TextField(placeholder, text: $text)
                .font(.cnBody)
                .foregroundColor(.textPrimary)
                .onSubmit { onSubmit?() }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.md)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.searchBar))
    }
}


// MARK: ─── 核心业务组件 ───


// MARK: 案件卡片

/// 案件列表项卡片（极简：名称 + 案号 + 灵活字段摘要 + 参与人数）
struct CaseCard: View {
    let caseItem: Case

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // 案件名称
            Text(caseItem.name)
                .font(.cnHeadline)
                .foregroundColor(.textPrimary)
                .lineLimit(2)

            // 案号
            if let caseNumber = caseItem.caseNumber {
                Text(caseNumber)
                    .font(.cnMonoFootnote)
                    .foregroundColor(.textSecondary)
            }

            // 灵活字段摘要（取前 3 个不重复的 label: value）
            let fieldSummaries = caseItem.allFieldLabels.prefix(3).compactMap { label -> String? in
                guard let val = caseItem.firstFieldValue(for: label) else { return nil }
                return "\(label)：\(val)"
            }
            if !fieldSummaries.isEmpty {
                Text(fieldSummaries.joined(separator: "  "))
                    .font(.cnCaption1)
                    .foregroundColor(.textTertiary)
                    .lineLimit(1)
            }

            // 元信息行
            HStack(spacing: Spacing.base) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "person.2")
                        .font(.system(size: 11))
                    Text("\(caseItem.personCount)人")
                }
                Spacer()
            }
            .font(.cnCaption1)
            .foregroundColor(.textTertiary)
        }
        .padding(Spacing.base)
        .cardStyleSolid()
    }
}


// MARK: 人脉行（Apple 通讯录风格）

/// 人脉列表行 — Apple 通讯录风格：竖线指示器 + 头像 + 名字 + 角色·关系 + 单位 + 活跃度
/// 支持 iPad 拖拽：可将联系人拖入事件编辑页建立参与人关联
struct PersonRow: View {
    let person: Person
    /// 是否显示活跃度信号（列表页显示，详情页可隐藏）
    var showActivity: Bool = true

    private var primaryRole: PersonRoleType {
        person.roleTypes.first ?? .other
    }

    /// 拖拽传输的 Person 标识符
    private var dragItem: some Transferable {
        PersonTransferData(personID: person.uniqueKey, name: person.name)
    }

    var body: some View {
        HStack(spacing: 0) {
            // 信任竖线指示器
            TrustIndicator(trustLevel: person.trustLevelRaw)
                .padding(.trailing, Spacing.md)

            // 头像
            AvatarPlaceholder(roleType: primaryRole, size: 40)
                .padding(.trailing, Spacing.md)

            // 信息区
            VStack(alignment: .leading, spacing: 2) {
                Text(person.name)
                    .font(.cnHeadline)
                    .foregroundColor(.textPrimary)

                HStack(spacing: 4) {
                    Text(primaryRole.rawValue)
                        .font(.cnCaption1)
                        .foregroundColor(primaryRole.swiftUIColor)
                    if person.relationship != .other {
                        Text("·")
                            .foregroundColor(.textTertiary)
                        RelationshipTypeTag(relationship: person.relationship)
                    }
                    Text("·")
                        .foregroundColor(.textTertiary)
                    Text("\(person.caseCount)案")
                        .font(.cnCaption1)
                        .foregroundColor(.textSecondary)
                }

                // 单位摘要（取第一个单位名）
                if let firstOrg = person.orgUnits.sorted(by: { $0.sortOrder < $1.sortOrder }).first {
                    OrgUnitBadge(orgUnit: firstOrg)
                }
            }

            Spacer()

            // 活跃度信号（轻量不催促）
            if showActivity, let signal = person.activitySignal {
                ActivitySignalView(signal: signal)
            }
        }
        .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.base)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.card))
        .cardShadow()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(person.name)，\(primaryRole.rawValue)，\(person.caseCount)案\(showActivity && person.activitySignal != nil ? "，" + (person.activitySignal?.label ?? "") : "")")
        .accessibilityAddTraits(.isButton)
        // iPad 拖拽
        .onDrag {
            NSItemProvider(object: person.uniqueKey as NSString)
        }
    }
}

// MARK: 关系类型标签

/// 关系类型小标签（Apple 通讯录风格）
struct RelationshipTypeTag: View {
    let relationship: RelationshipType

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: relationship.systemImage)
                .font(.system(size: 9))
            Text(relationship.rawValue)
        }
        .font(.cnCaption2)
        .foregroundColor(.textSecondary)
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, 1)
        .background(Color.textTertiary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.tag))
    }
}

// MARK: 单位标签

/// 单位摘要标签
struct OrgUnitBadge: View {
    let orgUnit: OrgUnit

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "building.2.fill")
                .font(.system(size: 9))
            Text(orgUnit.name)
            if let dept = orgUnit.department {
                Text("·\(dept)")
            }
        }
        .font(.cnCaption2)
        .foregroundColor(.textTertiary)
        .lineLimit(1)
    }
}

// MARK: 联系日志行

/// 单条联系日志行
struct ContactLogRow: View {
    let log: ContactLog

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(log.timestamp.formatted(date: .numeric, time: .shortened))
                .font(.cnCaption2)
                .foregroundColor(.textTertiary)
            Text(log.content)
                .font(.cnSubhead)
                .foregroundColor(.textPrimary)
                .lineLimit(3)
        }
        .padding(.vertical, Spacing.xs)
    }
}


// MARK: 角色分组区（核心组件）

/// 参与人按角色大类分组展示区
/// 案件详情和人脉详情共用
struct RoleGroupSection: View {
    let groupedPersons: [(PersonRoleType, [(role: String, persons: [CasePerson])])]

    /// 点击参与人时的回调
    var onPersonTap: ((Person) -> Void)? = nil

    @State private var expandedSections: Set<String> = []

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(groupedPersons, id: \.0.rawValue) { roleType, specificGroups in
                roleGroupCard(roleType: roleType, specificGroups: specificGroups)
            }
        }
    }

    @ViewBuilder
    private func roleGroupCard(
        roleType: PersonRoleType,
        specificGroups: [(role: String, persons: [CasePerson])]
    ) -> some View {
        let sectionKey = roleType.rawValue
        let isExpanded = expandedSections.contains(sectionKey)

        VStack(alignment: .leading, spacing: 0) {
            // 分组标题行（可点击折叠）
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if isExpanded {
                        expandedSections.remove(sectionKey)
                    } else {
                        expandedSections.insert(sectionKey)
                    }
                }
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: roleType.systemImage)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(roleType.swiftUIColor)

                    Text(roleType.rawValue)
                        .font(.cnTitle3)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Text("\(specificGroups.flatMap(\.persons).count)人")
                        .font(.cnSubhead)
                        .foregroundColor(.textTertiary)

                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textTertiary)
                }
                .padding(.horizontal, Spacing.base)
                .padding(.vertical, Spacing.md)
            }
            .buttonStyle(.plain)

            // 展开的参与人列表
            if isExpanded {
                VStack(spacing: 0) {
                    Divider().background(Color.divider)
                    ForEach(specificGroups, id: \.role) { role, persons in
                        ForEach(persons, id: \.id) { cp in
                            if let person = cp.person {
                                personInCaseRow(casePerson: cp, person: person)
                            }
                        }
                    }
                }
            }
        }
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.nestedCard))
        .cardShadow()
    }

    @ViewBuilder
    private func personInCaseRow(casePerson: CasePerson, person: Person) -> some View {
        Button {
            onPersonTap?(person)
        } label: {
            HStack(spacing: Spacing.md) {
                if let primaryRole = person.roleTypes.first {
                    AvatarPlaceholder(roleType: primaryRole, size: 24)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(person.name)
                        .font(.cnHeadline)
                        .foregroundColor(.textPrimary)
                    Text(casePerson.role)
                        .font(.cnCaption1)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                if let org = person.orgUnits.first?.name {
                    Text(org)
                        .font(.cnCaption2)
                        .foregroundColor(.textTertiary)
                        .lineLimit(1)
                        .frame(maxWidth: 100, alignment: .trailing)
                }
            }
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.md)
        }
        .buttonStyle(.plain)
        Divider().background(Color.divider).padding(.leading, Spacing.xxl * 2)
    }
}


// MARK: 搜索补全弹窗

/// 添加参与人搜索弹窗（底部 Sheet）
struct SearchPersonSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var searchResults: [Person] = []
    @State private var selectedPerson: Person?

    var onAdd: ((Person, String, PersonRoleType?) -> Void)?

    var recentPersons: [Person] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(text: $searchText, placeholder: "输入姓名搜索已有联系人...")
                    .padding(.horizontal, Spacing.base)
                    .padding(.top, Spacing.base)

                List {
                    if searchText.isEmpty && !recentPersons.isEmpty {
                        Section {
                            Text("最近添加")
                                .font(.cnCaption1)
                                .foregroundColor(.textTertiary)
                                .textCase(nil)
                                .listRowInsets(EdgeInsets(
                                    top: Spacing.sm, leading: Spacing.base,
                                    bottom: Spacing.xs, trailing: Spacing.base
                                ))

                            ForEach(recentPersons.prefix(5), id: \.id) { person in
                                personResultRow(person)
                            }
                        }
                    }

                    if !searchText.isEmpty {
                        Section {
                            ForEach(searchResults, id: \.id) { person in
                                personResultRow(person)
                            }

                            Button {
                                dismiss()
                            } label: {
                                Label {
                                    Text("新建联系人 \"\(searchText)\"")
                                        .font(.cnHeadline)
                                } icon: {
                                    Image(systemName: "person.badge.plus")
                                }
                                .foregroundColor(.tealLink)
                            }
                            .listRowBackground(Color.surfaceCard)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(Color.surfaceLight)
            .navigationTitle("添加参与人")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onChange(of: searchText) { _, _ in }
    }

    @ViewBuilder
    private func personResultRow(_ person: Person) -> some View {
        Button {
            selectedPerson = person
        } label: {
            HStack(spacing: Spacing.md) {
                if let primaryRole = person.roleTypes.first {
                    AvatarPlaceholder(roleType: primaryRole, size: 40)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(person.name)
                        .font(.cnHeadline)
                        .foregroundColor(.textPrimary)
                    if let org = person.orgUnits.first?.name {
                        Text(person.roleTypes.first.map { "\($0.rawValue) · \(org)" } ?? org)
                            .font(.cnCaption1)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding(.vertical, Spacing.xs)
        }
        .listRowBackground(Color.surfaceCard)
        .listRowSeparatorTint(Color.divider)
    }
}


// MARK: ─── 智能默认值：快捷日期选择器 ───

/// 快捷日期选项按钮组 — 替用户做聪明选择
/// 提供「明天」「下周一」「两周后」等快捷选项 + 「自定义」完整日期选择器
struct QuickDatePicker: View {
    @Binding var date: Date
    @Binding var hasDate: Bool
    var isAllDay: Bool = true

    private let calendar = Calendar.current

    /// 快捷选项定义
    private enum QuickOption: String, CaseIterable, Identifiable {
        case today = "今天"
        case tomorrow = "明天"
        case nextMonday = "下周一"
        case twoWeeks = "两周后"
        case custom = "自定义"

        var id: String { rawValue }

        func date(from base: Date, calendar: Calendar) -> Date? {
            switch self {
            case .today:
                return base
            case .tomorrow:
                return calendar.date(byAdding: .day, value: 1, to: base)
            case .nextMonday:
                var comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: base)
                comps.weekday = 2 // 周一
                comps.weekOfYear? += 1
                return calendar.date(from: comps)
            case .twoWeeks:
                return calendar.date(byAdding: .day, value: 14, to: base)
            case .custom:
                return nil
            }
        }

        /// 选中的快捷选项匹配（允许今天/明天 ±1 天的容差）
        func matches(_ target: Date, calendar: Calendar) -> Bool {
            guard self != .custom else { return false }
            if self == .today { return calendar.isDateInToday(target) }
            if self == .tomorrow { return calendar.isDateInTomorrow(target) }
            guard let candidate = date(from: Date(), calendar: calendar) else { return false }
            return calendar.isDate(candidate, inSameDayAs: target)
        }
    }

    @State private var selectedQuick: QuickOption?
    @State private var showCustomPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // 快捷按钮行
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(QuickOption.allCases) { option in
                        Button {
                            selectQuickOption(option)
                        } label: {
                            Text(option.rawValue)
                                .font(.cnSubhead)
                                .fontWeight(isQuickSelected(option) ? .semibold : .regular)
                                .foregroundColor(isQuickSelected(option) ? .white : .textSecondary)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(isQuickSelected(option) ? Color.tealLink : Color.surfaceCard)
                                )
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(isQuickSelected(option) ? Color.clear : Color.divider, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // 自定义日期选择器
            if showCustomPicker {
                DatePicker(
                    isAllDay ? "选择日期" : "选择日期时间",
                    selection: $date,
                    displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding(.top, Spacing.sm)
                .onChange(of: date) { _, _ in
                    // 用户手动改日期后，检查是否匹配某个快捷选项
                    updateQuickFromDate()
                }
            }
        }
        .onAppear {
            if hasDate { updateQuickFromDate() }
        }
    }

    private func selectQuickOption(_ option: QuickOption) {
        if option == .custom {
            selectedQuick = .custom
            showCustomPicker = true
            hasDate = true
        } else if let newDate = option.date(from: Date(), calendar: calendar) {
            selectedQuick = option
            date = newDate
            hasDate = true
            showCustomPicker = false
        }
    }

    private func isQuickSelected(_ option: QuickOption) -> Bool {
        if option == .custom { return showCustomPicker }
        if !hasDate { return false }
        return option.matches(date, calendar: calendar)
    }

    private func updateQuickFromDate() {
        for option in QuickOption.allCases where option != .custom {
            if option.matches(date, calendar: calendar) {
                selectedQuick = option
                showCustomPicker = false
                return
            }
        }
        selectedQuick = nil
        showCustomPicker = true
    }
}


// MARK: ─── View Modifiers ───


// MARK: 分组标题

/// 页面内分组标题样式
struct SectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.cnTitle3)
            .foregroundColor(.textPrimary)
            .padding(.horizontal, Spacing.base)
            .padding(.top, Spacing.xl)
            .padding(.bottom, Spacing.sm)
    }
}

extension View {
    func sectionHeaderStyle() -> some View {
        modifier(SectionHeaderStyle())
    }
}


// MARK: 列表项入场动画（精调版）

/// Stagger 列表项入场动画（配合 List / ForEach 使用）
/// 参数已按美化方案精调：delay 0.04s, duration 0.25s
struct StaggerEntranceModifier: ViewModifier {
    let index: Int
    let staggerDelay: Double = 0.04

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 12)
            .animation(
                .easeOut(duration: 0.25).delay(Double(index) * staggerDelay),
                value: isVisible
            )
            .onAppear { isVisible = true }
    }
}

extension View {
    func staggerEntrance(index: Int) -> some View {
        modifier(StaggerEntranceModifier(index: index))
    }
}


// MARK: 搜索框聚焦动画

/// 搜索框聚焦时的入场动画修饰器
struct SearchFocusAnimationModifier: ViewModifier {
    let isFocused: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isFocused ? 1 : 0)
            .offset(y: isFocused ? 0 : 8)
            .animation(.easeOut(duration: 0.25), value: isFocused)
    }
}

extension View {
    func searchFocusAnimation(isFocused: Bool) -> some View {
        modifier(SearchFocusAnimationModifier(isFocused: isFocused))
    }
}


// MARK: 同步状态指示器

/// iCloud 同步状态轻量指示器（列表页导航栏 / 设置页用）
/// 三种形态：同步中（旋转）、已同步（勾）、不可用/错误（感叹号）
struct SyncStatusIndicator: View {
    let status: SyncStatus
    var showLabel: Bool = true

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Group {
                switch status {
                case .checking:
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(.textTertiary)
                case .syncing:
                    Image(systemName: "icloud.and.arrow.up")
                        .font(.system(size: 12))
                        .foregroundColor(.textTertiary)
                        .symbolEffect(.pulse, options: .repeating)
                case .upToDate:
                    Image(systemName: "icloud.fill")
                        .font(.system(size: 12))
                        .foregroundColor(status.indicatorColor)
                case .unavailable:
                    Image(systemName: "icloud.slash")
                        .font(.system(size: 12))
                        .foregroundColor(status.indicatorColor)
                case .error:
                    Image(systemName: "exclamationmark.icloud")
                        .font(.system(size: 12))
                        .foregroundColor(status.indicatorColor)
                }
            }

            if showLabel {
                Text(status.displayText)
                    .font(.cnCaption2)
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 3)
        .background(Color.textTertiary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.tag))
        .accessibilityLabel("同步状态：\(status.displayText)")
    }
}


// MARK: 撤销横幅

/// 轻量撤销横幅 —— 删除/编辑操作后出现在列表底部
/// 显示 4 秒后自动消失，或用户手动关闭
struct UndoBanner: View {
    let message: String
    let onUndo: () -> Void
    let onDismiss: () -> Void

    @State private var appear = false

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "arrow.uturn.backward")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.tealLink)

            Text(message)
                .font(.cnCallout)
                .foregroundColor(.textPrimary)

            Spacer()

            Button("撤销") {
                onUndo()
            }
            .font(.cnSubhead.weight(.semibold))
            .foregroundColor(.tealLink)

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.md)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.button))
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
        .padding(.horizontal, Spacing.base)
        .padding(.bottom, Spacing.sm)
        .offset(y: appear ? 0 : 40)
        .opacity(appear ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appear)
        .onAppear {
            appear = true
            // 4 秒后自动消失
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.easeOut(duration: 0.2)) {
                    appear = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}


// MARK: 最近查看行

/// 「最近查看」快捷入口行（显示头像 + 姓名 + 跳转箭头）
struct RecentItemRow: View {
    let systemImage: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.cnBody)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.cnCaption1)
                    .foregroundColor(.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textTertiary)
        }
        .padding(.vertical, Spacing.xs)
    }
}


// MARK: ─── 类型化字段编辑器（飞书多维表格启发） ───

/// 根据 FieldType 切换编辑控件的字段编辑器
/// 文本 → TextField，日期 → DatePicker，人脉 → ContactPicker，选项 → Picker
struct TypedFieldEditor: View {
    let template: FieldTemplate
    @Binding var value: String
    @Binding var dateValue: Date?
    @Binding var personID: PersistentIdentifier?
    @Binding var personName: String
    @Binding var optionIndex: Int?

    @State private var showPersonPicker = false

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // 类型图标
            Image(systemName: template.fieldType.systemImage)
                .font(.system(size: 14))
                .foregroundColor(.textTertiary)
                .frame(width: 22)

            switch template.fieldType {
            case .text:
                TextField(template.name, text: $value)
                    .font(.cnBody)

            case .date:
                DatePicker(
                    "",
                    selection: Binding(
                        get: { dateValue ?? Date() },
                        set: { dateValue = $0 }
                    ),
                    displayedComponents: .date
                )
                .labelsHidden()
                .font(.cnBody)
                if dateValue != nil {
                    Button {
                        dateValue = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.textTertiary)
                    }
                }

            case .person:
                Button {
                    showPersonPicker = true
                } label: {
                    HStack {
                        if personName.isEmpty {
                            Text("选择\(template.name)")
                                .foregroundColor(.textTertiary)
                        } else {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 12))
                                    .foregroundColor(.tealLink)
                                Text(personName)
                                    .foregroundColor(.textPrimary)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.textTertiary)
                    }
                }
                .sheet(isPresented: $showPersonPicker) {
                    PersonFieldPicker(
                        searchText: "",
                        onSelect: { person in
                            personID = person.persistentModelID
                            personName = person.name
                            value = person.name
                            showPersonPicker = false
                        }
                    )
                }

            case .select:
                if template.options.isEmpty {
                    TextField(template.name, text: $value)
                        .font(.cnBody)
                } else {
                    Picker(template.name, selection: Binding(
                        get: { optionIndex ?? 0 },
                        set: { optionIndex = $0 }
                    )) {
                        Text("未选择").tag(0 as Int?)
                            .foregroundColor(.textTertiary)
                        ForEach(Array(template.options.enumerated()), id: \.offset) { idx, opt in
                            Text(opt).tag(idx as Int?)
                        }
                    }
                    .pickerStyle(.menu)
                    .font(.cnBody)
                }
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: 人脉选择器

/// 轻量人脉搜索选择器（Sheet 形式弹出，复用 SearchService）
struct PersonFieldPicker: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State var searchText: String
    var onSelect: (Person) -> Void

    @State private var results: [Person] = []

    var body: some View {
        NavigationStack {
            VStack {
                // 搜索栏
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.textTertiary)
                    TextField("搜索联系人", text: $searchText)
                        .font(.cnBody)
                        .onChange(of: searchText) { _, q in
                            results = SearchService(modelContext: modelContext).searchPersons(query: q)
                        }
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            results = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.textTertiary)
                        }
                    }
                }
                .padding(Spacing.md)
                .background(Color.surfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.search))
                .padding(.horizontal, Spacing.base)
                .padding(.top, Spacing.md)

                // 结果列表
                List {
                    ForEach(results, id: \.id) { person in
                        Button {
                            onSelect(person)
                            dismiss()
                        } label: {
                            HStack(spacing: Spacing.md) {
                                if let primaryRole = person.roleTypes.first {
                                    AvatarPlaceholder(roleType: primaryRole, size: 32)
                                } else {
                                    AvatarPlaceholder(roleType: .other, size: 32)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(person.name)
                                        .font(.cnHeadline)
                                        .foregroundColor(.textPrimary)
                                    if let firstOrg = person.orgUnits.first {
                                        Text(firstOrg.name)
                                            .font(.cnCaption2)
                                            .foregroundColor(.textTertiary)
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.plain)
            }
            .background(Color.surfaceLight)
            .navigationTitle("选择联系人")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}

// MARK: ─── 预设数据（开发预览用） ───

#if DEBUG
/// SwiftUI Preview 示例数据工厂
enum PreviewSampleData {
    /// 创建内存中的 ModelContainer 供预览使用
    @MainActor static var container: ModelContainer = {
        do {
            let schema = Schema([
                Person.self, Case.self, CasePerson.self,
                Tag.self,
                Event.self, EventPerson.self, EventCase.self
            ])
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: config)
            // PreviewData removed in YouMind v4 DataModel
            return container
        } catch {
            fatalError("预览 ModelContainer 创建失败: \(error)")
        }
    }()
}
#endif