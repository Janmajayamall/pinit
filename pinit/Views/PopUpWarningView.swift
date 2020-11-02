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
    
    var viewSize: CGSize {
        return CGSize(width: self.parentSize.width * self.viewWidthRatio, height: self.parentSize.height * self.viewHeightRatio)
    }
    var offset: CGSize {
        if (self.settingsViewModel.popUpWarningType != .none){
            return .zero
        }else {
            return CGSize(width: .zero, height: self.parentSize.height)
        }
    }
    
    var body: some View {
        VStack{
            Spacer()
            
            HStack{
                Spacer()
                Text(self.settingsViewModel.popUpWarningType.rawValue)
                    .font(Font.custom("Avenir", size: 17).bold())
                    .multilineTextAlignment(.center)
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
        PopUpWarningView(parentSize: .zero)
    }
}

enum PopUpWarningType: String {
    case locationPermissionUnavailable = "FinchIt needs access to your location for working 🤓. To continue, open settings and give location access to FinchIt 😛."
    case cameraPermissionUnavailable = "FinchIt needs access to your camera for working 🤓. To continue, open settings and give camera access to FinchIt 😛."
    case locationAndCameraPermissionUnavailable = "FinchIt needs access to your location and camera for working 🤓. To continue, open settings and give location and camera access to FinchIt 😛."
    case none = ""
}
