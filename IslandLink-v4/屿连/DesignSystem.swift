import SwiftUI

extension Color {
    static let oceanDeep = Color(hex: "0D2137")
    static let tealLink = Color(hex: "00897B")
    static let coralWarm = Color(hex: "E07B5A")
    static let surfaceLight = Color(uiColor: .systemGroupedBackground)
    static let surfaceCard = Color(uiColor: .secondarySystemGroupedBackground)
    static let divider = Color(uiColor: .separator)
    static let statusSuccess = Color(hex: "2E7D32")
    static let statusWarning = Color(hex: "ED6C02")
    static let statusError = Color(hex: "D32F2F")
    static let statusInfo = Color(hex: "1565C0")
    static let textPrimary = Color(uiColor: .label)
    static let textSecondary = Color(uiColor: .secondaryLabel)
    static let textTertiary = Color(uiColor: .tertiaryLabel)

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let red = Double((int >> 16) & 0xFF) / 255
        let green = Double((int >> 8) & 0xFF) / 255
        let blue = Double(int & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

extension Font {
    static let cnLargeTitle = Font.system(size: 34, weight: .bold)
    static let cnTitle1 = Font.system(size: 28, weight: .bold)
    static let cnTitle2 = Font.system(size: 22, weight: .semibold)
    static let cnTitle3 = Font.system(size: 20, weight: .semibold)
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
    static let tag: CGFloat = 8
    static let card: CGFloat = 8
    static let button: CGFloat = 8
    static let searchBar: CGFloat = 8
}

extension PersonRoleType {
    var swiftUIColor: Color { Color(hex: colorHex) }
    var swiftUIBackground: Color { swiftUIColor.opacity(0.12) }
}

extension RelationshipType {
    var swiftUIColor: Color { .tealLink }
}

extension EventType {
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

    var backgroundColor: Color { swiftUIColor.opacity(0.12) }
}

extension View {
    func cardStyleSolid() -> some View {
        background(Color.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.card, style: .continuous))
    }

    func cardStyle() -> some View {
        cardStyleSolid()
    }

    func cardShadow() -> some View {
        shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    func staggerEntrance(index: Int) -> some View {
        self
    }

}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textTertiary)

            TextField(placeholder, text: $text)
                .font(.cnBody)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.md)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.searchBar, style: .continuous))
    }
}

struct EventStatusBadge: View {
    let status: EventStatus

    var body: some View {
        Text(status.rawValue)
            .font(.cnCaption2)
            .foregroundColor(status.swiftUIColor)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(status.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.tag, style: .continuous))
    }
}

struct EventTypeTag: View {
    let eventType: EventType

    var body: some View {
        Label(eventType.rawValue, systemImage: eventType.systemImage)
            .font(.cnCaption2)
            .foregroundColor(eventType.swiftUIColor)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(eventType.swiftUIBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.tag, style: .continuous))
    }
}

struct RoleTypeTag: View {
    let roleType: PersonRoleType

    var body: some View {
        Label(roleType.rawValue, systemImage: roleType.systemImage)
            .font(.cnCaption2)
            .foregroundColor(roleType.swiftUIColor)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(roleType.swiftUIBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.tag, style: .continuous))
    }
}

struct RelationshipTypeTag: View {
    let relationship: RelationshipType

    var body: some View {
        Label(relationship.rawValue, systemImage: relationship.systemImage)
            .font(.cnCaption2)
            .foregroundColor(.tealLink)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(Color.tealLink.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.tag, style: .continuous))
    }
}

struct AvatarPlaceholder: View {
    let roleType: PersonRoleType
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(roleType.swiftUIBackground)
            Image(systemName: roleType.systemImage)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundColor(roleType.swiftUIColor)
        }
        .frame(width: size, height: size)
    }
}

struct LargeAvatarPlaceholder: View {
    let roleType: PersonRoleType

    var body: some View {
        AvatarPlaceholder(roleType: roleType, size: 64)
    }
}

struct PersonRow: View {
    let person: Person

    var body: some View {
        HStack(spacing: Spacing.md) {
            AvatarPlaceholder(roleType: person.roleTypes.first ?? .other, size: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(.cnHeadline)
                    .foregroundColor(.textPrimary)

                Text(subtitle)
                    .font(.cnCaption1)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            if person.importance >= 5 {
                Image(systemName: "star.fill")
                    .foregroundColor(.coralWarm)
            }
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.md)
        .cardStyleSolid()
    }

    private var subtitle: String {
        if let firstOrg = person.orgUnits.first {
            return firstOrg.name
        }
        let roles = person.roleTypes.map(\.rawValue).joined(separator: "、")
        return roles.isEmpty ? "暂无角色" : roles
    }
}

struct UndoBanner: View {
    let message: String
    let onUndo: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(message)
                .font(.cnCallout)
                .foregroundColor(.textPrimary)

            Spacer()

            Button("撤销", action: onUndo)
                .font(.cnSubhead.weight(.semibold))

            Button(action: onDismiss) {
                Image(systemName: "xmark")
            }
            .foregroundColor(.textTertiary)
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.md)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.card, style: .continuous))
        .padding(Spacing.base)
    }
}
