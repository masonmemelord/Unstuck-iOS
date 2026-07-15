//
//  Main.swift
//  Unstuck
//
//  Created by Mason Mitchell on 7/7/26.
//

import SwiftUI

struct MainView: View {
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
    @State private var isShowingTestingView = false
    @State private var schoolYear = "Freshman"
    

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
                        isShowingTestingView = true
                    } label: {
                        Text("Continue")
                            .font(.headline)
                            .foregroundStyle(textColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(primaryColor)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
        .fullScreenCover(isPresented: $isShowingTestingView) {
            TestingView()
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

    private func saveProfile() {
        // Hook this into Firestore when you are ready to persist onboarding answers.
    }
}

#Preview {
    MainView()
}
