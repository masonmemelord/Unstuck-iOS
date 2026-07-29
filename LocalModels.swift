//
//  LocalModels.swift
//  Unstuck
//
//  Created by Mason Mitchell on 7/29/26.
//
// Serves at the Database and Auth for local storage
import Foundation
import SwiftData

@Model
final class LocalProfile{
    var college: String
    var major: String
    var creditsTaken: Int
    var schoolYear: Int
    var updatedAt: Date
    
    init(college: String, major: String, creditsTaken: Int, schoolYear: Int, updatedAt: Date) {
        self.college = college
        self.major = major
        self.creditsTaken = creditsTaken
        self.schoolYear = schoolYear
        self.updatedAt = updatedAt
    }
    
}

@Model
final class LocalWeeklyCheckin {
    @Attribute(.unique) var id: String
    var feeling: String
    var weekFocus: String
    var studyHours: String
    var scheduleSummary: String
    var goals: [String]
    var blockers: String
    var createdAt: Date
    
    init(id: String, feeling: String, weekFocus: String, studyHours: String, scheduleSummary: String, goals: [String], blockers: String, createdAt: Date) {
        self.id = id
        self.feeling = feeling
        self.weekFocus = weekFocus
        self.studyHours = studyHours
        self.scheduleSummary = scheduleSummary
        self.goals = goals
        self.blockers = blockers
        self.createdAt = createdAt
    }
    
}

extension LocalWeeklyCheckin {
    var weeklyCheckIn: WeeklyCheckIn {
        WeeklyCheckIn(
            id: id,
            feeling: feeling,
            weekFocus: weekFocus,
            studyHours: studyHours,
            scheduleSummary: scheduleSummary,
            goals: goals,
            blockers: blockers,
            createdAt: createdAt
        )
    }
}
