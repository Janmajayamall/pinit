//
//  MainUnauthenticatedView.swift
//  pinit
//
//  Created by Janmajaya Mall on 1/11/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct MainUnauthenticatedView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var parentSize: CGSize
    var backgroudColorOpacity: CGFloat = 0.5
    
    @ViewBuilder
    var body: some View {
        if (self.settingsViewModel.user == nil){
            VStack{
                VStack{
                    Text("Welcome to FinchIt")
                        .foregroundColor(Color.primaryColor)
                        .applyDefaultThemeToTextHeader(ofType: .h1)
                }
                .padding()
                
                VStack{
                    Text("An app to Capture, Share, and Explore amazing moments!")
                        .foregroundColor(Color.white)
                        .font(Font.custom("Avenir", size: 20).bold())
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Button(action: {
                    self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .login)
                }, label: {
                    Text("Sign Up / Log In")
                })
                    .buttonStyle(LiveViewButtonStyle(backgroundColor: .black))
                    .padding()
                
                Spacer()
            }
            .padding(EdgeInsets(top: 100, leading: 5, bottom: 100, trailing: 5))
            .frame(width: self.parentSize.width, height: self.parentSize.height)
            .background(Color.black.opacity(0.5))
        }
    }
}

struct MainUnauthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        MainUnauthenticatedView(parentSize: .zero)
    }
}
