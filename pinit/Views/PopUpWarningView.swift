//
//  PopUpWarningView.swift
//  pinit
//
//  Created by Janmajaya Mall on 26/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct PopUpWarningView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    var parentSize: CGSize
    var popUpWarningType: PopUpWarningType
    
    var viewSize: CGSize {
        return CGSize(width: self.parentSize.width * self.viewWidthRatio, height: self.parentSize.height * self.viewHeightRatio)
    }
    var offset: CGSize {
        if (self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.activeType == .popUpWarning){
            return .zero
        }else {
            return CGSize(width: .zero, height: self.parentSize.height)
        }
    }
    
    var body: some View {
        ZStack {
            VStack{
                Spacer()
                
                HStack{
                    Spacer()
                    Text(self.popUpWarningType.rawValue)
                        .font(Font.custom("Avenir", size: 17).bold())
                        .foregroundColor(Color.black)
                        
                    Spacer()
                }
                
                Spacer()
                
                Button(action: {
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {return}
                    
                    if (UIApplication.shared.canOpenURL(settingsURL)){
                        UIApplication.shared.open(settingsURL)
                    }
                }, label: {
                    Text("Open Settings")
                })
                    .buttonStyle(SecondaryColorButtonStyle())
                
                Spacer()
            }.zIndex(1)
//            VStack{
//                HStack{
//                    Image(systemName: "xmark")
//                        .foregroundColor(Color.primaryColor)
//                        .applyDefaultIconTheme()
//                        .onTapGesture {
//
//                    }
//                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                    Spacer()
//                }
//                Spacer()
//            }.zIndex(1)
        }.frame(width: self.viewSize.width, height: self.viewSize.height)
            .background(Color.white)
                .cornerRadius(15)
            .offset(self.offset)
        .animation(.spring())
    }
    
    private let viewHeightRatio: CGFloat = 0.40
    private let viewWidthRatio: CGFloat = 0.80
}

struct PopUpWarningView_Previews: PreviewProvider {
    static var previews: some View {
        PopUpWarningView(parentSize: .zero, popUpWarningType: .none)
    }
}

enum PopUpWarningType: String {
    case locationPermissionUnavailable = "FinchIt does not has access to your location and needs it for working 🤓. Please open app settings and provide location access to FinchIt 😛."
    case cameraPermissionUnavailable = "FinchIt does not has access to your camera and needs it for working 🤓. Please open app settings and provide camera access to FinchIt 😛."
    case locationAndCameraPermissionUnavailable = "FinchIt is a location & camera based app and needs access to them for working 🤓. Please open app settings and provide required permissions to FinchIt 😛."
    case none = ""
}
