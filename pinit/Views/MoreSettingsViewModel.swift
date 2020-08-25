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
                
                Button(action: {
                    self.settingsViewModel.signOut()
                }, label: {
                    Text("Logout")
                })
                    .buttonStyle(SecondaryColorButtonStyle())
                    .padding(.bottom, 10)
                Button(action: {
                    print("logout")
                }, label: {
                    Text("Privacy")
                })
                    .buttonStyle(SecondaryColorButtonStyle())
               
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
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
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
    
    let viewHeightRatio: CGFloat = 0.35
    let viewWidthRatio: CGFloat = 0.8
}

struct MoreSettingsViewModel_Previews: PreviewProvider {
    static var previews: some View {
        MoreSettingsViewModel( parentSize: .zero)
    }
}
