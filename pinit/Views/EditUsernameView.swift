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
    @State var username: String
    
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
                Spacer()
                
                HStack{
                    Spacer()
                    Text("Change your username")
                        .applyDefaultThemeToTextHeader(ofType: .h3)
                    Spacer()
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                
                Spacer()
                
                HStack{
                    VStack{
                        CustomTextFieldView(text: self.$username, placeholder: "Username")
                            .font(Font.custom("Avenir", size: 18))
                            .foregroundColor(Color.black)
                        Divider().background(Color.secondaryColor)
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                
                Spacer()
                
                Button(action: {
                    self.changeUsername(to: self.username)
                    
                    // hiding the keyboard
                    self.hideKeyboard()
                }, label: {
                    Text("Done")
                    
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
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
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
        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.activeType = .normal
    }
    
    private let viewHeightRatio: CGFloat = 0.30
    private let viewWidthRatio: CGFloat = 0.8
}

struct EditUsernameView_Previews: PreviewProvider {
    static var previews: some View {
        EditUsernameView(username: "default name", parentSize: CGSize(width: 300, height: 200))
    }
}
