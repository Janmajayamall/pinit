//
//  CaptureImageView.swift
//  pinit
//
//  Created by Janmajaya Mall on 19/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI
import AVFoundation
import Combine

struct CaptureImageView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @ViewBuilder
    var body: some View {
        
        if self.settingsViewModel.screenManagementService.mainScreenService.captureImageViewScreenService.activeType == .editCaptureImage && self.settingsViewModel.editingViewModel != nil {
            EditCaptureImageView().environmentObject(self.settingsViewModel.editingViewModel!)
        }else if (self.settingsViewModel.screenManagementService.mainScreenService.captureImageViewScreenService.activeType == .editCaptureVideo && self.settingsViewModel.editingVideoViewModel != nil){
            EditCaptureVideoView().environmentObject(self.settingsViewModel.editingVideoViewModel!)
        }
        else{
            CameraFeedView()
        }
    }
    
}

struct CaptureImageView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureImageView()
    }
}
//parentSize: CGSize(width: 300, height: 800)
