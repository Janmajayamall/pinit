//
//  CaptureImageView.swift
//  pinit
//
//  Created by Janmajaya Mall on 19/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct CaptureImageView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    @ViewBuilder
    var body: some View {
    
        if self.settingsViewModel.screenManagementService.mainScreenService.captureImageViewScreenService.activeType == .editCaptureImage {
            EditCaptureImageView().environmentObject(EditingViewModel(selectedImage: Image("ProfileImage")))
        }else{
            VStack{
                HStack{
                    Image(systemName: "xmark")
                        .font(Font.system(size: 15, weight: .bold))
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            self.settingsViewModel.screenManagementService.mainScreenService.switchTo(screenType: .mainArView)
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
                    Spacer()
                }
                Spacer()
                HStack{
                    Spacer()
                    Circle()
                        .foregroundColor(.purple)
                        .frame(width: 60, height: 60)
                        .onTapGesture {
                            self.settingsViewModel.screenManagementService.mainScreenService.captureImageViewScreenService.switchTo(screenType: .editCaptureImage)
                    }
                    Spacer()
                }
            }
        }
    }
}

struct CaptureImageView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureImageView()
    }
}
//parentSize: CGSize(width: 300, height: 800)
