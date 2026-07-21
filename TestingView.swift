//
//  TestingView.swift
//  Unstuck
//
//  Created by Mason Mitchell on 7/8/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore


struct TestingView: View {
    @Environment(\.dismiss) private var dismiss

    let showsReturnButton: Bool
    let onReturnHome: (() -> Void)?

    init(showsReturnButton: Bool = true, onReturnHome: (() -> Void)? = nil) {
        self.showsReturnButton = showsReturnButton
        self.onReturnHome = onReturnHome
    }
    
    private let backgroundColor = Color(red: 0.043, green: 0.059, blue: 0.078)
    private let cardColor = Color(red: 0.071, green: 0.102, blue: 0.141)
    private let primaryColor = Color(red: 0.231, green: 0.510, blue: 0.965)
    private let accentColor = Color(red: 0.133, green: 0.773, blue: 0.369)
    private let warningColor = Color(red: 0.976, green: 0.451, blue: 0.086)
    private let textColor = Color(red: 0.973, green: 0.980, blue: 0.988)
    private let mutedTextColor = Color(red: 0.700, green: 0.753, blue: 0.835)
    
    

    private let feelings = ["Stressed", "Focused", "Motivated", "Burnt out"]

    @State private var selectedFeeling = ""
    @State private var weekFocus = ""
    @State private var scheduleSummary = ""
    @State private var studyHours = ""
    @State private var goals = [""]
    @State private var blockers = ""
    @State private var saveMessage = ""
    @State private var savedCheckIn: WeeklyCheckIn?
    @State private var isShowingOverview = false

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if showsReturnButton {
                            returnHeader
                        }

                        if selectedFeeling.isEmpty {
                            feelingPrompt
                        } else {
                            weeklyCheckInForm(scrollProxy: scrollProxy)
                        }
                    }
                    .padding(24)
                    .padding(.bottom, 32)
                    .frame(maxWidth: 460)
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
                .fullScreenCover(isPresented: $isShowingOverview) {
                    if let savedCheckIn {
                        OverviewView(checkIn: savedCheckIn) {
                            returnHome()
                        }
                    }
                }
            }
        }
    }

    private var returnHeader: some View {
        HStack {
            Button {
                returnHome()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(textColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(cardColor)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(primaryColor.opacity(0.24), lineWidth: 1)
                )
            }
            .accessibilityLabel("Return to dashboard")

            Spacer()
        }
    }

    private var feelingPrompt: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text("How are you feeling?")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(textColor)
                Text("Choose the feeling that best describes how you feel right now.")
                    .font(.headline)
                    .foregroundStyle(mutedTextColor)
                    .padding(.bottom, 20)
            }

            VStack(spacing: 12) {
                ForEach(feelings, id: \.self) { feeling in
                    Button {
                        selectedFeeling = feeling
                    } label: {
                        HStack {
                            Text(feeling)
                                .font(.headline)
                                .foregroundStyle(feelingTextColor(for: feeling))

                            Spacer()

                            Image(systemName: iconName(for: feeling))
                                .font(.headline)
                                .foregroundStyle(feelingTextColor(for: feeling))
                        }
                        .padding(16)
                        .background(feelingBackgroundColor(for: feeling))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(feelingTextColor(for: feeling).opacity(0.24), lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(.top, 48)
    }

    private func weeklyCheckInForm(scrollProxy: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            header

            VStack(alignment: .leading, spacing: 16) {
                inputField(title: "Weekly academic goal", placeholder: "What is the main theme for this week?", text: $weekFocus)

                inputField(title: "Study Hours", placeholder: "Example: 12", text: $studyHours)
                    .keyboardType(.numberPad)

                textArea(
                    title: "Weekly Schedule",
                    placeholder: "List your classes, work shifts, deadlines, meetings, and open study blocks.",
                    text: $scheduleSummary,
                    minHeight: 130
                )
            }

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Goals for the Week")
                        .font(.title3.bold())
                        .foregroundStyle(textColor)

                    Spacer()

                    Button {
                        addGoal(scrollProxy: scrollProxy)
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(textColor)
                            .frame(width: 36, height: 36)
                            .background(primaryColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .accessibilityLabel("Add goal")
                }

                ForEach(goals.indices, id: \.self) { index in
                    goalField(index: index)
                        .id(goalID(for: index))
                }
            }

            textArea(
                title: "Possible Blockers",
                placeholder: "What might get in the way this week?",
                text: $blockers,
                minHeight: 100
            )

            Button {
                saveWeeklyCheckIn()
            } label: {
                Text("Save Weekly Plan")
                    .font(.headline)
                    .foregroundStyle(textColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(primaryColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            if !saveMessage.isEmpty {
                Text(saveMessage)
                    .font(.footnote)
                    .foregroundStyle(accentColor)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(primaryColor)
                    .frame(width: 48, height: 48)
                    .background(cardColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Check-In")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(textColor)

                    Text("You are feeling \(selectedFeeling.lowercased()). Lets get to it!")
                        .font(.subheadline)
                        .foregroundStyle(mutedTextColor)
                }
            }

            Button {
                selectedFeeling = ""
                saveMessage = ""
            } label: {
                Text("Change Feeling")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(primaryColor)
            }
        }
    }

    private func goalField(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Goal \(index + 1)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(textColor)

                Spacer()

                if goals.count > 1 {
                    Button {
                        removeGoal(at: index)
                    } label: {
                        Image(systemName: "minus")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(textColor)
                            .frame(width: 28, height: 28)
                            .background(warningColor)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .accessibilityLabel("Remove goal \(index + 1)")
                }
            }

            TextField(goalPlaceholder(for: index), text: goalBinding(for: index))
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled()
                .foregroundStyle(textColor)
                .padding(14)
                .background(cardColor)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(primaryColor.opacity(0.2), lineWidth: 1)
                )
                .textFieldStyle(.plain)
        }
    }

    private func inputField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(textColor)

            TextField(placeholder, text: text)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled()
                .foregroundStyle(textColor)
                .padding(14)
                .background(cardColor)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(primaryColor.opacity(0.2), lineWidth: 1)
                )
                .textFieldStyle(.plain)
        }
    }

    private func textArea(title: String, placeholder: String, text: Binding<String>, minHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(textColor)

            TextEditor(text: text)
                .frame(minHeight: minHeight)
                .foregroundStyle(textColor)
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(
                    ZStack(alignment: .topLeading) {
                        cardColor

                        if text.wrappedValue.isEmpty {
                            Text(placeholder)
                                .font(.body)
                                .foregroundStyle(mutedTextColor.opacity(0.75))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 8)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(primaryColor.opacity(0.2), lineWidth: 1)
                )
        }
    }

    private func addGoal(scrollProxy: ScrollViewProxy) {
        goals.append("")
        saveMessage = ""

        let newGoalID = goalID(for: goals.count - 1)
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                scrollProxy.scrollTo(newGoalID, anchor: .center)
            }
        }
    }

    private func removeGoal(at index: Int) {
        guard goals.indices.contains(index), goals.count > 1 else { return }
        goals.remove(at: index)
        saveMessage = ""
    }

    private func goalBinding(for index: Int) -> Binding<String> {
        Binding(
            get: {
                guard goals.indices.contains(index) else { return "" }
                return goals[index]
            },
            set: { newValue in
                guard goals.indices.contains(index) else { return }
                goals[index] = newValue
            }
        )
    }

    private func returnHome() {
        isShowingOverview = false

        if let onReturnHome {
            onReturnHome()
        } else {
            dismiss()
        }
    }

    private func goalPlaceholder(for index: Int) -> String {
        switch index {
        case 0:
            return "Most important goal"
        case 1:
            return "Second priority"
        case 2:
            return "Third priority"
        default:
            return "Goal \(index + 1)"
        }
    }

    private func goalID(for index: Int) -> String {
        "goal-\(index)"
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

    private func feelingBackgroundColor(for feeling: String) -> Color {
        switch feeling {
        case "Stressed":
            return Color(red: 0.855, green: 0.647, blue: 0.125)
        case "Focused":
            return Color(red: 0.576, green: 0.773, blue: 0.992)
        case "Motivated":
            return accentColor
        case "Burnt out":
            return Color(red: 0.875, green: 0.184, blue: 0.184)
        default:
            return cardColor
        }
    }

    private func feelingTextColor(for feeling: String) -> Color {
        textColor
    }

    private func saveWeeklyCheckIn() {
        guard let uid = Auth.auth().currentUser?.uid else {
            saveMessage = "Please sign in before saving your weekly plan."
            return
        }

        let checkIn = WeeklyCheckIn(
            id: UUID().uuidString,
            feeling: selectedFeeling,
            weekFocus: weekFocus,
            studyHours: studyHours,
            scheduleSummary: scheduleSummary,
            goals: goals,
            blockers: blockers,
            createdAt: Date()
        )

        let data: [String: Any] = [
            "id": checkIn.id,
            "feeling": checkIn.feeling,
            "weekFocus": checkIn.weekFocus,
            "studyHours": checkIn.studyHours,
            "scheduleSummary": checkIn.scheduleSummary,
            "goals": checkIn.goals,
            "blockers": checkIn.blockers,
            "createdAt": Timestamp(date: checkIn.createdAt)
        ]

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("weeklyCheckIns")
            .document(checkIn.id)
            .setData(data) { error in
                if let error {
                    saveMessage = error.localizedDescription
                    return
                }

                savedCheckIn = checkIn
                saveMessage = "Weekly plan saved."
                isShowingOverview = true
            }
    }
    }

#Preview {
    TestingView()
}
