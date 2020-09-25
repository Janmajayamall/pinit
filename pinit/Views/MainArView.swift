//
//  MainArView.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics

struct MainArView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State var mapViewScreenState: SwipeScreenState = .down
    @State var mapViewYDragTranslation: CGFloat = 0
    
    @State var postDisplayType: PostDisplayType = .allPosts
    @ObservedObject var postDisplayInfoViewModel: PostDisplayInfoViewModel = PostDisplayInfoViewModel()
    
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
                            ZStack{
                                Image(systemName: self.postDisplayType == .allPosts ? "person.fill": "person.2.fill")
                                    .applyDefaultIconTheme()
                                
                                if (self.settingsViewModel.uploadIndicator > 0){
                                    Loader()
                                }
                                
                            }
                            .applyEdgePadding(for: .topLeft)
                            .onTapGesture {
                                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                                    AnalyticsParameterItemID: "id-\("title!")",
                                    AnalyticsParameterItemName: "title!",
                                    AnalyticsParameterContentType: "cont"
                                ])
                                if self.settingsViewModel.isUserAuthenticated() {
                                    switch self.postDisplayType {
                                    case .allPosts:
                                        self.postDisplayType = .privatePosts
                                    case .privatePosts:
                                        self.postDisplayType = .allPosts
                                    }
                                    
                                    // post notification for group scn node
                                    NotificationCenter.default.post(name: .groupSCNNodeDidRequestChangePostDisplayType, object: self.postDisplayType)
                                    
                                }else {
                                    self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .login)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.counterclockwise")
                                .applyDefaultIconTheme()
                                .applyEdgePadding(for: .topRight)
                                .onTapGesture {
                                    self.settingsViewModel.refreshScene()
                            }
                            
                            Image(systemName:"gear")
                                .applyDefaultIconTheme()
                                .applyEdgePadding(for: .topRight)
                                .onTapGesture {
                                    if self.settingsViewModel.isUserAuthenticated() {
                                        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .profile)
                                    }else {
                                        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .login)
                                    }
                            }
                        }
                        Spacer()
                        HStack{
                            Image(systemName: "camera.fill")
                                .applyDefaultIconTheme()
                                .applyEdgePadding(for: .bottomLeft)
                                .onTapGesture {
                                    if self.settingsViewModel.isUserAuthenticated() {
                                        //                                        // stop session
                                        //                                        self.settingsViewModel.appArScnView.pauseSession()
                                        
                                        self.settingsViewModel.screenManagementService.mainScreenService.switchTo(screenType: .captureImageView)
                                    }else {
                                        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .login)
                                    }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.left")
                                .applyDefaultIconTheme()
                                .applyEdgePadding(for: .bottomRight)
                                .onTapGesture {
                                    NotificationCenter.default.post(name: .aRViewDidTapBackIcon, object: true)
                            }
                            
                            Image(systemName: "mappin.and.ellipse")
                                .applyDefaultIconTheme()
                                .applyEdgePadding(for: .bottomRight)
                                .onTapGesture {
                                    print("Posted")
                                    // notifiy app ar scene to reset group scn nodes positions
                                    NotificationCenter.default.post(name: .aRViewDidRequestResetGroupNodesPos, object: true)
                            }
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
                        
                        if (self.settingsViewModel.postsDoNotExist == true){
                            VStack {
                                Spacer()
                                HStack{
                                    Spacer()
                                    Text("No Pins near you. Be the first one?")
                                        .foregroundColor(Color.white)
                                        .font(Font.custom("Avenir", size: 17).bold())
                                        .padding(10)
                                        .background(Color.black.opacity(0.3))
                                        .cornerRadius(10)
                                    Spacer()
                                }
                                Spacer()
                            }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height, alignment: .top)
                                .animation(.spring())
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
                }
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color.black)
                .edgesIgnoringSafeArea(.all)
                .gesture(DragGesture(minimumDistance: 10)
                    .onChanged({value in
                        guard self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.activeType == .normal else {return}
                        
                        guard (self.mapViewScreenState == .up && value.translation.height > 0) || (self.mapViewScreenState == .down && value.translation.height < 0) else {return}
                        
                        self.mapViewYDragTranslation = value.translation.height
                    })
                    .onEnded({value in
                        
                        guard self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.activeType == .normal else {return}
                        
                        if (self.mapViewScreenState == .up && value.translation.height > 0) {
                            self.mapViewScreenState = .down
                        }else if (self.mapViewScreenState == .down && value.translation.height < 0){
                            self.mapViewScreenState = .up
                        }
                        
                        self.mapViewYDragTranslation = 0
                        }
                ))
                .onDisappear {
                    self.settingsViewModel.appArScnView.pauseSession()
            }
            
            
        }
        
    }
    
    func forceMapViewToDownState(){
        self.mapViewYDragTranslation = 0
        self.mapViewScreenState = .down
    }
}

struct MainArView_Previews: PreviewProvider {
    static var previews: some View {
        MainArView()
    }
}


//Image(systemName: "chevron.down")
//    .applyDefaultIconTheme()
//    .onTapGesture {
//        // making sure mapView screen state is down
//        self.forceMapViewToDownState()
//
//        if self.settingsViewModel.isUserAuthenticated() {
//            self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .profile)
//        }else {
//            self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .login)
//        }
//}
//.applyTopLeftPaddingToIcon()

