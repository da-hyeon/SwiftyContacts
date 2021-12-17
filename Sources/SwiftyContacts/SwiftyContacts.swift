//    Copyright (c) 2022 Satish Babariya <satish.babariya@gmail.com>
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.

@_exported import Contacts

// Internal Static instance of CNContactStore
class ContactStore {
    static var `default` = CNContactStore()
}

/// Requests access to the user's contacts.
/// - Throws: Error information, if an error occurred.
/// - Returns: returns  true if the user allows access to contacts
@available(macOS 12.0.0, iOS 15.0.0, *)
public func requestAccess() async throws -> Bool {
    return try await ContactStore.default.requestAccess(for: .contacts)
}

/// Indicates the current authorization status to access contact data.
/// - Returns: Returns the authorization status for the given entityType.
public func authorizationStatus() -> CNAuthorizationStatus {
    return CNContactStore.authorizationStatus(for: .contacts)
}

/// Fetch all contacts from device
/// - Parameters:
///   - keysToFetch: The contact fetch request that specifies the search criteria.
///   - order: The sort order for contacts.
///   - unifyResults: A Boolean value that indicates whether to return linked contacts as unified contacts.
/// - Throws: Error information, if an error occurred.
/// - Returns: array of contacts
@available(macOS 12.0.0, iOS 15.0.0, *)
public func fetchContacts(keysToFetch: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()], order: CNContactSortOrder = .none, unifyResults: Bool = true) async throws -> [CNContact] {
    return try await withCheckedThrowingContinuation { continuation in
        do {
            var contacts: [CNContact] = []
            let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
            fetchRequest.unifyResults = unifyResults
            fetchRequest.sortOrder = order
            try ContactStore.default.enumerateContacts(with: fetchRequest) { contact, _ in
                contacts.append(contact)
            }
            continuation.resume(returning: contacts)
        } catch {
            continuation.resume(throwing: error)
        }
    }
}

/// fetch contacts matching a conditions.
/// - Parameters:
///   - predicate: A definition of logical conditions for constraining a search for a fetch or for in-memory filtering.
///   - keysToFetch: The contact fetch request that specifies the search criteria.
/// - Throws: Error information, if an error occurred.
/// - Returns: Array  of contacts
public func fetchContacts(predicate: NSPredicate, keysToFetch: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()]) throws -> [CNContact] {
    return try ContactStore.default.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
}

/// fetch contacts matching a name.
/// - Parameters:
///   - name: The name can contain any number of words.
///   - keysToFetch: The contact fetch request that specifies the search criteria.
/// - Throws: Error information, if an error occurred.
/// - Returns: Array  of contacts
public func fetchContacts(matchingName name: String, keysToFetch: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()]) throws -> [CNContact] {
    return try ContactStore.default.unifiedContacts(matching: CNContact.predicateForContacts(matchingName: name), keysToFetch: keysToFetch)
}

/// Fetch contacts matching an email address.
/// - Parameters:
///   - emailAddress: The email address to search for. Do not include a scheme (e.g., "mailto:").
///   - keysToFetch: The contact fetch request that specifies the search criteria.
/// - Throws: Error information, if an error occurred.
/// - Returns: Array  of contacts
public func fetchContacts(matchingEmailAddress emailAddress: String, keysToFetch: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()]) throws -> [CNContact] {
    return try ContactStore.default.unifiedContacts(matching: CNContact.predicateForContacts(matchingEmailAddress: emailAddress), keysToFetch: keysToFetch)
}

/// Fetch contacts matching a phone number.
/// - Parameters:
///   - phoneNumber: A CNPhoneNumber representing the phone number to search for. Do not include a scheme (e.g., "tel:").
///   - keysToFetch: The contact fetch request that specifies the search criteria.
/// - Throws: Error information, if an error occurred.
/// - Returns: Array  of contacts
public func fetchContacts(matching phoneNumber: CNPhoneNumber, keysToFetch: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()]) throws -> [CNContact] {
    return try ContactStore.default.unifiedContacts(matching: CNContact.predicateForContacts(matching: phoneNumber), keysToFetch: keysToFetch)
}

/// To fetch contacts matching contact identifiers.
/// - Parameters:
///   - identifiers: Contact identifiers to be matched.
///   - keysToFetch: The contact fetch request that specifies the search criteria.
/// - Throws: Error information, if an error occurred.
/// - Returns: Array  of contacts
public func fetchContacts(withIdentifiers identifiers: [String], keysToFetch: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()]) throws -> [CNContact] {
    return try ContactStore.default.unifiedContacts(matching: CNContact.predicateForContacts(withIdentifiers: identifiers), keysToFetch: keysToFetch)
}

/// To fetch contacts matching group identifier
/// - Parameters:
///   - groupIdentifier: The group identifier to be matched.
///   - keysToFetch: The contact fetch request that specifies the search criteria.
/// - Throws: Error information, if an error occurred.
/// - Returns: Array  of contacts
public func fetchContacts(withGroupIdentifier groupIdentifier: String, keysToFetch: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()]) throws -> [CNContact] {
    return try ContactStore.default.unifiedContacts(matching: CNContact.predicateForContactsInGroup(withIdentifier: groupIdentifier), keysToFetch: keysToFetch)
}

/// find the contacts in the specified container.
/// - Parameters:
///   - containerIdentifier: The container identifier to be matched.
///   - keysToFetch: The contact fetch request that specifies the search criteria.
/// - Throws: Error information, if an error occurred.
/// - Returns: Array  of contacts
public func fetchContacts(withContainerIdentifier containerIdentifier: String, keysToFetch: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()]) throws -> [CNContact] {
    return try ContactStore.default.unifiedContacts(matching: CNContact.predicateForContactsInContainer(withIdentifier: containerIdentifier), keysToFetch: keysToFetch)
}

/// Fetch a  contact with a given identifier.
/// - Parameters:
///   - identifier: The identifier of the contact to fetch.
///   - keysToFetch: The contact fetch request that specifies the search criteria.
/// - Throws: Error information, if an error occurred.
/// - Returns: Contact matching or linked to the identifier
public func fetchContact(withIdentifier identifier: String, keysToFetch: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()]) throws -> CNContact {
    return try ContactStore.default.unifiedContact(withIdentifier: identifier, keysToFetch: keysToFetch)
}

/// Adds the specified contact to the contact store.
/// - Parameters:
///   - contact: The new contact to add.
///   - identifier: The container identifier to add the new contact to. Set to nil for the default container.
/// - Throws: Error information, if an error occurred.
public func addContact(_ contact: CNMutableContact, toContainerWithIdentifier identifier: String? = nil) throws {
    let request = CNSaveRequest()
    request.add(contact, toContainerWithIdentifier: identifier)
    try ContactStore.default.execute(request)
}

/// Updates an existing contact in the contact store.
/// - Parameters:
///   - contact: The contact to update.
/// - Throws: Error information, if an error occurred.
public func updateContact(_ contact: CNMutableContact) throws {
    let request = CNSaveRequest()
    request.update(contact)
    try ContactStore.default.execute(request)
}
