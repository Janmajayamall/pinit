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
    @State var captureType: CameraFeedController.CameraOutputType = .photo
    
    @State var isLongPress: Bool = false
    @State var didTouchEnd: Bool = false
    @State var didTouchBegin: Bool = false
    
    var cancellables: Set<AnyCancellable> = []
    
    @ViewBuilder
    var body: some View {
        
        if self.settingsViewModel.screenManagementService.mainScreenService.captureImageViewScreenService.activeType == .editCaptureImage && self.settingsViewModel.editingViewModel != nil {
            EditCaptureImageView().environmentObject(self.settingsViewModel.editingViewModel!)
        }else if (self.settingsViewModel.screenManagementService.mainScreenService.captureImageViewScreenService.activeType == .editCaptureVideo && self.settingsViewModel.editingVideoViewModel != nil){
            EditCaptureVideoView().environmentObject(self.settingsViewModel.editingVideoViewModel!)
        }
        else{
            GeometryReader{ geometryProxy in
                
                CameraFeedViewController()
                
                if (self.isLongPress == false) {
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
                                            print("not possible error")
                                        }
                                        NotificationCenter.default.post(name: .cameraFeedSwitchFlashMode, object: self.cameraFlashMode)
                                        
                                }
                                
                            }.applyTopRightPaddingToIcon()
                        }
                        Spacer()
                    }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                }
                
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        //                        Button(action: {
                        //                            if (self.isLongPress == true){
                        //                                print("OFF")
                        ////                                NotificationCenter.default.post(name: .cameraFeedDidRequestToggleRecordingVideo, object: true)
                        //                                self.isLongPress = false
                        //                            }else {
                        //                                print("Camera")
                        //                                NotificationCenter.default.post(name: .cameraFeedDidRequestCaptureImage, object: true)
                        //                            }
                        //                        }, label: {
                        //
                        //                        })
                        Circle()
                            .foregroundColor(Color.white.opacity(0.00001))
                            .frame(width: self.isLongPress ? 120 : 80, height: self.isLongPress ? 120 : 80)
                            .overlay(Circle().stroke(Color.white, lineWidth: 8))
                            
                            .gesture(DragGesture(minimumDistance: 0.0)
                                .onChanged({ (value) in
                                    guard self.didTouchBegin == false else {return}
                                    self.didTouchBegin = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                        guard self.didTouchEnd == false else {return}
                                        self.isLongPress = true
                                        NotificationCenter.default.post(name: .cameraFeedDidRequestToggleRecordingVideo, object: true)
                                        
                                    })
                                    
                                }).onEnded({ (value) in
                                    DispatchQueue.main.async {
                                        self.didTouchEnd = true
                                    }
                                    if (self.isLongPress == false){
                                        NotificationCenter.default.post(name: .cameraFeedDidRequestCaptureImage, object: true)
                                    }else {
                                        NotificationCenter.default.post(name: .cameraFeedDidRequestToggleRecordingVideo, object: true)
                                    }
                                }))
                            .padding(.bottom, 10)
                            .animation(.spring())
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
