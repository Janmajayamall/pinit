//
//  MainArViewIndicatorsView.swift
//  pinit
//
//  Created by Janmajaya Mall on 25/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct MainArViewIndicatorsView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @ObservedObject var postDisplayInfoViewModel: PostDisplayInfoViewModel = PostDisplayInfoViewModel()
    
    var parentSize: CGSize
    
    var body: some View {
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
                }.frame(width: self.parentSize.width, height: self.parentSize.height, alignment: .top)
                    .animation(.spring())
            }
            
            if (self.settingsViewModel.postsDoNotExist == true || self.settingsViewModel.postDisplayNotification == true || self.settingsViewModel.sceneDidResetNotification == true){
                VStack {
                    Spacer()
                    if (self.settingsViewModel.postsDoNotExist == true){
                        HStack{
                            Spacer()
                            VStack{
                                Text("No captured moments around you.")
                                Text("Be the first one?")
                            }
                            .foregroundColor(Color.white)
                            .font(Font.custom("Avenir", size: 17).bold())
                            .multilineTextAlignment(.center)
                            .padding(10)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(10)
                            
                            Spacer()
                        }.padding(5)
                    }
                    if (self.settingsViewModel.postDisplayNotification == true){
                        HStack{
                            Spacer()
                            Text(self.settingsViewModel.postDisplayType == .allPosts ? "Normal View" : "Personal View")
                                .foregroundColor(Color.white)
                                .font(Font.custom("Avenir", size: 20).bold())
                                .padding(10)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(10)
                            Spacer()
                        }.padding(5)
                    }
                    if (self.settingsViewModel.sceneDidResetNotification == true){
                        HStack{
                            Spacer()
                            Text("Did reset scene")
                                .foregroundColor(Color.white)
                                .font(Font.custom("Avenir", size: 20).bold())
                                .padding(10)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(10)
                            Spacer()
                        }.padding(5)
                    }
                    Spacer()
                }.frame(width: self.parentSize.width, height: self.parentSize.height, alignment: .top)
                    .animation(.easeIn)
            }
            
            if (self.settingsViewModel.loadIndicator > 0 || self.settingsViewModel.refreshIndicator == true){
                PulseLoader(parentSize: self.parentSize)
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
                    .frame(width: self.parentSize.width)
                    .background(Color.black.opacity(0.4))
                }.frame(width: self.parentSize.width, height: self.parentSize.height, alignment: .top)
            }
            
            
        }.frame(width: parentSize.width, height: parentSize.height)
    }
}

struct MainArViewIndicatorsView_Previews: PreviewProvider {
    static var previews: some View {
        MainArViewIndicatorsView(parentSize: .zero)
    }
}
