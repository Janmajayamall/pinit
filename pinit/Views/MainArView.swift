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
        
    @State var postDisplayNotification: Bool = false
    @State var sceneDidResetNotification: Bool = false
    @ObservedObject var postDisplayInfoViewModel: PostDisplayInfoViewModel = PostDisplayInfoViewModel()
    
    var cancellables: Set<AnyCancellable> = []
    
    @ViewBuilder
    var body: some View {
        
        if (self.settingsViewModel.screenManagementService.mainScreenService.activeType == .captureImageView) {           
            CaptureImageView()
        }else {
            GeometryReader { geometryProxy in
                ZStack{
                    
                    UIKitArSceneView(appArScnView: self.settingsViewModel.appArScnView)
                    
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
                                    self.postDisplayNotification = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                        self.postDisplayNotification = false
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
                                            
                                            self.sceneDidResetNotification = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                                self.sceneDidResetNotification = false
                                            })
                                    }
                                    
                                    if (self.settingsViewModel.uploadIndicator > 0){
                                        Loader()
                                    }
                                }
                            }
                            .applyEdgePadding(for: .bottomRight)
                        }
                        
                    }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height, alignment: .top)
                    
                    ZStack{
                        if (self.settingsViewModel.internetErrorConnection == true){
                            VStack {
                                Spacer()
                                HStack{
                                    Spacer()
                                    Text("Couldn't refresh. No internet connection!")
                                        .foregroundColor(Color.white)
                                        .font(Font.custom("Avenir", size: 12).bold())
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    Spacer()
                                }
                                .background(Color.red)
                            }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height, alignment: .top)
                                .animation(.spring())
                        }
                        
                        if (self.settingsViewModel.postsDoNotExist == true || self.postDisplayNotification == true || self.sceneDidResetNotification == true){
                            VStack {
                                Spacer()
                                if (self.settingsViewModel.postsDoNotExist == true){
                                    HStack{
                                        Spacer()
                                        VStack{
                                            Text("No captured moments around you.")
                                            Text("Be the first one?")
                                        }
                                        .foregroundColor(Color.white)
                                        .font(Font.custom("Avenir", size: 17).bold())
                                        .multilineTextAlignment(.center)
                                        .padding(10)
                                        .background(Color.black.opacity(0.3))
                                        .cornerRadius(10)
                                        
                                        Spacer()
                                    }.padding(5)
                                }
                                if (self.postDisplayNotification == true){
                                    HStack{
                                        Spacer()
                                        Text(self.settingsViewModel.postDisplayType == .allPosts ? "Normal View" : "Personal View")
                                            .foregroundColor(Color.white)
                                            .font(Font.custom("Avenir", size: 20).bold())
                                            .padding(10)
                                            .background(Color.black.opacity(0.3))
                                            .cornerRadius(10)
                                        Spacer()
                                    }.padding(5)
                                }
                                if (self.sceneDidResetNotification == true){
                                    HStack{
                                        Spacer()
                                        Text("Did reset scene")
                                            .foregroundColor(Color.white)
                                            .font(Font.custom("Avenir", size: 20).bold())
                                            .padding(10)
                                            .background(Color.black.opacity(0.3))
                                            .cornerRadius(10)
                                        Spacer()
                                    }.padding(5)
                                }
                                Spacer()
                            }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height, alignment: .top)
                                .animation(.easeIn)
                        }
                        
                        if (self.settingsViewModel.loadIndicator > 0 || self.settingsViewModel.refreshIndicator == true){
                            PulseLoader(parentSize: geometryProxy.size)
                        }
                    }
                    
                    if self.postDisplayInfoViewModel.displayPostInfo == true {
                        VStack{
                            Spacer()
                            VStack{
                                HStack{
                                    Spacer()
                                    Image(systemName: "xmark")
                                        .font(Font.system(size:15, weight: .heavy))
                                        .foregroundColor(Color.white)
                                }.onTapGesture {
                                    self.postDisplayInfoViewModel.closeDisplayedInfo()
                                }
                                HStack(){                                   
                                    Text(self.postDisplayInfoViewModel.postDisplayInfo?.username ?? "")
                                        .foregroundColor(Color.white)
                                        .font(Font.custom("Avenir", size: 18).bold())
                                    Spacer()
                                }
                                HStack{
                                    Text(self.postDisplayInfoViewModel.postDisplayInfo?.description ?? "")
                                        .font(Font.custom("Avenir", size: 18))
                                        .foregroundColor(Color.white)
                                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                                    Spacer()
                                }
                            }
                            .padding(EdgeInsets(top: 10, leading: 5, bottom: 70, trailing: 5))
                            .frame(width: geometryProxy.size.width)
                            .background(Color.black.opacity(0.4))
                        }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height, alignment: .top)
                    }
                    ProfileView(parentSize: geometryProxy.size)
                    
                    LoginView(parentSize: geometryProxy.size).frame(width: geometryProxy.size.width, height: geometryProxy.size.height, alignment: .top)
                    
                    SetupProfileView(parentSize: geometryProxy.size)
                    
                    MoreSettingsViewModel(parentSize: geometryProxy.size)
                    
                    if (self.settingsViewModel.userProfile?.username != nil) {
                        EditUsernameView(username: self.settingsViewModel.userProfile?.username ?? "", currentUsername: self.settingsViewModel.userProfile?.username ?? "", parentSize: geometryProxy.size)
                    }
                    
                    PopUpWarningView(parentSize: geometryProxy.size, popUpWarningType: self.settingsViewModel.popUpWarningType)
                }
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color.black)
                .edgesIgnoringSafeArea(.all)
                .onDisappear {
                    self.settingsViewModel.appArScnView.pauseSession()
            }
        }
    }
        
    func areButtonsActive() -> Bool {
        // checking for no pop up warning
        return self.settingsViewModel.popUpWarningType == .none
    }
}

struct MainArView_Previews: PreviewProvider {
    static var previews: some View {
        MainArView()
    }
}
