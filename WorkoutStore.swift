import Foundation
import SwiftUI

@MainActor
final class WorkoutStore: ObservableObject {
    @Published var sessions: [WorkoutSession] = []
    @Published var metrics: [BodyMetrics] = []

    private let sessionsKey = "moyfitness.sessions.v1"
    private let metricsKey = "moyfitness.metrics.v1"

    init() { load() }

    func save(_ session: WorkoutSession) {
        sessions.append(session)
        persist()
    }

    func save(_ metric: BodyMetrics) {
        metrics.append(metric)
        persist()
    }

    func previousExercise(name: String, day: String) -> Exercise? {
        sessions.reversed()
            .first(where: { $0.day == day })?
            .exercises.first(where: { $0.name == name })
    }

    func exportJSON() -> URL? {
        let payload = Backup(sessions: sessions, metrics: metrics)
        guard let data = try? JSONEncoder.pretty.encode(payload) else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("MoyFitnessPRO-backup.json")
        do { try data.write(to: url); return url } catch { return nil }
    }

    private func load() {
        let decoder = JSONDecoder()
        if let d = UserDefaults.standard.data(forKey: sessionsKey),
           let value = try? decoder.decode([WorkoutSession].self, from: d) { sessions = value }
        if let d = UserDefaults.standard.data(forKey: metricsKey),
           let value = try? decoder.decode([BodyMetrics].self, from: d) { metrics = value }
    }

    private func persist() {
        let encoder = JSONEncoder()
        if let d = try? encoder.encode(sessions) { UserDefaults.standard.set(d, forKey: sessionsKey) }
        if let d = try? encoder.encode(metrics) { UserDefaults.standard.set(d, forKey: metricsKey) }
    }

    struct Backup: Codable {
        var sessions: [WorkoutSession]
        var metrics: [BodyMetrics]
    }
}

private extension JSONEncoder {
    static var pretty: JSONEncoder {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        e.dateEncodingStrategy = .iso8601
        return e
    }
}
