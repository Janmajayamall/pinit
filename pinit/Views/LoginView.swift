//
//  LoginView.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.window) var window: UIWindow?
    
    var parentSize: CGSize
    
    var viewHeight: CGFloat {
        print(self.parentSize.height, self.viewHeightRatio)
        return self.parentSize.height * self.viewHeightRatio
    }
    var offset: CGSize {
        if (self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.activeType == .login){
            return CGSize(width: .zero, height: self.parentSize.height - self.viewHeight)
        }
        return CGSize(width: .zero, height: self.parentSize.height)
    }
    
    @State var signInWithAppleCoordinator: SignInWithAppleCoordinator?
    
    @State var isEmailAuthViewOpen = false
    @State var emailAuthViewType: emailAuthenticationViewType = .signUp
    var body: some View {
        
        VStack{
            HStack{
                Image(systemName: "xmark")
                    .foregroundColor(Color.primaryColor)
                    .applyDefaultIconTheme()
                    .onTapGesture {
                        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .normal)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                Spacer()
            }
            Spacer()
            HStack{
                Text("Create an account to continue")
                    .applyDefaultThemeToTextHeader(ofType: .h1)
            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 30, trailing: 10))
            
            HStack{
                Button(action: {
                    self.emailAuthViewType = .signUp
                    self.isEmailAuthViewOpen = true
                }, label: {
                    Spacer()
                    Text("Sign up with Email")
                        .font(Font.custom("Avenir", size: 18).bold())
                        .foregroundColor(Color.white)
                    Spacer()
                    
                })
            }
            .frame(width: 280, height: 45)
            .background(Color.primaryColor)
            .cornerRadius(5)
            
            UIKitSignInWithApple().frame(width: 280, height: 45).onTapGesture {
                self.signInWithAppleCoordinator = SignInWithAppleCoordinator(window: self.window)
                self.signInWithAppleCoordinator?.signIn(onSignedInHandler: {user in                   
                    
//                    // close the login view
//                    self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .normal)
                })
            }
            
            Spacer()
            
            HStack{
                Text("Already have an account?").foregroundColor(Color.black)
                Text("Log In with email").foregroundColor(Color.primaryColor)
            }
            .font(Font.custom("Avenir", size: 15).bold())
            .foregroundColor(Color.black)
            .onTapGesture {
                self.emailAuthViewType = .login
                self.isEmailAuthViewOpen = true
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            
            Spacer()
            
            HStack{
                Spacer()
                Text("By signing in you agree with you Terms and Conditions.")
                .font(Font.custom("Avenir", size: 15))
                .foregroundColor(Color.black)
                Spacer()
            }.padding(.bottom, 20)
            
            Spacer()
        }
        .frame(width: self.parentSize.width, height: self.viewHeight)
        .background(Color.white)
        .cornerRadius(12)
        .offset(self.offset)
        .animation(.spring())
        .sheet(isPresented: self.$isEmailAuthViewOpen, content: {
            EmailAuthenticationView(isOpen: self.$isEmailAuthViewOpen, viewType: self.emailAuthViewType)
        })
    }
    
    private let viewHeightRatio: CGFloat = 0.6
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(parentSize: CGSize(width: 300, height: 800)).environmentObject(SettingsViewModel())
    }
}


