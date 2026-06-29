import SwiftUI
import CloudKit

enum SyncStatus: Equatable {
    case checking
    case unavailable(reason: String)
    case upToDate(lastSync: Date)
    case error(message: String, lastAttempt: Date)

    var displayText: String {
        switch self {
        case .checking:
            return "检查中..."
        case .unavailable(let reason):
            return reason
        case .upToDate(let lastSync):
            let formatter = RelativeDateTimeFormatter()
            formatter.locale = Locale(identifier: "zh_CN")
            return "已检查 · \(formatter.localizedString(for: lastSync, relativeTo: Date()))"
        case .error(let message, _):
            return message
        }
    }

    var systemImage: String {
        switch self {
        case .checking:
            return "icloud"
        case .unavailable:
            return "icloud.slash"
        case .upToDate:
            return "icloud.fill"
        case .error:
            return "exclamationmark.icloud"
        }
    }

    var indicatorColor: Color {
        switch self {
        case .checking:
            return .textTertiary
        case .unavailable:
            return .statusWarning
        case .upToDate:
            return .statusSuccess
        case .error:
            return .statusError
        }
    }
}

@MainActor
final class CloudSyncObserver: ObservableObject {
    static let shared = CloudSyncObserver()

    @Published var syncStatus: SyncStatus = .checking
    @Published var accountName: String?
    @Published var isCloudAvailable = false

    private init() {
        Task { await checkAccountStatus() }
    }

    func checkAccountStatus() async {
        syncStatus = .checking

        do {
            let container = CKContainer.default()
            let status = try await container.accountStatus()

            switch status {
            case .available:
                isCloudAvailable = true
                accountName = try? await container.userRecordID().recordName
                syncStatus = .upToDate(lastSync: Date())
            case .noAccount:
                isCloudAvailable = false
                accountName = nil
                syncStatus = .unavailable(reason: "未登录 iCloud")
            case .restricted:
                isCloudAvailable = false
                accountName = nil
                syncStatus = .unavailable(reason: "iCloud 访问受限")
            case .couldNotDetermine:
                isCloudAvailable = false
                accountName = nil
                syncStatus = .unavailable(reason: "无法检测 iCloud 状态")
            case .temporarilyUnavailable:
                isCloudAvailable = false
                accountName = nil
                syncStatus = .error(message: "iCloud 暂时不可用", lastAttempt: Date())
            @unknown default:
                isCloudAvailable = false
                accountName = nil
                syncStatus = .unavailable(reason: "iCloud 状态未知")
            }
        } catch {
            isCloudAvailable = false
            accountName = nil
            syncStatus = .error(message: error.localizedDescription, lastAttempt: Date())
        }
    }
}
