//
//  MoreSettingsViewModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 26/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct MoreSettingsViewModel: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    var parentSize: CGSize
    
    var viewSize: CGSize {
        return CGSize(width: self.parentSize.width * self.viewWidthRatio, height: self.parentSize.height * self.viewHeightRatio)
    }
    
    
    var offset: CGSize {
        if self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.activeType == .settings {
            return .zero
        }else{
            return CGSize(width: .zero, height: self.parentSize.height)
        }
    }
    
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                
                Button(action:{
                    
                }, label: {
                    HStack{
                        Spacer()
                        Text("Feedback")
                        Spacer()
                    }
                })
                    .buttonStyle(LeanOutlineColoredButtonStyle())
                
                Button(action:{
                    
                }, label: {
                    HStack{
                        Spacer()
                        Text("More about PinIt")
                        Spacer()
                    }
                })
                    .buttonStyle(LeanOutlineColoredButtonStyle())
                
                Button(action:{
                    
                }, label: {
                    HStack{
                        Spacer()
                        Text("Privacy Matters")
                        Spacer()
                    }
                })
                    .buttonStyle(LeanOutlineColoredButtonStyle())
                
                Button(action:{
                    self.settingsViewModel.signOut()
                }, label: {
                    HStack{
                        Spacer()
                        Text("Logout")
                        Spacer()
                    }
                })
                    .buttonStyle(LeanOutlineColoredButtonStyle())
                
                Spacer()
            }.zIndex(1)
            VStack{
                HStack{
                    Image(systemName: "xmark")
                        .foregroundColor(Color.primaryColor)
                        .applyDefaultIconTheme()
                        .onTapGesture {
                            self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.switchTo(screenType: .normal)
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    Spacer()
                }
                Spacer()
            }.zIndex(1)
        }
        .frame(width: self.viewSize.width, height: self.viewSize.height)
        .background(Color.white)
        .cornerRadius(15)
        .offset(self.offset)
        .animation(.spring())
    }
    
    let viewHeightRatio: CGFloat = 0.50
    let viewWidthRatio: CGFloat = 0.8
}

struct MoreSettingsViewModel_Previews: PreviewProvider {
    static var previews: some View {
        MoreSettingsViewModel( parentSize: .zero)
    }
}
