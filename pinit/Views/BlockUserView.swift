//
//  BlockUserView.swift
//  pinit
//
//  Created by Janmajaya Mall on 21/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct BlockUserView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Binding var isOpen: Bool
    
    @State var fakeNoteBinding: String = ""
    
    var body: some View {        
        return ZStack{
            VStack{
                HStack{
                    Text("Blocked Users")
                        .font(Font.custom("Avenir", size: 20).bold())
                        .foregroundColor(Color.primaryColor)
                    Spacer()
                }
                if (self.settingsViewModel.blockUsersService.blockedUsers.count == 0){
                    HStack{
                        Spacer()
                        Text("You haven't blocked anyone!")
                            .font(Font.custom("Avenir", size: 18).bold())
                            .foregroundColor(Color.textfieldColor)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }.padding(.top, 15)
                }else{
                    ScrollView{
                        ForEach(self.settingsViewModel.blockUsersService.blockedUsers) { blockedUser in
                            VStack{
                                BlockedUserRow(username: blockedUser.blockedUsername, uid: blockedUser.blockedUID, blockStatus: self.settingsViewModel.blockUsersService.checkBlockStatus(forUID: blockedUser.blockedUID))
                                Divider()
                            }
                            .padding(EdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5))
                            .background(Color.white)
                        }
                    }
                }
                Spacer()
            }
            .padding(10)
            .onTapGesture {
                self.hideKeyboard()
            }
            .background(Color.white)
            VStack{
                Spacer()
                VStack{
                    CustomTextFieldView(text: self.$settingsViewModel.blockUserViewModel.searchString, placeholder: "Type username of a user to block", noteText: self.$fakeNoteBinding)
                        .font(Font.custom("Avenir", size: 15).bold())
                        .foregroundColor(Color.black)
                    
                    if ((self.settingsViewModel.blockUserViewModel.searchedUser) != nil){
                        BlockedUserRow(username: self.settingsViewModel.blockUserViewModel.searchedUser!.username, uid: settingsViewModel.blockUserViewModel.searchedUser!.uid, blockStatus: self.settingsViewModel.blockUsersService.checkBlockStatus(forUID: settingsViewModel.blockUserViewModel.searchedUser!.uid))
                    }
                }
                .padding(10)
                .applyKeyboardAwarePadding()
                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.black), alignment: .top)
                .background(Color.white)
            }
            .background(Color.clear)
        }
        .background(Color.white)
    }
}

struct BlockedUserRow: View {
    
    @State var username: String
    @State var uid: String
    @State var blockStatus: BlockUsersService.BlockStatus
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        print("BLOCKED view view \(self.blockStatus)")
        return HStack(alignment: .center){
            Text(self.username)
                .font(Font.custom("Avenir", size: 15).bold())
                .foregroundColor(Color.black)
                .lineLimit(1)
            
            Spacer()
            
            HStack{
                if (self.blockStatus == .inactive){
                    Text("BLOCK")
                        .foregroundColor(Color.darkScarlet)
                }else if (self.blockStatus == .active){
                    Text("UNBLOCK")
                        .foregroundColor(Color.blue)
                }else {
                    Text("")
                        .foregroundColor(Color.clear)
                }
            }
            .font(Font.custom("Avenir", size: 15).bold())
            .onTapGesture {
                if (self.blockStatus == .active){
                    self.blockStatus = .inactive
                }else if (self.blockStatus == .inactive){
                    self.blockStatus = .active
                }
                self.requestBlockStatusChange(to: self.blockStatus)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.settingsViewModel.refreshScene()
                })
            }
        }
    }
    
    func requestBlockStatusChange(to status: BlockUsersService.BlockStatus){
        if (status == .active){
            let requestModel = RequestBlockUserModel(uid: self.uid, username: self.username)
            NotificationCenter.default.post(name: .blockUsersServiceDidRequestBlockUserModel, object: requestModel)
        }else if (status == .inactive){
            NotificationCenter.default.post(name: .blockUsersServiceDidRequestUnblockUser, object: self.uid)
        }
    }
}
//
//struct BlockUserView_Previews: PreviewProvider {
//    static var previews: some View {
//        BlockUserView()
//    }
//}
