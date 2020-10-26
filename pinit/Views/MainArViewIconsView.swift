//
//  MainArViewIconsView.swift
//  pinit
//
//  Created by Janmajaya Mall on 25/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct MainArViewIconsView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var parentsSize: CGSize
    
    var body: some View {
        VStack{
            HStack{
                HStack{
                    if (self.settingsViewModel.postDisplayType == .allPosts) {
                        Image("IconTransparent").resizable().frame(width: 50, height: 50).clipped()
                    }else{
                        HStack{
                            Image("IconTransparent").resizable().frame(width: 50, height: 50).clipped()
                            Text("🔒")
                        }
                    }
                }
                .font(Font.system(size: 30, weight: .heavy))
                .foregroundColor(Color.white)
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
                .applyEdgePadding(for: .topLeft)
                .onTapGesture {
                    guard self.areButtonsActive() else {return}
                    
                    if self.settingsViewModel.isUserAuthenticated() {
                        
                        // change post display type
                        self.settingsViewModel.togglePostDisplayType()
                        
                        // display post diplay notification text
                        self.settingsViewModel.postDisplayNotification = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            self.settingsViewModel.postDisplayNotification = false
                        })
                        
                    }else {
                        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .login)
                    }
                }
                
                
                Spacer()
                
                HStack{
                    Image(systemName: "arrow.counterclockwise")
                        .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                        .onTapGesture {
                            guard self.areButtonsActive() else {return}
                            
                            self.settingsViewModel.refreshScene()
                    }
                    
                    Image(systemName:"gear")
                        .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                        .onTapGesture {
                            guard self.areButtonsActive() else {return}
                            
                            if self.settingsViewModel.isUserAuthenticated() {
                                self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .profile)
                            }else {
                                self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .login)
                            }
                    }
                }
                .applyEdgePadding(for: .topRight)
            }
            Spacer()
            HStack{
                HStack{
                    Image(systemName: "camera.fill")
                        .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                        .onTapGesture {
                            guard self.areButtonsActive() else {return}
                            
                            if self.settingsViewModel.isUserAuthenticated() {
                                //                                        // stop session
                                //                                        self.settingsViewModel.appArScnView.pauseSession()
                                
                                self.settingsViewModel.screenManagementService.mainScreenService.switchTo(screenType: .captureImageView)
                            }else {
                                self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .login)
                            }
                    }
                }
                .applyEdgePadding(for: .bottomLeft)
                
                Spacer()
                
                HStack {
                    Image(systemName: "arrow.left")
                        .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                        .onTapGesture {
                            guard self.areButtonsActive() else {return}
                            
                            NotificationCenter.default.post(name: .aRViewDidTapBackIcon, object: true)
                    }
                    
                    ZStack{
                        Image(systemName: "mappin.and.ellipse")
                            .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                            .onTapGesture {
                                guard self.areButtonsActive() else {return}
                                
                                // notifiy app ar scene to reset group scn nodes positions
                                NotificationCenter.default.post(name: .aRViewDidRequestResetGroupNodesPos, object: true)
                                
                                self.settingsViewModel.sceneDidResetNotification = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                    self.settingsViewModel.sceneDidResetNotification = false
                                })
                        }
                        
                        if (self.settingsViewModel.uploadIndicator > 0){
                            Loader()
                        }
                    }
                }
                .applyEdgePadding(for: .bottomRight)
            }
            
        }.frame(width: self.parentsSize.width, height: self.parentsSize.height, alignment: .top)
    }
    
    func areButtonsActive() -> Bool {
        // checking for no pop up warning
        return self.settingsViewModel.popUpWarningType == .none
    }
}

struct MainArViewIconsView_Previews: PreviewProvider {
    static var previews: some View {
        MainArViewIconsView(parentsSize: .zero)
    }
}
