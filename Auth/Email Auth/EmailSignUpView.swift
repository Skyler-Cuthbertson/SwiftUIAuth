//
//  SignUpView.swift
//  Instructeeze
//
//  Created by Skyler Cuthbertson on 3/12/24.
//

import SwiftUI

private enum FocusableField: Hashable {
    case email
    case password
    case confirmPassword
}

struct EmailSignUpView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    @ObservedObject var viewModel: EmailViewModel
    @Environment(\.dismiss) var dismiss

    @FocusState private var focus: FocusableField?

    private func signUpWithEmailPassword() {
        if viewModel.password == viewModel.confirmPassword {
            Task {
                await viewModel.signUp()
                dismiss()
            }
        } else {
            authManager.errorMessage = "Confirmation password does not match."
        }
        
    }

    var body: some View {
        ScrollView {
            Image("LOGO")
                .resizable()
                .frame(width: 200, height: 200)
                .aspectRatio(contentMode: .fit)
                .clipShape(.rect(cornerRadius: 10))
            
            Text("Sign up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "at")
                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .password
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 4)
            
            HStack {
                Image(systemName: "lock")
                SecureField("Password", text: $viewModel.password)
                    .focused($focus, equals: .password)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .confirmPassword
                    }
                
                if viewModel.password == viewModel.confirmPassword && viewModel.password.count > 5 {
                    Spacer()
                    Image(systemName: "checkmark.seal.fill").foregroundStyle(.green).padding(.trailing)
                }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 8)
            
            HStack {
                Image(systemName: "lock.rotation")
                SecureField("Confirm password", text: $viewModel.confirmPassword)
                    .focused($focus, equals: .confirmPassword)
                    .submitLabel(.go)
                    .onSubmit { signUpWithEmailPassword() }
                
                if viewModel.password == viewModel.confirmPassword && viewModel.password.count > 5 {
                    Spacer()
                    Image(systemName: "checkmark.seal.fill").foregroundStyle(.green).padding(.trailing)
                }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 8)
            
            
            if !authManager.errorMessage.isEmpty {
                VStack {
                    Text(authManager.errorMessage)
                        .foregroundColor(Color(UIColor.systemRed))
                }
            }
            
            Button(action: signUpWithEmailPassword) {
                if authManager.authenticationState != .authenticating {
                    Text("Sign up")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(!viewModel.isValid)
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            
            HStack {
                Text("Already have an account?")
                Button(action: { viewModel.switchFlow() }) {
                    Text("Log in")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding([.top, .bottom], 50)
            
        }
        .listStyle(.plain)
        .padding()
        .scrollDismissesKeyboard(.interactively)
    }
}

