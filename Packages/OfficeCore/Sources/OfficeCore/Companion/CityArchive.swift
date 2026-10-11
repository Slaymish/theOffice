import Foundation

/// Portable app information. Mac filesystem locations, raw CLI logs, credentials and runtime permissions stay on the Mac.
public struct CityArchive: Codable, Equatable, Sendable {
    public var version = 1
    public var jobs: [CityJobSnapshot]
    public init(jobs: [CityJobSnapshot]) { self.jobs = jobs }
}
public struct CityJobSnapshot: Codable, Equatable, Sendable, Identifiable {
    public var id: UUID
    public var date: Date
    public var request: String
    public var hires: [String]
    public var costUSD: Double?
    public var budgetUSD: Double
    public var duration: TimeInterval
    public var files: [String]
    public var outcome: String
    public var buildingID: UUID?
    public var floorID: UUID?
    public var tokens: Int?
    public init(id: UUID, date: Date, request: String, hires: [String], costUSD: Double?, budgetUSD: Double,
                duration: TimeInterval, files: [String], outcome: String, buildingID: UUID?, floorID: UUID?, tokens: Int?) {
        self.id = id; self.date = date; self.request = request; self.hires = hires; self.costUSD = costUSD
        self.budgetUSD = budgetUSD; self.duration = duration; self.files = files; self.outcome = outcome
        self.buildingID = buildingID; self.floorID = floorID; self.tokens = tokens
    }
}
public struct CityHistorySnapshot: Codable, Equatable, Sendable, Identifiable {
    public var id: UUID
    public var date: Date
    public var job: UUID
    public var kind: String
    public var title: String?
    public var text: String
    public init(id: UUID, date: Date, job: UUID, kind: String, title: String?, text: String) {
        self.id = id; self.date = date; self.job = job; self.kind = kind; self.title = title; self.text = text
    }
}
public struct CityTotalsSnapshot: Codable, Equatable, Sendable {
    public var jobs: Int
    public var succeeded: Int
    public var cancelled: Int
    public var spendUSD: Double
    public var tokens: Int
    public var duration: TimeInterval
    public init(jobs: Int, succeeded: Int, cancelled: Int, spendUSD: Double, tokens: Int, duration: TimeInterval) {
        self.jobs = jobs; self.succeeded = succeeded; self.cancelled = cancelled
        self.spendUSD = spendUSD; self.tokens = tokens; self.duration = duration
    }
}
public struct CityFloorConfiguration: Codable, Equatable, Sendable {
    public var provider: String?
    public var model: String?
    public var budgetUSD: Double
    public var purpose: String?
    public var presetID: String?
    public var branch: String?
    public var allowedServers: [String]?
    public var allowedSkills: [String]?
    public var lastRequest: String?
    public var queuedRequests: [String]
    public init(provider: String?, model: String?, budgetUSD: Double, purpose: String?, presetID: String?, branch: String?,
                allowedServers: [String]?, allowedSkills: [String]?, lastRequest: String?, queuedRequests: [String]) {
        self.provider = provider; self.model = model; self.budgetUSD = budgetUSD; self.purpose = purpose
        self.presetID = presetID; self.branch = branch; self.allowedServers = allowedServers
        self.allowedSkills = allowedSkills; self.lastRequest = lastRequest; self.queuedRequests = queuedRequests
    }
}
