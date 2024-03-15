//
//  PasswordResetView.swift
//  Instructeeze
//
//  Created by Skyler Cuthbertson on 3/12/24.
//

import SwiftUI


struct PasswordResetView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
        
    @State var email: String = ""
    @State private var showAlert = false

    private func resetPassword() {
        Task {
            do {
                try await authManager.resetPassword(email: email)
                showAlert.toggle()
            } catch {
                print(error)
            }
        }
    } // func
    
    var body: some View {
        ScrollView {
            Image("LOGO")
                .resizable()
                .frame(width: 125, height: 125)
                .aspectRatio(contentMode: .fit)
                .clipShape(.rect(cornerRadius: 10))
            
            Text("Reset Password")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "at")
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                    .submitLabel(.send)
                    .onSubmit { resetPassword() }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 4)
            

            
            if !authManager.errorMessage.isEmpty {
                VStack {
                    Text(authManager.errorMessage)
                        .foregroundColor(Color(UIColor.systemRed))
                }
            }
            
            Button(action: resetPassword) {
                if !authManager.loading {
                    Text("Reset Password")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(!email.contains("@"))
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            
        } // v
        .listStyle(.plain)
        .padding()
        .scrollDismissesKeyboard(.interactively)
        .onAppear { authManager.errorMessage = "" }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Password Reset Link Sent"), message: Text("A password reset link has been sent to your email."), dismissButton: .cancel(Text("Ok"), action: { dismiss() }))
        }
    }
}
