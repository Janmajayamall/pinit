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
        if (!self.settingsViewModel.onboardingViewModel.checkOnboardingStatus(for: .unauthenticatedMainARView) && self.settingsViewModel.user == nil){
            MainOnboardingUnAuthenticatedView(parentSize: self.parentSize)
        }else if (!self.settingsViewModel.onboardingViewModel.checkOnboardingStatus(for: .authenticatedMainARView) && self.settingsViewModel.user != nil && self.settingsViewModel.userProfile != nil){
            MainOnboardingAuthenticatedView(parentSize: self.parentSize)
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
                Text("An app to Capture, Relive, and Share your moments with others")
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
    @State var screenNumber: ScreenNumber = .three
    
    var parentSize: CGSize
    var backgroudColorOpacity: CGFloat = 0.5
    
    func getChangeStepButtons(prev: ScreenNumber? = nil, next: ScreenNumber? = nil) -> some View {
        return AnyView (
            HStack{
                
                if (prev != nil){
                    Image(systemName:"arrow.left")
                        .font(Font.system(size: 25, weight: .heavy))
                        .foregroundColor(Color.primaryColor)
                        .padding()
                        .onTapGesture {
                            self.screenNumber = prev!
                    }
                }
                
                Spacer()
                
                if (next != nil){
                    Image(systemName:"arrow.right")
                        .font(Font.system(size: 25, weight: .heavy))
                        .foregroundColor(Color.primaryColor)
                        .padding()
                        .onTapGesture {
                            self.screenNumber = next!
                            
                    }
                }
                
            }
        )
    }
    
    var body: some View {
        VStack{
            if (self.screenNumber == .one){
                VStack{
                    HStack{
                        Text("Hi")
                            .foregroundColor(Color.white)
                        Text("\(self.settingsViewModel.userProfile!.username)")
                            .foregroundColor(Color.primaryColor)
                        
                        
                    }.applyDefaultThemeToTextHeader(ofType: .h1)
                        .padding()
                    
                    VStack{
                        Text("Thanks for Signing up! Right now you are viewing your surroundings through FinchIt")
                    }
                    .foregroundColor(Color.white)
                    .font(Font.custom("Avenir", size: 20).bold())
                    .multilineTextAlignment(.center)
                    .padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(next: .two)
                    
                }
            }else if (self.screenNumber == .two){
                VStack{
                    Text("That means all captured moments, can be a photo or a video, by anyone within a few meters from your location will float in front of you in AR.")
                        .foregroundColor(Color.white)
                        .font(Font.custom("Avenir", size: 20).bold())
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(prev: .one, next: .three)
                }
            }else if (self.screenNumber == .three){
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
                        Text("indicates you are in Normal view.")
                    }
                    .foregroundColor(Color.white)
                    .font(Font.custom("Avenir", size: 20).bold())
                    .padding()
                    
                    Text("In Normal view, you can view all moments captured by anyone near your location.")
                        .foregroundColor(Color.white)
                        .font(Font.custom("Avenir", size: 20).bold())
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    
                    Spacer()
                    
                    self.getChangeStepButtons(prev: .two, next: .four)
                }
            }
            else if (self.screenNumber == .four){
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
                        Text("indicates you are in Personal view.")
                    }
                    .foregroundColor(Color.white)
                    .font(Font.custom("Avenir", size: 20).bold())
                    .multilineTextAlignment(.center)
                    .padding()
                    
                    Text("In Personal view, you only view moments that you have captured near your current location.")
                    
                    Spacer()
                    
                    self.getChangeStepButtons(prev: .three, next: .five)
                }
                .foregroundColor(Color.white)
                .font(Font.custom("Avenir", size: 20).bold())
                .multilineTextAlignment(.center)
            }
            else if (self.screenNumber == .five){
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
                    
                    
                    Text("By tapping on them").padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(prev: .four, next: .six)
                }
                .foregroundColor(Color.white)
                .font(Font.custom("Avenir", size: 20).bold())
                .multilineTextAlignment(.center)
            }else if (self.screenNumber == .six){
                VStack{
                    VStack{
                        HStack{
                            Text("Tap on")
                            Image(systemName:"gear")
                                .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                            Text("on top right")
                        }
                        Text("to open settings")
                    }.padding()
                    
                    VStack{
                        HStack{
                            Text("Tap on")
                            Image(systemName:"arrow.counterclockwise")
                                .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                            Text("to left of settings")
                        }
                        Text("to reload all captured moments floating in fron of you")
                    }.padding()
                    
                    Spacer()
                    
                    self.getChangeStepButtons(prev: .five, next: .seven)
                }
                .foregroundColor(Color.white)
                .font(Font.custom("Avenir", size: 20).bold())
                .multilineTextAlignment(.center)
            }else if (self.screenNumber == .seven){
                VStack{
                    VStack{
                        HStack{
                            Text("Tap on")
                            Image(systemName:"camera.fill")
                                .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                            Text("on bottom left")
                        }
                        Text("to capture your moment at a location and share with others")
                        
                        Spacer()
                        
                        self.getChangeStepButtons(prev: .six)
                    }.padding()
                }
            }else if (self.screenNumber == .eight){
                
            }
        }
        .padding(EdgeInsets(top: 100, leading: 5, bottom: 100, trailing: 5))
        .frame(width: self.parentSize.width, height: self.parentSize.height)
        
    }
    
    enum ScreenNumber {
        case one
        case two
        case three
        case four
        case five
        case six
        case seven
        case eight
    }
}
