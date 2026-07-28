//
//  DashboardMetrics.swift
//  Unstuck
//
//  Created by Mason Mitchell on 7/22/26.
//

import Foundation

struct DashboardMetrics {
    let planStatus: String
    let checkIn: String
    let recovery: String
    let workload: String
    let weeklyStatusText: String

    static func from(
        latestCheckIn: WeeklyCheckIn?,
        isLoading: Bool,
        fallbackMessage: String
    ) -> DashboardMetrics {
        DashboardMetrics(
            planStatus: planStatus(for: latestCheckIn),
            checkIn: checkInValue(for: latestCheckIn),
            recovery: recoveryValue(for: latestCheckIn),
            workload: workloadValue(for: latestCheckIn),
            weeklyStatusText: weeklyStatusText(
                for: latestCheckIn,
                isLoading: isLoading,
                fallbackMessage: fallbackMessage
            )
        )
    }

    private static func planStatus(for checkIn: WeeklyCheckIn?) -> String {
        checkIn == nil ? "Pending" : "Ready"
    }

    private static func checkInValue(for checkIn: WeeklyCheckIn?) -> String {
        checkIn?.feeling ?? "Needed"
    }

    private static func recoveryValue(for checkIn: WeeklyCheckIn?) -> String {
        guard let checkIn else { return "Unset" }

        switch checkIn.feeling {
        case "Burnt out":
            return "Prioritize"
        case "Stressed":
            return "Protect"
        case "Focused":
            return "Steady"
        case "Motivated":
            return "Active"
        default:
            return "Set"
        }
    }

    private static func workloadValue(for checkIn: WeeklyCheckIn?) -> String {
        guard let checkIn else { return "Unknown" }

        let studyHours = Int(checkIn.studyHours.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0

        switch studyHours {
        case 12...:
            return "Heavy"
        case 6...11:
            return "Moderate"
        case 1...5:
            return "Light"
        default:
            return "Unclear"
        }
    }

    private static func weeklyStatusText(
        for checkIn: WeeklyCheckIn?,
        isLoading: Bool,
        fallbackMessage: String
    ) -> String {
        if isLoading {
            return "Loading your latest weekly check-in..."
        }

        if let checkIn {
            return "Latest plan: \(checkIn.weekFocus). Feeling: \(checkIn.feeling). Study target: \(checkIn.studyHours) hours."
        }

        return fallbackMessage.isEmpty ? "Start a check-in to generate this week's plan." : fallbackMessage
    }
}
