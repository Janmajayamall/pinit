//
//  CaptureImageView.swift
//  pinit
//
//  Created by Janmajaya Mall on 19/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI
import AVFoundation
import Combine

struct CaptureImageView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @State var cameraPosition: CameraFeedController.CameraInUsePosition = .rear
    @State var cameraFlashMode: AVCaptureDevice.FlashMode = .off

    var cancellables: Set<AnyCancellable> = []
    
    @ViewBuilder
    var body: some View {
    
        if self.settingsViewModel.screenManagementService.mainScreenService.captureImageViewScreenService.activeType == .editCaptureImage && self.settingsViewModel.editingViewModel != nil {
            EditCaptureImageView().environmentObject(self.settingsViewModel.editingViewModel!)
        }else{
            GeometryReader{ geometryProxy in
            
                CameraFeedViewController()
                
                VStack{
                    HStack (alignment: .top){
                        Image(systemName: "xmark")
                            .foregroundColor(Color.white)
                        .applyDefaultIconTheme()
                            .onTapGesture {
                                self.settingsViewModel.screenManagementService.mainScreenService.switchTo(screenType: .mainArView)
                        }
                        .applyTopLeftPaddingToIcon()
                        Spacer()
                        VStack{
                            Image(systemName: self.cameraPosition == .rear ? "gobackward" : "goforward")
                                .foregroundColor(Color.white)
                            .applyDefaultIconTheme()
                                .onTapGesture {
                                    switch self.cameraPosition{
                                    case .rear:
                                        self.cameraPosition = .front
                                    case .front:
                                        self.cameraPosition = .rear
                                    }
                                    NotificationCenter.default.post(name: .cameraFeedSwitchInUseCamera, object: self.cameraPosition)
                            }.padding(.bottom)
                            
                            Image(systemName: self.cameraFlashMode == .off ? "bolt.slash" : "bolt.fill")
                                .foregroundColor(Color.white)
                            .applyDefaultIconTheme()
                                .onTapGesture {
                                    switch self.cameraFlashMode{
                                    case .off:
                                        self.cameraFlashMode = .on
                                    case .on:
                                        self.cameraFlashMode = .off
                                    default:
                                        print("no possible error")
                                    }
                                    NotificationCenter.default.post(name: .cameraFeedSwitchFlashMode, object: self.cameraFlashMode)
                                    
                            }
                            
                        }.applyTopRightPaddingToIcon()
                    }
                    Spacer()
                }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        Circle()
                            .foregroundColor(Color.white.opacity(0.00001))
                            .frame(width: 80, height: 80)
                            .overlay(Circle().stroke(Color.white, lineWidth: 8))
                            .onTapGesture {

                                NotificationCenter.default.post(name: .cameraFeedDidRequestCaptureImage, object: true)
                        }
                        .padding(.bottom, 10)
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
