import SwiftData
import SwiftUI

/// "你们之间" is the core IslandLink surface: it explains why two people are connected.
struct PersonConnectionView: View {
    let personA: Person
    let personB: Person

    private var sharedCases: [Case] {
        personA.sharedCases(with: personB).sorted { $0.updatedAt > $1.updatedAt }
    }

    private var sharedEvents: [Event] {
        personA.sharedEvents(with: personB).sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
    }

    private var evidence: [ConnectionEvidence] {
        personA.connectionEvidence(with: personB)
    }

    private var mutualPeople: [Person] {
        let ids = personA.mutualConnectionIDs(with: personB)
        let people = personA.cases.flatMap(\.allPersons) + personA.events.flatMap(\.participants)
        var seen = Set<PersistentIdentifier>()
        return people.filter { person in
            guard ids.contains(person.persistentModelID), !seen.contains(person.persistentModelID) else { return false }
            seen.insert(person.persistentModelID)
            return true
        }
        .sorted { $0.name < $1.name }
    }

    var body: some View {
        List {
            Section {
                header
            }

            if evidence.isEmpty && mutualPeople.isEmpty {
                ContentUnavailableView(
                    "还没有直接连接",
                    systemImage: "link.badge.plus",
                    description: Text("共同参与的第一个事件、案件或协作，会成为这段关系的第一条证据。")
                )
            }

            if !evidence.isEmpty {
                Section("连接证据") {
                    ForEach(evidence) { item in
                        evidenceRow(item)
                    }
                }
            }

            if !mutualPeople.isEmpty {
                Section("共同认识的人") {
                    ForEach(mutualPeople, id: \.persistentModelID) { person in
                        HStack(spacing: 12) {
                            Image(systemName: person.roleTypes.first?.systemImage ?? "person.crop.circle")
                                .foregroundStyle(.teal)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(person.name)
                                    .font(.headline)
                                Text(person.roleTypes.map(\.rawValue).joined(separator: "、"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("你们之间")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: 16) {
            personBadge(personA)
            Image(systemName: "link")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.teal)
            personBadge(personB)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(personA.name) 和 \(personB.name) 之间的连接")
    }

    private func personBadge(_ person: Person) -> some View {
        VStack(spacing: 6) {
            Image(systemName: person.roleTypes.first?.systemImage ?? "person.crop.circle.fill")
                .font(.title2)
                .foregroundStyle(.teal)
            Text(person.name)
                .font(.headline)
                .lineLimit(1)
            Text(person.roleTypes.first?.rawValue ?? "联系人")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func evidenceRow(_ evidence: ConnectionEvidence) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: evidence.kind.systemImage)
                .foregroundStyle(.teal)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(evidence.title)
                        .font(.headline)
                    Spacer()
                    Text(evidence.kind.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                if let subtitle = evidence.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let date = evidence.date {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(evidence.kind.rawValue)：\(evidence.title)")
    }
}
