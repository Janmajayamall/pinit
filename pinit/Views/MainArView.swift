//
//  MainArView.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics
import Combine


struct MainArView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var cancellables: Set<AnyCancellable> = []
    
    @ViewBuilder
    var body: some View {
        
        if (self.settingsViewModel.screenManagementService.mainScreenService.activeType == .captureImageView) {
            CaptureImageView()
        }else {
            GeometryReader { geometryProxy in
                ZStack{
                    
                    UIKitArSceneView(appArScnView: self.settingsViewModel.appArScnView)
                                                        
                    MainArViewIconsView(parentsSize: geometryProxy.size)
                    
                    MainOnboardingView(parentSize: geometryProxy.size)
                                                        
                    MainArViewIndicatorsView(parentSize: geometryProxy.size)
                    
                    ZStack{
                        ProfileView(parentSize: geometryProxy.size)
                        
                        LoginView(parentSize: geometryProxy.size).frame(width: geometryProxy.size.width, height: geometryProxy.size.height, alignment: .top)
                        
                        SetupProfileView(parentSize: geometryProxy.size)
                        
                        MoreSettingsViewModel(parentSize: geometryProxy.size)
                        
                        if (self.settingsViewModel.userProfile?.username != nil) {
                            EditUsernameView(username: self.settingsViewModel.userProfile?.username ?? "", currentUsername: self.settingsViewModel.userProfile?.username ?? "", parentSize: geometryProxy.size)
                        }
                        
                        PopUpWarningView(parentSize: geometryProxy.size, popUpWarningType: self.settingsViewModel.popUpWarningType)
                    }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                                      
                    
                }
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color.black)
                .edgesIgnoringSafeArea(.all)
                .onDisappear {
                    self.settingsViewModel.appArScnView.pauseSession()
            }
        }
    }
    
}

struct MainArView_Previews: PreviewProvider {
    static var previews: some View {
        MainArView()
    }
}
