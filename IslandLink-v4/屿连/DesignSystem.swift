import SwiftUI

extension Notification.Name {

static let islandLinkFocusSearch = Notification.Name("islandLinkFocusSearch")

}

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

struct PersonTransferData: Codable, Transferable {

let personID: String

let name: String

static var transferRepresentation: some TransferRepresentation {

CodableRepresentation(contentType: .utf8PlainText)

}

}

extension Color {

static let oceanDeep = Color(hex: "0D2137")

static let tealLink = Color(hex: "00897B")

static let coralWarm = Color(hex: "E07B5A")

static let surfaceLight = Color("SurfaceLight")

static let surfaceCard = Color("SurfaceCard")

static let divider = Color("Divider")

static let statusSuccess = Color(hex: "2E7D32")

static let statusWarning = Color(hex: "ED6C02")

static let statusError = Color(hex: "D32F2F")

static let statusInfo = Color(hex: "1565C0")

static let textPrimary = Color("TextPrimary")

static let textSecondary = Color("TextSecondary")

static let textTertiary = Color("TextTertiary")

}

extension Color {

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

extension PersonRoleType {

var swiftUIColor: Color { Color(hex: colorHex) }

var swiftUIBackground: Color { swiftUIColor.opacity(0.12) }

}

extension EventStatus {

var swiftUIColor: Color {

switch self {

case .planned: return .statusInfo

case .confirmed: return .tealLink

case .completed: return .statusSuccess

case .cancelled: return .textTertiary

}

}

var dotColor: Color { swiftUIColor }

var backgroundColor: Color { swiftUIColor.opacity(0.12) }

}

extension EventType {

var swiftUIColor: Color { Color(hex: colorHex) }

var swiftUIBackground: Color { swiftUIColor.opacity(0.12) }

}

extension ActivitySignal {

var displayColor: Color {

switch self {

case .active: return .statusSuccess

case .recent, .inactive: return .textTertiary

}

}

var displayBackground: Color {

switch self {

case .active: return .statusSuccess.opacity(0.12)

case .recent, .inactive: return .textTertiary.opacity(0.08)

}

}

var dotColor: Color {

switch self {

case .active: return .statusSuccess

case .recent, .inactive: return .textTertiary

}

}

}

extension Font {

static let cnLargeTitle = Font.system(size: 34, weight: .bold)

static let cnTitle1 = Font.system(size: 28, weight: .bold)

static let cnTitle2 = Font.system(size: 22, weight: .semibold)

static let cnTitle3 = Font.system(size: 20, weight: .medium)

static let cnHeadline = Font.system(size: 17, weight: .semibold)

static let cnBody = Font.system(size: 17)

static let cnCallout = Font.system(size: 16)

static let cnSubhead = Font.system(size: 15)

static let cnFootnote = Font.system(size: 13)

static let cnCaption1 = Font.system(size: 12)

static let cnCaption2 = Font.system(size: 11, weight: .medium)

static let cnMonoFootnote = Font.system(size: 13).monospacedDigit()

static let cnMonoSubhead = Font.system(size: 15).monospacedDigit()

}

enum Spacing {

static let xs: CGFloat = 4

static let sm: CGFloat = 8

static let md: CGFloat = 12

static let base: CGFloat = 16

static let lg: CGFloat = 20

static let xl: CGFloat = 24

static let xxl: CGFloat = 32

}

enum CornerRadius {

static let card: CGFloat = 16

static let nestedCard: CGFloat = 12

static let button: CGFloat = 12

static let tag: CGFloat = 6

static let searchBar: CGFloat = 12

static let sheet: CGFloat = 24

static let modal: CGFloat = 32

static let capsule: CGFloat = 20

}

extension View {

func cardStyle() -> some View {

self

.background(.regularMaterial)

.clipShape(RoundedRectangle(cornerRadius: CornerRadius.card))

.shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)

}

func cardStyleSolid() -> some View {

self

.background(Color.surfaceCard)

.clipShape(RoundedRectangle(cornerRadius: CornerRadius.card))

.shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 1)

}

func cardShadow() -> some View { cardStyleSolid() }

}

struct EventStatusBadge: View {

let status: EventStatus

var body: some View {

HStack(spacing: Spacing.xs) {

Circle().fill(status.dotColor).frame(width: 6, height: 6)

Text(status.rawValue).font(.cnCaption2).foregroundColor(status.swiftUIColor)

}

.padding(.horizontal, Spacing.sm)

.padding(.vertical, Spacing.xs)

.background(status.backgroundColor)

.clipShape(RoundedRectangle(cornerRadius: CornerRadius.tag))

.accessibilityLabel("事件状态：(status.rawValue)")

}

}

struct RoleTypeTag: View {

let roleType: PersonRoleType

var body: some View {

Label {

Text(roleType.rawValue).font(.cnCaption2)

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

struct EventTypeTag: View {

let eventType: EventType

var body: some View {

HStack(spacing: Spacing.xs) {

Image(systemName: eventType.systemImage)

.font(.system(size: 10, weight: .bold))

Text(eventType.rawValue).font(.cnCaption2)

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

struct AvatarPlaceholder: View {

let roleType: PersonRoleType

var size: CGFloat = 44

var body: some View {

ZStack {

Circle().fill(roleType.swiftUIBackground).frame(width: size, height: size)

Image(systemName: roleType.systemImage)

.font(.system(size: size * 0.45))

.foregroundColor(roleType.swiftUIColor)

}

.accessibilityLabel(roleType.rawValue)

}

}

struct LargeAvatarPlaceholder: View {

let roleType: PersonRoleType

var body: some View {

ZStack {

Circle().fill(roleType.swiftUIBackground).frame(width: 120, height: 120)

Image(systemName: roleType.systemImage)

.font(.system(size: 48))

.foregroundColor(roleType.swiftUIColor)

}

}

}

// MARK: 信任指示器

struct TrustIndicator: View {

let trustLevel: Int

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

struct ActivitySignalView: View {

let signal: ActivitySignal?

var body: some View {

Group {

if let signal = signal {

HStack(spacing: 3) {

if case .active = signal {

Circle().fill(Color.statusSuccess).frame(width: 6, height: 6)

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

// MARK: 案件卡片

struct CaseCard: View {

let caseItem: Case

var body: some View {

VStack(alignment: .leading, spacing: Spacing.sm) {

Text(caseItem.name)

.font(.cnHeadline)

.foregroundColor(.textPrimary)

.lineLimit(2)

if let caseNumber = caseItem.caseNumber {

Text(caseNumber)

.font(.cnMonoFootnote)

.foregroundColor(.textSecondary)

}

let fieldSummaries = caseItem.allFieldLabels.prefix(3).compactMap { label -> String? in

guard let val = caseItem.firstFieldValue(for: label) else { return nil }

return "\(label)：\(val)"

}

if !fieldSummaries.isEmpty {

Text(fieldSummaries.joined(separator: " "))

.font(.cnCaption1)

.foregroundColor(.textTertiary)

.lineLimit(1)

}

HStack(spacing: Spacing.base) {

HStack(spacing: Spacing.xs) {

Image(systemName: "person.2").font(.system(size: 11))

Text("\(caseItem.personCount) 人")

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

struct PersonRow: View {

let person: Person

var showActivity: Bool = true

private var primaryRole: PersonRoleType { person.roleTypes.first ?? .other }

var body: some View {

HStack(spacing: 0) {

TrustIndicator(trustLevel: person.trustLevelRaw)

.padding(.trailing, Spacing.md)

AvatarPlaceholder(roleType: primaryRole, size: 40)

.padding(.trailing, Spacing.md)

VStack(alignment: .leading, spacing: 2) {

Text(person.name)

.font(.cnHeadline)

.foregroundColor(.textPrimary)

HStack(spacing: 4) {

Text(primaryRole.rawValue)

.font(.cnCaption1)

.foregroundColor(primaryRole.swiftUIColor)

if person.relationship != .other {

Text("·").foregroundColor(.textTertiary)

RelationshipTypeTag(relationship: person.relationship)

}

Text("·").foregroundColor(.textTertiary)

Text("\(person.caseCount) 案")

.font(.cnCaption1)

.foregroundColor(.textSecondary)

}

if let firstOrg = person.orgUnits.sorted(by: { $0.sortOrder < $1.sortOrder }).first {

OrgUnitBadge(orgUnit: firstOrg)

}

}

Spacer()

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

.accessibilityLabel("\(person.name)，\(primaryRole.rawValue)，\(person.caseCount) 案\(showActivity && person.activitySignal != nil ? "，" + (person.activitySignal?.label ?? "") : "")")

.accessibilityAddTraits(.isButton)

.onDrag { NSItemProvider(object: person.id as NSString) }

}

}

// MARK: 关系类型标签

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

struct OrgUnitBadge: View {

let orgUnit: OrgUnit

var body: some View {

HStack(spacing: 2) {

Image(systemName: "building.2.fill")

.font(.system(size: 9))

Text(orgUnit.name)

if let dept = orgUnit.department {

Text("·(dept)")

}

}

.font(.cnCaption2)

.foregroundColor(.textTertiary)

.lineLimit(1)

}

}

// MARK: 联系日志行

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

// MARK: 角色分组区

struct RoleGroupSection: View {

let groupedPersons: [(PersonRoleType, [(role: String, persons: [CasePerson])])]

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

private func roleGroupCard(roleType: PersonRoleType, specificGroups: [(role: String, persons: [CasePerson])]) -> some View {

let sectionKey = roleType.rawValue

let isExpanded = expandedSections.contains(sectionKey)

VStack(alignment: .leading, spacing: 0) {

Button {

withAnimation(.easeInOut(duration: 0.25)) {

if isExpanded { expandedSections.remove(sectionKey) }

else { expandedSections.insert(sectionKey) }

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

Text("(specificGroups.flatMap(.persons).count）人")

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

if isExpanded {

VStack(spacing: 0) {

Divider().background(Color.divider)

ForEach(specificGroups, id: .role) { role, persons in

ForEach(persons, id: .id) { cp in

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

struct SearchPersonSheet: View {

@Environment(.dismiss) private var dismiss

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

.listRowInsets(EdgeInsets(top: Spacing.sm, leading: Spacing.base, bottom: Spacing.xs, trailing: Spacing.base))

ForEach(recentPersons.prefix(5), id: .id) { person in

personResultRow(person)

}

}

}

if !searchText.isEmpty {

Section {

ForEach(searchResults, id: .id) { person in

personResultRow(person)

}

Button { dismiss() } label: {

Label {

Text("新建联系人 \(searchText)")

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

Button { selectedPerson = person } label: {

HStack(spacing: Spacing.md) {

if let primaryRole = person.roleTypes.first {

AvatarPlaceholder(roleType: primaryRole, size: 40)

}

VStack(alignment: .leading, spacing: 2) {

Text(person.name)

.font(.cnHeadline)

.foregroundColor(.textPrimary)

if let org = person.orgUnits.first?.name {

Text(person.roleTypes.first.map { "($0.rawValue) · (org)" } ?? org)

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

// MARK: 快捷日期选择器

struct QuickDatePicker: View {

@Binding var date: Date

@Binding var hasDate: Bool

var isAllDay: Bool = true

private let calendar = Calendar.current

private enum QuickOption: String, CaseIterable, Identifiable {

case today = "今天", tomorrow = "明天", nextMonday = "下周一", twoWeeks = "两周后", custom = "自定义"

var id: String { rawValue }

func date(from base: Date, calendar: Calendar) -> Date? {

switch self {

case .today: return base

case .tomorrow: return calendar.date(byAdding: .day, value: 1, to: base)

case .nextMonday:

var comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: base)

comps.weekday = 2; comps.weekOfYear? += 1; return calendar.date(from: comps)

case .twoWeeks: return calendar.date(byAdding: .day, value: 14, to: base)

case .custom: return nil

}

}

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

if showCustomPicker {

DatePicker(

isAllDay ? "选择日期" : "选择日期时间",

selection: $date,

displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]

)

.datePickerStyle(.graphical)

.padding(.top, Spacing.sm)

.onChange(of: date) { _, _ in updateQuickFromDate() }

}

}

.onAppear { if hasDate { updateQuickFromDate() } }

}

private func selectQuickOption(_ option: QuickOption) {

if option == .custom {

selectedQuick = .custom; showCustomPicker = true; hasDate = true

} else if let newDate = option.date(from: Date(), calendar: calendar) {

selectedQuick = option; date = newDate; hasDate = true; showCustomPicker = false

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

selectedQuick = option; showCustomPicker = false; return

}

}

selectedQuick = nil; showCustomPicker = true

}

}

// MARK: 分组标题

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

func sectionHeaderStyle() -> some View { modifier(SectionHeaderStyle()) }

}

// MARK: 列表项入场动画

struct StaggerEntranceModifier: ViewModifier {

let index: Int

let staggerDelay: Double = 0.04

@State private var isVisible = false

func body(content: Content) -> some View {

content

.opacity(isVisible ? 1 : 0)

.offset(y: isVisible ? 0 : 12)

.animation(.easeOut(duration: 0.25).delay(Double(index) * staggerDelay), value: isVisible)

.onAppear { isVisible = true }

}

}

extension View {

func staggerEntrance(index: Int) -> some View { modifier(StaggerEntranceModifier(index: index)) }

}

// MARK: 搜索框聚焦动画

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

struct SyncStatusIndicator: View {

let status: SyncStatus

var showLabel: Bool = true

var body: some View {

HStack(spacing: Spacing.xs) {

Group {

switch status {

case .checking:

ProgressView().scaleEffect(0.7).tint(.textTertiary)

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

.accessibilityLabel("同步状态：(status.displayText)")

}

}

// MARK: 撤销横幅

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

Button("撤销") { onUndo() }

.font(.cnSubhead.weight(.semibold))

.foregroundColor(.tealLink)

Button { onDismiss() } label: {

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

DispatchQueue.main.asyncAfter(deadline: .now() + 4) {

withAnimation(.easeOut(duration: 0.2)) { appear = false }

DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onDismiss() }

}

}

}

}

// MARK: 最近查看行

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

// MARK: 类型化字段编辑器

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

Image(systemName: template.fieldType.systemImage)

.font(.system(size: 14))

.foregroundColor(.textTertiary)

.frame(width: 22)

switch template.fieldType {

case .text:

TextField(template.name, text: $value)

.font(.cnBody)

case .date:

DatePicker("", selection: Binding(get: { dateValue ?? Date() }, set: { dateValue = $0 }), displayedComponents: .date)

.labelsHidden()

.font(.cnBody)

if dateValue != nil {

Button { dateValue = nil } label: {

Image(systemName: "xmark.circle.fill")

.font(.system(size: 14))

.foregroundColor(.textTertiary)

}

}

case .person:

Button { showPersonPicker = true } label: {

HStack {

if personName.isEmpty {

Text("选择（template.name）")

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

PersonFieldPicker(searchText: "", onSelect: { person in

personID = person.persistentModelID

personName = person.name

value = person.name

showPersonPicker = false

})

}

case .select:

if template.options.isEmpty {

TextField(template.name, text: $value)

.font(.cnBody)

} else {

Picker(template.name, selection: Binding(get: { optionIndex ?? 0 }, set: { optionIndex = $0 })) {

Text("未选择").tag(0 as Int?)

.foregroundColor(.textTertiary)

ForEach(Array(template.options.enumerated()), id: .offset) { idx, opt in

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

struct PersonFieldPicker: View {

@Environment(.modelContext) private var modelContext

@Environment(.dismiss) private var dismiss

@State var searchText: String

var onSelect: (Person) -> Void

@State private var results: [Person] = []

var body: some View {

NavigationStack {

VStack {

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

List {

ForEach(results, id: .id) { person in

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

#if DEBUG

enum PreviewSampleData {

@MainActor

static var container: ModelContainer = {

do {

let schema = Schema([

Person.self,

Case.self,

CasePerson.self,

Tag.self,

Event.self,

EventPerson.self,

EventCase.self

])

let config = ModelConfiguration(isStoredInMemoryOnly: true)

let container = try ModelContainer(for: schema, configurations: config)

PreviewData.makeSampleData(modelContext: container.mainContext)

return container

} catch {

fatalError("预览 ModelContainer 创建失败： (error)")

}

}()

}

#endif
