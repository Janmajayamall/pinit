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
    @State var mapViewYDragTranslation: CGFloat = 0
    
    @State var showMenu: Bool = false
    
    @ViewBuilder
    var body: some View {
        
        if (self.settingsViewModel.screenManagementService.mainScreenService.activeType == .captureImageView) {           
            CaptureImageView()
        }else {
            GeometryReader { geometryProxy in
                ZStack{
                    
                    UIKitArSceneView(parentSize: geometryProxy.size)
                    
                    MapView(parentGeometrySize: geometryProxy.size, screenState: self.$mapViewScreenState, yDragTranslation: self.$mapViewYDragTranslation)
                    
                    
                    VStack{
                        HStack{
                            //                            HStack{
                            Image(systemName: "person.fill")
                            .applyDefaultIconTheme()
                                .applyTopLeftPaddingToIcon()
                                .onTapGesture {
                                    if self.settingsViewModel.isUserAuthenticated() {
                                        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .profile)
                                    }else {
                                        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .login)
                                    }
                                    self.showMenu = false
                            }.zIndex(3)
                                                 
                            Spacer()
                        }
                        Spacer()
                        HStack{
                            Image(systemName: "camera.fill")
                                .applyDefaultIconTheme()
                                .padding(EdgeInsets(top: 0, leading: 45, bottom: 45, trailing: 0))
                                .onTapGesture {
                                    // closing the map view, if it is open
                                    self.forceMapViewToDownState()
                                    
                                    if self.settingsViewModel.isUserAuthenticated() {
                                        self.settingsViewModel.screenManagementService.mainScreenService.switchTo(screenType: .captureImageView)
                                    }else {
                                        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .login)
                                    }
                            }
                            
                            Spacer()
                        }
                        
                    }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height, alignment: .top)
                    
                    ProfileView(parentSize: geometryProxy.size)
                    
                    
                    
                    LoginView(parentSize: geometryProxy.size).frame(width: geometryProxy.size.width, height: geometryProxy.size.height, alignment: .top)
                    
                    SetupProfileView(parentSize: geometryProxy.size)
                    
                    EditProfileImageView(imageCropViewModel: ImageCropViewModel(image: self.settingsViewModel.userProfileImage ?? UIImage(imageLiteralResourceName: "ProfileImage")), parentSize: geometryProxy.size)
                    
                    MoreSettingsViewModel(parentSize: geometryProxy.size)
                    
                    if self.settingsViewModel.userProfile?.username != nil {
                        EditUsernameView(username: self.settingsViewModel.userProfile!.username, parentSize: geometryProxy.size)
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


