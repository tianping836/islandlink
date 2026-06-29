import Foundation

import SwiftData

// MARK: - 枚举定义

/// 人员角色大类（可多选：一个人可以同时是法官和前律师等）

enum PersonRoleType: String, Codable, CaseIterable, Identifiable {

case judge = "法官"

case prosecutor = "检察官"

case lawyer = "律师"

case party = "当事人"

case police = "公安民警"

case witness = "证人"

case clerk = "书记员"

case expert = "鉴定人"

case other = "其他"

var id: String { rawValue }

var systemImage: String {

switch self {

case .judge: return "hammer.fill"

case .prosecutor: return "building.columns.fill"

case .lawyer: return "briefcase.fill"

case .party: return "person.fill"

case .police: return "shield.fill"

case .witness: return "eye.fill"

case .clerk: return "doc.text.fill"

case .expert: return "flask.fill"

case .other: return "person.crop.circle"

}

}

/// 降饱和后的角色色（Apple 风格，保持色相、降低饱和度 25-30%）

var colorHex: String {

switch self {

case .judge: return "#C0392B"

case .prosecutor: return "#2C6FAC"

case .lawyer: return "#3D7A4B"

case .party: return "#D4744A"

case .police: return "#5B5096"

case .witness: return "#2D7F75"

case .clerk: return "#6B5046"

case .expert: return "#A8456E"

case .other: return "#616161"

}

}

}

/// 关系类型 

enum RelationshipType: String, Codable, CaseIterable, Identifiable {

case colleague = "同事"

case friend = "朋友"

case client = "客户"

case classmate = "同学"

case family = "家人"

case teacher = "老师"

case student = "学生"

case partner = "合作伙伴"

case other = "其他"

var id: String { rawValue }

var systemImage: String {

switch self {

case .colleague: return "building.2.fill"

case .friend: return "heart.fill"

case .client: return "person.fill.checkmark"

case .classmate: return "graduationcap.fill"

case .family: return "house.fill"

case .teacher: return "book.fill"

case .student: return "pencil.fill"

case .partner: return "handshake.fill"

case .other: return "person.crop.circle.fill"

}

}

}

/// 事件类型 

enum EventType: String, Codable, CaseIterable, Identifiable {

case meeting = "会议"

case deadline = "截止日"

case hearing = "开庭"

case filing = "立案/递交"

case research = "调研"

case travel = "出差"

case social = "社交"

case other = "其他"

var id: String { rawValue }

var systemImage: String {

switch self {

case .meeting: return "person.2.fill"

case .deadline: return "clock.badge.exclamationmark"

case .hearing: return "hammer.fill"

case .filing: return "doc.text.fill"

case .research: return "book.fill"

case .travel: return "airplane"

case .social: return "bubble.left.and.bubble.right.fill"

case .other: return "calendar"

}

}

var colorHex: String {

switch self {

case .meeting: return "#2C6FAC"

case .deadline: return "#C0392B"

case .hearing: return "#D4744A"

case .filing: return "#3D7A4B"

case .research: return "#5B5096"

case .travel: return "#2D7F75"

case .social: return "#A8456E"

case .other: return "#616161"

}

}

}

/// 事件状态 

enum EventStatus: String, Codable, CaseIterable, Identifiable {

case planned = "计划中"

case confirmed = "已确认"

case completed = "已完成"

case cancelled = "已取消"

var id: String { rawValue }

}

/// 活跃度信号 

enum ActivitySignal {

case active(daysAgo: Int)

case recent(months: Int)

case inactive(months: Int)

var label: String {

switch self {

case .active(let d): return d <= 0 ? "今天" : "\(d)天"

case .recent(let m): return "\(m)月"

case .inactive(let m): return "\(m)月+"

}

}

}

enum ConnectionEvidenceKind: String, CaseIterable, Identifiable {

case event = "共同事件"

case matter = "共同案件"

case person = "共同联系人"

var id: String { rawValue }

var systemImage: String {

switch self {

case .event: return "calendar.badge.clock"

case .matter: return "folder.fill"

case .person: return "person.2.fill"

}

}

}

struct ConnectionEvidence: Identifiable {

let id: String

let kind: ConnectionEvidenceKind

let title: String

let subtitle: String?

let date: Date?

let strength: Int

}

// MARK: - SwiftData 模型

/// 标签

@Model

final class Tag {

var name: String

var colorHex: String

/// 反向关系：打此标签的人

@Relationship(inverse: \Person.tags)

var persons: [Person] = []

init(name: String, colorHex: String = "#666666") {

self.name = name

self.colorHex = colorHex

}

}

/// 人脉

@Model

final class Person {

// 基本信息 

var name: String

var pinyin: String

var pinyinInitials: String

/// 角色类型（可多选），存为 JSON 字符串数组 

var _roleTypesJSON: String = "[]"

var roleTypes: [PersonRoleType] {

get { Self.decodeJSON(_roleTypesJSON) ?? [] }

set {

if let data = try? JSONEncoder().encode(newValue),

let str = String(data: data, encoding: .utf8) { _roleTypesJSON = str }

}

}

var title: String?

var _relationshipRaw: String = RelationshipType.other.rawValue

var relationship: RelationshipType {

get { RelationshipType(rawValue: _relationshipRaw) ?? .other }

set { _relationshipRaw = newValue.rawValue }

}

var referrer: String?

// 联系方式 

var phone: String?

var phone2: String?

var email: String?

var wechat: String?

var address: String?

// 备注 

var notes: String?

var importance: Int = 3

// 头像

@Attribute(.externalStorage)

var avatarData: Data?

var trustLevelRaw: Int = 0

// 关联

@Relationship(deleteRule: .nullify)

var tags: [Tag] = []

@Relationship(deleteRule: .cascade, inverse: \CasePerson.person)

var casePersons: [CasePerson] = []

@Relationship(deleteRule: .cascade, inverse: \EventPerson.person)

var eventPersons: [EventPerson] = []

@Relationship(deleteRule: .cascade, inverse: \OrgUnit.person)

var orgUnits: [OrgUnit] = []

@Relationship(deleteRule: .cascade, inverse: \ContactLog.person)

var contactLogs: [ContactLog] = []

// 元数据 

var isArchived: Bool = false

var createdAt: Date = Date()

var updatedAt: Date = Date()

// MARK: 唯一约束 

var uniqueKey: String {

[name].compactMap { $0 }.joined(separator: "|")

}

init(

name: String,

roleTypes: [PersonRoleType] = [],

title: String? = nil,

phone: String? = nil,

email: String? = nil,

wechat: String? = nil,

notes: String? = nil,

importance: Int = 3

) {

self.name = name

self.pinyin = name.toPinyin()

self.pinyinInitials = name.toPinyinInitials()

self._roleTypesJSON = ""

defer { self.roleTypes = roleTypes }

self.title = title

self.phone = phone

self.email = email

self.wechat = wechat

self.notes = notes

self.importance = importance

}

// MARK: - 查询辅助

var casesByRole: [(PersonRoleType, [CasePerson])] {

let grouped = Dictionary(grouping: casePersons) { $0.roleCategory }

return PersonRoleType.allCases.compactMap { roleType in

guard let items = grouped[roleType], !items.isEmpty else { return nil }

return (roleType, items.sorted { $0.sortOrder < $1.sortOrder })

}

}

var caseCount: Int { casePersons.count }

var cases: [Case] {
var seen = Set<PersistentIdentifier>()
return casePersons.compactMap { $0.`case` }.filter { seen.insert($0.persistentModelID).inserted }
}

var eventCount: Int { eventPersons.count }

var events: [Event] {
var seen = Set<PersistentIdentifier>()
return eventPersons.compactMap { $0.event }.filter { seen.insert($0.persistentModelID).inserted }
}

// MARK: - 连接信号

var lastActiveDate: Date? {

var candidates: [Date] = []

for cp in casePersons {

if let c = cp.`case` { candidates.append(c.updatedAt) }

}

for ep in eventPersons {

if let e = ep.event, let date = e.date { candidates.append(date) }

}

return candidates.max()

}

var activitySignal: ActivitySignal? {

guard let lastDate = lastActiveDate else { return nil }

let days = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0

if days <= 30 { return .active(daysAgo: days) }

let months = Calendar.current.dateComponents([.month], from: lastDate, to: Date()).month ?? 1

let m = max(months, 1)

return days <= 180 ? .recent(months: m) : .inactive(months: m)

}

func sharedCases(with other: Person) -> [Case] {

let myCaseIDs = Set(casePersons.compactMap { $0.`case`?.persistentModelID })

return other.cases.filter { myCaseIDs.contains($0.persistentModelID) }

}

func sharedEvents(with other: Person) -> [Event] {

let myEventIDs = Set(eventPersons.compactMap { $0.event?.persistentModelID })

return other.events.filter { myEventIDs.contains($0.persistentModelID) }

}

func connectionEvidence(with other: Person) -> [ConnectionEvidence] {
let eventEvidence = sharedEvents(with: other).map { event in
ConnectionEvidence(
id: "event-\(event.persistentModelID)",
kind: .event,
title: event.title,
subtitle: event.location ?? event.summary,
date: event.date,
strength: event.eventType == .social ? 2 : 3
)
}

let caseEvidence = sharedCases(with: other).map { item in
ConnectionEvidence(
id: "case-\(item.persistentModelID)",
kind: .matter,
title: item.name,
subtitle: item.caseNumber,
date: item.updatedAt,
strength: 2
)
}

return (eventEvidence + caseEvidence).sorted {
if $0.strength != $1.strength { return $0.strength > $1.strength }
return ($0.date ?? .distantPast) > ($1.date ?? .distantPast)
}
}

func mutualConnectionIDs(with other: Person) -> Set<PersistentIdentifier> {
let myCasePeople = casePersons.flatMap { $0.`case`?.allPersons ?? [] }
let myEventPeople = eventPersons.flatMap { $0.event?.participants ?? [] }
let otherCasePeople = other.casePersons.flatMap { $0.`case`?.allPersons ?? [] }
let otherEventPeople = other.eventPersons.flatMap { $0.event?.participants ?? [] }
let myConnected = Set((myCasePeople + myEventPeople).map(\.persistentModelID))
let otherConnected = Set((otherCasePeople + otherEventPeople).map(\.persistentModelID))
return myConnected
.intersection(otherConnected)
.subtracting([persistentModelID, other.persistentModelID])
}

static func decodeJSON<T: Decodable>(_ json: String) -> T? {

guard let data = json.data(using: .utf8) else { return nil }

return try? JSONDecoder().decode(T.self, from: data)

}

}

/// 单位

@Model

final class OrgUnit {

var name: String

var department: String?

var person: Person?

var sortOrder: Int = 0

init(name: String, department: String? = nil, sortOrder: Int = 0) {

self.name = name

self.department = department

self.sortOrder = sortOrder

}

}

/// 联系日志

@Model

final class ContactLog {

var timestamp: Date = Date()

var content: String

var person: Person?

var sortOrder: Int = 0

init(timestamp: Date = Date(), content: String, sortOrder: Int = 0) {

self.timestamp = timestamp

self.content = content

self.sortOrder = sortOrder

}

}

/// 案件（极简：名称 + 案号 + 自由字段 + 人脉关联）

@Model

final class Case {

var name: String

var caseNumber: String?

var notes: String?

var entrustmentDate: Date?

@Relationship(deleteRule: .cascade, inverse: \CaseFieldValue.`case`)

var customFields: [CaseFieldValue] = []

@Relationship(deleteRule: .cascade, inverse: \CasePerson.`case`)

var casePersons: [CasePerson] = []

@Relationship(deleteRule: .cascade, inverse: \EventCase.`case`)

var eventCases: [EventCase] = []

var isArchived: Bool = false

var createdAt: Date = Date()

var updatedAt: Date = Date()

init(name: String, caseNumber: String? = nil, notes: String? = nil, entrustmentDate: Date? = nil) {

self.name = name

self.caseNumber = caseNumber

self.notes = notes

self.entrustmentDate = entrustmentDate

}

func fieldValues(for label: String) -> [String] {

customFields

.filter { $0.label == label }

.sorted { $0.sortOrder < $1.sortOrder }

.map { $0.value }

}

func firstFieldValue(for label: String) -> String? {

customFields

.filter { $0.label == label }

.min { $0.sortOrder < $1.sortOrder }?.value

}

var allFieldLabels: [String] {

Array(Set(customFields.map { $0.label })).sorted()

}

var personCount: Int { casePersons.count }

var allPersons: [Person] { casePersons.compactMap { $0.person } }

var personsByRole: [(PersonRoleType, [(role: String, persons: [CasePerson])])] {

let grouped = Dictionary(grouping: casePersons) { $0.roleCategory }

return PersonRoleType.allCases.compactMap { roleType in

guard let items = grouped[roleType], !items.isEmpty else { return nil }

let bySpecificRole = Dictionary(grouping: items) { $0.role }

.sorted { $0.key < $1.key }

.map { (role: $0.key, persons: $0.value.sorted { $0.sortOrder < $1.sortOrder }) }

return (roleType, bySpecificRole)

}

}

func persons(of roleType: PersonRoleType) -> [Person] {

casePersons.filter { $0.roleCategory == roleType }.compactMap { $0.person }

}

}

// MARK: - 灵活字段系统

enum FieldType: String, Codable, CaseIterable, Identifiable {

case text = "文本"

case date = "日期"

case person = "人脉"

case select = "选项"

var id: String { rawValue }

}

@Model

final class FieldTemplate {

@Attribute(.unique)

var name: String

var _fieldTypeRaw: String = FieldType.text.rawValue

var fieldType: FieldType {

get { FieldType(rawValue: _fieldTypeRaw) ?? .text }

set { _fieldTypeRaw = newValue.rawValue }

}

var _optionsJSON: String = "[]"

var options: [String] {

get { Self.decodeJSON(_optionsJSON) ?? [] }

set {

if let data = try? JSONEncoder().encode(newValue),

let str = String(data: data, encoding: .utf8) { _optionsJSON = str }

}

}

var usageCount: Int = 1

var sortOrder: Int = 0

var createdAt: Date = Date()

init(name: String, fieldType: FieldType = .text, options: [String] = [], sortOrder: Int = 0) {

self.name = name

self._fieldTypeRaw = fieldType.rawValue

self.sortOrder = sortOrder

self._optionsJSON = ""

defer { self.options = options }

}

static func decodeJSON<T: Decodable>(_ json: String) -> T? {

guard let data = json.data(using: .utf8) else { return nil }

return try? JSONDecoder().decode(T.self, from: data)

}

}

@Model final class CaseFieldValue {

var label: String

var value: String

var sortOrder: Int = 0

var dateValue: Date?

var _personIDData: Data?

var optionIndex: Int?

var `case`: Case?

init(label: String, value: String, sortOrder: Int = 0) {

self.label = label

self.value = value

self.sortOrder = sortOrder

}

}

/// 案件-人脉关联枢纽

@Model final class CasePerson {

var role: String

var _roleCategoryRaw: String?

var roleCategory: PersonRoleType? {

get {

guard let raw = _roleCategoryRaw else { return nil }

return PersonRoleType(rawValue: raw)

}

set { _roleCategoryRaw = newValue?.rawValue }

}

var note: String?

var sortOrder: Int = 0

var joinedAt: Date? = Date()

var person: Person?

var `case`: Case?

init(person: Person? = nil, case: Case? = nil, role: String, roleCategory: PersonRoleType? = nil, note: String? = nil, sortOrder: Int = 0) {

self.person = person

self.`case` = `case`

self.role = role

self.roleCategory = roleCategory

self.note = note

self.sortOrder = sortOrder

}

}

/// 事件

@Model final class Event {

var title: String

var date: Date?

var endDate: Date?

var isAllDay: Bool = false

var location: String?

var summary: String?

var _eventTypeRaw: String = EventType.other.rawValue

var eventType: EventType {

get { EventType(rawValue: _eventTypeRaw) ?? .other }

set { _eventTypeRaw = newValue.rawValue }

}

var _statusRaw: String = EventStatus.planned.rawValue

var status: EventStatus {

get { EventStatus(rawValue: _statusRaw) ?? .planned }

set { _statusRaw = newValue.rawValue }

}

@Relationship(deleteRule: .cascade, inverse: \EventPerson.event)

var eventPersons: [EventPerson] = []

@Relationship(deleteRule: .cascade, inverse: \EventCase.event)

var eventCases: [EventCase] = []

var isArchived: Bool = false

var createdAt: Date = Date()

var updatedAt: Date = Date()

init(title: String, date: Date? = nil, eventType: EventType = .other) {

self.title = title

self.date = date

self._eventTypeRaw = eventType.rawValue

}

var participants: [Person] { eventPersons.compactMap { $0.person } }

var associatedCases: [Case] { eventCases.compactMap { $0.`case` } }

}

/// 事件-人关联

@Model final class EventPerson {

var role: String?

var sortOrder: Int = 0

var person: Person?

var event: Event?

init(person: Person? = nil, event: Event? = nil, role: String? = nil, sortOrder: Int = 0) {

self.person = person

self.event = event

self.role = role

self.sortOrder = sortOrder

}

}

/// 事件-案件关联

@Model final class EventCase {

var sortOrder: Int = 0

var event: Event?

var `case`: Case?

init(event: Event? = nil, case: Case? = nil, sortOrder: Int = 0) {

self.event = event

self.`case` = `case`

self.sortOrder = sortOrder

}

}

// MARK: - 拼音扩展

extension String {

func toPinyin() -> String {

let mutable = NSMutableString(string: self)

CFStringTransform(mutable, nil, kCFStringTransformToLatin, false)

CFStringTransform(mutable, nil, kCFStringTransformStripDiacritics, false)

return mutable as String

}

func toPinyinInitials() -> String {

toPinyin()

.split(separator: " ")

.compactMap { $0.first?.uppercased() }

.joined()

}

}
