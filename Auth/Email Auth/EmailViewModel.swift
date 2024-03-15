//
//  SignInEmailViewModel.swift
//  Instructeeze
//
//  Created by Skyler Cuthbertson on 3/7/24.
//

//
//  SignInEmailViewModel.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Nick Sarno on 1/21/23.
//

import Foundation

@MainActor
class EmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    @Published var isValid  = false

    init() {
        AuthenticationManager.shared.$flow
            .combineLatest($email, $password, $confirmPassword)
            .map { flow, email, password, confirmPassword in
            flow == .login
              ? !(!email.contains("@") || password.count < 6)
              : !(!email.contains("@") || password.count < 6 || confirmPassword.count < 6 || password != confirmPassword)
            }
            .assign(to: &$isValid)
    }
    
    
    func signUp() async {
        DispatchQueue.main.async {
            AuthenticationManager.shared.authenticationState = .authenticating
            AuthenticationManager.shared.errorMessage = ""
        }
        
        do {
            let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
            let user = DBUser(auth: authDataResult)
            try await UserManager.shared.createNewUser(user: user)
            
            DispatchQueue.main.async {
                AuthenticationManager.shared.authenticationState = .authenticated
            }

        } catch {
            print(error)
            DispatchQueue.main.async {
                AuthenticationManager.shared.errorMessage = error.localizedDescription
                AuthenticationManager.shared.authenticationState = .unauthenticated
            }
        } // catch

    } // func
    
    func signIn() async {
        DispatchQueue.main.async {
            AuthenticationManager.shared.authenticationState = .authenticating
            AuthenticationManager.shared.errorMessage = ""
        }
 
        do {
            try await AuthenticationManager.shared.signInUser(email: email, password: password)
            DispatchQueue.main.async {
                AuthenticationManager.shared.authenticationState = .authenticated
            }
        } catch {
            print(error)
            DispatchQueue.main.async {
                AuthenticationManager.shared.errorMessage = error.localizedDescription
                AuthenticationManager.shared.authenticationState = .unauthenticated
            }
        } // catch
        
    } // func
    
    
    func reset() {
        AuthenticationManager.shared.flow = .login
        email = ""
        password = ""
        confirmPassword = ""
    } // func
    
    func switchFlow() {
        AuthenticationManager.shared.flow = AuthenticationManager.shared.flow == .login ? .signUp : .login
        AuthenticationManager.shared.errorMessage = ""
        self.password = ""
        self.confirmPassword = ""
    } // func
    
}
