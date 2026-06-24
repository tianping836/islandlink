import SwiftUI
import SwiftData
import CloudKit
import Combine
import CoreData

// MARK: - 同步状态枚举

/// iCloud 同步的全局状态，驱动设置页和列表页的同步指示器
enum SyncStatus: Equatable {
    case checking
    case unavailable(reason: String)
    case syncing
    case upToDate(lastSync: Date)
    case error(message: String, lastAttempt: Date)

    var displayText: String {
        switch self {
        case .checking:                     return "检查中..."
        case .unavailable(let reason):      return reason
        case .syncing:                      return "同步中..."
        case .upToDate(let lastSync):
            let formatter = RelativeDateTimeFormatter()
            formatter.locale = Locale(identifier: "zh_CN")
            return "已同步 · \(formatter.localizedString(for: lastSync, relativeTo: Date()))"
        case .error(let message, _):        return message
        }
    }

    var systemImage: String {
        switch self {
        case .checking:           return "icloud"
        case .unavailable:        return "icloud.slash"
        case .syncing:            return "icloud.and.arrow.up"
        case .upToDate:           return "icloud.fill"
        case .error:              return "icloud.slash"
        }
    }

    var indicatorColor: Color {
        switch self {
        case .checking, .syncing:  return .textTertiary
        case .unavailable:         return .statusWarning
        case .upToDate:            return .statusSuccess
        case .error:               return .statusError
        }
    }

    var shouldShowLoading: Bool {
        switch self {
        case .checking, .syncing: return true
        default:                  return false
        }
    }
}

// MARK: - iCloud 同步观察器

@MainActor
final class CloudSyncObserver: ObservableObject {
    static let shared = CloudSyncObserver()

    @Published var syncStatus: SyncStatus = .checking
    @Published var accountName: String?
    @Published var isCloudAvailable: Bool = false

    let refreshTrigger = PassthroughSubject<Void, Never>()

    private var eventObserver: NSObjectProtocol?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        Task { await checkAccountStatus() }
        startObservingRemoteChanges()
    }

    // MARK: - 账户检测

    func checkAccountStatus() async {
        syncStatus = .checking
        let container = CKContainer.default()

        do {
            let status = try await container.accountStatus()
            switch status {
            case .available:
                isCloudAvailable = true
                let recordID = try await container.userRecordID()
                accountName = recordID.recordName
                syncStatus = .upToDate(lastSync: Date())
            case .noAccount:
                isCloudAvailable = false
                accountName = nil
                syncStatus = .unavailable(reason: "未登录 iCloud")
            case .restricted:
                isCloudAvailable = false
                accountName = nil
                syncStatus = .unavailable(reason: "iCloud 访问受限（家长控制）")
            case .couldNotDetermine:
                isCloudAvailable = false
                accountName = nil
                syncStatus = .unavailable(reason: "无法检测 iCloud 状态")
            case .temporarilyUnavailable:
                isCloudAvailable = false
                accountName = nil
                syncStatus = .error(message: "iCloud 暂时不可用，稍后重试", lastAttempt: Date())
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

    // MARK: - 远程变更监听

    private func startObservingRemoteChanges() {
        eventObserver = NotificationCenter.default.addObserver(
            forName: NSPersistentCloudKitContainer.eventChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }

            if let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                as? NSPersistentCloudKitContainer.Event {

                switch event.type {
                case .setup:
                    self.syncStatus = .syncing
                case .import:
                    self.syncStatus = .syncing
                case .export:
                    self.syncStatus = .syncing
                @unknown default:
                    break
                }

                if event.endDate != nil {
                    if event.succeeded {
                        self.syncStatus = .upToDate(lastSync: Date())
                    } else if let error = event.error {
                        self.syncStatus = .error(
                            message: self.userFacingMessage(for: error as NSError),
                            lastAttempt: Date()
                        )
                    }
                }
            }
        }

        refreshTrigger
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                Task { await self?.checkAccountStatus() }
            }
            .store(in: &cancellables)
    }

    // MARK: - 错误消息转换

    private func userFacingMessage(for error: NSError) -> String {
        let ckErr = CKError(_nsError: error)

        switch ckErr.code {
        case .networkUnavailable, .networkFailure:
            return "网络不可用，稍后同步"
        case .quotaExceeded:
            return "iCloud 储存空间已满"
        case .serverRejectedRequest:
            return "iCloud 服务暂时拒绝"
        case .notAuthenticated:
            return "iCloud 认证已过期，请重新登录"
        case .requestRateLimited:
            return "同步过于频繁，稍后继续"
        default:
            return "同步出错，稍后重试"
        }
    }

    deinit {
        if let observer = eventObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// MARK: - ViewModifier

struct SyncStatusOverlay: ViewModifier {
    @ObservedObject var syncObserver = CloudSyncObserver.shared

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if syncObserver.syncStatus.shouldShowLoading {
                    VStack(spacing: Spacing.base) {
                        Spacer().frame(height: 80)
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.tealLink)
                        Text("正在同步数据...")
                            .font(.cnCallout)
                            .foregroundColor(.textTertiary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.surfaceLight)
                    .transition(.opacity)
                }
            }
    }
}

extension View {
    func syncAware() -> some View {
        modifier(SyncStatusOverlay())
    }
}