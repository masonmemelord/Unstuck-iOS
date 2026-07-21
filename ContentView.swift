//
//  ContentView.swift
//  Unstuck
//
//  Created by Mason Mitchell on 7/6/26.
//

import SwiftUI
import FirebaseAuth

private enum AuthMode {
    case login //case for Login and signUp
    case signUp

    var title: String {
        switch self {
        case .login:
            return "Log in"
        case .signUp:
            return "Sign up"
        }
    }

    var subtitle: String {
        switch self {
        case .login:
            return "Welcome back to Unstuck."
        case .signUp:
            return "Create an account to start getting Unstuck."
        }
    }

    var buttonTitle: String {
        switch self {
        case .login:
            return "Log In"
        case .signUp:
            return "Sign Up"
        }
    }
}

struct ContentView: View {
    private let backgroundColor = Color(red: 0.043, green: 0.059, blue: 0.078)
    private let cardColor = Color(red: 0.071, green: 0.102, blue: 0.141)
    private let primaryColor = Color(red: 0.231, green: 0.510, blue: 0.965)
    private let accentColor = Color(red: 0.133, green: 0.773, blue: 0.369)
    private let warningColor = Color(red: 0.976, green: 0.451, blue: 0.086)
    private let textColor = Color(red: 0.973, green: 0.980, blue: 0.988)
    private let mutedTextColor = Color(red: 0.580, green: 0.639, blue: 0.722)

    @State private var currentUser: FirebaseAuth.User?
    @State private var authListener: AuthStateDidChangeListenerHandle?
    @State private var isShowingLogin = false
    @State private var isShowingNewUserOnboarding = false
    @State private var authMode: AuthMode = .login
    @State private var email = ""
    @State private var password = ""
    @State private var authMessage = ""
    @State private var isAuthenticating = false

    var body: some View {
        Group {
            if currentUser == nil {
                coverPage
            } else if isShowingNewUserOnboarding {
                MainView()
            } else {
                MainTabView()
            }
        }
        .onAppear {
            startAuthListener()
        }
        .sheet(isPresented: $isShowingLogin) {
            loginSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var coverPage: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 24) { //Icon Logic
                Image(systemName: "brain.filled.head.profile")
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundStyle(primaryColor)
                    .frame(width: 96, height: 96)
                    .background(cardColor)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(accentColor.opacity(0.35), lineWidth: 1)
                    )

                VStack(spacing: 10) {
                    Text("Unstuck")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(textColor)

                    Text("Get Unstuck.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(mutedTextColor)
                }

                Button { //Button Login
                    isShowingLogin = true
                } label: {
                    Text("Start")
                        .font(.headline)
                        .foregroundStyle(textColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(primaryColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                HStack(spacing: 10) { //HStack works similar to navbar Left-Right logic
                    Circle()
                        .fill(accentColor)
                        .frame(width: 10, height: 10)
                    Text("Recovery ready")
                        .font(.subheadline)
                        .foregroundStyle(mutedTextColor)
                    Circle()
                        .fill(warningColor)
                        .frame(width: 10, height: 10)
                }
            }
            .padding(28)
            .frame(maxWidth: 360)
            .background(cardColor.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(primaryColor.opacity(0.25), lineWidth: 1)
            )
            .padding()
        }
    }
    // This view basically functions as a new View within the same file. When you click start it asks for you to either Sign Up/In
    private var loginSheet: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(authMode.title)
                        .font(.title.bold())
                        .foregroundStyle(textColor)

                    Text(authMode.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(mutedTextColor)
                }

                HStack(spacing: 8) {
                    authModeButton("Log In", mode: .login)
                    authModeButton("Sign Up", mode: .signUp)
                }
                .padding(4)
                .background(cardColor)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                    //$email is being changed to and sent to Firebasse
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .inputStyle(cardColor: cardColor, textColor: textColor)

                    SecureField("Password", text: $password)
                        .textContentType(.password) //SecureField takes password and send it to Firebase
                        .inputStyle(cardColor: cardColor, textColor: textColor)
                }

                if !authMessage.isEmpty {
                    Text(authMessage)
                        .font(.footnote)
                        .foregroundStyle(authMessage == "Logged in." || authMessage == "Account created." ? accentColor : warningColor)
                }

                Button {
                    handleAuthAction()
                } label: {
                    authButtonLabel(authMode.buttonTitle)
                }
                .disabled(isAuthenticating)
            }
            .padding(24)
        }
    }
    
    //function initializating variables title as a string and mode. Arrow functions as the logic being returned to the view
    // Functions always need
    // 1. initialization, 2. logic, 3. return
    private func authModeButton(_ title: String, mode: AuthMode) -> some View {
        Button {
            authMode = mode
            authMessage = ""
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(authMode == mode ? textColor : mutedTextColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(authMode == mode ? primaryColor : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .disabled(isAuthenticating)
    }

    private func authButtonLabel(_ title: String) -> some View {
        HStack {
            if isAuthenticating {
                ProgressView()
                    .tint(textColor)
            }

            Text(title)
                .font(.headline)
        }
        .foregroundStyle(textColor)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
        .background(primaryColor)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func startAuthListener() { //checks for any auth changes
        guard authListener == nil else { return }

        currentUser = Auth.auth().currentUser
        authListener = Auth.auth().addStateDidChangeListener { _, user in
            currentUser = user

            if user == nil {
                isShowingNewUserOnboarding = false
            }
        }
    }

    private func handleAuthAction() {
        //Switch case, works similar to an if/elif branch
        switch authMode {
        case .login:
            signIn()
        case .signUp:
            createAccount()
        }
    }

    private func signIn() {
        //guard is a security credential that takes the variable(s) out of scope if requirements arent met/
        guard validateCredentials() else { return }

        isAuthenticating = true
        authMessage = ""

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isAuthenticating = false

            if let error {
                authMessage = error.localizedDescription
                return
            }

            currentUser = result?.user //Question-mark works as a collapse 
            password = ""
            authMessage = "Logged in."
            isShowingLogin = false
            isShowingNewUserOnboarding = false
        }
    }

    private func createAccount() {
        guard validateCredentials() else { return }

        isAuthenticating = true
        authMessage = ""

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isAuthenticating = false

            if let error {
                authMessage = error.localizedDescription
                return
            }

            currentUser = result?.user
            password = ""
            authMessage = "Account created."
            isShowingLogin = false
            isShowingNewUserOnboarding = true
        }
    }

    private func validateCredentials() -> Bool {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || password.isEmpty {
            authMessage = "Enter an email and password."
            return false
        }

        return true
    }
}

private enum MainAppTab: Hashable {
    case home
    case checkIn
    case history
    case settings
}

private struct MainTabView: View {
    private let backgroundColor = Color(red: 0.043, green: 0.059, blue: 0.078)
    private let primaryColor = Color(red: 0.231, green: 0.510, blue: 0.965)

    @State private var selectedTab: MainAppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                onStartCheckIn: { selectedTab = .checkIn },
                onShowPlanHistory: { selectedTab = .history },
                showsSettingsButton: false
            )
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(MainAppTab.home)

            TestingView(showsReturnButton: false) {
                selectedTab = .home
            }
            .tabItem {
                Label("Check-In", systemImage: "square.and.pencil")
            }
            .tag(MainAppTab.checkIn)

            PlanHistoryView(showsReturnButton: false)
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            .tag(MainAppTab.history)

            SettingsView(showsReturnButton: false)
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(MainAppTab.settings)
        }
        .tint(primaryColor)
        .toolbarBackground(backgroundColor, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

private extension View {
    func inputStyle(cardColor: Color, textColor: Color) -> some View {
        self
            .foregroundStyle(textColor)
            .padding(14)
            .background(cardColor)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .textFieldStyle(.plain)
    }
}

#Preview {
    ContentView()
}
