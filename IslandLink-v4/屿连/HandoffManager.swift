import Foundation

import SwiftUI

import SwiftData

enum HandoffActivityType {

static let viewPerson = "com.youmind.islandlink.viewPerson"

static let viewCase = "com.youmind.islandlink.viewCase"

static let viewEvent = "com.youmind.islandlink.viewEvent"

static let viewMatters = "com.youmind.islandlink.viewMatters"

}

@MainActor

final class HandoffManager {

static let shared = HandoffManager()

private var currentActivity: NSUserActivity?

func activityForPerson(_ person: Person) -> NSUserActivity {

let activity = NSUserActivity(activityType: HandoffActivityType.viewPerson)

activity.title = person.name

activity.userInfo = ["personID": person.id]

activity.isEligibleForHandoff = true

activity.isEligibleForSearch = true

return activity

}

func activityForCase(_ caseItem: Case) -> NSUserActivity {

let activity = NSUserActivity(activityType: HandoffActivityType.viewCase)

activity.title = caseItem.name

activity.userInfo = ["caseID": caseItem.id]

activity.isEligibleForHandoff = true

return activity

}

func activityForEvent(_ event: Event) -> NSUserActivity {

let activity = NSUserActivity(activityType: HandoffActivityType.viewEvent)

activity.title = event.title

activity.userInfo = ["eventID": event.id]

activity.isEligibleForHandoff = true

return activity

}

static func resolveActivity(_ userActivity: NSUserActivity) -> NavigationTarget? {

switch userActivity.activityType {

case HandoffActivityType.viewPerson:

guard let id = userActivity.userInfo?["personID"] as? String else { return nil }

return .person(id: id)

case HandoffActivityType.viewCase:

guard let id = userActivity.userInfo?["caseID"] as? String else { return nil }

return .caseItem(id: id)

case HandoffActivityType.viewEvent:

guard let id = userActivity.userInfo?["eventID"] as? String else { return nil }

return .event(id: id)

case HandoffActivityType.viewMatters:

return .tab(.matters)

default:

return nil

}

}

}

enum NavigationTarget: Equatable {

case person(id: String)

case caseItem(id: String)

case event(id: String)

case tab(TabTarget)

enum TabTarget: Int, Equatable { case people = 1, matters = 2, settings = 3 }

}

extension View {

func handoff(_ activity: NSUserActivity?) -> some View {

self.userActivity(activity?.activityType ?? "", element: activity) { _, _ in }

}

}
