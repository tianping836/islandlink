import SwiftUI
import SwiftData
import CloudKit
import CoreSpotlight
import WidgetKit

// MARK: - App 入口

/// 屿连 IslandLink — 律师人脉优先管理
///
/// 架构：
/// - SwiftUI 声明式 UI
/// - SwiftData 本地持久化 + CloudKit 多设备同步
/// - 3 Tab：人脉 / 事项（案件+事件）/ 设置
/// - 支持 iPhone / iPad / Mac (Designed for iPad)
@main
struct IslandLinkApp: App {

    // MARK: 全局状态

    @StateObject private var subManager = SubscriptionManager.shared
    @StateObject private var appLockManager = AppLockManager()
    @AppStorage("appAppearance") private var appAppearanceRaw: String = AppAppearance.system.rawValue
    @AppStorage("appLockEnabled") private var appLockEnabled: Bool = false
    @AppStorage("lockTimeout") private var lockTimeout: Int = 60

    @Environment(\.scenePhase) private var scenePhase

    // MARK: ModelContainer

    /// 共享 ModelContainer，使用 App Group 目录以支持 Widget 数据共享
    let modelContainer: ModelContainer

    init() {
        do {
            // 优先使用 App Group 共享目录（Widget 可访问）
            let sharedDirectory = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: "group.com.youmind.islandlink")
            let storeURL: URL
            if let sharedDir = sharedDirectory {
                storeURL = sharedDir.appendingPathComponent("IslandLink.sqlite")
            } else {
                // 回退到默认 Application Support 目录
                let supportDir = FileManager.default.urls(
                    for: .applicationSupportDirectory, in: .userDomainMask
                ).first!
                storeURL = supportDir.appendingPathComponent("default.store")
            }

            let config = ModelConfiguration(url: storeURL)

            // Schema 包含全部数据模型
            modelContainer = try ModelContainer(
                for:
                    Person.self,
                    OrgUnit.self,
                    ContactLog.self,
                    Case.self,
                    CasePerson.self,
                    FieldTemplate.self,
                    CaseFieldValue.self,
                    Tag.self,
                    Event.self,
                    EventPerson.self,
                    EventCase.self,
                    RedeemCode.self,
                configurations: config
            )
        } catch {
            fatalError("ModelContainer 初始化失败: \(error.localizedDescription)")
        }
    }

    // MARK: Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .environmentObject(subManager)
                .environmentObject(appLockManager)
                .preferredColorScheme(colorScheme)
                .onAppear {
                    Task.detached {
                        await SpotlightIndexManager.shared.rebuildAllIndices(
                            modelContext: modelContainer.mainContext
                        )
                    }
                }
                .onContinueUserActivity(CSSearchableItemActionType) { userActivity in
                    // Spotlight 搜索结果 → 导航到对应详情页
                    handleSpotlightNavigation(userActivity)
                }
                .onContinueUserActivity(HandoffActivityType.viewPerson) { userActivity in
                    handleHandoffNavigation(userActivity)
                }
                .onContinueUserActivity(HandoffActivityType.viewCase) { userActivity in
                    handleHandoffNavigation(userActivity)
                }
                .onContinueUserActivity(HandoffActivityType.viewEvent) { userActivity in
                    handleHandoffNavigation(userActivity)
                }
                .onContinueUserActivity(HandoffActivityType.viewMatters) { userActivity in
                    handleHandoffNavigation(userActivity)
                }
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .background:
                appLockManager.didEnterBackground()
                // 触发 Widget 时间线刷新
                WidgetCenter.shared.reloadAllTimelines()
            case .active:
                appLockManager.didBecomeActive()
            default:
                break
            }
        }
        .modelContainer(modelContainer)
    }

    // MARK: - 深色模式

    private var colorScheme: ColorScheme? {
        guard let appearance = AppAppearance(rawValue: appAppearanceRaw) else { return nil }
        switch appearance {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    // MARK: - Deep Link 处理

    /// 处理 `islandlink://` URL Scheme
    private func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host else { return }

        switch host {
        case "new-event":
            NotificationCenter.default.post(
                name: .islandLinkDeepLinkNewEvent, object: nil
            )
        case "new-person":
            NotificationCenter.default.post(
                name: .islandLinkDeepLinkNewPerson, object: nil
            )
        case "new-case":
            NotificationCenter.default.post(
                name: .islandLinkDeepLinkNewCase, object: nil
            )
        default:
            break
        }
    }

    // MARK: - Spotlight 导航

    private func handleSpotlightNavigation(_ userActivity: NSUserActivity) {
        guard let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
            return
        }

        let parts = identifier.split(separator: ".", maxSplits: 1)
        guard parts.count == 2 else { return }

        let type = String(parts[0])
        let id = String(parts[1])

        switch type {
        case "person":
            NotificationCenter.default.post(
                name: .islandLinkNavigateToPerson,
                object: nil,
                userInfo: ["personID": id]
            )
        case "case":
            NotificationCenter.default.post(
                name: .islandLinkNavigateToCase,
                object: nil,
                userInfo: ["caseID": id]
            )
        case "event":
            NotificationCenter.default.post(
                name: .islandLinkNavigateToEvent,
                object: nil,
                userInfo: ["eventID": id]
            )
        default:
            break
        }
    }

    // MARK: - Handoff 导航

    private func handleHandoffNavigation(_ userActivity: NSUserActivity) {
        guard let target = HandoffManager.resolveActivity(userActivity) else { return }

        switch target {
        case .person(let id):
            NotificationCenter.default.post(
                name: .islandLinkNavigateToPerson,
                object: nil,
                userInfo: ["personID": id]
            )
        case .caseItem(let id):
            NotificationCenter.default.post(
                name: .islandLinkNavigateToCase,
                object: nil,
                userInfo: ["caseID": id]
            )
        case .event(let id):
            NotificationCenter.default.post(
                name: .islandLinkNavigateToEvent,
                object: nil,
                userInfo: ["eventID": id]
            )
        case .tab(let tab):
            NotificationCenter.default.post(
                name: .islandLinkNavigateToTab,
                object: nil,
                userInfo: ["tab": tab.rawValue]
            )
        }
    }
}

// MARK: - 全局通知名称

extension Notification.Name {
    static let islandLinkDeepLinkNewEvent = Notification.Name("islandLinkDeepLinkNewEvent")
    static let islandLinkDeepLinkNewPerson = Notification.Name("islandLinkDeepLinkNewPerson")
    static let islandLinkDeepLinkNewCase = Notification.Name("islandLinkDeepLinkNewCase")
    static let islandLinkNavigateToPerson = Notification.Name("islandLinkNavigateToPerson")
    static let islandLinkNavigateToCase = Notification.Name("islandLinkNavigateToCase")
    static let islandLinkNavigateToEvent = Notification.Name("islandLinkNavigateToEvent")
    static let islandLinkNavigateToTab = Notification.Name("islandLinkNavigateToTab")
}

// MARK: - AppLockManager 占位

/// 应用锁管理器（简版，完整实现在独立文件中）
final class AppLockManager: ObservableObject {
    @Published var isLocked: Bool = false
    private var backgroundTime: Date?

    func didEnterBackground() {
        backgroundTime = Date()
    }

    func didBecomeActive() {
        guard let bgTime = backgroundTime else { return }
        _ = bgTime
        backgroundTime = nil
    }
}

// MARK: - AppAppearance 枚举（编译隔离）
// 注：完整定义在 SettingsView.swift 中，此处提供编译所需的最小声明

enum AppAppearance: String, CaseIterable {
    case system = "跟随系统"
    case light  = "浅色"
    case dark   = "深色"

    var systemImage: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }
}