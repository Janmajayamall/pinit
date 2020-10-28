//
//  AuthenticationService.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseAnalytics
import AuthenticationServices
import CryptoKit
import Combine
import UIKit

class AuthenticationService {
    
    private var handle: AuthStateDidChangeListenerHandle?
    private var user: User?
    
    init(){}
    
    func registerStateListener(){
        self.stopStateListener()
        self.handle = Auth.auth().addStateDidChangeListener({(auth, user) in
            self.user = user
            print("User has been recorded as \(user)")
            self.postNotification(for: .authenticationServiceDidAuthStatusChange, withObject: user)
        })
    }
    
    func signOut(){
        do {
            try Auth.auth().signOut()
        }catch {
            print("Error trying to sign out: \(error.localizedDescription)")
        }
    }
    
    func stopStateListener(){
        if let handle = self.handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func startService(){
//        self.registerStateListener()
    }
    
    func stopService(){
        self.stopStateListener()
    }
    
    func setupService() {
        self.registerStateListener()
    }
    
    func postNotification(for notificationType: Notification.Name, withObject object: User?){       
        NotificationCenter.default.post(name: notificationType, object: object)
    }
}

class SignInWithAppleCoordinator: NSObject {
    
    private weak var window: UIWindow!
    private var onSignedInHandler: ((User) -> Void)?
    private var currentNonce: String?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    private func appleIDRequest(withState: SignInState) -> ASAuthorizationAppleIDRequest {
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.state = withState.rawValue
        
        let nonce = randomNonceString()
        self.currentNonce = nonce
        request.nonce = sha256(nonce)
        
        return request
    }
    
    func signIn(onSignedInHandler: @escaping (User) -> Void) {
        
        self.onSignedInHandler = onSignedInHandler
        
        let request = self.appleIDRequest(withState: .signIn)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
    }
}

extension SignInWithAppleCoordinator: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = self.currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
                return
            }
            guard let stateRaw = appleIDCredential.state, let state = SignInState(rawValue: stateRaw) else {
                print("Invalid state: request must be started with one of the SignInStates")
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            switch state {
            case .signIn:
                Auth.auth().signIn(with: credential, completion: {(result, error) in
                    if let error = error {
                        print("Error authenticating: \(error.localizedDescription)")
                        return
                    }
                    
                    // create an event
                    AnalyticsService.logSignUpEvent(withProvider: .apple)
                    
                    guard let user = result?.user else {return}
                    if let onSignedInHandler = self.onSignedInHandler {
                        onSignedInHandler(user)
                    }
                })
            default:
                break
            }
            
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple error: \(error.localizedDescription)")
    }
}

extension SignInWithAppleCoordinator: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.window
    }
}



// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}

@available(iOS 13, *)
private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
    }.joined()
    
    return hashString
}

class SignInWithEmailCoordinator {
    var emailId: String
    var password: String
    var onSignedInHandler: ((User) -> Void)?
    
    init(emailId: String, password:String){
        self.emailId = emailId
        self.password = password
    }
    
    func login(onSignedInHandler: @escaping (User) -> Void, onErrorHandler: @escaping (AuthErrorCode) -> Void) {
        
        self.onSignedInHandler = onSignedInHandler
        
        Auth.auth().signIn(withEmail: self.emailId, password: self.password) { (result, error) in
            if let error = error {
                print("Sign In with email & password failed with error: \(error._code)")
                
                // default error code is 17009 (i.e. when password is wrong)
                onErrorHandler(AuthErrorCode(rawValue: error._code) ?? AuthErrorCode(rawValue: 17009)!)
            }
            
            guard let user = result?.user else {return}
            if let onSignedInHandler = self.onSignedInHandler {
                onSignedInHandler(user)
            }
        }
    }
    
    func signUp(onSignedInHandler: @escaping (User) -> Void, onErrorHandler: @escaping (AuthErrorCode) -> Void) {
        self.onSignedInHandler = onSignedInHandler
        
        Auth.auth().createUser(withEmail: self.emailId, password: self.password) { (result, error) in
            if let error = error {
                print("Create user with email & password failed with error: \(error.localizedDescription)")
                
                // default error coe is 17020 (i.e. network error)
                onErrorHandler(AuthErrorCode(rawValue: error._code) ?? AuthErrorCode(rawValue: 17020)!)
                return
            }
            
            guard let user = result?.user else {return}
            if let onSignedInHandler = self.onSignedInHandler {
                onSignedInHandler(user)
            }
        }
    }
}

enum SignInState: String {
    case signIn
    case reauth
}
