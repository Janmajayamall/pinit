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
        return self.parentSize.height * self.viewHeightRatio
    }
    var offset: CGSize {
        if (self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.activeType == .login){
            return CGSize(width: .zero, height: self.parentSize.height - self.viewHeight)
        }
        return CGSize(width: .zero, height: self.parentSize.height)
    }
    
    @State var signInWithAppleCoordinator: SignInWithAppleCoordinator?
    
    @State var emailAuthViewType: emailAuthenticationViewType = .signUp
    
    @State var isSheetOpen: Bool = false
    @State var loginViewSheetType: LoginViewSheetType = .none
    var body: some View {
        
        VStack{
            HStack{
                Image(systemName: "xmark")                
                    .applyDefaultIconTheme(forIconDisplayType: .normal)
                    .onTapGesture {
                        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .normal)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                Spacer()
            }
            Spacer()
            HStack{
                Text("Create an account \nto continue")
                    .applyDefaultThemeToTextHeader(ofType: .h1)
                .lineLimit(nil)
            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10))
            HStack{
                Button(action: {
                    self.emailAuthViewType = .signUp
                    self.loginViewSheetType = .emailAuth
                    self.isSheetOpen = true
                    
                    // set user default
                    self.settingsViewModel.onboardingViewModel.markOnboardingStatus(for: .unauthenticatedMainARView, to: 1)
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
                
                // set user default
                self.settingsViewModel.onboardingViewModel.markOnboardingStatus(for: .unauthenticatedMainARView, to: 1)
            }
                                    
            VStack{
                HStack{
                    Spacer()
                    Text("By signing up, you confirm that you agree")
                    Spacer()
                }
                HStack{
                    Spacer()
                    Text("with our")
                    Text("End User License Agreement")
                        .underline()
                        .foregroundColor(Color.blue)
                        .onTapGesture {
                            self.loginViewSheetType = .endUserLicenseAgreement
                            self.isSheetOpen = true
                    }
                    Text("and have")
                    .foregroundColor(Color.textfieldColor)
                    Spacer()
                }
                HStack{
                    Spacer()
                    Text("read and understood our")
                    Text("Privacy Policy")
                        .underline()
                        .foregroundColor(Color.blue)
                        .onTapGesture {
                            self.loginViewSheetType = .privacyPolicy
                            self.isSheetOpen = true
                    }
                    Spacer()
                }
            }
            .font(Font.custom("Avenir", size: 13))
            .foregroundColor(Color.textfieldColor)
            .padding(EdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5))
            
            Spacer()
            
            //            Divider().background(Color.blue).frame(height: 10)
            HStack{
                Text("Already have an account?").foregroundColor(Color.black)
                Text("Log In").foregroundColor(Color.primaryColor)
            }
            .font(Font.custom("Avenir", size: 18).bold())
            .foregroundColor(Color.black)
            .onTapGesture {
                self.emailAuthViewType = .login
                self.loginViewSheetType = .emailAuth
                self.isSheetOpen = true
                
                // set user default
                self.settingsViewModel.onboardingViewModel.markOnboardingStatus(for: .unauthenticatedMainARView, to: 1)
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))
            
            
        }
        .frame(width: self.parentSize.width, height: self.viewHeight)
        .background(Color.white)
        .cornerRadius(12)
        .offset(self.offset)
        .animation(.spring())
        .sheet(isPresented: self.$isSheetOpen, content: {
            if (self.loginViewSheetType == .emailAuth){
                EmailAuthenticationView(isOpen: self.$isSheetOpen, viewType: self.emailAuthViewType)
            }else if (self.loginViewSheetType == .privacyPolicy){
                UIKitSafariWebView(url: URL(string: "http://www.finchit.tech/privacy")!)
            }else if (self.loginViewSheetType == .endUserLicenseAgreement){
                TermsAndConditionsView(isOpen: self.$isSheetOpen)
            }
            
            VStack{Text("").foregroundColor(Color.white)}.background(Color.white)
            
        })
    }
    
    private let viewHeightRatio: CGFloat = 0.65
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(parentSize: CGSize(width: 300, height: 800)).environmentObject(SettingsViewModel())
    }
}

enum LoginViewSheetType {
    case emailAuth
    case privacyPolicy
    case endUserLicenseAgreement
    case none
}

