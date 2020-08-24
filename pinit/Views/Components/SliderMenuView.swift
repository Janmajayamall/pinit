//
//  SliderMenuView.swift
//  pinit
//
//  Created by Janmajaya Mall on 23/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct SliderMenuView: View {
    
    @State var showMenu: Bool = false
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        ZStack{
            if (self.showMenu == true){
                VStack{
                    Image(systemName: "person.fill")
                        .applyDefaultIconTheme()
                        .padding(.bottom, 15)
                    
                    Image(systemName: "globe")
                        .applyDefaultIconTheme()
                        .padding(.bottom, 15)
                    
                    Image(systemName: "globe")
                        .applyDefaultIconTheme()
                        .onTapGesture {
                            self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .profile)
                            self.showMenu = false
                    }
                        .padding(.bottom, 15)
                }
            }
            
            Image(systemName: self.showMenu ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                .font(Font.system(size: 20, weight: .heavy))
                .foregroundColor(Color.white)
                .onTapGesture {
                    guard self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.activeType == .normal else {return}
                    
                    withAnimation {
                        self.showMenu = !self.showMenu
                    }
            }
            .offset(CGSize(width: .zero, height: self.showMenu ? 80 : 0))
            .animation(.linear)
        }.frame(width: 50, height: 80, alignment: .top)
    }
}

struct SliderMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SliderMenuView()
    }
}
