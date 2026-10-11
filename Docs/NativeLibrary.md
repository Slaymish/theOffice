# Shared native library

The Mac app, iPhone companion and OfficeCore consume HamishNativeLibrary 0.2.x from its public GitHub
repository. Dependency versions live in project.yml and Packages/OfficeCore/Package.swift. Xcode's generated
project remains ignored; OfficeCore's Package.resolved records its tested version.

Shared implementations now cover JSON coding, application-support path resolution, private atomic file
writes, unreadable-file preservation, text copy and per-device Keychain access. DataFiles remains the city's
adapter: it keeps the same folder, ISO 8601 dates, custom journal codecs, isolated test/dev paths and read-only
render behavior. CompanionCoding keeps its sorted JSON output, preserving signed command semantics.

LinkKeychain keeps service `nz.hamish.TheCity.link`, account `pairing` and After First Unlock / This Device
Only accessibility. It updates an existing item rather than deleting it before a replacement is known to work.
No key rotation or migration is required. This code change does not read or modify existing credentials as setup.

Sparkle remains the Mac app's explicit dependency. Its small updater adapter, signed appcast workflow and
keys remain app-owned; the cross-platform library deliberately excludes Sparkle. Agent streams, pairing/HMAC
protocol, RealityKit scenes, lifecycle, brands and permissions remain city-specific.

For shared fixes, change/test/release HamishNativeLibrary first, update this app's resolved dependency, then
run `make test`, both native builds and hosted app tests. Publish through the city's release skill when asked.
Updating the library tag alone does not update installed City applications. No new background memory sync,
agent provider, signing identity or OS permission is introduced by this integration.
