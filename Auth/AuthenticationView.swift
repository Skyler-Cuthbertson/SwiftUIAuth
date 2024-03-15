//
//  SignUpView.swift
//  Instructeeze
//
//  Created by Skyler Cuthbertson on 3/7/24.
//


//
//  AuthenticationView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Nick Sarno on 1/21/23.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    @StateObject private var viewModel = AuthenticationViewModel()
    
    @StateObject private var viewModelEmail = EmailViewModel()
    
    var body: some View {
            
        ScrollView {
            Image("LOGO")
                .resizable()
                .frame(width: 200, height: 200)
                .aspectRatio(contentMode: .fit)
                .clipShape(.rect(cornerRadius: 10))
                .padding(.bottom, 20)
            
            // MARK: - APPPLE
            Button(action: {
                Task {
                    do {
                        try await viewModel.signInApple()
                        authManager.authenticationState = .authenticated
                        // dismiss()
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                SignInWithAppleButtonViewRepresentable(type: .continue, style: .white)
                    .allowsHitTesting(false)
            })
            .frame(height: 55)
            
            
            // MARK: - GOOGLE
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)) {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        authManager.authenticationState = .authenticated
                        // dismiss()
                    } catch {
                        print(error)
                    }
                }
            }
//            .frame(height: 55)
            
            
            // MARK: - EMAIL & PASSWORD
            NavigationLink {
                switch authManager.flow {
                case .login:
                    EmailSignInView(viewModel: viewModelEmail)
                case .signUp:
                    EmailSignUpView(viewModel: viewModelEmail)
                } // switch
            } label: {
                HStack {
                    Image(systemName: "envelope.fill")
                    Text("Continue with Email")
                }
                .font(.headline)
                .foregroundColor(.black)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(5)
            } // nav link
            
            Spacer()
        } // scroll
        .padding()
        .navigationTitle(Text("Instructeeze"))
   
    } // body
} // main



