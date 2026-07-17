//
//  HomeView.swift
//  Unstuck
//
//  Created by Mason Mitchell on 7/14/26.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
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
    @State private var latestCheckIn: WeeklyCheckIn?

    private var userEmail: String {
        Auth.auth().currentUser?.email ?? "Student"
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
                    nextBuildSection
                }
                .padding(24)
                .padding(.bottom, 32)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
        }
        .fullScreenCover(isPresented: $isShowingTestingView) {
            TestingView()
        }
        .fullScreenCover(isPresented: $isShowingLatestPlan) {
            if let latestCheckIn {
                OverviewView(checkIn: latestCheckIn)
            }
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

    private var weeklyStatusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundStyle(primaryColor)
                    .frame(width: 34)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Weekly Check-In")
                        .font(.headline)
                        .foregroundStyle(textColor)

                    Text("Start a check-in to generate this week's plan. Saved history comes next when Firebase data storage is added.")
                        .font(.subheadline)
                        .foregroundStyle(mutedTextColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button {
                isShowingTestingView = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Start Weekly Check-In")
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
            metricTile(title: "Plan Status", value: "Pending", icon: "list.bullet.clipboard", color: warningColor)
            metricTile(title: "Check-In", value: "Needed", icon: "checkmark.circle", color: primaryColor)
            metricTile(title: "Recovery", value: "Unset", icon: "heart.fill", color: accentColor)
            metricTile(title: "Workload", value: "Unknown", icon: "books.vertical.fill", color: mutedTextColor)
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
                isShowingTestingView = true
            }

            actionRow(
                title: "View Latest Plan",
                detail: latestCheckIn == nil ? "No saved plan loaded yet." : "Open your most recent weekly plan.",
                icon: "doc.text.magnifyingglass",
                color: accentColor
            ) {
                isShowingLatestPlan = true
            }
            .opacity(latestCheckIn == nil ? 0.55 : 1)
            .disabled(latestCheckIn == nil)

            actionRow(
                title: "About Unstuck",
                detail: "Read the mission, founder note, and team values.",
                icon: "info.circle.fill",
                color: primaryColor
            ) {
                isShowingAbout = true
            }
        }
    }

    private var nextBuildSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Next Build")
                .font(.headline)
                .foregroundStyle(textColor)

            checklistItem("Save WeeklyCheckIn records under the signed-in user's uid.")
            checklistItem("Load the latest check-in here and replace the placeholder metrics.")
            checklistItem("Add a plan history view once multiple check-ins exist.")
        }
        .padding(18)
        .background(cardColor.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accentColor.opacity(0.18), lineWidth: 1)
        )
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
}

#Preview {
    HomeView()
}
