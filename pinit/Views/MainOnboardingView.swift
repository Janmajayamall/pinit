//
//  MainOnboardingView.swift
//  pinit
//
//  Created by Janmajaya Mall on 25/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct MainOnboardingView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var parentSize: CGSize
    var backgroudColorOpacity: CGFloat = 0.5
    
    @ViewBuilder
    var body: some View {
        if (self.settingsViewModel.onboardingViewModel.checkOnboardingStatus(for: .unauthenticatedMainARView) == 0 && self.settingsViewModel.user == nil){
            MainOnboardingUnAuthenticatedView(parentSize: self.parentSize)
        }else if (self.settingsViewModel.onboardingViewModel.checkOnboardingStatus(for: .authenticatedMainARView) <  MainOnboardingAuthenticatedView.ScreenNumber.getMaxScreenNumber() && self.settingsViewModel.user != nil && self.settingsViewModel.userProfile != nil){
            MainOnboardingAuthenticatedView(screenNumber: MainOnboardingAuthenticatedView.ScreenNumber.init(rawValue: self.settingsViewModel.onboardingViewModel.checkOnboardingStatus(for: .authenticatedMainARView))!, parentSize: self.parentSize)
        }
    }
}

struct MainOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        MainOnboardingView(parentSize: .zero)
    }
}

struct MainOnboardingUnAuthenticatedView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var parentSize: CGSize
    var backgroudColorOpacity: CGFloat = 0.5
    
    var body: some View {
        VStack{
            VStack{
                Text("Welcome to FinchIt")
                    .foregroundColor(Color.primaryColor)
                    .applyDefaultThemeToTextHeader(ofType: .h1)
            }
            .padding()
            
            VStack{
                Text("An app to Capture, Share, and Explore amazing moments!")
                    .foregroundColor(Color.white)
                    .font(Font.custom("Avenir", size: 20).bold())
                    .multilineTextAlignment(.center)
            }
            .padding()
            
            Button(action: {
                 self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .login)
            }, label: {
                Text("Sign Up")
            })
                .buttonStyle(LiveViewButtonStyle(backgroundColor: .black))
                .padding()
  
            Spacer()
            
            Image(systemName:"xmark")
                .foregroundColor(Color.primaryColor)
                .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                .padding()
                .onTapGesture {
                    self.settingsViewModel.onboardingViewModel.markOnboardingStatus(for: .unauthenticatedMainARView, to: 1)
            }
            
        }
        .padding(EdgeInsets(top: 100, leading: 5, bottom: 100, trailing: 5))
        .frame(width: self.parentSize.width, height: self.parentSize.height)
        .background(Color.black.opacity(0.5))
    }
}

struct MainOnboardingAuthenticatedView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State var screenNumber: ScreenNumber
    
    var parentSize: CGSize
    var backgroudColorOpacity: CGFloat = 0.5
    
    func getChangeStepButtons(for screenNumber: ScreenNumber, nextCallback: (() -> Void)? = nil, previousCallback: (() -> Void)? = nil) -> some View {
        return AnyView (
            HStack{
                if (self.screenNumber.rawValue > 0){
                    Image(systemName:"arrow.left")
                        .foregroundColor(Color.primaryColor)
                        .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                        .padding()
                        .onTapGesture {
                            self.screenNumber = ScreenNumber.init(rawValue: self.screenNumber.rawValue-1)!
                            
                            self.settingsViewModel.onboardingViewModel.markOnboardingStatus(for: .authenticatedMainARView, to: self.screenNumber.rawValue)
                            
                            if let previousCallback = previousCallback {
                                previousCallback()
                            }
                    }
                }
                
                Spacer()
                
                if (self.screenNumber.rawValue < ScreenNumber.getMaxScreenNumber() - 1){
                    Image(systemName:"arrow.right")
                        .foregroundColor(Color.primaryColor)
                        .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                        .padding()
                        .onTapGesture {
                            self.screenNumber = ScreenNumber.init(rawValue: self.screenNumber.rawValue+1)!
                            
                            self.settingsViewModel.onboardingViewModel.markOnboardingStatus(for: .authenticatedMainARView, to: self.screenNumber.rawValue)
                            
                            if let nextCallback = nextCallback {
                                nextCallback()
                            }
                    }
                }
                
            }
        )
    }
    
    var body: some View {
        VStack{
            if (self.screenNumber == .zero){
                VStack{
                    HStack{
                        Text("Hi")
                            .foregroundColor(Color.white)
                        Text("\(self.settingsViewModel.userProfile!.username)")
                            .foregroundColor(Color.primaryColor)
                    }.applyDefaultThemeToTextHeader(ofType: .h1)
                        .applyLiveFeedTextModifier()
                    
                    VStack{
                        Text("Thanks for Signing up!")
                        Text("Right now you are viewing your surroundings through FinchIt.")
                    }
                    .applyLiveFeedTextModifier()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                    
                }
            }else if (self.screenNumber == .one){
                VStack{
                    Text("That means all moments captured in a photo or a video, by you or anyone, within a few meters of your current location will float in front of you.")
                        .applyLiveFeedTextModifier()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber, nextCallback: {
                        self.settingsViewModel.appArScnView.setupOnboardingNodes()
                    })
                }
            }else if (self.screenNumber == .two){
                VStack{
                    Text("Like this...")
                        .applyLiveFeedTextModifier()
                    
                    Spacer()
                    
                    Text("LITERALLY FLOATING!")
                        .applyLiveFeedTextModifier()
                    
                    self.getChangeStepButtons(for: self.screenNumber, previousCallback: {
                        self.settingsViewModel.appArScnView.resetScene()
                        self.settingsViewModel.appArScnView.startSession()
                    })
                }
            }else if (self.screenNumber == .three){
                VStack{
                    Text("That's right! You can see yours and others' amazing moments captured right at your current location, floating in front of you.")
                        .applyLiveFeedTextModifier()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
            }else if (self.screenNumber == .four){
                VStack{
                    Text("This makes FinchIt damn interesting and fun to play with!")
                        .applyLiveFeedTextModifier()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
            }else if (self.screenNumber == .five){
                VStack{
                    Text("You can tap on floating moments to see more of them available at your location.")
                        .applyLiveFeedTextModifier()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
            }else if (self.screenNumber == .six){
                VStack{
                    Text("You can drag them around.")
                        .applyLiveFeedTextModifier()
                }
                
                Spacer()
                
                self.getChangeStepButtons(for: self.screenNumber)
            }
            else if (self.screenNumber == .seven){
                VStack{
                    Text("You can zoom in and zoom out on them")
                        .applyLiveFeedTextModifier()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
            }else if (self.screenNumber == .eight){
                VStack{
                    Text("You can tap and hold to see captions & who captured them.")
                        .applyLiveFeedTextModifier()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
            }else if (self.screenNumber == .nine){
                VStack{
                    VStack{
                        HStack{
                            Text("You can tap on")
                            Image(systemName:"mappin.and.ellipse")
                                .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                        }
                        Text("on bottom right to bring them back in front of you as before.")
                    }
                    .applyLiveFeedTextModifier()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
            }
            else if (self.screenNumber == .ten){
                VStack{
                    VStack{
                        HStack{
                            Text("Icon")
                            Image("IconTransparent").resizable().frame(width: 50, height: 50)
                                .clipped()
                                .background(Color.black.opacity(0.1))
                                .cornerRadius(10)
                            Text("on top right")
                        }
                        Text("indicates you are in Public View, which means you see captured moment by you and others")
                    }
                    .applyLiveFeedTextModifier()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber, nextCallback: {
                        self.settingsViewModel.postDisplayType = .privatePosts
                    })
                }
            }
            else if (self.screenNumber == .eleven){
                VStack {
                    VStack{
                        HStack{
                            Text("Icon")
                            HStack{
                                Image("IconTransparent").resizable().frame(width: 50, height: 50).clipped()
                                Text("🔒")
                            }
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(10)
                            Text("On top right")
                        }
                        Text("indicates you are in Personal view, which means you only see your captured moments")
                    }
                    .applyLiveFeedTextModifier()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber, nextCallback: {
                        self.settingsViewModel.postDisplayType = .allPosts
                    }, previousCallback: {
                        self.settingsViewModel.postDisplayType = .allPosts
                    })
                }
                .foregroundColor(Color.white)
                .font(Font.custom("Avenir", size: 20).bold())
                .multilineTextAlignment(.center)
            }
            else if (self.screenNumber == .twelve){
                VStack{
                    Text("You can toggle toggle between") .applyLiveFeedTextModifier()
                    
                    VStack{
                        Image("IconTransparent").resizable().frame(width: 50, height: 50)
                            .clipped()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(10)
                        Text("AND").applyLiveFeedTextModifier()
                        HStack{
                            Image("IconTransparent").resizable().frame(width: 50, height: 50).clipped()
                            Text("🔒")
                        }
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    
                    Text("by tapping on them")
                        .applyLiveFeedTextModifier()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber, previousCallback: {
                        self.settingsViewModel.postDisplayType = .privatePosts
                    })
                }
            }else if (self.screenNumber == .thirteen){
                VStack{
                    VStack{
                        Text("To open settings")
                        HStack{
                            Text("tap on")
                            Image(systemName:"gear")
                                .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                        }
                        Text("on top right")
                    }
                    .applyLiveFeedTextModifier()
                    
                    VStack{
                        Text("To refresh")
                        HStack{
                            Text("tap on")
                            Image(systemName:"arrow.counterclockwise")
                                .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                        }
                        Text("to the left of settings")
                    }
                    .applyLiveFeedTextModifier()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
                .foregroundColor(Color.white)
                .font(Font.custom("Avenir", size: 20).bold())
                .multilineTextAlignment(.center)
            }else if (self.screenNumber == .fourteen){
                VStack{
                    VStack{
                        Text("To capture your moment, so others can see it floating at the your current location.")
                        HStack{
                            Text("tap on")
                            Image(systemName:"camera.fill")
                                .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                            Text("on bottom left")
                        }
                    }
                    .applyLiveFeedTextModifier()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber, nextCallback: {
                        self.settingsViewModel.appArScnView.resetScene()
                        self.settingsViewModel.appArScnView.startSession()
                    })
                }
                .foregroundColor(Color.white)
                .font(Font.custom("Avenir", size: 20).bold())
                .multilineTextAlignment(.center)
            }else if (self.screenNumber == .fifteen){
                VStack{
                    
                    Text("Hurray! Now its your turn to Capture your amazing moments around the world!")
                        .applyLiveFeedTextModifier()
                    
                    
                    Button(action: {
                        // mark authenticatedOnboarding & unauthenticatedOnboarding as done
                        self.settingsViewModel.onboardingViewModel.markOnboardingStatus(for: .authenticatedMainARView, to: ScreenNumber.getMaxScreenNumber())
                        self.settingsViewModel.onboardingViewModel.markOnboardingStatus(for: .unauthenticatedMainARView, to: 1)
                        
                        // reset the scene
                        self.settingsViewModel.resetARScene()
                        
                        self.settingsViewModel.startARScene()
                    }, label: {
                        Text("Get started with FinchIt!")
                    })
                        .buttonStyle(LiveViewButtonStyle(backgroundColor: .black))
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
        .onAppear {
            if (self.screenNumber.rawValue >= 2 && self.screenNumber.rawValue <= 14){
                self.settingsViewModel.appArScnView.setupOnboardingNodes()
            }
        }
    }
    
    enum ScreenNumber: Int {
        case zero = 0
        case one = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5
        case six = 6
        case seven = 7
        case eight =  8
        case nine = 9
        case ten = 10
        case eleven = 11
        case twelve = 12
        case thirteen = 13
        case fourteen = 14
        case fifteen = 15
        
        static func getMaxScreenNumber() -> Int{
            return 16
        }
    }
}
