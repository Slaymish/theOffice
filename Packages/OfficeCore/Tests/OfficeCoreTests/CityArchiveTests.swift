import Foundation
import Testing
@testable import OfficeCore

struct CityArchiveTests {
    @Test func portableArchiveAndCompleteFloorDetailsSurviveWireRoundTrip() throws {
        let id = UUID(), floorID = UUID(), now = Date(timeIntervalSince1970: 1_800_000_000)
        var floor = FloorSnapshot(id: floorID, name: "Fictional floor", hires: [], request: nil, phase: .idle, startedAt: nil)
        floor.configuration = CityFloorConfiguration(provider: "claude", model: "fictional", budgetUSD: 1,
            purpose: "Fictional purpose", presetID: nil, branch: "test", allowedServers: [], allowedSkills: [],
            lastRequest: String(repeating: "Full request ", count: 100), queuedRequests: ["Fictional queued job"])
        floor.history = [CityHistorySnapshot(id: UUID(), date: now, job: UUID(), kind: "request", title: nil,
            text: String(repeating: "Complete history ", count: 100))]
        floor.totals = CityTotalsSnapshot(jobs: 5, succeeded: 3, cancelled: 1, spendUSD: 1.25, tokens: 100, duration: 60)
        let job = CityJobSnapshot(id: UUID(), date: now, request: "Fictional journal request", hires: [], costUSD: 0.1,
            budgetUSD: 1, duration: 2, files: ["fictional.txt"], outcome: "completed", buildingID: id, floorID: floorID, tokens: 5)
        let snapshot = CitySnapshot(host: "Fictional Mac", takenAt: now,
            buildings: [BuildingSnapshot(id: id, name: "Fictional project", title: nil, style: 0, floors: [floor])],
            archive: CityArchive(jobs: [job]))
        var parser = LinkFramer()
        let decoded = try parser.feed(LinkFramer.frame(.snapshot(snapshot)))
        #expect(decoded == [.snapshot(snapshot)])
        var json = try JSONSerialization.jsonObject(with: CompanionCoding.encoder.encode(snapshot)) as! [String: Any]
        json.removeValue(forKey: "archive")
        let old = try CompanionCoding.decoder.decode(CitySnapshot.self, from: JSONSerialization.data(withJSONObject: json))
        #expect(old.archive == nil && old.buildings == snapshot.buildings)
    }
}
