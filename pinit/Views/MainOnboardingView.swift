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
            .cornerRadius(10)
            .padding()
            
            VStack{
                Text("An app to Capture, Share, and Explore amazing moments!")
                    .foregroundColor(Color.white)
                    .font(Font.custom("Avenir", size: 20).bold())
                    .multilineTextAlignment(.center)
            }
            .padding()
            .cornerRadius(10)
            .padding()
            
            VStack{
                VStack{
                    HStack{
                        Text("Tap on")
                        Image(systemName:"gear")
                            .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                        Text("on top right")
                    }
                    HStack{
                        Text("to Continue")
                    }
                }
                .foregroundColor(Color.white)
                .font(Font.custom("Avenir", size: 20).bold())
            }
            .padding()
            .cornerRadius(10)
            .padding()
            
            Image(systemName:"checkmark")
                .font(Font.system(size: 25, weight: .heavy))
                .foregroundColor(Color.white)
                .padding()
                .onTapGesture {
                    
            }
            
        }.frame(width: self.parentSize.width, height: self.parentSize.height)
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
                        .padding()
                    
                    VStack{
                        Text("Thanks for Signing up!")
                        Text("Right now you are viewing your surroundings through FinchIt.")
                    }
                    .foregroundColor(Color.white)
                    .font(Font.custom("Avenir", size: 20).bold())
                    .multilineTextAlignment(.center)
                    .padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                    
                }
            }else if (self.screenNumber == .one){
                VStack{
                    Text("That means all moments captured in a photo or a video, by you or anyone, within a few meters of your current location will float in front of you.")
                        .foregroundColor(Color.white)
                        .font(Font.custom("Avenir", size: 20).bold())
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber, nextCallback: {
                        self.settingsViewModel.appArScnView.setupOnboardingNodes()
                    })
                }
            }else if (self.screenNumber == .two){
                VStack{
                    Text("Like this...LITERALLY FLOATING!")
                        .foregroundColor(Color.white)
                        .font(Font.custom("Avenir", size: 20).bold())
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber, previousCallback: {
                        self.settingsViewModel.appArScnView.resetScene()
                    })
                }
            }else if (self.screenNumber == .three){
                VStack{
                    Text("That's right! You can see yours and others' amazing moments captured right at your current location, floating in front of you.")
                        .foregroundColor(Color.white)
                        .font(Font.custom("Avenir", size: 20).bold())
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
            }else if (self.screenNumber == .four){
                VStack{
                    Text("This makes FinchIt damn interesting and fun to play with!")
                        .foregroundColor(Color.white)
                        .font(Font.custom("Avenir", size: 20).bold())
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
            }else if (self.screenNumber == .five){
                VStack{
                    Text("You can tap on floating moments to see more of them available at your location.")
                        .foregroundColor(Color.white)
                        .font(Font.custom("Avenir", size: 20).bold())
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
            }else if (self.screenNumber == .six){
                VStack{
                    Text("You can drag them around.")
                        .foregroundColor(Color.white)
                        .font(Font.custom("Avenir", size: 20).bold())
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                Spacer()
                
                self.getChangeStepButtons(for: self.screenNumber)
            }
            else if (self.screenNumber == .seven){
                VStack{
                    Text("You can zoom in and zoom out on them")
                        .foregroundColor(Color.white)
                        .font(Font.custom("Avenir", size: 20).bold())
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
            }else if (self.screenNumber == .eight){
                VStack{
                    Text("You can tap and hold to see captions & who captured them.")
                        .foregroundColor(Color.white)
                        .font(Font.custom("Avenir", size: 20).bold())
                        .multilineTextAlignment(.center)
                        .padding()
                    
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
                    .foregroundColor(Color.white)
                    .font(Font.custom("Avenir", size: 20).bold())
                    .multilineTextAlignment(.center)
                    .padding()
                    
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
                    .foregroundColor(Color.white)
                    .font(Font.custom("Avenir", size: 20).bold())
                    .padding()
                    
                    Text("")
                        .foregroundColor(Color.white)
                        .font(Font.custom("Avenir", size: 20).bold())
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    
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
                    .foregroundColor(Color.white)
                    .font(Font.custom("Avenir", size: 20).bold())
                    .multilineTextAlignment(.center)
                    .padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber, nextCallback: {
                        self.settingsViewModel.postDisplayType = .allPosts
                    }, previousCallback: {
                        self.settingsViewModel.postDisplayType = .privatePosts
                    })
                }
                .foregroundColor(Color.white)
                .font(Font.custom("Avenir", size: 20).bold())
                .multilineTextAlignment(.center)
            }
            else if (self.screenNumber == .twelve){
                VStack{
                    Text("You can toggle toggle between").padding()
                    
                    VStack{
                        Image("IconTransparent").resizable().frame(width: 50, height: 50)
                            .clipped()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(10)
                        Text("AND")
                        HStack{
                            Image("IconTransparent").resizable().frame(width: 50, height: 50).clipped()
                            Text("🔒")
                        }
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(10)
                    }.padding()
                    
                    
                    Text("by tapping on them").padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
                .foregroundColor(Color.white)
                .font(Font.custom("Avenir", size: 20).bold())
                .multilineTextAlignment(.center)
            }else if (self.screenNumber == .thirteen){
                VStack{
                    VStack{
                        Text("To open settings")
                        HStack{
                            Text("tap on")
                            Image(systemName:"gear")
                                .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                            Text("on top right")
                        }
                    }.padding()
                    
                    VStack{
                     Text("To refresh")
                        HStack{
                            Text("tap on")
                            Image(systemName:"arrow.counterclockwise")
                                .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                             Text("to the left of settings")
                        }
                    }.padding()
                    
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
                    }.padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(for: self.screenNumber)
                }
                .foregroundColor(Color.white)
                .font(Font.custom("Avenir", size: 20).bold())
                .multilineTextAlignment(.center)
            }else if (self.screenNumber == .fifteen){
                VStack{
                    VStack{
                        Text("That's it for now! Now its youe turn to Capture, Share, and Explore amazing moments with FinchIt")
                    }.padding()
                    
                    Text("Note: imporve the line + change add a `Get started buttton`").onTapGesture {
                        self.settingsViewModel.onboardingViewModel.markOnboardingStatus(for: .authenticatedMainARView, to: ScreenNumber.getMaxScreenNumber())
                    }
                    
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
