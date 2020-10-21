//
//  BlockUserView.swift
//  pinit
//
//  Created by Janmajaya Mall on 21/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct BlockUserView: View {
    
    @ObservedObject var blockUserViewModel: BlockUserViewModel = BlockUserViewModel()
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Binding var isOpen: Bool
    
    @State var fakeNoteBinding: String = ""
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Text("Blocked Users")
                        .font(Font.custom("Avenir", size: 20).bold())
                        .foregroundColor(Color.primaryColor)
                    Spacer()
                }
                ScrollView{
                    ForEach(self.settingsViewModel.blockUsersService.blockedUsers) { blockedUser in
                        VStack{
                            BlockedUserRow(username: "blockedUser.blockedUsername", uid: "blockedUser.blockedUID", blockStatus: self.settingsViewModel.blockUsersService.checkBlockStatus(forUID: blockedUser.blockedUID))
                            
                            Divider()
                        }
                        .padding(EdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5))
                        .background(Color.white)
                    }
                }
                
            }
            .padding(10)
            .background(Color.white)
            VStack{
                Spacer()
                VStack{
                    CustomTextFieldView(text: self.$blockUserViewModel.searchString, placeholder: "Type username to block a user", noteText: self.$fakeNoteBinding)
                        .font(Font.custom("Avenir", size: 15).bold())
                        .foregroundColor(Color.black)
                    
                    if ((self.blockUserViewModel.searchedUser) != nil){
                        BlockedUserRow(username: self.blockUserViewModel.searchedUser!.username, uid: self.blockUserViewModel.searchedUser!.uid, blockStatus: self.settingsViewModel.blockUsersService.checkBlockStatus(forUID: self.blockUserViewModel.searchedUser!.uid))
                    }
                }
                .padding(10)
                .applyKeyboardAwarePadding()
                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.black), alignment: .top)
                .background(Color.white)
            }
        }
        .background(Color.white)
    }
}

struct BlockedUserRow: View {
    
    @State var username: String
    @State var uid: String
    @State var blockStatus: BlockUsersService.BlockStatus
    
    var body: some View {
        print(self.username, self.uid, self.blockStatus)
        return HStack(alignment: .center){
            Text(self.username)
                .font(Font.custom("Avenir", size: 15).bold())
                .foregroundColor(Color.black)
                .lineLimit(1)
            Spacer()
            
            HStack{
                if (self.blockStatus == .inactive){
                    Text("Block")
                        .foregroundColor(Color.darkScarlet)
                }else if (self.blockStatus == .active){
                    Text("Unblock")
                        .foregroundColor(Color.blue)
                }else {
                    Text("")
                        .foregroundColor(Color.white)
                }
            }
            .onTapGesture {
                print("CHANGED \(self.blockStatus)")
                if (self.blockStatus == .active){
                    self.blockStatus = .inactive
                }else if (self.blockStatus == .inactive){
                    self.blockStatus = .active
                }
//                self.requestBlockStatusChange(to: self.blockStatus)
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
