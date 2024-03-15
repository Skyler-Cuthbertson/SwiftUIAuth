//
//  ProfileView.swift
//  Instructeeze
//
//  Created by Skyler Cuthbertson on 3/12/24.
//


import SwiftUI
import FirebaseAnalytics
import FirebaseAuth

struct UserProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var SM: StudentsDataModel
    @EnvironmentObject var CM: CoursesDataModel
    @Environment(\.dismiss) var dismiss
    @State var presentingConfirmationDialog = false
    @State var presentingConfirmationDialogSignOut = false
    @State var presentingChangeEmail = false
    @State var presentingResetPassword = false
    @State var showAlert = false
    
    private func deleteAccount() {
        Task {
            
            await authManager.delete()
            dismiss() // Adios
            
        } // task
    } // func

    private func signOut() {
        authManager.signOut()
        SM.resetData()
    }

    var body: some View {
        Form {
            Section {
                VStack {
                    HStack {
                        Spacer()
                        Image("LOGO")
                            .resizable()
                            .frame(width: 125 , height: 125)
                            .aspectRatio(contentMode: .fit)
                            .clipShape(.rect(cornerRadius: 10))
                        Spacer()
                    }
                }
            }
            .listRowBackground(Color(UIColor.systemGroupedBackground))
            
            Section("Email") {
                Text(authManager.user?.email ?? "No User Found")
            }
            
            Section("Edit Account") {
                Button(role: .cancel, action: { presentingChangeEmail.toggle() }) {
                    HStack {
                        Text("").frame(maxWidth: 0) // make the listRowDivider extend all the way
                        Spacer()
                        Text("Change Email")
                        Spacer()
                    }
                }


                Button(role: .cancel, action: { presentingResetPassword.toggle() }) {
                    HStack {
                        Text("").frame(maxWidth: 0) // make the listRowDivider extend all the way
                        Spacer()
                        Text("Reset Password")
                        Spacer()
                    }
                }
            } // section
            
            Section {
                Button(role: .cancel, action: { presentingConfirmationDialogSignOut.toggle() }) {
                    HStack {
                        Spacer()
                        Text("Sign Out")
                        Spacer()
                    }
                }
            }
            
            Section {
                Button(role: .destructive, action: { presentingConfirmationDialog.toggle() }) {
                    HStack {
                        Spacer()
                        Text("Delete Account")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        
        .sheet(isPresented: $presentingChangeEmail) { ChangeEmailView() }
        .sheet(isPresented: $presentingResetPassword) { PasswordResetView() }
        
        .confirmationDialog("Deleting your account is permanent. Do you want to delete your account?",
                            isPresented: $presentingConfirmationDialog, titleVisibility: .visible) {
            Button("Delete Account", role: .destructive, action: {showAlert.toggle()})
            Button("Cancel", role: .cancel, action: { })
        }
        .confirmationDialog("Do you want to sign out of your account?",
                            isPresented: $presentingConfirmationDialogSignOut, titleVisibility: .visible) {
            Button("Sign Out", action: signOut).bold()
            Button("Cancel", role: .cancel, action: { })
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Confirm Delete"), message: Text("This cannot be reversed and all data will be deleted."), primaryButton: .destructive(Text("Delete"), action: {
                deleteAccount()
            }), secondaryButton: .cancel(Text("Cancel")))
        }
    }
}
