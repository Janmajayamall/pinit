//
//  CameraFeedView.swift
//  pinit
//
//  Created by Janmajaya Mall on 17/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI
import AVFoundation

struct CameraFeedView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @State var cameraPosition: CameraFeedController.CameraInUsePosition = .rear
    @State var cameraFlashMode: AVCaptureDevice.FlashMode = .off
    @State var captureType: CameraFeedController.CameraOutputType = .photo
    
    @State var isLongPress: Bool = false
    @State var didTouchEnd: Bool = false
    @State var didTouchBegin: Bool = false
    
    @State var recordingTimer: Timer?
    @State var recordingCircleFillRatio: CGFloat =  0
    
    
    var body: some View {
        GeometryReader{ geometryProxy in
            
            CameraFeedViewController()
            
            if (self.isLongPress == false) {
                VStack{
                    HStack (alignment: .top){
                        Image(systemName: "chevron.left")
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
                    Circle()
                        .foregroundColor(Color.white.opacity(0.00001))
                        .frame(width: self.isLongPress ? 120 : 80, height: self.isLongPress ? 120 : 80)
                        .overlay(Circle().stroke(Color.white, lineWidth: 8))
                        .overlay(Circle()
                            .trim(from: 1-self.recordingCircleFillRatio, to: 1)
                            .stroke(Color.red, lineWidth: 8))
                        .gesture(DragGesture(minimumDistance: 0.0)
                            .onChanged({ (value) in
                                guard self.didTouchBegin == false else {return}
                                self.didTouchBegin = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                    guard self.didTouchEnd == false else {return}
                                    self.isLongPress = true
                                    NotificationCenter.default.post(name: .cameraFeedDidRequestToggleRecordingVideo, object: true)
                                    
                                    // start recording timer
                                    let increaseBy: Double = 0.01
                                    let timeInterval = (self.maxRecordingTime / (1/increaseBy))
                                    self.recordingTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: {_ in
                                        self.recordingCircleFillRatio += CGFloat(increaseBy)
                                    })
                                    
                                    // set recording deadline
                                    self.setRecordingDeadline()
                                })
                                
                            }).onEnded({ (value) in
                                DispatchQueue.main.async {
                                    self.didTouchEnd = true
                                }
                                if (self.isLongPress == false){
                                    NotificationCenter.default.post(name: .cameraFeedDidRequestCaptureImage, object: true)
                                }else {
                                    // invalidating the timer
                                    self.recordingTimer?.invalidate()
                                    
                                    NotificationCenter.default.post(name: .cameraFeedDidRequestToggleRecordingVideo, object: true)
                                }
                            }))
                        .padding(.bottom, 20)
                        .animation(.spring())
                    Spacer()
                }
            }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
            
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
    }
    
    func setRecordingDeadline() {
        DispatchQueue.main.asyncAfter(deadline: .now() + self.maxRecordingTime, execute: {
            // invalidating the timer
            self.recordingTimer?.invalidate()
            
            NotificationCenter.default.post(name: .cameraFeedDidRequestToggleRecordingVideo, object: true)
        })
    }
    
    let maxRecordingTime: Double = 10.0
}

struct CameraFeedView_Previews: PreviewProvider {
    static var previews: some View {
        CameraFeedView()
    }
}
