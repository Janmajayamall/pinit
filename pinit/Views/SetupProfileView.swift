//
//  SetupProfileView.swift
//  pinit
//
//  Created by Janmajaya Mall on 25/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct SetupProfileView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    var parentSize: CGSize
    @ObservedObject var setupProfileViewModel: SetupProfileViewModel = SetupProfileViewModel()
        
    var viewSize: CGSize {
        return CGSize(width: self.parentSize.width * self.viewWidthRatio, height: self.parentSize.height * self.viewHeightRatio)
    }
    
    var offset: CGSize {
        if self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.activeType == .setupProfile {
            return .zero
        }else{
            return CGSize(width: .zero, height: self.parentSize.height)
        }
    }
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Text("Set up your profile")
                        .font(Font.custom("Avenir", size: 20)
                            .bold())
                        .foregroundColor(Color.black)
                }.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                
                Image(uiImage: self.setupProfileViewModel.profileImage)
                    .resizable().scaledToFit()
                    .frame(width: self.profileImageDim, height: self.profileImageDim, alignment: .center)
                    .overlay(Circle().stroke(Color.secondaryColor, lineWidth: 8).frame(width: self.profileImageDim, height: self.profileImageDim))
                    .cornerRadius(self.profileImageDim/2)
                    .clipped()
                    .onTapGesture {
                        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.setupProfileViewScreenService.switchTo(screenType: .pickImage)
                }
                .padding(.bottom, 10)
                
                HStack{
                    Spacer()
                    VStack{
                        TextField("Username", text: self.$setupProfileViewModel.username)
                            .font(Font.custom("Avenir", size: 18))
                        Divider().background(Color.secondaryColor)
                    }
                    Spacer()
                }
                
                Button(action: {
                    self.setupProfileViewModel.setupProfile()
                }, label: {
                    Text("Done")
                })
                    .buttonStyle(SecondaryColorButtonStyle())
                
                Spacer()
            }
        }
        .frame(width: self.viewSize.width, height: self.viewSize.height)
        .background(Color.white)
        .cornerRadius(15)
        .offset(self.offset)
        .animation(.spring())
    }
    
    let viewHeightRatio: CGFloat = 0.5
    let viewWidthRatio: CGFloat = 0.8
    let profileImageDim: CGFloat = 100
}

struct SetupProfileView_Previews: PreviewProvider {
    static var previews: some View {
        SetupProfileView(parentSize: .zero)
    }
}



