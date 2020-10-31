//
//  EditCaptureImageView.swift
//  pinit
//
//  Created by Janmajaya Mall on 19/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct EditCaptureImageView: View {
    
    @EnvironmentObject var editingViewModel: EditingViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @Environment(\.window) var window: UIWindow?
    
    @State var screenState: EditCaptureImageScreenState = .normal
    @State var isUserDrawing: Bool = false
    
    func getScaledSize(for size: CGSize) -> CGSize{
        let width = UIScreen.main.bounds.size.width
        
        let height = (size.height / size.width) * width
        
        return CGSize(width: width, height: height)
    }
    
    var body: some View {
        // binding for descriptionText
        let descriptionText = Binding<String>(
            get: {
                self.editingViewModel.descriptionText
        }, set: {
            let descriptionText = $0.trimmingCharacters(in: .newlines)
            self.editingViewModel.descriptionText = String(descriptionText.prefix(425))
        }
        )
        
        return GeometryReader { geometryProxy in
            ZStack{
                VStack{
                    Spacer()
                    VStack{
                        Image(uiImage: self.editingViewModel.selectedImage)
                            .resizable()
                            .frame(width: self.getScaledSize(for: self.editingViewModel.selectedImage.size).width, height: self.getScaledSize(for: self.editingViewModel.selectedImage.size).height)
                    }
                    .getViewRect(to: self.$editingViewModel.imageRect)
                    Spacer()
                }
                
                if (self.screenState == .description){
                    FadeKeyboard(descriptionText: descriptionText, parentSize: geometryProxy.size )
                }
                
                if (self.screenState == .normal){
                    VStack{
                        HStack{
                            Image(systemName: "xmark")
                                .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                                .onTapGesture {
                                    self.settingsViewModel.screenManagementService.mainScreenService.captureImageViewScreenService.switchTo(screenType: .normal)
                            }
                            .applyTopLeftPaddingToIcon()
                            Spacer()
                            
                            
                            Image(systemName: "checkmark")
                                .applyDefaultIconTheme(forIconDisplayType: .liveFeed)
                                .onTapGesture {
                                    self.finalisePostImage()
                            }.applyTopRightPaddingToIcon()
                            
                        }
                        Spacer()
                    }
                    .frame(width: self.getScaledSize(for: self.editingViewModel.selectedImage.size).width, height: self.getScaledSize(for: self.editingViewModel.selectedImage.size).height)
                    .safeTopEdgePadding()
                }
                
            }
            .onTapGesture {
                if self.screenState == .description {
                    self.screenState = .normal
                }else if self.screenState == .normal {
                    self.screenState = .description
                }
            }
            
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
    
    func finalisePostImage() {
        // set screen state to done
        self.screenState = .done
        
        // capture view on screen after 0.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.editingViewModel.setFinalImage(withWindow: self.window)
            
            // reseting editing view model
            self.settingsViewModel.resetEditingViewModel()
            
            // reset main screen to main ar view
            self.settingsViewModel.screenManagementService.mainScreenService.switchTo(screenType: .mainArView)
        })
    }
}

struct EditCaptureImageView_Previews: PreviewProvider {
    static var previews: some View {
        EditCaptureImageView()
    }
}


enum EditCaptureImageScreenState {
    case normal
    case painting
    case description
    case done
}
