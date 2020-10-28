//
//  CameraFeedOnboardingView.swift
//  pinit
//
//  Created by Janmajaya Mall on 28/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct CameraFeedOnboardingView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State var screenNumber: ScreenNumber = .zero
    
    var parentSize: CGSize
    
    func getChangeStepButtons(for screenNumber: ScreenNumber) -> some View {
        print(screenNumber, "camera feed view onboarding")
        return AnyView (
            HStack{
                if (self.screenNumber.rawValue > 0){
                    Image(systemName:"arrow.left")
                        .foregroundColor(Color.primaryColor)
                        .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                        .padding()
                        .onTapGesture {
                            self.screenNumber = ScreenNumber.init(rawValue: self.screenNumber.rawValue-1)!
                    }
                }
                
                Spacer()
                
                if (self.screenNumber.rawValue < ScreenNumber.maxScreenNumber - 1){
                    Image(systemName:"arrow.right")
                    .foregroundColor(Color.primaryColor)
                    .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                    .padding()
                        .onTapGesture {
                            self.screenNumber = ScreenNumber.init(rawValue: self.screenNumber.rawValue+1)!
                    }
                }
            }
        )
    }
    
    var body: some View {
        VStack{
            if (self.screenNumber == .zero){
                VStack{
                    
                    Text("Ready to capture your first moment?").padding()
                                        
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
                .foregroundColor(Color.white)
                .font(Font.custom("Avenir", size: 20).bold())
                .multilineTextAlignment(.center)
            }else if (self.screenNumber == .one){
                VStack{
                    VStack{
                        Text("Tap on")
                        Circle()
                            .foregroundColor(Color.white.opacity(0.00001))
                            .frame(width: 80, height: 80)
                            .overlay(Circle().stroke(Color.white, lineWidth: 8))
                        Text("to capture a photo")
                        Text("and tap & hold to capture a video")
                    }.padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
                .foregroundColor(Color.white)
                .font(Font.custom("Avenir", size: 20).bold())
                .multilineTextAlignment(.center)
            }else if (self.screenNumber == .two){
                VStack{
                    Text("After capturing your moment tap anywhere on screen to give moment a caption")
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
                .foregroundColor(Color.white)
                .font(Font.custom("Avenir", size: 20).bold())
                .multilineTextAlignment(.center)
            }else if (self.screenNumber == .three){
                VStack{
                    VStack{
                        Text("To post your moment at your current location")
                        HStack{
                            Text("tap on")
                            Image(systemName: "checkmark")
                                .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                            Text("on top right!")
                        }
                        
                    }.padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
                .foregroundColor(Color.white)
                .font(Font.custom("Avenir", size: 20).bold())
                .multilineTextAlignment(.center)
            
            }else if (self.screenNumber == .four){
                VStack{
                    Text("After posting, you and others can see your moment floating at your current location!")
                        .padding()
                    
                    Text("Ready to capture")
                        .onTapGesture {
                            self.settingsViewModel.onboardingViewModel.markOnboardingStatus(for: .cameraFeedView, to: CameraFeedOnboardingView.ScreenNumber.maxScreenNumber)
                    }
                        .padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
                .foregroundColor(Color.white)
                .font(Font.custom("Avenir", size: 20).bold())
                .multilineTextAlignment(.center)
                
            }
        }
        .padding(EdgeInsets(top: 100, leading: 5, bottom: 100, trailing: 5))
        .frame(width: self.parentSize.width, height: self.parentSize.height)
        .background(Color.black.opacity(0.5))
        .onTapGesture {
            
            
        }
    }
            
    enum ScreenNumber: Int {
        case zero = 0
        case one = 1
        case two = 2
        case three = 3
        case four = 4
        
        static var maxScreenNumber: Int = 5
    }
}

struct CameraFeedOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        CameraFeedOnboardingView(parentSize: .zero)
    }
}
