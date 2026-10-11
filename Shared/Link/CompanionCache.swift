import Foundation
import NativeCore
import OfficeCore

/// Host and key binding prevent displaying one Mac's private snapshot after pairing with another Mac.
struct CompanionCache: Sendable {
    let url: URL
    struct Entry: Codable { var hostID: UUID; var keyFingerprint: Data; var snapshot: CitySnapshot }
    func load(hostID: UUID, keyFingerprint: Data) throws -> CitySnapshot? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        let bytes = try Data(contentsOf: url)
        guard bytes.count <= LinkFramer.maximumLength else { throw CocoaError(.fileReadTooLarge) }
        let entry = try NativeJSON.decode(Entry.self, from: bytes)
        guard entry.hostID == hostID, entry.keyFingerprint == keyFingerprint,
              entry.snapshot.version == CitySnapshot.protocolVersion else { return nil }
        return entry.snapshot
    }
    func save(_ snapshot: CitySnapshot, hostID: UUID, keyFingerprint: Data) throws {
        let bytes = try NativeJSON.encode(Entry(hostID: hostID, keyFingerprint: keyFingerprint, snapshot: snapshot))
        guard bytes.count <= LinkFramer.maximumLength else { throw CocoaError(.fileWriteUnknown) }
        try AtomicFile.write(bytes, to: url)
    }
    func clear() throws {
        if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
    }
}
