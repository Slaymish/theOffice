import Foundation
import OfficeCore
import NativeCore
import NativeSecurity

/// Keeps the pairing in the Keychain on both devices: the link key, and which Mac it belongs to.
enum LinkKeychain {
    private static let service = "nz.hamish.TheCity.link"
    private static let store = KeychainStore(service: service, accessibility: .afterFirstUnlockThisDeviceOnly)

    static func load() -> PairingRecord? {
        guard let data = try? store.read(account: "pairing") else { return nil }
        return try? NativeJSON.decode(PairingRecord.self, from: data, dates: .deferredToDate)
    }

    static func save(_ record: PairingRecord) {
        guard let data = try? NativeJSON.encode(record, dates: .deferredToDate, formatting: []) else { return }
        // Updating an existing item retains the old pairing if the new write fails.
        try? store.write(data, account: "pairing")
    }

    static func clear() {
        try? store.remove(account: "pairing")
    }
}

/// The saved half of a `PairingCode`.
struct PairingRecord: Codable, Equatable {
    var hostID: UUID
    var host: String
    var key: Data

    init(_ code: PairingCode) {
        hostID = code.hostID
        host = code.host
        key = code.key
    }

    var code: PairingCode { PairingCode(hostID: hostID, host: host, key: key) }
}
