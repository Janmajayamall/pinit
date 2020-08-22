//
//  EmailAuthenticationView.swift
//  pinit
//
//  Created by Janmajaya Mall on 23/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct EmailAuthenticationView: View {
    
    @State var emailId: String = ""
    @State var password: String = ""
    @State var loadingIndicator: Bool = false
    
    @Binding var isOpen: Bool
    var viewType: emailAuthenticationViewType
    
    var body: some View {
        VStack{
            HStack{
                Image(systemName: "xmark")
                    .font(Font.system(size: 15, weight: .bold))
                    .foregroundColor(Color.primaryColor)
                    .onTapGesture {
                        self.isOpen = false
                }
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
                Spacer()
            }
            
            HStack{
                Text(self.viewType == .login ? "Login to your account" : "Sign up with email").font(Font.custom("Avenir", size: 20).bold())
                Spacer()
            }.padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 0))
            
            HStack{
                VStack{
                    TextField("Email", text: self.$emailId)
                        .font(Font.custom("Avenir", size: 15).bold())
                    Divider().background(Color.secondaryColor)
                }
            }.padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
            
            HStack{
                VStack{
                    TextField("Password", text: self.$password)
                        .font(Font.custom("Avenir", size: 15).bold())
                    Divider().background(Color.secondaryColor)
                }
            }.padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 20))
            
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
    }
    
    func authenticateUser() {
        // set loader indicator to true
        self.loadingIndicator = true
        
        //creating sign in coordinator
        let signInWithEmailCoordinator = SignInWithEmailCoordinator(emailId: self.emailId, password: self.password)
        
        if (self.viewType == .login){
            signInWithEmailCoordinator.login { (user) in
                self.loadingIndicator = false
                self.isOpen = false
            }
        }else if (self.viewType == .signUp){
            signInWithEmailCoordinator.signUp { (user) in
                self.loadingIndicator = false
                self.isOpen = false
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
