import CoreSpotlight
import MobileCoreServices
import SwiftUI
import SwiftData

// MARK: - ─── Spotlight 系统搜索集成 ───

/// Spotlight 索引管理器（单例，主线程安全）
@MainActor
final class SpotlightIndexManager {
    static let shared = SpotlightIndexManager()

    private init() {}

    // MARK: - 索引联系人

    func indexPerson(_ person: Person) {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .contact)
        attributeSet.displayName = person.name
        if let title = person.title {
            attributeSet.title = title
        }

        var phoneNumbers: [String] = []
        if let phone = person.phone { phoneNumbers.append(phone) }
        if let phone2 = person.phone2 { phoneNumbers.append(phone2) }
        if !phoneNumbers.isEmpty {
            attributeSet.phoneNumbers = phoneNumbers
        }

        if let email = person.email {
            attributeSet.emailAddresses = [email]
        }

        var keywords: [String] = [person.name]
        if let firstOrg = person.orgUnits.first { keywords.append(firstOrg.name) }
        keywords.append(contentsOf: person.roleTypes.map(\.rawValue))
        attributeSet.keywords = keywords

        var desc = "律师联系人 · \(person.roleTypes.map(\.rawValue).joined(separator: "、"))"
        if let firstOrg = person.orgUnits.first {
            desc = "\(person.roleTypes.map(\.rawValue).joined(separator: "、")) · \(firstOrg.name)"
        }
        attributeSet.contentDescription = desc

        attributeSet.thumbnailData = roleColorThumbnail(for: person.roleTypes.first ?? .other)

        let identifier = "person.\(person.id)"

        let item = CSSearchableItem(
            uniqueIdentifier: identifier,
            domainIdentifier: "com.youmind.islandlink.person",
            attributeSet: attributeSet
        )
        item.expirationDate = nil

        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error {
                print("[SpotlightIndexManager] 索引联系人失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 索引案件

    func indexCase(_ caseItem: Case) {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
        attributeSet.displayName = caseItem.name
        attributeSet.title = caseItem.name

        if let caseNumber = caseItem.caseNumber {
            attributeSet.contentDescription = caseNumber
        }

        var keywords: [String] = [caseItem.name]
        if let caseNumber = caseItem.caseNumber { keywords.append(caseNumber) }
        keywords.append(contentsOf: caseItem.customFields.map { $0.value })
        attributeSet.keywords = keywords

        attributeSet.thumbnailData = genericCaseThumbnail()

        let identifier = "case.\(caseItem.id)"

        let item = CSSearchableItem(
            uniqueIdentifier: identifier,
            domainIdentifier: "com.youmind.islandlink.case",
            attributeSet: attributeSet
        )
        item.expirationDate = nil

        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error {
                print("[SpotlightIndexManager] 索引案件失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 索引事件

    func indexEvent(_ event: Event) {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .item)
        attributeSet.displayName = event.title
        attributeSet.title = event.title

        var descParts: [String] = [event.eventType.rawValue]
        if let date = event.date {
            descParts.append(date.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
        }
        if let location = event.location, !location.isEmpty {
            descParts.append(location)
        }
        attributeSet.contentDescription = descParts.joined(separator: " · ")

        var keywords: [String] = [event.title, event.eventType.rawValue]
        if let location = event.location { keywords.append(location) }
        if let summary = event.summary { keywords.append(summary) }
        attributeSet.keywords = keywords

        attributeSet.startDate = event.date

        let identifier = "event.\(event.id)"

        let item = CSSearchableItem(
            uniqueIdentifier: identifier,
            domainIdentifier: "com.youmind.islandlink.event",
            attributeSet: attributeSet
        )
        item.expirationDate = event.date?.addingTimeInterval(7 * 24 * 3600)

        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error {
                print("[SpotlightIndexManager] 索引事件失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 移除索引

    func removePerson(_ person: Person) {
        let identifier = "person.\(person.id)"
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [identifier]) { error in
            if let error {
                print("[SpotlightIndexManager] 移除联系人索引失败: \(error.localizedDescription)")
            }
        }
    }

    func removeCase(_ caseItem: Case) {
        let identifier = "case.\(caseItem.id)"
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [identifier]) { error in
            if let error {
                print("[SpotlightIndexManager] 移除案件索引失败: \(error.localizedDescription)")
            }
        }
    }

    func removeEvent(_ event: Event) {
        let identifier = "event.\(event.id)"
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [identifier]) { error in
            if let error {
                print("[SpotlightIndexManager] 移除事件索引失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 全量重建索引

    func rebuildAllIndices(modelContext: ModelContext) {
        let domains: [String] = [
            "com.youmind.islandlink.person",
            "com.youmind.islandlink.case",
            "com.youmind.islandlink.event"
        ]
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: domains) { error in
            if let error {
                print("[SpotlightIndexManager] 清空索引失败: \(error.localizedDescription)")
            }
        }

        let personDescriptor = FetchDescriptor<Person>(sortBy: [SortDescriptor(\.name)])
        if let persons = try? modelContext.fetch(personDescriptor) {
            for person in persons { indexPerson(person) }
        }

        let caseDescriptor = FetchDescriptor<Case>(sortBy: [SortDescriptor(\.name)])
        if let cases = try? modelContext.fetch(caseDescriptor) {
            for caseItem in cases { indexCase(caseItem) }
        }

        let eventDescriptor = FetchDescriptor<Event>(
            sortBy: [SortDescriptor(\.date)]
        )
        if let events = try? modelContext.fetch(eventDescriptor) {
            for event in events { indexEvent(event) }
        }

        print("[SpotlightIndexManager] 全量 Spotlight 索引重建完成。")
    }

    // MARK: - 缩略图生成

    private func roleColorThumbnail(for role: PersonRoleType) -> Data? {
        #if os(macOS)
        return nil
        #else
        let size = CGSize(width: 80, height: 80)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let color: UIColor
            switch role {
            case .judge:      color = UIColor(red: 0.753, green: 0.224, blue: 0.169, alpha: 1)
            case .prosecutor: color = UIColor(red: 0.173, green: 0.435, blue: 0.675, alpha: 1)
            case .lawyer:     color = UIColor(red: 0.239, green: 0.478, blue: 0.294, alpha: 1)
            case .party:      color = UIColor(red: 0.831, green: 0.455, blue: 0.290, alpha: 1)
            case .police:     color = UIColor(red: 0.357, green: 0.314, blue: 0.588, alpha: 1)
            case .witness:    color = UIColor(red: 0.176, green: 0.498, blue: 0.459, alpha: 1)
            case .clerk:      color = UIColor(red: 0.420, green: 0.314, blue: 0.275, alpha: 1)
            case .expert:     color = UIColor(red: 0.659, green: 0.271, blue: 0.431, alpha: 1)
            case .other:      color = UIColor(red: 0.380, green: 0.380, blue: 0.380, alpha: 1)
            }
            ctx.cgContext.setFillColor(color.cgColor)
            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        return image.pngData()
        #endif
    }

    private func genericCaseThumbnail() -> Data? {
        #if os(macOS)
        return nil
        #else
        let size = CGSize(width: 80, height: 80)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let color = UIColor(red: 0.086, green: 0.396, blue: 0.753, alpha: 1)
            ctx.cgContext.setFillColor(color.cgColor)
            let roundedPath = UIBezierPath(
                roundedRect: CGRect(origin: .zero, size: size),
                cornerRadius: 16
            ).cgPath
            ctx.cgContext.addPath(roundedPath)
            ctx.cgContext.fillPath()
        }
        return image.pngData()
        #endif
    }
}

// MARK: - ─── CSIndexExtensionRequestHandler ───

import CoreSpotlight

final class IslandLinkSpotlightHandler: CSIndexExtensionRequestHandler {
    override func searchableIndex(
        _ searchableIndex: CSSearchableIndex,
        reindexAllSearchableItemsWithAcknowledgementHandler acknowledgementHandler: @escaping () -> Void
    ) {
        print("[IslandLinkSpotlightHandler] 系统请求重建 Spotlight 索引")
        acknowledgementHandler()
    }

    override func searchableIndex(
        _ searchableIndex: CSSearchableIndex,
        reindexSearchableItemsWithIdentifiers identifiers: [String],
        acknowledgementHandler: @escaping () -> Void
    ) {
        print("[IslandLinkSpotlightHandler] 系统请求重建部分索引：\(identifiers)")
        acknowledgementHandler()
    }
}