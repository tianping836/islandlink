import Contacts

import SwiftUI

import SwiftData

@MainActor

final class ContactsImportManager: ObservableObject {

static let shared = ContactsImportManager()

private let store = CNContactStore()

@Published var isAuthorized: Bool = false

@Published var allContacts: [CNContact] = []

private let keysToFetch: [CNKeyDescriptor] = [

CNContactGivenNameKey as CNKeyDescriptor,

CNContactFamilyNameKey as CNKeyDescriptor,

CNContactPhoneNumbersKey as CNKeyDescriptor,

CNContactEmailAddressesKey as CNKeyDescriptor,

CNContactOrganizationNameKey as CNKeyDescriptor,

CNContactJobTitleKey as CNKeyDescriptor,

CNContactNoteKey as CNKeyDescriptor,

CNContactImageDataKey as CNKeyDescriptor,

CNContactThumbnailImageDataKey as CNKeyDescriptor

]

func requestAccess() async -> Bool {

do { return try await store.requestAccess(for: .contacts) } catch { return false }

}

func fetchAllContacts() -> [CNContact] {

let request = CNContactFetchRequest(keysToFetch: keysToFetch)

var results: [CNContact] = []

try? store.enumerateContacts(with: request) { contact, _ in

results.append(contact)

}

return results.sorted { ($0.familyName + $0.givenName) < ($1.familyName + $1.givenName) }

}

func fullName(for contact: CNContact) -> String {
let name = "\(contact.familyName)\(contact.givenName)".trimmingCharacters(in: .whitespacesAndNewlines)
return name.isEmpty ? "未命名联系人" : name
}

func primaryPhone(for contact: CNContact) -> String? {

contact.phoneNumbers.first?.value.stringValue

}

func primaryEmail(for contact: CNContact) -> String? {

contact.emailAddresses.first?.value as String?

}

func organization(for contact: CNContact) -> String? {

contact.organizationName.isEmpty ? nil : contact.organizationName

}

func jobTitle(for contact: CNContact) -> String? {

contact.jobTitle.isEmpty ? nil : contact.jobTitle

}

func importContact(_ contact: CNContact, into modelContext: ModelContext) -> Person {

let person = Person(

name: fullName(for: contact),

roleTypes: [.other],

title: jobTitle(for: contact),

phone: primaryPhone(for: contact),

notes: contact.note.isEmpty ? nil : contact.note

)

person.email = primaryEmail(for: contact)

if contact.phoneNumbers.count > 1 {

person.phone2 = contact.phoneNumbers.dropFirst().first?.value.stringValue

}

if let orgName = organization(for: contact) {

let unit = OrgUnit(name: orgName)

unit.person = person

modelContext.insert(unit)

}

modelContext.insert(person)

return person

}

enum ImportStatus { case new, alreadyImported }

struct ImportEntry: Identifiable {

let id: String

let contact: CNContact

let name: String

let phone: String?

let org: String?

let status: ImportStatus

var isSelected: Bool = false

}

func findExistingPerson(for contact: CNContact, in persons: [Person]) -> Person? {
let name = fullName(for: contact)
let phone = primaryPhone(for: contact)
let email = primaryEmail(for: contact)
return persons.first { person in
person.name == name ||
(phone != nil && (person.phone == phone || person.phone2 == phone)) ||
(email != nil && person.email == email)
}
}

}
