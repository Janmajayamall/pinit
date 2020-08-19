//
//  EditUsernameView.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct EditUsernameView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State var username: String = "janmajayamall"
    
    var parentSize: CGSize
    
    var viewHeight: CGFloat {
        self.parentSize.height * self.viewHeightRatio
    }
    var viewWidth: CGFloat {
        self.parentSize.width * self.viewWidthRatio
    }
    
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Text("Change your username").font(Font.custom("Avenir", size: 20)).bold().foregroundColor(Color.black)
                    Spacer()
                }.padding(.bottom, 2)
                HStack{
                    TextField("Username", text: self.$username).font(Font.custom("Avenir", size: 18)).padding(10).background(Color.textfieldColor).cornerRadius(5)
                }.padding(EdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5))
                Button(action: {
                    print("dadada")
                }, label: {
                    HStack{
                        Spacer()
                        Text("Done").font(Font.custom("Avenir", size: 20)).bold().foregroundColor(Color.white)
                        Spacer()
                    }
                    .frame(width: 100, height: 50)
                    .clipped()
                    .background(Color.secondaryColor)
                    .cornerRadius(25)
                    
                })
                Spacer()
            }.zIndex(1)
            VStack{
                HStack{
                    Image(systemName: "xmark").font(Font.system(size: 15, weight: .bold))
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
//                            self.screenManagement.activeProfileScreenOverlay = .none
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
        .offset(CGSize(width: .zero, height:self.parentSize.height))
        .animation(.spring())
    }
    
    private let viewHeightRatio: CGFloat = 0.3
    private let viewWidthRatio: CGFloat = 0.8
}

struct EditUsernameView_Previews: PreviewProvider {
    static var previews: some View {
        EditUsernameView(parentSize: CGSize(width: 300, height: 200))
    }
}
