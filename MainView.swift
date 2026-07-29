//
//  Main.swift
//  Unstuck
//
//  Created by Mason Mitchell on 7/7/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MainView: View {
    let onComplete: (() -> Void)?

    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
    }
    private let backgroundColor = Color(red: 0.043, green: 0.059, blue: 0.078)
    private let cardColor = Color(red: 0.071, green: 0.102, blue: 0.141)
    private let primaryColor = Color(red: 0.231, green: 0.510, blue: 0.965)
    private let accentColor = Color(red: 0.133, green: 0.773, blue: 0.369)
    private let textColor = Color(red: 0.973, green: 0.980, blue: 0.988)
    private let mutedTextColor = Color(red: 0.700, green: 0.753, blue: 0.835)
    
    //Array logic
    private let schoolYears = ["Freshman", "Sophomore", "Junior", "Senior", "Graduate", "Other"]
    
    //variable list @State because they're dynamic
    @State private var college = ""
    @State private var major = ""
    @State private var creditsTaken = ""
    @State private var schoolYear = "Freshman"
    @State private var profileMessage = ""
    @State private var isSavingProfile = false
    

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start getting Unstuck")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(textColor)
                            .padding(.top, 16)
                        
                        Text("But first, about you.")
                            .font(.headline)
                            .foregroundStyle(mutedTextColor)
                            .padding(.bottom, 10)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        
                        //local changes for the logic, check how title and placeholder are being updated
                        profileField(title: "College", placeholder: "Where do you go?", text: $college)
                        profileField(title: "Major", placeholder: "What are you studying?", text: $major)
                        profileField(title: "Credits Taken", placeholder: "Example: 45", text: $creditsTaken)
                            .keyboardType(.numberPad)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("School Year")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(textColor)
                            
                            //For loop calls the picker until a choice is made
                            Picker("School Year", selection: $schoolYear) {
                                ForEach(schoolYears, id: \.self) { year in
                                    Text(year)
                                }
                            }
                            
                            //Aesthetic changes
                            .pickerStyle(.menu)
                            .tint(textColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(cardColor)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(primaryColor.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }

                    Button {
                        saveProfile()
                    } label: {
                        HStack {
                            if isSavingProfile {
                                ProgressView()
                                    .tint(textColor)
                            }

                            Text(isSavingProfile ? "Saving..." : "Continue")
                                .font(.headline)
                        }
                        .foregroundStyle(textColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(primaryColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .disabled(isSavingProfile)

                    if !profileMessage.isEmpty {
                        Text(profileMessage)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(profileMessageColor)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack(spacing: 10) {
                        Text("Your answers help personalize your recovery plan.")
                            .font(.footnote)
                            .foregroundStyle(mutedTextColor)
                    }
                }
                .padding(24)
                .frame(maxWidth: 420)
                .frame(maxWidth: .infinity)
            }
        }
    }
    //private function being called in the ZStack
    //variables in the parenthesis are being initialized and the arrow represents the logic being send to the view
    private func profileField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(textColor)

            TextField(placeholder, text: text)
                .textInputAutocapitalization(.words)
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

    private var profileMessageColor: Color {
        profileMessage == "Profile saved." ? accentColor : Color(red: 0.976, green: 0.451, blue: 0.086)
    }

    private func saveProfile() {
        guard !isSavingProfile else { return }

        let trimmedCollege = college.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMajor = major.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCredits = creditsTaken.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedCollege.isEmpty else {
            profileMessage = "Enter your college before continuing."
            return
        }

        guard !trimmedMajor.isEmpty else {
            profileMessage = "Enter your major before continuing."
            return
        }

        guard let creditCount = Int(trimmedCredits), (0...300).contains(creditCount) else {
            profileMessage = "Credits taken must be a number between 0 and 300."
            return
        }

        isSavingProfile = true
        profileMessage = ""

        if let uid = Auth.auth().currentUser?.uid {
            // Signed-in profiles stay under users/{uid} for future cross-device sync.
            let profileData: [String: Any] = [
                "college": trimmedCollege,
                "major": trimmedMajor,
                "creditsTaken": creditCount,
                "schoolYear": schoolYear,
                "onboardingCompleted": true,
                "updatedAt": FieldValue.serverTimestamp()
            ]

            Firestore.firestore()
                .collection("users")
                .document(uid)
                .setData(profileData, merge: true) { error in
                    isSavingProfile = false

                    if let error {
                        profileMessage = error.localizedDescription
                        return
                    }

                    profileMessage = "Profile saved."
                    onComplete?()
                }
            return
        }

        // Local profiles keep onboarding private and available without network access.
        LocalProfileStore.save(
            LocalUserProfile(
                college: trimmedCollege,
                major: trimmedMajor,
                creditsTaken: creditCount,
                schoolYear: schoolYear,
                updatedAt: Date()
            )
        )
        isSavingProfile = false
        profileMessage = "Profile saved."
        onComplete?()
    }
}

#Preview {
    MainView()
}
