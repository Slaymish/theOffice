import OfficeCore
import SwiftUI

/// Reads the exact paired Mac copy, including while offline. Runtime actions remain on the existing command path.
struct SyncedInformationView: View {
    let snapshot: CitySnapshot?
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                if let snapshot {
                    Section("Saved copy") {
                        Text(snapshot.host)
                        Text("Received \(snapshot.takenAt.formatted())")
                        Text("This copy refreshes when both apps are open on the same network. Jobs and approvals require the Mac.")
                    }
                    ForEach(snapshot.buildings) { building in
                        Section(building.displayName) {
                            if let purpose = building.purpose { Text(purpose) }
                            if let preview = building.previewURL { Text(preview).textSelection(.enabled) }
                            ForEach(building.floors) { floor in
                                NavigationLink(floor.name) { floorDetails(floor) }
                            }
                        }
                    }
                    Section("Job journal") {
                        if let jobs = snapshot.archive?.jobs {
                            ForEach(jobs.reversed()) { job in
                                NavigationLink {
                                    Form {
                                        Section("Request") { Text(job.request).textSelection(.enabled) }
                                        Section("Result") {
                                            Text(job.outcome); Text(job.date.formatted())
                                            LabeledContent("Duration", value: "\(job.duration.formatted()) seconds")
                                            LabeledContent("Tokens", value: "\(job.tokens ?? 0)")
                                            if let cost = job.costUSD { LabeledContent("Cost", value: "$\(cost.formatted())") }
                                            LabeledContent("Budget", value: "$\(job.budgetUSD.formatted())")
                                            Text(job.hires.joined(separator: ", "))
                                        }
                                        Section("Files") { ForEach(job.files, id: \.self) { Text($0).textSelection(.enabled) } }
                                    }.navigationTitle("Job")
                                } label: {
                                    VStack(alignment: .leading) { Text(job.request); Text("\(job.outcome) · \(job.date.formatted())").font(.caption) }
                                }
                            }
                        } else { Text("Reconnect to an updated Mac app to sync its journal.") }
                    }
                } else { Text("Connect to your Mac to receive its city.") }
            }
            .navigationTitle("Synced information")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
    private func floorDetails(_ floor: FloorSnapshot) -> some View {
        Form {
            if let config = floor.configuration {
                Section("Configuration") {
                    if let purpose = config.purpose { Text(purpose) }
                    LabeledContent("Provider", value: config.provider ?? "Default")
                    LabeledContent("Model", value: config.model ?? "Default")
                    LabeledContent("Budget", value: "$\(config.budgetUSD.formatted())")
                    if let branch = config.branch { LabeledContent("Branch", value: branch) }
                    if let preset = config.presetID { LabeledContent("Preset", value: preset) }
                    Text("Staff: " + floor.hires.joined(separator: ", "))
                    Text("Servers: " + (config.allowedServers ?? []).joined(separator: ", "))
                    Text("Skills: " + (config.allowedSkills ?? []).joined(separator: ", "))
                }
                Section("Last request") { if let request = config.lastRequest { Text(request).textSelection(.enabled) } }
                Section("Queued requests") { ForEach(Array(config.queuedRequests.enumerated()), id: \.offset) { Text($0.element).textSelection(.enabled) } }
            }
            if let totals = floor.totals {
                Section("All time") {
                    LabeledContent("Jobs", value: "\(totals.jobs)")
                    LabeledContent("Succeeded", value: "\(totals.succeeded)")
                    LabeledContent("Cancelled", value: "\(totals.cancelled)")
                    LabeledContent("Spend", value: "$\(totals.spendUSD.formatted())")
                    LabeledContent("Tokens", value: "\(totals.tokens)")
                    LabeledContent("Duration", value: "\(totals.duration.formatted()) seconds")
                }
            }
            Section("History") {
                ForEach((floor.history ?? []).reversed()) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.title ?? entry.kind)
                        Text(entry.date.formatted()).font(.caption)
                        Text(entry.text).textSelection(.enabled)
                    }
                }
            }
        }.navigationTitle(floor.name)
    }
}
