//
//  AuthenticationManager.swift
//  Instructeeze
//
//  Created by Skyler Cuthbertson on 3/7/24.
//

//
//  AuthenticationManager.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Nick Sarno on 1/21/23.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

enum AuthenticationState {
  case unauthenticated
  case authenticating
  case authenticated
}

enum AuthenticationFlow {
  case login
  case signUp
}


@MainActor
class AuthenticationManager: ObservableObject {
    
    static var shared = AuthenticationManager()
    
    private init() {
        self.registerAuthStateHandler()
    }
    
    
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var user: User?
    @Published var flow: AuthenticationFlow = .login
    @Published var errorMessage = ""
    @Published var loading = false

    
    private var authStateHandler: AuthStateDidChangeListenerHandle?

    
    // MARK: - Functions
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
                self.authenticationState = user == nil ? .unauthenticated : .authenticated
                print("YEET", self.authenticationState)
                
            }
        }
    }
    

        
//    func getProviders() throws -> [AuthProviderOption] {
//        guard let providerData = Auth.auth().currentUser?.providerData else {
//            throw URLError(.badServerResponse)
//        }
//        
//        var providers: [AuthProviderOption] = []
//        for provider in providerData {
//            if let option = AuthProviderOption(rawValue: provider.providerID) {
//                providers.append(option)
//            } else {
//                assertionFailure("Provider option not found: \(provider.providerID)")
//            }
//        }
//        print(providers)
//        return providers
//    }
        
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.flow = .login
            self.authenticationState = .unauthenticated
        } catch {
            print(error)
            self.authenticationState = .unauthenticated
            self.errorMessage = error.localizedDescription
            
        }
    }
    
    func delete() async {
        guard let user = Auth.auth().currentUser else {
            self.authenticationState = .unauthenticated
            print(URLError(.badURL).localizedDescription)
            return
        }
        
        do {
            try Auth.auth().signOut()
            try await user.delete() // delete the auth user
            try await UserManager.shared.userDocument(userId: user.uid).delete() // delete the users/user.id document
            
            DispatchQueue.main.async {
                self.flow = .login
                self.authenticationState = .unauthenticated
            }
        } catch {
            print(error)
            DispatchQueue.main.async {
                self.authenticationState = .unauthenticated
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - SIGN IN EMAIL

extension AuthenticationManager {
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func resetPassword(email: String) async throws {
        DispatchQueue.main.async {
            self.loading = true
            self.errorMessage = ""
        }
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            DispatchQueue.main.async {
                self.loading = false
            }

        } catch {
            print(error)
            DispatchQueue.main.async {
                self.loading = false
            }
            throw error
        }
    }
    
//    func updatePassword(password: String) async throws {
//        self.loading = true
//        self.errorMessage = ""
//        
//        guard let user = Auth.auth().currentUser else {
//            throw URLError(.badServerResponse)
//        }
//        do {
//            try await user.updatePassword(to: password)
//            self.loading = false
//        } catch {
//            
//        }
//    }
    
    func updateEmail(email: String) async throws {
        DispatchQueue.main.async {
            self.loading = true
            self.errorMessage = ""
        }
        
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        do {
            try await user.updateEmail(to: email)
            DispatchQueue.main.async {
                self.loading = false
            }
        } catch {
            print(error)
            DispatchQueue.main.async {
                self.loading = false
            }
            throw error
        }
    }
}

// MARK: - SIGN IN SSO

extension AuthenticationManager {
    
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    @discardableResult
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}


