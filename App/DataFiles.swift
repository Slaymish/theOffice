import Foundation
import NativeCore

/// The city's saved files: one folder (`-data <dir>` gives a dev build its own), read and written only through here.
enum DataFiles {
    static let directory: URL = LaunchArgument.value("-data").map { URL(fileURLWithPath: $0) }
        ?? (TestHost.isActive ? FileManager.default.temporaryDirectory.appendingPathComponent("TheCityTests-\(UUID().uuidString)") : nil)
        ?? (try! AppDirectories.applicationSupportURL(appID: "The City"))

    /// Renders load the real city to draw it, but must never write it back over the running app's.
    private static let isReadOnly = ["-render-preview", "-render-icon", "-render-reel"].contains { ProcessInfo.processInfo.arguments.contains($0) }

    static func url(_ name: String) -> URL { directory.appendingPathComponent(name) }

    static var decoder: JSONDecoder {
        NativeJSON.decoder()
    }

    static var encoder: JSONEncoder {
        NativeJSON.encoder(formatting: [.prettyPrinted, .sortedKeys])
    }

    /// Nil when there's no file yet. A file that won't decode is moved aside first, so the next save can't overwrite it.
    static func load<T: Decodable>(_ type: T.Type, from url: URL, decoder: JSONDecoder = decoder) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        do {
            return try decoder.decode(type, from: data)
        } catch {
            NSLog("The City couldn't read \(url.path): \(error)")
            guard !isReadOnly else { return nil }
            if let kept = try? AtomicFile.preserveUnreadable(at: url) { unreadable.append(kept) }
            return nil
        }
    }

    static func save<T: Encodable>(_ value: T, to url: URL, encoder: JSONEncoder = encoder) {
        guard !isReadOnly, let data = try? encoder.encode(value) else { return }
        try? AtomicFile.write(data, to: url)
    }

    /// Files set aside this launch, for the city to tell the user about.
    nonisolated(unsafe) private(set) static var unreadable: [URL] = []
}
