import Foundation
import CryptoKit
import Testing
import OfficeCore
@testable import TheCity

struct CompanionCacheTests {
    @Test func cacheIsDurableAndBoundToBothHostAndKey() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: folder) }
        let cache = CompanionCache(url: folder.appendingPathComponent("copy.json"))
        let host = UUID(), fingerprint = Data(SHA256.hash(data: Data(repeating: 3, count: 32)))
        let snapshot = CitySnapshot(host: "Fictional Mac", takenAt: Date(timeIntervalSince1970: 1_800_000_000), buildings: [])
        try cache.save(snapshot, hostID: host, keyFingerprint: fingerprint)
        #expect(try cache.load(hostID: host, keyFingerprint: fingerprint) == snapshot)
        #expect(try cache.load(hostID: UUID(), keyFingerprint: fingerprint) == nil)
        #expect(try cache.load(hostID: host, keyFingerprint: Data(repeating: 9, count: 32)) == nil)
        try cache.clear()
        #expect(try cache.load(hostID: host, keyFingerprint: fingerprint) == nil)
    }
    @Test func malformedSavedCopyIsPreserved() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: folder) }
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appendingPathComponent("copy.json"), bad = Data("bad fixture".utf8)
        try bad.write(to: url)
        let cache = CompanionCache(url: url)
        #expect(throws: (any Error).self) { try cache.load(hostID: UUID(), keyFingerprint: Data()) }
        #expect(try Data(contentsOf: url) == bad)
    }
}
