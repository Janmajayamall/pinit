//
//  EditCaptureVideoView.swift
//  pinit
//
//  Created by Janmajaya Mall on 13/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct EditCaptureVideoView: View {
    
    @EnvironmentObject var editingVideoViewModel: EditingVideoViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @State var screenState: EditCaptureVideoScreenState = .normal
    
    var body: some View {
        GeometryReader { geometryProxy in
            ZStack{
                UIKitAVPlayerView(frame: CGRect(x: 0, y: 0, width: geometryProxy.size.width, height: geometryProxy.size.height), videoFilePathUrl: self.editingVideoViewModel.videoOutputFileUrl)
                
                if (self.screenState == .description){
                    FadeKeyboard(descriptionText: self.$editingVideoViewModel.descriptionText, parentSize: geometryProxy.size)
                }
                
                if (self.screenState == .normal) {
                    VStack{
                        HStack{
                            Image(systemName: "xmark")
                                .foregroundColor(Color.white)
                                .applyDefaultIconTheme()
                                .onTapGesture {
                                    self.settingsViewModel.screenManagementService.mainScreenService.captureImageViewScreenService.switchTo(screenType: .normal)
                            }
                            .applyTopLeftPaddingToIcon()
                            Spacer()
                                            
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.white)
                                .applyDefaultIconTheme()
                                .onTapGesture {
                                    self.finalisePostVideo()
                            }
                            .applyTopRightPaddingToIcon()
                            
                        }
                        Spacer()
                    }
                    .frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                    .safeTopEdgePadding()
                }
            }
            .onTapGesture {
                if (self.screenState == .normal){
                    self.screenState = .description
                }else {
                    self.screenState = .normal
                }
            }
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
    }
    
    func finalisePostVideo() {
        // request upload video post
        self.editingVideoViewModel.uploadPost()
        
        // reset editing video view model
        self.settingsViewModel.resetEditingVideoViewModel()
        
        // reset main screen to main ar view
          self.settingsViewModel.screenManagementService.mainScreenService.switchTo(screenType: .mainArView)
    }
}

struct EditCaptureVideoView_Previews: PreviewProvider {
    static var previews: some View {
        EditCaptureVideoView()
    }
}

enum EditCaptureVideoScreenState {
    case normal
    case description
}
