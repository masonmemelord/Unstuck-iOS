//
//  HomeView.swift
//  Unstuck
//
//  Created by Mason Mitchell on 7/14/26.
//

import SwiftUI
import SwiftData
import FirebaseAuth
import FirebaseFirestore



struct HomeView: View {
    @Query(sort: \LocalWeeklyCheckin.createdAt, order: .reverse)
    private var localCheckins: [LocalWeeklyCheckin]
    
    let onStartCheckIn: (() -> Void)?
    let onShowPlanHistory: (() -> Void)?
    let showsSettingsButton: Bool

    init(
        onStartCheckIn: (() -> Void)? = nil,
        onShowPlanHistory: (() -> Void)? = nil,
        showsSettingsButton: Bool = true
    ) {
        self.onStartCheckIn = onStartCheckIn
        self.onShowPlanHistory = onShowPlanHistory
        self.showsSettingsButton = showsSettingsButton
    }

    private let backgroundColor = Color(red: 0.043, green: 0.059, blue: 0.078)
    private let cardColor = Color(red: 0.071, green: 0.102, blue: 0.141)
    private let primaryColor = Color(red: 0.231, green: 0.510, blue: 0.965)
    private let accentColor = Color(red: 0.133, green: 0.773, blue: 0.369)
    private let warningColor = Color(red: 0.976, green: 0.451, blue: 0.086)
    private let textColor = Color(red: 0.973, green: 0.980, blue: 0.988)
    private let mutedTextColor = Color(red: 0.700, green: 0.753, blue: 0.835)
    

    @State private var isShowingTestingView = false
    @State private var isShowingSettings = false
    @State private var isShowingAbout = false
    @State private var isShowingLatestPlan = false
    @AppStorage(LocalWeeklyCheckInStore.revisionKey) private var localCheckInsRevision = 0
    @State private var isShowingPlanHistory = false
    @State private var latestCheckIn: WeeklyCheckIn?
    @State private var isLoadingLatestCheckIn = false
    @State private var dashboardMessage = ""

    private var metrics: DashboardMetrics {
        DashboardMetrics.from(
            latestCheckIn: latestCheckIn,
            isLoading: isLoadingLatestCheckIn,
            fallbackMessage: dashboardMessage
        )
    }

    private var localCheckInSignature: String {
        "\(localCheckInsRevision):" + localCheckins.map(\.id).joined(separator: ",")
    }

    private var userEmail: String {
        if let email = Auth.auth().currentUser?.email {
            return email
        }

        // Local mode uses onboarding details instead of a Firebase email.
        if let profile = LocalProfileStore.load() {
            return "\(profile.schoolYear) · \(profile.major)"
        }

        return "Local Student"
    }

    private var workloadColor: Color {
        switch metrics.workload {
        case "Heavy":
            return warningColor
        case "Moderate":
            return primaryColor
        case "Light":
            return accentColor
        default:
            return mutedTextColor
        }
    }

    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    weeklyStatusCard
                    metricGrid
                    actionSection
                    
                }
                .padding(24)
                .padding(.bottom, 32)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            loadLatestCheckIn()
        }
        .onChange(of: localCheckInSignature) {
            loadLatestCheckIn()
        }
        .fullScreenCover(isPresented: $isShowingTestingView, onDismiss: loadLatestCheckIn) {
            TestingView()
        }
        .fullScreenCover(isPresented: $isShowingLatestPlan) {
            if let latestCheckIn {
                OverviewView(checkIn: latestCheckIn) {
                    isShowingLatestPlan = false
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingPlanHistory, onDismiss: loadLatestCheckIn) {
            PlanHistoryView()
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $isShowingAbout) {
            AboutView()
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Dashboard")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(textColor)

                Text(userEmail)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(mutedTextColor)
                    .lineLimit(1)
            }

            Spacer()

            if showsSettingsButton {
                Button {
                    isShowingSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
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
                .accessibilityLabel("Open settings")
            }
        }
    }

    private var weeklyStatusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: latestCheckIn == nil ? "calendar.badge.clock" : "calendar.badge.checkmark")
                    .font(.title2)
                    .foregroundStyle(latestCheckIn == nil ? primaryColor : accentColor)
                    .frame(width: 34)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Weekly Check-In")
                        .font(.headline)
                        .foregroundStyle(textColor)

                    Text(metrics.weeklyStatusText)
                        .font(.subheadline)
                        .foregroundStyle(mutedTextColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button {
                openCheckIn()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(latestCheckIn == nil ? "Start Weekly Check-In" : "Create New Check-In")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.headline)
                .foregroundStyle(textColor)
                .padding(16)
                .background(primaryColor)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(18)
        .background(cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(primaryColor.opacity(0.22), lineWidth: 1)
        )
    }

    private var metricGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            metricTile(title: "Plan Status", value: metrics.planStatus, icon: "list.bullet.clipboard", color: latestCheckIn == nil ? warningColor : accentColor)
            metricTile(title: "Check-In", value: metrics.checkIn, icon: "checkmark.circle", color: primaryColor)
            metricTile(title: "Recovery", value: metrics.recovery, icon: "heart.fill", color: accentColor)
            metricTile(title: "Workload", value: metrics.workload, icon: "books.vertical.fill", color: workloadColor)
        }
    }

    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actions")
                .font(.headline)
                .foregroundStyle(textColor)

            actionRow(
                title: "Create this week's plan",
                detail: "Answer your weekly check-in questions.",
                icon: "square.and.pencil",
                color: primaryColor
            ) {
                openCheckIn()
            }

            actionRow(
                title: "Plan History",
                detail: latestCheckIn == nil ? "View saved plans after your first check-in." : "Review every saved weekly plan.",
                icon: "clock.arrow.circlepath",
                color: accentColor
            ) {
                openPlanHistory()
            }

            actionRow(
                title: "About Unstuck",
                detail: "Find out about us and future plans.",
                icon: "info.circle.fill",
                color: primaryColor
            ) {
                isShowingAbout = true
            }
        }
    }
    
    private func metricTile(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.headline)
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(mutedTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(color.opacity(0.18), lineWidth: 1)
        )
    }

    private func actionRow(title: String, detail: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(color)
                    .frame(width: 34, height: 34)
                    .background(color.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(textColor)

                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(mutedTextColor)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(mutedTextColor)
            }
            .padding(14)
            .background(cardColor)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func checklistItem(_ title: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "circle")
                .font(.caption)
                .foregroundStyle(accentColor)
                .padding(.top, 3)

            Text(title)
                .font(.footnote)
                .foregroundStyle(mutedTextColor)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func openCheckIn() {
        if let onStartCheckIn {
            onStartCheckIn()
        } else {
            isShowingTestingView = true
        }
    }

    private func openPlanHistory() {
        if let onShowPlanHistory {
            onShowPlanHistory()
        } else {
            isShowingPlanHistory = true
        }
    }

    private func loadLatestCheckIn() {
        guard let uid = Auth.auth().currentUser?.uid else {
            // Local users read from SwiftData first, then fall back to the older device store.
            latestCheckIn = localCheckins.first?.weeklyCheckIn ?? LocalWeeklyCheckInStore.latest()
            dashboardMessage = latestCheckIn == nil ? "No saved weekly plan yet." : ""
            return
        }

        isLoadingLatestCheckIn = true
        dashboardMessage = ""

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("weeklyCheckIns")
            .order(by: "createdAt", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                isLoadingLatestCheckIn = false

                if let error {
                    latestCheckIn = nil
                    dashboardMessage = error.localizedDescription
                    return
                }

                guard let document = snapshot?.documents.first else {
                    latestCheckIn = nil
                    dashboardMessage = "No saved weekly plan yet."
                    return
                }

                latestCheckIn = makeCheckIn(from: document)
                dashboardMessage = latestCheckIn == nil ? "Could not read the latest weekly plan." : ""
            }
    }

    private func makeCheckIn(from document: QueryDocumentSnapshot) -> WeeklyCheckIn? {
        let data = document.data()

        guard
            let id = data["id"] as? String,
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

#Preview {
    HomeView()
}
