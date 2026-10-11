import Foundation
import NativeCore

/// Carries data over from when the app was called The Office (`nz.hamish.theoffice`).
enum LegacyData {
    static func migrate() {
        let files = FileManager.default
        let old = try! AppDirectories.applicationSupportURL(appID: "The Office")
        let new = try! AppDirectories.applicationSupportURL(appID: "The City")
        if files.fileExists(atPath: old.path), !files.fileExists(atPath: new.path) {
            try? files.moveItem(at: old, to: new)
        }

        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: "migratedFromTheOffice") else { return }
        for (key, value) in defaults.persistentDomain(forName: "nz.hamish.theoffice") ?? [:] where defaults.object(forKey: key) == nil {
            defaults.set(value, forKey: key)
        }
        if defaults.string(forKey: "brand") == "the-office" { defaults.set("the-city", forKey: "brand") }
        defaults.set(true, forKey: "migratedFromTheOffice")
    }
}
