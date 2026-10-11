import Foundation
import Network
import NativeSync
import OfficeCore

/// Preserve City's existing wire protocol, pairing key and key separation when using the shared transport.
enum LinkTLS {
    static let serviceType = "_thecity._tcp"
    static func parameters(key: Data) -> NWParameters {
        LocalTLS.parameters(key: key, domain: "thecity-local-link", identity: "thecity")
    }
}

typealias LinkConnection = LocalConnection<LinkMessage>

#if os(macOS)
@MainActor final class LinkListener {
    private let listener = LocalListener<LinkMessage>(maximumLength: LinkFramer.maximumLength)
    var onConnection: ((LinkConnection) -> Void)?
    var onStatus: ((String) -> Void)?
    func start(key: Data, name: String, hostID: UUID) {
        listener.onConnection = { [weak self] in self?.onConnection?($0) }
        listener.onStatus = { [weak self] in self?.onStatus?($0) }
        try? listener.start(parameters: LinkTLS.parameters(key: key), name: name,
                            serviceType: LinkTLS.serviceType, hostID: hostID)
    }
    func retry() { listener.retry() }
    func stop() { listener.stop() }
}
#endif

#if os(iOS)
@MainActor final class LinkBrowser {
    private let browser = LocalBrowser()
    func start(hostID: UUID, key: Data, found: @escaping @MainActor (NWEndpoint) -> Void) {
        browser.start(hostID: hostID, parameters: LinkTLS.parameters(key: key), serviceType: LinkTLS.serviceType, found: found)
    }
    func retry() { browser.retry() }
    func stop() { browser.stop() }
}
#endif
