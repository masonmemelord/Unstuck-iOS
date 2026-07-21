//
//  AboutView.swift
//  Unstuck
//
//  Created by Mason Mitchell on 7/15/26.
//

import SwiftUI

struct AboutView: View {
    private let backgroundColor = Color(red: 0.043, green: 0.059, blue: 0.078)
    private let cardColor = Color(red: 0.071, green: 0.102, blue: 0.141)
    private let primaryColor = Color(red: 0.231, green: 0.510, blue: 0.965)
    private let accentColor = Color(red: 0.133, green: 0.773, blue: 0.369)
    private let textColor = Color(red: 0.973, green: 0.980, blue: 0.988)
    private let mutedTextColor = Color(red: 0.700, green: 0.753, blue: 0.835)

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    missionCard
                    founderCard
                    teamCard
                    nextBuildCard
                }
                .padding(24)
                .padding(.bottom, 32)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("About Unstuck")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(textColor)

                Text("A student-built app for students")
                    .font(.headline)
                    .foregroundStyle(mutedTextColor)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

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
    }

    private var missionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Mission", icon: "target", color: accentColor)

            Text("Unstuck exists to help students turn stress, workload, and scattered goals into a focused weekly plan.")
                .font(.body.weight(.semibold))
                .foregroundStyle(textColor)
                .fixedSize(horizontal: false, vertical: true)

            Text("Students face a multitude of stressors, and sometimes the work becomes their life. Unstuck allows a break from the constant work, and provides plans to build structure, wellness, and success.")
                .font(.subheadline)
                .foregroundStyle(mutedTextColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .aboutCard(cardColor: cardColor, strokeColor: accentColor)
    }

    private var founderCard: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(primaryColor)
                    .frame(width: 56, height: 56)
                    .background(primaryColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Mason Mitchell")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(textColor)

                    Text("Founder, developer, and designer of Unstuck.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(mutedTextColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text("I started Unstuck as a  tool for students who need structure outside of school curriculum. I believe that bringing holistic balance is key to success.")
                .font(.subheadline)
                .foregroundStyle(mutedTextColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .aboutCard(cardColor: cardColor, strokeColor: primaryColor)
    }

    private var teamCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Team Values", icon: "person.3.fill", color: accentColor)

            valueRow(title: "Student-first", detail: "The app is designed around real student schedules, energy, and academic pressure.")
            valueRow(title: "Recovery-aware", detail: "Plans should support progress without pushing students deeper into burnout.")
            valueRow(title: "Practical", detail: "Every screen should help the user take a clear next step.")
        }
        .aboutCard(cardColor: cardColor, strokeColor: accentColor)
    }

    private var nextBuildCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Next Build", icon: "hammer.fill", color: primaryColor)

            Text("Current roadmap items for making Unstuck more reliable, secure, and useful.")
                .font(.subheadline)
                .foregroundStyle(mutedTextColor)
                .fixedSize(horizontal: false, vertical: true)

            valueRow(title: "Stronger check-in validation", detail: "Validate required answers and study-hour input before saving weekly check-ins to Firebase.")
            valueRow(title: "Account data cleanup", detail: "Delete the user's Firestore check-ins when their account is deleted.")
            valueRow(title: "Automated testing", detail: "Add tests for dashboard metrics, Firestore decoding, and the main navigation flow.")
        }
        .aboutCard(cardColor: cardColor, strokeColor: primaryColor)
    }

    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(color)

            Text(title)
                .font(.headline)
                .foregroundStyle(textColor)
        }
    }

    private func valueRow(title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(accentColor)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(textColor)

                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(mutedTextColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private extension View {
    func aboutCard(cardColor: Color, strokeColor: Color) -> some View {
        self
            .padding(18)
            .background(cardColor)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(strokeColor.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    AboutView()
}
