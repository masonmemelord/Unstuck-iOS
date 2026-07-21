//
//  PlanHistoryView.swift
//  Unstuck
//
//  Created by Mason Mitchell on 7/20/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PlanHistoryView: View {
    @Environment(\.dismiss) private var dismiss

    let showsReturnButton: Bool

    init(showsReturnButton: Bool = true) {
        self.showsReturnButton = showsReturnButton
    }

    private let backgroundColor = Color(red: 0.043, green: 0.059, blue: 0.078)
    private let cardColor = Color(red: 0.071, green: 0.102, blue: 0.141)
    private let primaryColor = Color(red: 0.231, green: 0.510, blue: 0.965)
    private let accentColor = Color(red: 0.133, green: 0.773, blue: 0.369)
    private let warningColor = Color(red: 0.976, green: 0.451, blue: 0.086)
    private let textColor = Color(red: 0.973, green: 0.980, blue: 0.988)
    private let mutedTextColor = Color(red: 0.700, green: 0.753, blue: 0.835)

    @State private var checkIns: [WeeklyCheckIn] = []
    @State private var selectedCheckIn: WeeklyCheckIn?
    @State private var isLoading = false
    @State private var message = ""

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        summaryCard
                        contentState
                    }
                    .padding(24)
                    .padding(.bottom, 32)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .onAppear {
            loadPlanHistory()
        }
        .refreshable {
            loadPlanHistory()
        }
        .fullScreenCover(item: $selectedCheckIn) { checkIn in
            OverviewView(checkIn: checkIn) {
                selectedCheckIn = nil
            }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            if showsReturnButton {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "house.fill")
                        .font(.headline)
                        .foregroundStyle(textColor)
                        .frame(width: 44, height: 44)
                        .background(cardColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(primaryColor.opacity(0.24), lineWidth: 1)
                        )
                }
                .accessibilityLabel("Return to dashboard")
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Plan History")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(textColor)

                Text("Saved weekly check-ins")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(mutedTextColor)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
        .padding(.bottom, 12)
        .background(backgroundColor)
    }

    private var summaryCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.headline)
                .foregroundStyle(accentColor)
                .frame(width: 34, height: 34)
                .background(accentColor.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text("Your saved plans")
                    .font(.headline)
                    .foregroundStyle(textColor)

                Text(summaryText)
                    .font(.subheadline)
                    .foregroundStyle(mutedTextColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accentColor.opacity(0.22), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var contentState: some View {
        if isLoading {
            stateCard(
                icon: "arrow.triangle.2.circlepath",
                title: "Loading plans",
                detail: "Checking Firestore for your saved weekly check-ins.",
                color: primaryColor
            )
        } else if checkIns.isEmpty {
            stateCard(
                icon: "calendar.badge.plus",
                title: "No saved plans yet",
                detail: message.isEmpty ? "Create a weekly check-in first, then come back here to review it." : message,
                color: warningColor
            )
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("History")
                    .font(.headline)
                    .foregroundStyle(textColor)

                ForEach(checkIns) { checkIn in
                    Button {
                        selectedCheckIn = checkIn
                    } label: {
                        historyRow(for: checkIn)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var summaryText: String {
        if isLoading {
            return "Loading your saved plans."
        }

        if checkIns.count == 1 {
            return "1 saved plan is available. Tap it to share the results in the plan overview."
        }

        if checkIns.count > 1 {
            return "\(checkIns.count) saved plans are available. Newest plans appear first."
        }

        return message.isEmpty ? "Plan history will appear here after Firebase saves your first check-in." : message
    }

    private func historyRow(for checkIn: WeeklyCheckIn) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: iconName(for: checkIn.feeling))
                    .font(.headline)
                    .foregroundStyle(textColor)
                    .frame(width: 36, height: 36)
                    .background(color(for: checkIn.feeling).opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(checkIn.weekFocus.isEmpty ? "Weekly Plan" : checkIn.weekFocus)
                        .font(.headline)
                        .foregroundStyle(textColor)
                        .lineLimit(2)

                    Text(dateFormatter.string(from: checkIn.createdAt))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(mutedTextColor)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(mutedTextColor)
                    .padding(.top, 8)
            }

            HStack(spacing: 8) {
                tag(checkIn.feeling, color: color(for: checkIn.feeling))
                tag("\(checkIn.studyHours) study hrs", color: primaryColor)
                tag("\(cleanedGoals(for: checkIn).count) goals", color: accentColor)
            }
        }
        .padding(16)
        .background(cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(primaryColor.opacity(0.16), lineWidth: 1)
        )
    }

    private func tag(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.caption.weight(.bold))
            .foregroundStyle(textColor)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func stateCard(icon: String, title: String, detail: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(textColor)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(mutedTextColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor.opacity(0.74))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func loadPlanHistory() {
        guard let uid = Auth.auth().currentUser?.uid else {
            checkIns = []
            message = "Sign in to load your saved plans."
            return
        }

        isLoading = true
        message = ""

        // Security: user data stays under users/{uid}; Firestore rules should also require request.auth.uid == uid.
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("weeklyCheckIns")
            .order(by: "createdAt", descending: true) // Newest saved check-ins appear first in history.
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    isLoading = false

                    if let error {
                        checkIns = []
                        message = error.localizedDescription
                        return
                    }

                    let decodedCheckIns = snapshot?.documents.compactMap { makeCheckIn(from: $0) } ?? []
                    checkIns = decodedCheckIns
                    message = decodedCheckIns.isEmpty ? "No saved weekly plans found." : ""
                }
            }
    }

    private func makeCheckIn(from document: QueryDocumentSnapshot) -> WeeklyCheckIn? {
        let data = document.data()

        // Decode each field defensively so one malformed Firestore document does not break the whole list.
        guard
            let feeling = data["feeling"] as? String,
            let weekFocus = data["weekFocus"] as? String,
            let studyHours = data["studyHours"] as? String,
            let scheduleSummary = data["scheduleSummary"] as? String,
            let goals = data["goals"] as? [String],
            let blockers = data["blockers"] as? String
        else {
            return nil
        }

        let createdAt: Date
        if let timestamp = data["createdAt"] as? Timestamp {
            createdAt = timestamp.dateValue()
        } else if let date = data["createdAt"] as? Date {
            createdAt = date
        } else {
            createdAt = Date()
        }

        return WeeklyCheckIn(
            id: data["id"] as? String ?? document.documentID,
            feeling: feeling,
            weekFocus: weekFocus,
            studyHours: studyHours,
            scheduleSummary: scheduleSummary,
            goals: goals,
            blockers: blockers,
            createdAt: createdAt
        )
    }

    private func cleanedGoals(for checkIn: WeeklyCheckIn) -> [String] {
        checkIn.goals
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func iconName(for feeling: String) -> String {
        switch feeling {
        case "Stressed":
            return "exclamationmark.triangle.fill"
        case "Focused":
            return "scope"
        case "Motivated":
            return "bolt.fill"
        case "Burnt out":
            return "flame.fill"
        default:
            return "circle.fill"
        }
    }

    private func color(for feeling: String) -> Color {
        switch feeling {
        case "Burnt out", "Stressed":
            return warningColor
        case "Motivated":
            return accentColor
        case "Focused":
            return primaryColor
        default:
            return mutedTextColor
        }
    }
}

#Preview {
    PlanHistoryView()
}
