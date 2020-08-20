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
        print("View Height \(self.parentSize.height) and View width \(self.parentSize.width)")
        return self.parentSize.height * self.viewHeightRatio
    }
    var offset: CGSize {
        if (self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.activeType == .login){
            return CGSize(width: .zero, height: self.parentSize.height - self.viewHeight)
        }
        return CGSize(width: .zero, height: self.parentSize.height)
    }
    
    var window: UIWindow? = UIApplication.shared.windows.first ?? nil
    @State var signInWithAppleCoordinator: SignInWithAppleCoordinator?
    
    
    var body: some View {
        
        VStack{
            HStack{
                Image(systemName: "xmark")
                    .font(Font.system(size: 15, weight: .bold))
                    .foregroundColor(Color.primaryColor)
                    .onTapGesture {
                        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .normal)
                }
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
                Spacer()
            }
            HStack{
                Spacer()
                Text("Create an accout or Sign In to continue.").font(Font.custom("Avenir", size: 30))
                Spacer()
            }.padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))
            
            UIKitSignInWithApple().frame(width: 280, height: 45).onTapGesture {
                self.signInWithAppleCoordinator = SignInWithAppleCoordinator(window: self.window! )
                self.signInWithAppleCoordinator?.signIn(onSignedInHandler: {user in
                    print("Logged in with name \(String(describing: user.displayName)) & email \(String(describing: user.email))")
                    
                    // close the login view
                    self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .normal)
                })
            }
            Spacer()
            HStack{
                Spacer()
                Text("By signing in you agree with you Terms and Conditions.").font(Font.custom("Avenir", size: 15))
                Spacer()
            }.padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
            Spacer()
        }
        .frame(width: self.parentSize.width, height: self.viewHeight, alignment: .top)
        .background(Color.white)
        .cornerRadius(12)
        .offset(self.offset)
        .animation(.spring())
    }
    
    private let viewHeightRatio: CGFloat = 0.7
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(parentSize: CGSize(width: 300, height: 800)).environmentObject(SettingsViewModel())
    }
}
