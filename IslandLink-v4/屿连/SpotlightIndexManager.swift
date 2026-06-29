import SwiftData

@MainActor
final class SpotlightIndexManager {
    static let shared = SpotlightIndexManager()

    private init() {}

    func rebuildAllIndices(modelContext: ModelContext) async {
        // Spotlight is intentionally deferred until the core relationship loop is stable.
        _ = modelContext
    }
}
