//
//  EditUsernameView.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct EditUsernameView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State var username: String = "janmajayamall"
    
    var parentSize: CGSize
    
    var viewSize: CGSize {
        return CGSize(width: self.viewWidthRatio * self.parentSize.width, height: self.viewHeightRatio * self.parentSize.height)
    }
    
    var offset: CGSize {
        if(self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.activeType == .editUsername){
            return .zero
        }
        return CGSize(width: .zero, height: self.parentSize.height)
    }
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Spacer()
                    Text("Change your username").font(Font.custom("Avenir", size: 20)).bold().foregroundColor(Color.black)
                    Spacer()
                }.padding(EdgeInsets(top: 35, leading: 0, bottom: 1, trailing: 0))
                HStack{
                    VStack{
                        TextField("Username", text: self.$username)
                            .font(Font.custom("Avenir", size: 18))
                        Divider().background(Color.secondaryColor)
                    }
                }.padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 5))
                Button(action: {
                    self.changeUsername(to: self.username)
                }, label: {
                    HStack{
                        Spacer()
                        Text("Done").font(Font.custom("Avenir", size: 20)).bold().foregroundColor(Color.white)
                        Spacer()
                    }
                    .frame(width: 100, height: 50)
                    .clipped()
                    .background(Color.secondaryColor)
                    .cornerRadius(25)
                    
                })
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
        .offset(self.offset)
        .cornerRadius(15)
        .animation(.spring())
    }
    
    func changeUsername(to username: String){        
        NotificationCenter.default.post(name: .userProfileServiceDidRequestUsernameChange, object: username)
    }
    
    private let viewHeightRatio: CGFloat = 0.3
    private let viewWidthRatio: CGFloat = 0.8
}

struct EditUsernameView_Previews: PreviewProvider {
    static var previews: some View {
        EditUsernameView(parentSize: CGSize(width: 300, height: 200))
    }
}
