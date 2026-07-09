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

