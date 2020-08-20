//
//  ProfileView.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var name: String = "janmajayamall · 45" // you can call pictures at different places as anchors (but anchors dont sound nice)
    var parentSize:CGSize
    
    var viewSize:CGSize{
        return CGSize(width: self.parentSize.width * self.viewWidthRatio, height: self.parentSize.height * self.viewHeightRatio)
    }
        
    var offset:CGSize {
        if (self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.activeType == .profile){
            return .zero
        }else {
            return CGSize(width: .zero, height: self.parentSize.height)
        }
    }
    
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                Rectangle().foregroundColor(Color.black)
                    .frame(width: 100, height: 100, alignment: .center)
                    .overlay(Circle().stroke(Color.secondaryColor, lineWidth: 8).frame(width: 100, height: 100))
                    .cornerRadius(50)
                    .clipped()
                    .onTapGesture {
                        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.switchTo(screenType: .editProfileImage)
                    }
                    .padding(.bottom, 10)
                
                HStack{
                    Spacer()
                    Text(self.name)
                        .font(Font.system(size: 18, weight: .semibold, design: .rounded))
                        .onTapGesture {
                            self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.switchTo(screenType: .editUsername)
                    }
                    Spacer()
                }
                Spacer()
            }.zIndex(1)
            VStack{
                HStack{
                    Image(systemName: "xmark").font(Font.system(size: 15, weight: .bold))
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .normal)
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
    
    private let viewHeightRatio: CGFloat = 0.3
    private let viewWidthRatio: CGFloat = 0.8
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(parentSize: CGSize(width: 300, height: 800))
    }
}
