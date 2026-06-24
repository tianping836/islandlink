import Foundation
import SwiftUI
import SwiftData
import CoreSpotlight

// MARK: - Handoff 活动类型标识

/// 跨设备 Handoff 活动类型常量
enum HandoffActivityType {
    static let viewPerson  = "com.youmind.islandlink.viewPerson"
    static let viewCase    = "com.youmind.islandlink.viewCase"
    static let viewEvent   = "com.youmind.islandlink.viewEvent"
    static let viewMatters  = "com.youmind.islandlink.viewMatters"
}

// MARK: - Handoff 管理器

/// 跨设备接力（Handoff）管理器
@MainActor
final class HandoffManager {
    static let shared = HandoffManager()

    private init() {}

    // MARK: - 当前活动（防止重复注册）

    private var currentActivity: NSUserActivity?

    /// 释放当前活动
    private func invalidateCurrent() {
        currentActivity?.invalidate()
        currentActivity = nil
    }

    // MARK: - 联系人活动

    func activityForPerson(_ person: Person) -> NSUserActivity {
        invalidateCurrent()

        let activity = NSUserActivity(activityType: HandoffActivityType.viewPerson)
        activity.title = "\(person.name) · 联系人"
        activity.userInfo = [
            "personID": person.id,
            "personName": person.name
        ]
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = true
        activity.isEligibleForPublicIndexing = false
        activity.persistentIdentifier = "person/\(person.id)"
        activity.targetContentIdentifier = "person/\(person.id)"

        if let webURL = URL(string: "https://islandlink.app/person/\(person.id)") {
            activity.webpageURL = webURL
        }

        let attributes = CSSearchableItemAttributeSet(contentType: .contact)
        attributes.displayName = person.name
        attributes.contentDescription = person.roleTypes.map(\.rawValue).joined(separator: "、")
        activity.contentAttributeSet = attributes

        currentActivity = activity
        return activity
    }

    // MARK: - 案件活动

    func activityForCase(_ caseItem: Case) -> NSUserActivity {
        invalidateCurrent()

        let activity = NSUserActivity(activityType: HandoffActivityType.viewCase)
        activity.title = "\(caseItem.name) · 案件"
        activity.userInfo = [
            "caseID": caseItem.id,
            "caseName": caseItem.name
        ]
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = true
        activity.isEligibleForPublicIndexing = false
        activity.persistentIdentifier = "case/\(caseItem.id)"
        activity.targetContentIdentifier = "case/\(caseItem.id)"

        if let webURL = URL(string: "https://islandlink.app/case/\(caseItem.id)") {
            activity.webpageURL = webURL
        }

        let attributes = CSSearchableItemAttributeSet(contentType: .content)
        attributes.displayName = caseItem.name
        attributes.contentDescription = caseItem.caseNumber ?? "案件"
        if let caseNumber = caseItem.caseNumber {
            attributes.keywords = [caseNumber]
        }
        activity.contentAttributeSet = attributes

        currentActivity = activity
        return activity
    }

    // MARK: - 事件活动

    func activityForEvent(_ event: Event) -> NSUserActivity {
        invalidateCurrent()

        let activity = NSUserActivity(activityType: HandoffActivityType.viewEvent)
        activity.title = "\(event.title) · 事件"
        activity.userInfo = [
            "eventID": event.id,
            "eventTitle": event.title
        ]
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = true
        activity.isEligibleForPublicIndexing = false
        activity.persistentIdentifier = "event/\(event.id)"
        activity.targetContentIdentifier = "event/\(event.id)"

        if let webURL = URL(string: "https://islandlink.app/event/\(event.id)") {
            activity.webpageURL = webURL
        }

        let attributes = CSSearchableItemAttributeSet(contentType: .item)
        attributes.displayName = event.title
        attributes.contentDescription = event.eventType.rawValue
        if let date = event.date {
            attributes.startDate = date
        }
        activity.contentAttributeSet = attributes

        currentActivity = activity
        return activity
    }

    // MARK: - Tab 页面活动

    func activityForMatters() -> NSUserActivity {
        invalidateCurrent()

        let activity = NSUserActivity(activityType: HandoffActivityType.viewMatters)
        activity.title = "岛连 · 事项"
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = false
        activity.persistentIdentifier = "tab/matters"
        activity.targetContentIdentifier = "tab/matters"

        if let webURL = URL(string: "https://islandlink.app/matters") {
            activity.webpageURL = webURL
        }

        currentActivity = activity
        return activity
    }

    // MARK: - 恢复导航

    static func resolveActivity(_ userActivity: NSUserActivity) -> NavigationTarget? {
        switch userActivity.activityType {
        case HandoffActivityType.viewPerson:
            guard let personID = userActivity.userInfo?["personID"] as? String else { return nil }
            return .person(id: personID)

        case HandoffActivityType.viewCase:
            guard let caseID = userActivity.userInfo?["caseID"] as? String else { return nil }
            return .caseItem(id: caseID)

        case HandoffActivityType.viewEvent:
            guard let eventID = userActivity.userInfo?["eventID"] as? String else { return nil }
            return .event(id: eventID)

        case HandoffActivityType.viewMatters:
            return .tab(.matters)

        default:
            return nil
        }
    }
}

// MARK: - 导航目标

enum NavigationTarget: Equatable {
    case person(id: String)
    case caseItem(id: String)
    case event(id: String)
    case tab(TabTarget)

    enum TabTarget: Int, Equatable {
        case people = 1
        case matters = 2
        case settings = 3
    }
}

// MARK: - View Extension: Handoff 修饰符

extension View {
    func handoff(_ activity: NSUserActivity?) -> some View {
        Group {
            if let activity = activity {
                self.userActivity(activity.activityType, element: activity) { _, activity in
                    activity.needsSave = true
                }
            } else {
                self
            }
        }
    }
}