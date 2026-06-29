import SwiftUI

struct SettingsView: View {
    @ObservedObject private var syncObserver = CloudSyncObserver.shared
    @AppStorage("appAppearance") private var appAppearanceRaw = AppAppearance.system.rawValue
    @AppStorage("caseModuleEnabled") private var caseModuleEnabled = true

    var body: some View {
        NavigationStack {
            List {
                productSection
                syncSection
                focusSection
                appearanceSection
                privacySection
                aboutSection
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.surfaceLight)
            .navigationTitle("设置")
        }
    }

    private var productSection: some View {
        Section {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Label("看见人脉中的真实路径", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                    .font(.cnHeadline)
                    .foregroundColor(.textPrimary)

                Text("屿连聚焦专业关系导航：你们之间、连接证据、共同经历和人脉网络。")
                    .font(.cnCallout)
                    .foregroundColor(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, Spacing.xs)
        } header: {
            Text("产品方向")
        }
    }

    private var syncSection: some View {
        Section {
            HStack(spacing: Spacing.md) {
                Image(systemName: syncObserver.syncStatus.systemImage)
                    .font(.system(size: 20))
                    .foregroundColor(syncObserver.syncStatus.indicatorColor)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(syncObserver.isCloudAvailable ? "iCloud 可用" : "本机优先")
                        .font(.cnBody)
                        .foregroundColor(.textPrimary)
                    Text(syncObserver.syncStatus.displayText)
                        .font(.cnCaption1)
                        .foregroundColor(.textTertiary)
                }

                Spacer()
            }
            .padding(.vertical, Spacing.xs)

            Button {
                Task { await syncObserver.checkAccountStatus() }
            } label: {
                Label("重新检查同步状态", systemImage: "arrow.clockwise")
                    .font(.cnBody)
            }
            .foregroundColor(.tealLink)
        } header: {
            Text("同步")
        } footer: {
            Text("业务数据应优先保留在设备和用户自己的 iCloud 账户内。")
        }
    }

    private var focusSection: some View {
        Section {
            Toggle(isOn: $caseModuleEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("显示事项板块")
                        .font(.cnBody)
                        .foregroundColor(.textPrimary)
                    Text("事项只作为关系证据来源，不扩展成复杂案件管理。")
                        .font(.cnCaption1)
                        .foregroundColor(.textTertiary)
                }
            }
            .tint(.tealLink)
        } header: {
            Text("范围控制")
        }
    }

    private var appearanceSection: some View {
        Section {
            Picker("外观", selection: $appAppearanceRaw) {
                ForEach(AppAppearance.allCases, id: \.rawValue) { appearance in
                    Label(appearance.rawValue, systemImage: appearance.systemImage)
                        .tag(appearance.rawValue)
                }
            }
        } header: {
            Text("外观")
        }
    }

    private var privacySection: some View {
        Section {
            Label("本地优先", systemImage: "lock.shield.fill")
            Label("不上传业务关系数据", systemImage: "eye.slash.fill")
            Label("证据来自真实事件和共同经历", systemImage: "checkmark.seal.fill")
        } header: {
            Text("隐私与信任")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("版本")
                Spacer()
                Text(appVersion)
                    .foregroundColor(.textTertiary)
            }

            HStack {
                Text("开发准则")
                Spacer()
                Text("第一性原理 / 对抗式审查")
                    .foregroundColor(.textTertiary)
            }
        } header: {
            Text("关于")
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
