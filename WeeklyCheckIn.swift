//
//  WeeklyCheckIn.swift
//  Unstuck
//
//  Created by Mason Mitchell on 7/9/26.
//

import Foundation

struct WeeklyCheckIn: Identifiable, Codable {
    let id: String
    let feeling: String
    let weekFocus: String
    let studyHours: String
    let scheduleSummary: String
    let goals: [String]
    let blockers: String
    let createdAt: Date
}

// Local profile data keeps onboarding useful when the user chooses not to sign in.
struct LocalUserProfile: Codable {
    let college: String
    let major: String
    let creditsTaken: Int
    let schoolYear: String
    let updatedAt: Date
}

// UserDefaults is enough for the local-first MVP; migrate to SwiftData if plan data grows.
enum LocalProfileStore {
    private static let profileKey = "unstuck.localProfile"

    static func save(_ profile: LocalUserProfile) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: profileKey)
    }

    static func load() -> LocalUserProfile? {
        guard let data = UserDefaults.standard.data(forKey: profileKey) else { return nil }
        return try? JSONDecoder().decode(LocalUserProfile.self, from: data)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: profileKey)
    }
}

// Local check-ins power dashboard and history without requiring Firebase Auth.
enum LocalWeeklyCheckInStore {
    private static let checkInsKey = "unstuck.localWeeklyCheckIns"
    static let revisionKey = "unstuck.localWeeklyCheckInsRevision"

    static func save(_ checkIn: WeeklyCheckIn) {
        // Replace matching ids so future edits do not create duplicate history rows.
        var checkIns = loadAll()
        checkIns.removeAll { $0.id == checkIn.id }
        checkIns.append(checkIn)
        persist(checkIns)
        bumpRevision()
    }

    static func loadAll() -> [WeeklyCheckIn] {
        guard let data = UserDefaults.standard.data(forKey: checkInsKey),
              let checkIns = try? JSONDecoder().decode([WeeklyCheckIn].self, from: data)
        else {
            return []
        }

        return checkIns.sorted { $0.createdAt > $1.createdAt }
    }

    static func latest() -> WeeklyCheckIn? {
        loadAll().first
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: checkInsKey)
        bumpRevision()
    }

    private static func persist(_ checkIns: [WeeklyCheckIn]) {
        guard let data = try? JSONEncoder().encode(checkIns.sorted(by: { $0.createdAt > $1.createdAt })) else { return }
        UserDefaults.standard.set(data, forKey: checkInsKey)
    }

    private static func bumpRevision() {
        let currentRevision = UserDefaults.standard.integer(forKey: revisionKey)
        UserDefaults.standard.set(currentRevision + 1, forKey: revisionKey)
    }
}

