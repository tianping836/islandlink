import SwiftUI

import SwiftData

/// 事件列表页 — 「事项」Tab 的事件子页

/// 搜索栏 + 类型筛选胶囊 + 即将到来/已完成分组 

struct EventListView: View {

@Environment(.modelContext) private var modelContext

@Query(sort: \Event.date, order: .forward) private var allEvents: [Event]

@State private var searchText = ""

@State private var selectedType: EventType? = nil

@State private var completionFeedbackTrigger = false

@Environment(.isSearching) private var isSearching

@State private var undoEvent: Event?

@State private var showUndoBanner = false

var body: some View {

NavigationStack {

VStack(spacing: 0) {

if isSearching || selectedType != nil {

typeFilterBar

.transition(.move(edge: .top).combined(with: .opacity))

}

ScrollView {

LazyVStack(spacing: Spacing.md) {

if !upcomingEvents.isEmpty {

Text("即将到来")

.font(.cnTitle3)

.foregroundColor(.textPrimary)

.frame(maxWidth: .infinity, alignment: .leading)

.padding(.top, Spacing.sm)

ForEach(Array(upcomingEvents.enumerated()), id: .element.id) { index, event in

NavigationLink {

EventDetailView(event: event)

} label: {

EventCard(event: event)

}

.buttonStyle(.plain)

.staggerEntrance(index: index)

.swipeActions(edge: .trailing) {

Button {

withAnimation { toggleEventCompletion(event) }

} label: {

Label("标记完成", systemImage: "checkmark.circle")

}

.tint(.tealLink)

Button(role: .destructive) {

deleteEvent(event)

} label: {

Label("删除", systemImage: "trash")

}

}

}

}

if !pastEvents.isEmpty {

Text("已完成")

.font(.cnTitle3)

.foregroundColor(.textPrimary)

.frame(maxWidth: .infinity, alignment: .leading)

.padding(.top, Spacing.md)

ForEach(Array(pastEvents.enumerated()), id: .element.id) { index, event in

NavigationLink {

EventDetailView(event: event)

} label: {

EventCard(event: event)

}

.buttonStyle(.plain)

.opacity(0.7)

}

}

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

.refreshable { await refreshSync() }

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

message: "已删除「(event.title)」",

onUndo: { performUndo() },

onDismiss: { undoEvent = nil; showUndoBanner = false }

)

}

}

}

}

private var typeFilterBar: some View {

ScrollView(.horizontal, showsIndicators: false) {

HStack(spacing: Spacing.sm) {

FilterChip(label: "全部", isSelected: selectedType == nil) {

selectedType = nil

}

ForEach(EventType.allCases, id: .self) { type in

FilterChip(label: type.rawValue, isSelected: selectedType == type) {

selectedType = (selectedType == type) ? nil : type

}

}

}

.padding(.horizontal, Spacing.base)

.padding(.vertical, Spacing.sm)

}

}

struct FilterChip: View {

let label: String

let isSelected: Bool

let action: () -> Void

var body: some View {

Button(action: action) {

Text(label)

.font(.cnCaption1)

.foregroundColor(isSelected ? .white : .textSecondary)

.padding(.horizontal, Spacing.md)

.padding(.vertical, Spacing.sm)

.background(

Capsule().fill(isSelected ? Color.tealLink : Color.surfaceCard)

)

}

}

}

private var filteredEvents: [Event] {

var result = allEvents

if let type = selectedType {

result = result.filter { $0.eventType == type }

}

if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {

let q = searchText.lowercased()

result = result.filter {

$0.title.localizedStandardContains(q)

|| ($0.location?.localizedStandardContains(q) ?? false)

|| ($0.summary?.localizedStandardContains(q) ?? false)

|| $0.participants.contains { $0.name.localizedStandardContains(q) }

}

}

return result

}

private var upcomingEvents: [Event] {

filteredEvents.filter { $0.status != .completed && $0.status != .cancelled }

}

private var pastEvents: [Event] {

filteredEvents.filter { $0.status == .completed || $0.status == .cancelled }

}

private func toggleEventCompletion(_ event: Event) {

if event.status == .completed {

event.status = .planned

} else {

event.status = .completed

}

completionFeedbackTrigger.toggle()

}

private func deleteEvent(_ event: Event) {

undoEvent = event

NotificationManager.shared.cancelReminder(for: event)

event.eventPersons.forEach { modelContext.delete($0) }

event.eventCases.forEach { modelContext.delete($0) }

modelContext.delete(event)

try? modelContext.save()

showUndoBanner = true

}

private func performUndo() {

guard let event = undoEvent else { return }

let restored = Event(title: event.title, date: event.date, eventType: event.eventType)

restored.status = event.status

restored.location = event.location

restored.summary = event.summary

for ep in event.eventPersons {

if let person = ep.person {

let newEP = EventPerson(person: person, event: restored, role: ep.role)

modelContext.insert(newEP)

}

}

for ec in event.eventCases {

if let c = ec.`case` {

let newEC = EventCase(event: restored, case: c)

modelContext.insert(newEC)

}

}

modelContext.insert(restored)

try? modelContext.save()

NotificationManager.shared.scheduleReminder(for: restored)

undoEvent = nil

showUndoBanner = false

}

private var emptyStateView: some View {

VStack(spacing: Spacing.base) {

Spacer().frame(height: 60)

Image(systemName: "calendar.badge.plus")

.font(.system(size: 48))

.foregroundColor(.tealLink.opacity(0.4))

Text("暂无事项")

.font(.cnHeadline)

.foregroundColor(.textPrimary)

Text("点击右上角 + 添加第一个事件")

.font(.cnBody)

.foregroundColor(.textSecondary)

}

}

}
