import SwiftData
import SwiftUI

/// A deliberately simple first version of the professional relationship map.
struct PersonNetworkView: View {
    let focalPerson: Person

    @Query(filter: #Predicate<Person> { !$0.isArchived }, sort: \Person.name)
    private var allPersons: [Person]

    private var connectedPeople: [Person] {
        allPersons
            .filter { $0.persistentModelID != focalPerson.persistentModelID }
            .filter { connectionStrength(with: $0) > 0 }
            .sorted {
                if connectionStrength(with: $0) != connectionStrength(with: $1) {
                    return connectionStrength(with: $0) > connectionStrength(with: $1)
                }
                return $0.name < $1.name
            }
    }

    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: focalPerson.roleTypes.first?.systemImage ?? "person.crop.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.teal)
                    Text(focalPerson.name)
                        .font(.title2.weight(.semibold))
                    Text("这些人与你有真实共同经历")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }

            if connectedPeople.isEmpty {
                ContentUnavailableView(
                    "网络正在生长",
                    systemImage: "point.3.connected.trianglepath.dotted",
                    description: Text("共同参与的事件或案件，会在这里形成你的专业关系路径。")
                )
            } else {
                Section("最近的连接") {
                    ForEach(connectedPeople, id: \.persistentModelID) { person in
                        NavigationLink {
                            PersonConnectionView(personA: focalPerson, personB: person)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: person.roleTypes.first?.systemImage ?? "person.crop.circle")
                                    .foregroundStyle(.teal)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(person.name)
                                        .font(.headline)
                                    Text(connectionSummary(with: person))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("人脉网络")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func connectionStrength(with person: Person) -> Int {
        focalPerson.connectionEvidence(with: person).reduce(0) { $0 + $1.strength }
    }

    private func connectionSummary(with person: Person) -> String {
        let evidence = focalPerson.connectionEvidence(with: person)
        let caseCount = evidence.filter { $0.kind == .matter }.count
        let eventCount = evidence.filter { $0.kind == .event }.count
        var parts: [String] = []
        if eventCount > 0 { parts.append("\(eventCount) 个共同事件") }
        if caseCount > 0 { parts.append("\(caseCount) 个共同案件") }
        return parts.isEmpty ? "暂无共同经历" : parts.joined(separator: " · ")
    }
}
