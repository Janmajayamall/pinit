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
    
    @State var safariUrl: URL?
    
    @State var moreSettingsViewSheetType: MoreSettingsViewSheetType = .none
    @State var isSheetOpen: Bool = false
    
    
    var body: some View {
        ZStack{
            VStack{
                
                Button(action:{
                    self.moreSettingsViewSheetType = .feedback
                    self.isSheetOpen = true
                }, label: {
                    HStack{
                        Text("Your feedback")
                            .padding(.leading, 5)
                        Spacer()
                    }
                })
                    .buttonStyle(LeanOutlineColoredButtonStyle())
                
                Button(action:{
                    self.moreSettingsViewSheetType = .report
                    self.isSheetOpen = true
                }, label: {
                    HStack{
                        Text("Report a user")
                            .padding(.leading, 5)
                        Spacer()
                    }
                })
                    .buttonStyle(LeanOutlineColoredButtonStyle())
                
                Button(action:{
                    self.moreSettingsViewSheetType = .blockUser
                    self.isSheetOpen = true
                }, label: {
                    HStack{
                        Text("Blocked users")
                            .padding(.leading, 5)
                        Spacer()
                    }
                })
                    .buttonStyle(LeanOutlineColoredButtonStyle())
                
                Button(action:{
                    guard let url = URL(string: "http://www.finchit.tech/home") else {return}
                    self.safariUrl = url
                    self.moreSettingsViewSheetType = .safari
                    self.isSheetOpen = true
                }, label: {
                    HStack{
                        Text("More about us")
                            .padding(.leading, 5)
                        Spacer()
                    }
                })
                    .buttonStyle(LeanOutlineColoredButtonStyle())
                
                Button(action:{
                    guard let url = URL(string: "http://www.finchit.tech/privacy") else {return}
                    self.safariUrl = url
                    self.moreSettingsViewSheetType = .safari
                    self.isSheetOpen = true
                }, label: {
                    HStack{
                        Text("Privacy Policy")
                            .padding(.leading, 5)
                        Spacer()
                    }
                })
                    .buttonStyle(LeanOutlineColoredButtonStyle())
                
                Button(action:{
                    self.settingsViewModel.signOut()
                }, label: {
                    HStack{
                        Text("Logout")
                            .padding(.leading, 5)
                        Spacer()
                    }
                })
                    .buttonStyle(LeanOutlineColoredButtonStyle())
                
                Spacer()
            }
            .padding(EdgeInsets(top: 50, leading: 0, bottom: 10, trailing: 0))
            .zIndex(1)
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
        .sheet(isPresented: self.$isSheetOpen, content: {
            if (self.moreSettingsViewSheetType == .feedback){
                FeedbackView(isOpen: self.$isSheetOpen)
            }else if(self.moreSettingsViewSheetType == .report){
                ReportUserView(isOpen: self.$isSheetOpen)
            }else if (self.moreSettingsViewSheetType == .safari){
                UIKitSafariWebView(url: self.safariUrl!)
            }else if (self.moreSettingsViewSheetType == .blockUser){
                BlockUserView(isOpen: self.$isSheetOpen).environmentObject(self.settingsViewModel)
            }
            VStack{Text("").foregroundColor(Color.white)}.background(Color.white)
            
        })
    }
    
    let viewHeightRatio: CGFloat = 0.58
    let viewWidthRatio: CGFloat = 0.8
}

struct MoreSettingsViewModel_Previews: PreviewProvider {
    static var previews: some View {
        MoreSettingsViewModel( parentSize: .zero)
    }
}

enum MoreSettingsViewSheetType {
    case feedback
    case report
    case safari
    case blockUser
    case none
}
