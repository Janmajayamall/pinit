//
//  MainArView.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct MainArView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State var mapViewScreenState: SwipeScreenState = .down
    @State var mapViewyDragTranslation: CGFloat = 0
    
    @ViewBuilder
    var body: some View {
        
        if (self.settingsViewModel.screenManagementService.mainScreenService.activeType == .captureImageView) {            
            CaptureImageView()
        }else {
            GeometryReader { geometryProxy in
                ZStack{
                    
                    UIKitArSceneView(parentSize: geometryProxy.size)
                    
                    MapView(parentGeometrySize: geometryProxy.size, screenState: self.$mapViewScreenState, yDragTranslation: self.$mapViewyDragTranslation)
                    
                    VStack{
                        HStack{
                            Spacer()
                            Button(action: {
                                if self.settingsViewModel.isUserAuthenticated() {
                                    self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .profile)
                                }else {
                                    self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .login)
                                    
                                }
                            },label: {
                                Image(systemName: "camera.circle.fill").font(Font.system(size: 20, weight: .bold)).foregroundColor(Color.primaryColor).padding(40)
                            })
                        }
                        Spacer()
                        HStack{
                            Button(action: {
                                self.settingsViewModel.screenManagementService.mainScreenService.switchTo(screenType: .captureImageView)
                            }, label: {
                                Image(systemName: "camera.circle.fill").font(Font.system(size: 20, weight: .bold)).foregroundColor(Color.primaryColor).padding(40)
                            })
                            
                            Spacer()
                        }
                        
                    }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height, alignment: .top)
                        .background(Color.black)
                    
                    ProfileView(parentSize: geometryProxy.size)
                    
                    EditProfileImageView(parentSize: geometryProxy.size)
                    
                    EditUsernameView(parentSize: geometryProxy.size)
                    
                    LoginView(parentSize: geometryProxy.size)
                }
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).background(Color.black).edgesIgnoringSafeArea(.all)
            
        }
    
    }
    
    
}

struct MainArView_Previews: PreviewProvider {
    static var previews: some View {
        MainArView()
    }
}
