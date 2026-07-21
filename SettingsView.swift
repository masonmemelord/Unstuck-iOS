//
//  SettingsView.swift
//  Unstuck
//
//  Created by Mason Mitchell on 7/15/26.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
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
    private let mutedTextColor = Color(red: 0.580, green: 0.639, blue: 0.722)

    @Environment(\.dismiss) private var dismiss

    @State private var currentEmail = Auth.auth().currentUser?.email ?? "No email available"
    @State private var newEmail = ""
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    @State private var statusMessage = ""
    @State private var isWorking = false
    @State private var isShowingDeleteConfirmation = false

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    accountCard
                    securityCard
                    dangerZone
                }
                .padding(24)
                .padding(.bottom, 32)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
        }
        .alert("Delete account?", isPresented: $isShowingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This permanently deletes your Firebase Auth account. This cannot be undone.")
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Settings")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(textColor)

                Text("Manage your login and account security.")
                    .font(.headline)
                    .foregroundStyle(mutedTextColor)
            }

            Spacer()

            if showsReturnButton {
                Button {
                    dismiss()
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
                .accessibilityLabel("Return to dashboard")
            }
        }
    }

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Login Information", icon: "person.crop.circle.fill", color: primaryColor)

            VStack(alignment: .leading, spacing: 8) {
                Text("Current Email")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(mutedTextColor)

                Text(currentEmail)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            inputField(title: "New Email", placeholder: "name@example.com", text: $newEmail)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            secureInputField(title: "Current Password", placeholder: "Required to update email", text: $currentPassword)

            primaryButton(title: "Update Email", icon: "envelope.fill") {
                updateEmail()
            }
        }
        .settingsCard(cardColor: cardColor, strokeColor: primaryColor)
    }

    private var securityCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Password", icon: "lock.fill", color: accentColor)

            secureInputField(title: "Current Password", placeholder: "Required to update password", text: $currentPassword)
            secureInputField(title: "New Password", placeholder: "At least 6 characters", text: $newPassword)
            secureInputField(title: "Confirm New Password", placeholder: "Retype new password", text: $confirmNewPassword)

            primaryButton(title: "Update Password", icon: "key.fill") {
                updatePassword()
            }
        }
        .settingsCard(cardColor: cardColor, strokeColor: accentColor)
    }

    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Account", icon: "exclamationmark.triangle.fill", color: warningColor)

            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(statusMessageColor)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                signOut()
            } label: {
                actionLabel(title: "Sign Out", icon: "rectangle.portrait.and.arrow.right", color: primaryColor)
            }
            .disabled(isWorking)

            Button(role: .destructive) {
                guard validateCurrentPassword() else { return }
                isShowingDeleteConfirmation = true
            } label: {
                actionLabel(title: "Delete Account", icon: "trash.fill", color: warningColor)
            }
            .disabled(isWorking)

            Text("Deleting your account requires your current password so Firebase can re-authenticate the request.")
                .font(.caption)
                .foregroundStyle(mutedTextColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .settingsCard(cardColor: cardColor, strokeColor: warningColor)
    }

    private var statusMessageColor: Color {
        statusMessage.lowercased().contains("updated") || statusMessage.lowercased().contains("signed out") ? accentColor : warningColor
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

    private func inputField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(mutedTextColor)

            TextField(placeholder, text: text)
                .foregroundStyle(textColor)
                .padding(14)
                .background(backgroundColor.opacity(0.72))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(primaryColor.opacity(0.18), lineWidth: 1)
                )
        }
    }

    private func secureInputField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(mutedTextColor)

            SecureField(placeholder, text: text)
                .textContentType(.password)
                .foregroundStyle(textColor)
                .padding(14)
                .background(backgroundColor.opacity(0.72))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(primaryColor.opacity(0.18), lineWidth: 1)
                )
        }
    }

    private func primaryButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            actionLabel(title: title, icon: icon, color: primaryColor)
        }
        .disabled(isWorking)
    }

    private func actionLabel(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)

            Text(isWorking ? "Working..." : title)
                .font(.headline)

            Spacer()
        }
        .foregroundStyle(textColor)
        .padding(16)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func updateEmail() {
        let trimmedEmail = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            statusMessage = "Enter a new email address."
            return
        }
        guard validateCurrentPassword() else { return }

        reauthenticate { user in
            user.sendEmailVerification(beforeUpdatingEmail: trimmedEmail) { error in
                completeWork(error: error, successMessage: "Verification sent. Confirm the new email to finish updating your login.") {
                    newEmail = ""
                    clearPasswords()
                }
            }
        }
    }

    private func updatePassword() {
        guard validateCurrentPassword() else { return }
        guard newPassword.count >= 6 else {
            statusMessage = "New password must be at least 6 characters."
            return
        }
        guard newPassword == confirmNewPassword else {
            statusMessage = "New passwords do not match."
            return
        }

        reauthenticate { user in
            user.updatePassword(to: newPassword) { error in
                completeWork(error: error, successMessage: "Password updated.") {
                    clearPasswords()
                }
            }
        }
    }

    private func deleteAccount() {
        guard validateCurrentPassword() else { return }

        reauthenticate { user in
            user.delete { error in
                completeWork(error: error, successMessage: "Account deleted.") {
                    clearPasswords()
                    dismiss()
                }
            }
        }
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
            statusMessage = "Signed out."
            dismiss()
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func validateCurrentPassword() -> Bool {
        guard !currentPassword.isEmpty else {
            statusMessage = "Enter your current password first."
            return false
        }

        return true
    }

    private func reauthenticate(then action: @escaping (FirebaseAuth.User) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            statusMessage = "No signed-in email account was found."
            return
        }

        isWorking = true
        statusMessage = ""

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error {
                completeWork(error: error, successMessage: "")
                return
            }

            action(user)
        }
    }

    private func completeWork(error: Error?, successMessage: String, onSuccess: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            isWorking = false

            if let error {
                statusMessage = error.localizedDescription
                return
            }

            onSuccess?()
            statusMessage = successMessage
        }
    }

    private func clearPasswords() {
        currentPassword = ""
        newPassword = ""
        confirmNewPassword = ""
    }
}

private extension View {
    func settingsCard(cardColor: Color, strokeColor: Color) -> some View {
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
    SettingsView()
}
