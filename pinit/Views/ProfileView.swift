//
//  ProfileView.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var name: String = "janmajayamall · 45" // you can call pictures at different places as anchors (but anchors dont sound nice)
    var parentSize: CGSize
    
    var viewHeight:CGFloat {
        self.parentSize.height * self.viewHeightRatio
    }
    var viewWidth:CGFloat {
        self.parentSize.width * self.viewWidthRatio
    }
    
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                Rectangle().foregroundColor(Color.black)
                    .frame(width: 100, height: 100, alignment: .center)
                    .overlay(Circle().stroke(Color.secondaryColor, lineWidth: 8).frame(width: 100, height: 100))
                    .cornerRadius(50)
                    .clipped()
                    .onTapGesture {
//                        guard self.screenManagement.activeMainScreenOverlay == .profile && self.screenManagement.activeProfileScreenOverlay == .none else {return}
//                        self.screenManagement.activeProfileScreenOverlay = .changeProfileImage
                    }
                    .padding(.bottom, 10)
                
                HStack{
                    Spacer()
                    Text(self.name)
                        .font(Font.system(size: 18, weight: .semibold, design: .rounded))
                        .onTapGesture {
//                            guard self.screenManagement.activeMainScreenOverlay == .profile && self.screenManagement.activeProfileScreenOverlay == .none else {return}
//                            self.screenManagement.activeProfileScreenOverlay = .changeUsername
                    }
                    Spacer()
                }
                Spacer()
            }.zIndex(1)
            VStack{
                HStack{
                    Image(systemName: "xmark").font(Font.system(size: 15, weight: .bold))
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            //checking profileOverlay is none. If not none, then don't respond.
//                            guard self.screenManagement.activeProfileScreenOverlay == .none else {return}
//
//                            self.screenManagement.activeMainScreenOverlay = .none
                        }
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
                    Spacer()
                }
                Spacer()
            }.zIndex(1)
        }
        .frame(width: self.viewWidth, height: self.viewHeight)
        .background(Color.white)
        .cornerRadius(15)
        .offset(CGSize(width: .zero, height: parentSize.height))
        .animation(.spring())
    }
    
    private let viewHeightRatio: CGFloat = 0.3
    private let viewWidthRatio: CGFloat = 0.8
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(parentSize: CGSize(width: 300, height: 800))
    }
}
