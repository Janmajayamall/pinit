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
    
    @State var isSafariOpen: Bool = false
    @State var safariUrl: URL?
    
    var body: some View {
        ZStack{
            VStack{
                Spacer()
               
                Button(action:{
                    guard let url = URL(string: "http://www.finchit.tech/suggestions") else {return}
                    self.safariUrl = url
                    self.isSafariOpen = true
                }, label: {
                    HStack{
                        Text("Your suggestions for FinchIt")
                         .padding(.leading, 5)
                        Spacer()
                    }
                })
                    .buttonStyle(LeanOutlineColoredButtonStyle())
                
                Button(action:{
                    guard let url = URL(string: "http://www.finchit.tech/home") else {return}
                    self.safariUrl = url
                    self.isSafariOpen = true
                }, label: {
                    HStack{
                        Text("More about FinchIt")
                            .padding(.leading, 5)
                        Spacer()
                    }
                })
                    .buttonStyle(LeanOutlineColoredButtonStyle())
                
                Button(action:{
                    guard let url = URL(string: "http://www.finchit.tech/privacy") else {return}
                    self.safariUrl = url
                    self.isSafariOpen = true
                }, label: {
                    HStack{
                        Text("Privacy Matters")
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
        .sheet(isPresented: self.$isSafariOpen, content: {
            UIKitSafariWebView(url: self.safariUrl!)
        })
    }
    
    let viewHeightRatio: CGFloat = 0.45
    let viewWidthRatio: CGFloat = 0.8
}

struct MoreSettingsViewModel_Previews: PreviewProvider {
    static var previews: some View {
        MoreSettingsViewModel( parentSize: .zero)
    }
}
