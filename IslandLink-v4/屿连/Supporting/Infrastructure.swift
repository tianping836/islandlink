import SwiftUI

import SwiftData

@MainActor

final class NotificationManager: ObservableObject {

static let shared = NotificationManager()

@Published var isAuthorized = false

func requestAuthorization() async -> Bool { true }

func scheduleNotification(for event: Event) {}

}

class SearchService {

let modelContext: ModelContext

init(modelContext: ModelContext) { self.modelContext = modelContext }

func searchPersons(query: String) -> [Person] {

guard !query.isEmpty else { return [] }

let descriptor = FetchDescriptor(predicate: #Predicate { $0.name.localizedStandardContains(query) })

return (try? modelContext.fetch(descriptor)) ?? []

}

}
