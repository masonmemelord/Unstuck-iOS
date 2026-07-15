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

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                AppNavBar(title: "Home", onHome: nil) {
                    try? Auth.auth().signOut()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Unstuck")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(textColor)

                    Text("Plan your week around your energy, workload, and goals.")
                        .font(.headline)
                        .foregroundStyle(mutedTextColor)
                }

                VStack(spacing: 14) {
                    Button {
                        isShowingTestingView = true
                    } label: {
                        homeButtonLabel(
                            title: "Start Weekly Check-In",
                            icon: "calendar.badge.plus",
                            color: primaryColor
                        )
                    }

                    Button {
                        // Later: open latest saved OverviewView from Firestore
                    } label: {
                        homeButtonLabel(
                            title: "View Latest Plan",
                            icon: "list.bullet.clipboard",
                            color: accentColor
                        )
                    }

                }
            }
            .padding(24)
            .frame(maxWidth: 420)
        }
        .fullScreenCover(isPresented: $isShowingTestingView) {
            TestingView()
        }
    }

    private func homeButtonLabel(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .frame(width: 28)

            Text(title)
                .font(.headline)

            Spacer()
        }
        .foregroundStyle(textColor)
        .padding(16)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    HomeView()
}
