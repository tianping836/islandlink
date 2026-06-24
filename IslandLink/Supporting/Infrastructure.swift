import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    private init() {}
    func scheduleReminder(for event: Event) {}
    func cancelReminder(for event: Event) {}
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { cont in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in cont.resume(returning: granted) }
        }
    }
}
