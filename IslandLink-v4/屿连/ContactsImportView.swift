import Contacts
import SwiftData
import SwiftUI

struct ContactsImportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var importManager = ContactsImportManager.shared
    @Query(sort: \Person.name) private var existingPersons: [Person]

    @State private var entries: [ContactsImportManager.ImportEntry] = []
    @State private var isLoading = false
    @State private var isImporting = false
    @State private var importedCount = 0
    @State private var errorMessage: String?

    private var selectedCount: Int {
        entries.filter { $0.isSelected }.count
    }

    var body: some View {
        NavigationStack {
            Group {
                if importManager.isAuthorized {
                    contactList
                } else {
                    permissionView
                }
            }
            .navigationTitle("导入通讯录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
            .task {
                if importManager.isAuthorized {
                    await loadContacts()
                }
            }
        }
    }

    private var permissionView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.tealLink)
            Text("访问通讯录")
                .font(.cnTitle2)
            Text("屿连需要读取系统通讯录，帮你把联系人放进人脉网络。")
                .font(.cnBody)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxl)
            Button {
                Task {
                    let granted = await importManager.requestAccess()
                    importManager.isAuthorized = granted
                    if granted {
                        await loadContacts()
                    }
                }
            } label: {
                Text("允许访问")
                    .font(.cnBody.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.xxl)
                    .padding(.vertical, Spacing.md)
                    .background(RoundedRectangle(cornerRadius: CornerRadius.button).fill(Color.tealLink))
            }
            Text("通讯录数据只会写入本机屿连数据库。")
                .font(.cnCaption1)
                .foregroundColor(.textTertiary)
            Spacer()
        }
        .padding()
    }

    private var contactList: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView("正在读取通讯录...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if entries.isEmpty {
                ContentUnavailableView("没有可导入的联系人", systemImage: "person.2.slash")
            } else {
                List {
                    if importedCount > 0 {
                        Section {
                            Label("已导入 \(importedCount) 位联系人", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.statusSuccess)
                        }
                    }

                    Section {
                        ForEach($entries) { $entry in
                            Toggle(isOn: $entry.isSelected) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.name)
                                        .font(.cnBody)
                                    if let org = entry.org, !org.isEmpty {
                                        Text(org)
                                            .font(.cnCaption1)
                                            .foregroundColor(.textSecondary)
                                    } else if let phone = entry.phone, !phone.isEmpty {
                                        Text(phone)
                                            .font(.cnCaption1)
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                            }
                            .disabled(entry.status == .alreadyImported)
                        }
                    } header: {
                        Text("系统通讯录")
                    }
                }

                Button {
                    importSelected()
                } label: {
                    Text(selectedCount == 0 ? "选择联系人" : "导入 \(selectedCount) 位联系人")
                        .font(.cnBody.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(RoundedRectangle(cornerRadius: CornerRadius.button).fill(selectedCount == 0 ? Color.textTertiary : Color.tealLink))
                }
                .disabled(selectedCount == 0 || isImporting)
                .padding(Spacing.base)
                .background(.regularMaterial)
            }
        }
        .overlay(alignment: .bottom) {
            if let errorMessage {
                Text(errorMessage)
                    .font(.cnCaption1)
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.base)
                    .padding(.vertical, Spacing.sm)
                    .background(Capsule().fill(Color.statusError))
                    .padding(.bottom, Spacing.lg)
            }
        }
    }

    private func loadContacts() async {
        isLoading = true
        defer { isLoading = false }

        let contacts = importManager.fetchAllContacts()
        entries = contacts.map { contact in
            let existing = importManager.findExistingPerson(for: contact, in: existingPersons) != nil
            return ContactsImportManager.ImportEntry(
                id: contact.identifier,
                contact: contact,
                name: importManager.fullName(for: contact),
                phone: importManager.primaryPhone(for: contact),
                org: importManager.organization(for: contact),
                status: existing ? .alreadyImported : .new,
                isSelected: !existing
            )
        }
    }

    private func importSelected() {
        isImporting = true
        defer { isImporting = false }

        let selected = entries.filter { $0.isSelected && $0.status == .new }
        for entry in selected {
            _ = importManager.importContact(entry.contact, into: modelContext)
        }

        do {
            try modelContext.save()
            importedCount += selected.count
            entries.removeAll { selected.map(\.id).contains($0.id) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
