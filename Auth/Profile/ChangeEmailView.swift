//
//  ChangeEmailView.swift
//  Instructeeze
//
//  Created by Skyler Cuthbertson on 3/12/24.
//



import SwiftUI


private enum FocusableField: Hashable {
  case email
  case password
}

struct ChangeEmailView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State var newEmail: String = ""
    @State var password: String = ""
    @FocusState private var focus: FocusableField?
    
    @State private var showAlert = false

    private func changeEmail() {
        Task {
            do {
                try await authManager.updateEmail(email: newEmail)
                showAlert.toggle()
            } catch {
                print(error)
            }
        }
    }

    var body: some View {
        ScrollView {
            Image("LOGO")
                .resizable()
                .frame(width: 125, height: 125)
                .aspectRatio(contentMode: .fit)
                .clipShape(.rect(cornerRadius: 10))
            
            Text("Change Email Address")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "at")
                TextField("New Email", text: $newEmail)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($focus, equals: .email)
                    .keyboardType(.emailAddress)
                    .submitLabel(.next)
                    .onSubmit {
                        changeEmail()
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 4)
            
            HStack {
                Image(systemName: "lock")
                SecureField("Current Password", text: $password)
                    .focused($focus, equals: .password)
                    .submitLabel(.send)
                    .onSubmit {
                        changeEmail()
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
            
            Button(action: changeEmail) {
                if !authManager.loading {
                    Text("Change Email")
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
            .disabled(!newEmail.contains("@") || password.count < 6)
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            
        } // v
        .listStyle(.plain)
        .padding()
        .scrollDismissesKeyboard(.interactively)
        .onAppear { authManager.errorMessage = "" }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Verify New Email"), message: Text("A verification link has been sent to your new email. Once verified, login with your new credentials."), dismissButton: .cancel(Text("Ok"), action: { authManager.signOut() }))
        }
    }
}
