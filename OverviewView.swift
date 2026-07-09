//
//  OverviewView.swift
//  Unstuck
//
//  Created by Mason Mitchell on 7/8/26.
//

import SwiftUI

struct OverviewView: View {
    let checkIn: WeeklyCheckIn //calls from WeeklyCheckIn

    private let backgroundColor = Color(red: 0.043, green: 0.059, blue: 0.078)
    private let cardColor = Color(red: 0.071, green: 0.102, blue: 0.141)
    private let primaryColor = Color(red: 0.231, green: 0.510, blue: 0.965)
    private let accentColor = Color(red: 0.133, green: 0.773, blue: 0.369)
    private let textColor = Color(red: 0.973, green: 0.980, blue: 0.988)
    private let mutedTextColor = Color(red: 0.700, green: 0.753, blue: 0.835)

    init(checkIn: WeeklyCheckIn) { //initializes self from the weeklycheckin, pulls all vars from weeklycheckin
        self.checkIn = checkIn
    }

    private var cleanedGoals: [String] {
        checkIn.goals
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private var parsedStudyHours: Int {
        Int(checkIn.studyHours.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }

    private var combinedMetrics: String {
        ([checkIn.feeling, checkIn.weekFocus, checkIn.studyHours, checkIn.scheduleSummary, checkIn.blockers] + checkIn.goals)
            .joined(separator: " ")
            .lowercased()
    }

    private var hasUpcomingTest: Bool {
        combinedMetrics.contains("test") || combinedMetrics.contains("exam") || combinedMetrics.contains("quiz") || combinedMetrics.contains("midterm") || combinedMetrics.contains("final")
    }

    private var hasHeavyWorkload: Bool {
        combinedMetrics.contains("heavy") || combinedMetrics.contains("work shift") || combinedMetrics.contains("workload") || parsedStudyHours >= 12 || cleanedGoals.count >= 4
    }

    private var needsRecoveryAdjustment: Bool {
        hasUpcomingTest && hasHeavyWorkload || checkIn.feeling == "Burnt out" || checkIn.feeling == "Stressed"
    }

    private var movementPlan: String {
        if hasUpcomingTest && hasHeavyWorkload {
            return "Skip long gym sessions this week. Use 10-minute stretch breaks, short walks, and basic calisthenics between study blocks."
        }

        if checkIn.feeling == "Burnt out" {
            return "Prioritize your health, keep things light, and do something you enjoy. School is important, but so is your mental health."
        }

        if checkIn.feeling == "Stressed" {
            return "Keep movement low-friction: stretching, an easy walk, or one short bodyweight circuit."
        }

        return "Plan 2-3 workouts around your lightest days, but keep one backup stretch routine ready."
    }

    private var weeklyPlanItems: [String] {
        var items = [String]()

        if hasUpcomingTest {
            items.append("Put preparation first. Review your information in smaller blocks during the week instead of saving it for one long session.")
        }

        if hasHeavyWorkload {
            items.append("Protect your highest-energy time for schoolwork. Move optional tasks to lighter days.")
        }

        if parsedStudyHours > 0 {
            items.append("Target about \(parsedStudyHours) study hours total, broken into 60-90 minute blocks.")
        }

        if !cleanedGoals.isEmpty {
            items.append("Anchor each day to one goal so the week stays realistic.")
        }

        items.append(movementPlan)
        items.append("End each day with a five-minute reset: check tomorrow's top task, clear one small blocker, and stop there.")

        return items
    }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    dataFlowSection
                    metricSummary
                    logicFlowSection
                    planSection
                    goalsSection
                    recoverySection
                }
                .padding(24)
                .padding(.bottom, 32)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Plan for the Week")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(textColor)

            Text("Built from your check-in, schedule, goals, and current energy.")
                .font(.headline)
                .foregroundStyle(mutedTextColor)
        }
    }

    private var dataFlowSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Data Flow")
                .font(.title3.bold())
                .foregroundStyle(textColor)

            flowStep(number: "1", title: "TestingView collects check-in data", detail: "Feeling, weekly academic goal, study hours, schedule, goals, and blockers.")
            flowStep(number: "2", title: "OverviewView receives a WeeklyCheckIn", detail: "The model is passed into this view through init(checkIn:).")
            flowStep(number: "3", title: "Planner checks the workload", detail: "The view detects tests, heavy weeks, total study hours, and recovery risk.")
            flowStep(number: "4", title: "Plan cards are generated", detail: "The recommendations below are built from those checks.")
        }
        .padding(18)
        .background(cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var metricSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week's Load")
                .font(.title3.bold())
                .foregroundStyle(textColor)

            HStack(spacing: 10) {
                metricPill(title: "Feeling", value: checkIn.feeling, color: feelingColor)
                metricPill(title: "Study", value: parsedStudyHours > 0 ? "\(parsedStudyHours) hrs" : "Not set", color: primaryColor)
            }

            summaryRow(icon: "target", title: "Focus", value: checkIn.weekFocus)
            summaryRow(icon: "calendar", title: "Schedule", value: checkIn.scheduleSummary)
            summaryRow(icon: "exclamationmark.triangle", title: "Blockers", value: checkIn.blockers)
        }
        .padding(18)
        .background(cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var logicFlowSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Logic Flow")
                .font(.title3.bold())
                .foregroundStyle(textColor)

            logicRow(
                title: "Upcoming test detected",
                isActive: hasUpcomingTest,
                detail: "Looks for test, exam, quiz, midterm, or final in the check-in text."
            )

            logicRow(
                title: "Heavy workload detected",
                isActive: hasHeavyWorkload,
                detail: "Turns on when study hours are 12+, goals are high, or schedule text mentions heavy workload/work shifts."
            )

            logicRow(
                title: "Recovery adjustment needed",
                isActive: needsRecoveryAdjustment,
                detail: "If active, the plan favors stretching, walks, and calisthenics over long gym sessions."
            )
        }
        .padding(18)
        .background(cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var planSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recommended Plan")
                .font(.title3.bold())
                .foregroundStyle(textColor)

            ForEach(weeklyPlanItems, id: \.self) { item in
                planCard(text: item)
            }
        }
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Goal Order")
                .font(.title3.bold())
                .foregroundStyle(textColor)

            if cleanedGoals.isEmpty {
                planCard(text: "No goals were added yet. Start with one school task and one recovery task.")
            } else {
                ForEach(Array(cleanedGoals.enumerated()), id: \.offset) { index, goal in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.headline)
                            .foregroundStyle(textColor)
                            .frame(width: 32, height: 32)
                            .background(primaryColor)
                            .clipShape(Circle())

                        Text(goal)
                            .font(.body)
                            .foregroundStyle(textColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(14)
                    .background(cardColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
    }

    private var recoverySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recovery Adjustment")
                .font(.title3.bold())
                .foregroundStyle(textColor)

            Text(movementPlan)
                .font(.body)
                .foregroundStyle(textColor)

            Text("Example: if you have a test and a heavy work week, choose stretching or calisthenics instead of forcing a full gym session.")
                .font(.footnote)
                .foregroundStyle(mutedTextColor)
        }
        .padding(18)
        .background(cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accentColor.opacity(0.25), lineWidth: 1)
        )
    }

    private var feelingColor: Color {
        switch checkIn.feeling {
        case "Burnt out":
            return Color(red: 0.875, green: 0.184, blue: 0.184)
        case "Stressed":
            return Color(red: 0.855, green: 0.647, blue: 0.125)
        case "Focused":
            return Color(red: 0.576, green: 0.773, blue: 0.992)
        case "Motivated":
            return accentColor
        default:
            return primaryColor
        }
    }

    private func flowStep(number: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .foregroundStyle(textColor)
                .frame(width: 32, height: 32)
                .background(primaryColor)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(textColor)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(mutedTextColor)
            }
        }
    }

    private func logicRow(title: String, isActive: Bool, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isActive ? accentColor : mutedTextColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(textColor)

                    Text(isActive ? "Active" : "Inactive")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(isActive ? backgroundColor : mutedTextColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isActive ? accentColor : cardColor)
                        .clipShape(Capsule())
                }

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(mutedTextColor)
            }
        }
        .padding(12)
        .background(backgroundColor.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func metricPill(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(mutedTextColor)

            Text(value)
                .font(.headline)
                .foregroundStyle(textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.22))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(color.opacity(0.35), lineWidth: 1)
        )
    }

    private func summaryRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(primaryColor)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(mutedTextColor)

                Text(value.isEmpty ? "Not provided" : value)
                    .font(.body)
                    .foregroundStyle(textColor)
            }
        }
    }

    private func planCard(text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(accentColor)
                .frame(width: 9, height: 9)
                .padding(.top, 7)

            Text(text)
                .font(.body)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    OverviewView(
        checkIn: WeeklyCheckIn(
            id: UUID().uuidString,
            feeling: "Stressed",
            weekFocus: "Prepare for biology exam and stay caught up in math",
            studyHours: "14",
            scheduleSummary: "Biology test Friday, two work shifts, calculus homework due Wednesday, group project meeting Thursday.",
            goals: [
                "Review biology chapters 4-6",
                "Finish calculus problem set",
                "Submit project outline"
            ],
            blockers: "Heavy workload, limited evenings, tired after work",
            createdAt: Date()
        )
    )
}
