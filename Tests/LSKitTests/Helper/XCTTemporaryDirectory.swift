import Foundation

public func XCTTemporaryDirectory(
    path: String? = nil,
    fileManager: FileManager = .default,
    perform: (URL) throws -> Void
) throws {
    let directory = fileManager.temporaryDirectory.appending(path: path ?? UUID().uuidString)

    do {
        try perform(directory)
        try fileManager.removeItem(at: directory)
    } catch {
        try fileManager.removeItem(at: directory)
        throw error
    }
}

public func XCTTemporaryDirectory(
    path: String? = nil,
    fileManager: FileManager = .default,
    perform: (URL) async throws -> Void
) async throws {
    let directory = fileManager.temporaryDirectory.appending(path: path ?? UUID().uuidString)

    do {
        try await perform(directory)
        try fileManager.removeItem(at: directory)
    } catch {
        try fileManager.removeItem(at: directory)
        throw error
    }
}
