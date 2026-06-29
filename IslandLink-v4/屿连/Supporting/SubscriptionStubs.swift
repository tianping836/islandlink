import SwiftUI

import SwiftData

@MainActor

final class SubscriptionManager: ObservableObject {

static let shared = SubscriptionManager()

static let freePersonLimit = 50

static let freeCaseEventLimit = 50

@Published var isPro = false

@Published var proSource: ProSource?

@Published var purchaseError: String?

@Published var showUpgradeSheet = false

@Published var personCount = 0

@Published var caseEventCount = 0

@Published var invitationDaysRemaining = 0

var canAddPerson: Bool { isPro || personCount < Self.freePersonLimit }

var canAddCaseOrEvent: Bool { isPro || caseEventCount < Self.freeCaseEventLimit }

enum ProSource { case purchased, invitation }

}

struct UpgradeSheet: View {

@Environment(\.dismiss) private var dismiss

var body: some View {

NavigationStack {

VStack(spacing: 20) {

Image(systemName: "crown.fill")

.font(.system(size: 48))

.foregroundColor(.tealLink)

Text("屿连 Pro")

.font(.cnTitle2)

Text("即将上线")

.font(.cnBody)

.foregroundColor(.textSecondary)

}

.toolbar {

ToolbarItem(placement: .topBarTrailing) {

Button { dismiss() } label: {

Image(systemName: "xmark.circle.fill")

.font(.system(size: 24))

.foregroundColor(.textTertiary)

}

}

}

}

}

}

struct RedeemSheet: View {

@Environment(\.dismiss) private var dismiss

@State private var code = ""

var body: some View {

NavigationStack {

VStack(spacing: 20) {

Image(systemName: "gift.fill")

.font(.system(size: 48))

.foregroundColor(.tealLink)

Text("兑换邀请码")

.font(.cnTitle2)

TextField("输入邀请码", text: $code)

.textFieldStyle(.roundedBorder)

.frame(width: 240)

Button("兑换") { dismiss() }

.buttonStyle(.borderedProminent)

.tint(.tealLink)

}

.toolbar {

ToolbarItem(placement: .topBarTrailing) {

Button { dismiss() } label: {

Image(systemName: "xmark.circle.fill")

.font(.system(size: 24))

.foregroundColor(.textTertiary)

}

}

}

}

}

}

struct CodeGeneratorSheet: View {

@Environment(\.dismiss) private var dismiss

var body: some View {

NavigationStack {

List {

Text("邀请码生成器（开发中）")

.font(.cnBody)

.foregroundColor(.textSecondary)

}

.navigationTitle("生成邀请码")

.toolbar {

ToolbarItem(placement: .topBarTrailing) {

Button { dismiss() } label: {

Image(systemName: "xmark.circle.fill")

.font(.system(size: 24))

.foregroundColor(.textTertiary)

}

}

}

}

}

}

struct LimitReachedBanner: View {

enum LimitType { case person, caseOrEvent }

let type: LimitType

var body: some View {

HStack {

Image(systemName: "exclamationmark.triangle.fill")

.foregroundColor(.coralWarm)

Text("已达免费版上限，升级 Pro 解锁更多")

.font(.cnCaption1)

.foregroundColor(.textSecondary)

}

.padding()

.background(Color.surfaceCard)

.clipShape(RoundedRectangle(cornerRadius: CornerRadius.card))

}

}
