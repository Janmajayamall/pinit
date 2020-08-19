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
    var parentSize: CGSize
    var viewHeight: CGFloat {
        return self.parentSize.height * self.viewHeightRatio
    }
    
    var window: UIWindow? = UIApplication.shared.windows.first ?? nil
    @State var signInWithAppleCoordinator: SignInWithAppleCoordinator?
    
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Text("Create an accout or Sign In to continue.").font(Font.custom("Avenir", size: 30)).padding(.bottom, 10)
                    Spacer()
                }.padding(10)
                Spacer()
                UIKitSignInWithApple().frame(width: 280, height: 45).onTapGesture {
                    self.signInWithAppleCoordinator = SignInWithAppleCoordinator(window: self.window! )
                    self.signInWithAppleCoordinator?.signIn(onSignedInHandler: {user in
                        print("Logged in with name \(String(describing: user.displayName)) & email \(String(describing: user.email))")
                        
                        // close the login view
                        self.settingsViewModel.screenManagementService.activeMainScreenOverlay = .none
                    })
                }
                Spacer()
                HStack{
                    Spacer()
                    Text("By signing in you agree with you Terms and Conditions.").font(Font.custom("Avenir", size: 15))
                    Spacer()
                }.padding(10)
            }.zIndex(1)
            
            VStack{
                HStack{
                    Image(systemName: "xmark")
                        .font(Font.system(size: 15, weight: .bold))
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            self.settingsViewModel.screenManagementService.activeMainScreenOverlay = .none
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
                    Spacer()
                }
                Spacer()
            }.zIndex(1)
        }
        .frame(width: self.parentSize.width, height: self.viewHeight, alignment: .top)
        .background(Color.white)
        .cornerRadius(12)
        .offset(CGSize(width: .zero, height: self.settingsViewModel.screenManagementService.activeMainScreenOverlay == .login ? self.parentSize.height - self.viewHeight : self.parentSize.height))
        .animation(.spring())
    }
    
    private let viewHeightRatio: CGFloat = 0.6
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(parentSize: CGSize(width: 300, height: 800)).environmentObject(SettingsViewModel())
    }
}
