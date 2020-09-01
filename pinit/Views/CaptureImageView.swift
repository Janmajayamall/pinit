//
//  CaptureImageView.swift
//  pinit
//
//  Created by Janmajaya Mall on 19/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct CaptureImageView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    @ViewBuilder
    var body: some View {
    
        if self.settingsViewModel.screenManagementService.mainScreenService.captureImageViewScreenService.activeType == .editCaptureImage {
            EditCaptureImageView().environmentObject(EditingViewModel(selectedImage: Image("ProfileImage")))
        }else{
            GeometryReader{ geometryProxy in
            
                CameraFeedViewController()
                
                VStack{
                    HStack{
                        Image(systemName: "xmark")
                            .foregroundColor(Color.white)
                        .applyDefaultIconTheme()
                            .onTapGesture {
                                self.settingsViewModel.screenManagementService.mainScreenService.switchTo(screenType: .mainArView)
                        }
                        .applyTopLeftPaddingToIcon()
                        Spacer()
                    }
                    Spacer()
                    HStack{
                        Image(systemName: "xmark")
                            .foregroundColor(Color.white)
                        .applyDefaultIconTheme()
                            .onTapGesture {
                                NotificationCenter.default.post(name: .cameraFeedSwitchInUseCamera, object: true)
                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 0))
                        Spacer()
                    }
                }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        Circle()
                            .foregroundColor(.purple)
                            .frame(width: 80, height: 80)
                            .onTapGesture {
                                self.settingsViewModel.screenManagementService.mainScreenService.captureImageViewScreenService.switchTo(screenType: .editCaptureImage)
                        }
                        Spacer()
                    }
                }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct CaptureImageView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureImageView()
    }
}
//parentSize: CGSize(width: 300, height: 800)
