//
//  EmailSignInView.swift
//  Instructeeze
//
//  Created by Skyler Cuthbertson on 3/7/24.
//

//
//  SignInEmailView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Nick Sarno on 1/21/23.
//

import SwiftUI


private enum FocusableField: Hashable {
  case email
  case password
}


struct EmailSignInView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    @ObservedObject var viewModel: EmailViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focus: FocusableField?
    @State private var presentForgotPassword = false

    var body: some View {
        
        ScrollView {
            Image("LOGO")
                .resizable()
                .frame(width: 200, height: 200)
                .aspectRatio(contentMode: .fit)
                .clipShape(.rect(cornerRadius: 10))
            
            Text("Login")
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
                    .submitLabel(.go)
                    .onSubmit {
                        signInWithEmailPassword()
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 8)
            
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    presentForgotPassword.toggle()
                }
                .fontWeight(.semibold)
                .foregroundStyle(Color(.systemBlue))
                .font(.subheadline)
            }
            
            if !authManager.errorMessage.isEmpty {
                VStack {
                    Text(authManager.errorMessage)
                        .foregroundColor(Color(UIColor.systemRed))
                }
            }
            
            Button(action: signInWithEmailPassword) {
                if authManager.authenticationState != .authenticating {
                    Text("Login")
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
            .disabled(!viewModel.isValid)
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            
            HStack {
                Text("Don't have an account yet?")
                Button(action: { viewModel.switchFlow() }) {
                    Text("Sign up")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding([.top, .bottom], 50)
            
        } // v
        .listStyle(.plain)
        .padding()
        .scrollDismissesKeyboard(.interactively)
        .sheet(isPresented: $presentForgotPassword) { PasswordResetView() }

    
    
    } // body
    
    private func signInWithEmailPassword() {
        Task {
            await viewModel.signIn()
            dismiss()

        } // task
    } // func
    
} // main


