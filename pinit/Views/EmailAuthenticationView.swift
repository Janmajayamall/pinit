//
//  EmailAuthenticationView.swift
//  pinit
//
//  Created by Janmajaya Mall on 23/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI
import FirebaseAuth
import FirebaseAnalytics

struct EmailAuthenticationView: View {
    
    @State var emailId: String = ""
    @State var password: String = "" {
        didSet {
            if self.password.count <= 6 {
                self.passwordError = "Password is weak. Choose a stronger password"
            }
        }
    }
    @State var loadingIndicator: Bool = false
    
    @State var passwordError: String = ""
    @State var emailIdError:String = ""
    
    @Binding var isOpen: Bool
    var viewType: emailAuthenticationViewType
    
    var body: some View {
        VStack{
            HStack{
                Image(systemName: "xmark")
                    .foregroundColor(Color.primaryColor)
                    .applyDefaultIconTheme()
                    .onTapGesture {
                        self.isOpen = false
                }
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
                Spacer()
            }
            
            HStack{
                Text(self.viewType == .login ? "Login to your account" : "Sign up with email")
                    .font(Font.custom("Avenir", size: 20).bold())
                    .foregroundColor(Color.black)
                Spacer()
            }.padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 0))
            
            HStack{
                VStack{
                    CustomTextFieldView(text: self.$emailId, placeholder: "Email ID", noteText: self.$emailIdError)
                        .font(Font.custom("Avenir", size: 15).bold())
                        .foregroundColor(Color.black)
                }
            }.padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
            
            HStack{
                VStack{
                    CustomTextFieldView(text: self.$password, placeholder: "Password", noteText: self.$passwordError, isFieldSecure: true)
                        .font(Font.custom("Avenir", size: 15).bold())
                        .foregroundColor(Color.black)
                }
            }.padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
            
            HStack{
                Button(action: {
                    self.authenticateUser()
                }, label: {
                    Spacer()
                    Text(self.viewType == .login ? "Login" : "Sign Up").font(Font.custom("Avenir", size: 20).bold()).foregroundColor(Color.white)
                    Spacer()
                    
                })
            }
            .frame(width: 280, height: 45)
            .background(Color.primaryColor)
            .cornerRadius(5)
            
            Spacer()
        }
        .background(Color.white)
    }
    
    func authenticateUser() {
        // set loader indicator to true
        self.loadingIndicator = true
        
        //creating sign in coordinator
        let signInWithEmailCoordinator = SignInWithEmailCoordinator(emailId: self.emailId, password: self.password)
        
        if (self.viewType == .login){
            signInWithEmailCoordinator.login(onSignedInHandler: {(user) in
                self.loadingIndicator = false
                self.isOpen = false
                
               // create an event
                AnalyticsService.logSignInEvent(withProvider: .email)
                
            }) { (errorCode) in
                switch (errorCode){
                case .invalidEmail:
                    self.emailIdError = "Email ID is not valid"
                    self.passwordError = ""
                case .missingEmail:
                    self.emailIdError = "EmailID cannot be empty"
                    self.passwordError = ""
                case .wrongPassword:
                    self.passwordError = "Password is invalid"
                    self.emailIdError = ""
                case .userNotFound:
                    self.passwordError = "User with email does not exists"
                    self.emailIdError = ""
                default:
                    self.passwordError = "Email or Password are incorrect"
                    self.emailIdError = ""
                }
            }
        }else if (self.viewType == .signUp){
            signInWithEmailCoordinator.signUp(onSignedInHandler: { (user) in
                self.loadingIndicator = false
                self.isOpen = false
                
                // create an event
                AnalyticsService.logSignInEvent(withProvider: .email)
                
            }) { (errorCode) in
                switch (errorCode){
                case .emailAlreadyInUse:
                    self.emailIdError = "Account with Email ID already exists"
                    self.passwordError = ""
                case .invalidEmail:
                    self.emailIdError = "Email ID is invalid"
                    self.passwordError = ""
                case .missingEmail:
                    self.emailIdError = "Email ID field is empty"
                    self.passwordError = ""
                case .weakPassword:
                    self.passwordError = "Enter a stronger password"
                default:
                    self.passwordError = "Sorry, something went wrong. Please try again!"
                }
            }
        }
    }
}

enum emailAuthenticationViewType {
    case signUp
    case login
}

//struct SignInWithEmailView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignInWithEmailView(isOpen: )
//    }
//}
