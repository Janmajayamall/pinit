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
                    guard self.checkIconStatus(for: .privateOrPersonal) == .active else {return}
                    
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
                            guard self.checkIconStatus(for: .arrowCounterclockwise) == .active else {return}
                            
                            self.settingsViewModel.refreshScene()
                    }
                    
                    Image(systemName:"gear")
                        .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                        .onTapGesture {
                            guard self.checkIconStatus(for: .gear) == .active else {return}
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
                            guard self.checkIconStatus(for: .cameraFill) == .active else {return}
                            
                            if self.settingsViewModel.isUserAuthenticated() {
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
                            guard self.checkIconStatus(for: .arrowLeft) == .active else {return}
                            
                            NotificationCenter.default.post(name: .aRViewDidTapBackIcon, object: true)
                    }
                    
                    ZStack{
                        Image(systemName: "mappin.and.ellipse")
                            .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                            .onTapGesture {
                                guard self.checkIconStatus(for: .mappinAndEllipse) == .active else {return}
                                
                                // notifiy app ar scene to reset group scn nodes positions
                                NotificationCenter.default.post(name: .aRViewResetNodesPostion, object: true)
                                
                                self.settingsViewModel.resetNodePositionNotification = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                    self.settingsViewModel.resetNodePositionNotification = false
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
    
    func checkIconStatus(for iconType: MainArViewIconsType) -> IconStatusType {
        guard (self.settingsViewModel.popUpWarningType == .none && self.settingsViewModel.user != nil) else {
            return .onlyVisible
        }
        
        let mainArViewOnboardingStatus = self.settingsViewModel.onboardingViewModel.checkOnboardingStatus(for: .authenticatedMainARView)
        
        guard mainArViewOnboardingStatus < MainOnboardingView.ScreenNumber.getMaxScreenNumber() else {
            if (self.settingsViewModel.userProfile == nil){
                return .onlyVisible
            }else {
                return .active
            }
        }
        
        switch iconType {
        case .arrowCounterclockwise:
//            if (mainArViewOnboardingStatus >= 13){
//                return .onlyVisible
//            }
            return .onlyVisible
        case .gear:
//            if (mainArViewOnboardingStatus >= 13){
//                return .onlyVisible
//            }
            return .onlyVisible
        case .cameraFill:
//            if (mainArViewOnboardingStatus >= 14){
//                return .onlyVisible
//            }
            return .onlyVisible
        case .arrowLeft:
//            if (mainArViewOnboardingStatus >= 9){
//                return .active
//            }
            return .onlyVisible
        case .mappinAndEllipse:
//            if (mainArViewOnboardingStatus >= 9){
//                return .active
//            }
            return .active
        case .privateOrPersonal:
//            if (mainArViewOnboardingStatus >= 10){
//                return .active
//            }
            return .active
        }
                
    }
    
    enum MainArViewIconsType: String {
        case arrowCounterclockwise = "arrow.counterclockwise"
        case gear
        case cameraFill = "camera.fill"
        case arrowLeft = "arrow.left"
        case mappinAndEllipse = "mappin.and.ellipse"
        case privateOrPersonal
    }
    
    enum IconStatusType {
        case onlyVisible
        case active
        case none
    }
}

struct MainArViewIconsView_Previews: PreviewProvider {
    static var previews: some View {
        MainArViewIconsView(parentsSize: .zero)
    }
}
