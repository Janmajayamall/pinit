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
    @State var usernameError: String = ""
    
    var currentUsername: String
    
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
    
    @State var forceRenderBool: Bool = true
    
    var body: some View {
        
        let usernameBinding = Binding<String>(get: {
            return self.username
        }, set: {
            var username = $0.lowercased()
            username = username.trimmingCharacters(in: .whitespacesAndNewlines)
            self.username = String(username.prefix(25))
            
            // forcing render UI
            self.forceRenderBool.toggle()
        })
        
        return ZStack{
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
                        CustomTextFieldView(text: usernameBinding, placeholder: "Username", noteText: self.$usernameError)
                            .font(Font.custom("Avenir", size: 18))
                            .foregroundColor(Color.black)
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                
                Spacer()
                
                Button(action: {
                    self.changeUsername(to: self.username)
                    self.hideKeyboard()
                }, label: {
                    Text("Done")
                    
                })
                    .buttonStyle(SecondaryColorButtonStyle())
                    .padding(EdgeInsets(top: self.forceRenderBool ? 0 : 0, leading: 0, bottom: 0, trailing: 0))
                Spacer()
            }.zIndex(1)
            VStack{
                HStack{
                    Image(systemName: "xmark")
                        .applyDefaultIconTheme(forIconDisplayType: .normal)
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
    
    func changeUsername(to username: String){
        // checking whether username has been changed or not
        guard self.currentUsername != self.username else {
            self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.activeType = .normal
            return 
        }
        
        // checking whether username is already taken or not
        UserProfileService.checkUsernameExists(for: self.username) { (exists) in
            if (exists == true){
                self.usernameError = "Username already taken"
            }else {
                self.usernameError = ""
                // hiding the keyboard
                self.hideKeyboard()
                
                NotificationCenter.default.post(name: .userProfileServiceDidRequestUsernameChange, object: username)
                self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.activeType = .normal
            }
        }
    }
    
    private let viewHeightRatio: CGFloat = 0.30
    private let viewWidthRatio: CGFloat = 0.8
}

struct EditUsernameView_Previews: PreviewProvider {
    static var previews: some View {
        EditUsernameView(username: "default name", currentUsername: "",parentSize: CGSize(width: 300, height: 200))
    }
}
