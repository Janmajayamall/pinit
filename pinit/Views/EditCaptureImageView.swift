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
    
    @State var screenState: ScreenState = .normal
    @State var isUserDrawing: Bool = false
    
    var body: some View {
        GeometryReader { geometryProxy in
            ZStack{
                
                Image(uiImage: self.editingViewModel.selectedImage)
                    .resizable()
                    .frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                    .getViewRect(to: self.$editingViewModel.imageRect)
                
                // draw paths
                ForEach(self.editingViewModel.imagePainting.pathDrawings, content: {return $0})
                // draw current path
                self.editingViewModel.imagePainting.currentDrawing
                
                if (self.screenState == .description){
                    FadeKeyboard(parentSize: geometryProxy.size)
                }
                
                if (self.screenState == .normal){
                    VStack{
                        HStack{
                            Image(systemName: "xmark")
                                .foregroundColor(Color.white)
                                .applyDefaultIconTheme()
                                .onTapGesture {
                                    self.settingsViewModel.screenManagementService.mainScreenService.switchTo(screenType: .mainArView)
                            }
                            .applyTopLeftPaddingToIcon()
                            Spacer()
                            
                            
                            Image(systemName: "scribble")
                                .foregroundColor(Color.white)
                                .applyDefaultIconTheme()
                                .onTapGesture {
                                    self.screenState = .painting
                            }
                            .applyTopRightPaddingToIcon()
                            .padding(.trailing, 5)
                            
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.white)
                                .applyDefaultIconTheme()
                                .onTapGesture {
                                    self.finalisePostImage()
                            }
                            .applyTopRightPaddingToIcon()
                            
                        }
                        Spacer()
                    }
                    .frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                    .safeTopEdgePadding()
                }
                
                if (self.screenState == .painting && self.isUserDrawing == false){
                    VStack{
                        HStack{
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color.white)
                                .applyDefaultIconTheme()
                                .onTapGesture {
                                    guard self.screenState == .painting else {return}
                                    self.screenState = .normal
                            }
                            .applyTopLeftPaddingToIcon()
                            
                            
                            Spacer()
                            
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(Color.white)
                                .applyDefaultIconTheme()
                                .onTapGesture {
                                    guard self.screenState == .painting else {return}
                                    
                                    self.editingViewModel.imagePainting.undoPathDrawing()
                            }
                            .applyTopRightPaddingToIcon()
                            
                        }
                        
                        Spacer()
                    }
                    .frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                    .safeTopEdgePadding()
                }
                
                if (self.screenState == .painting && self.isUserDrawing == false){
                    VStack{
                        HStack{
                            Spacer()
                            ColorPickerSlider(selectedYCoord: self.editingViewModel.imagePainting.selectedColorYCoord)
                                .frame(width: ColorPickerSlider.colorPickerExpandedCircleDia * 1.5)
                                .padding(EdgeInsets(top: 100, leading: 0, bottom: 0, trailing: 15))
                        }
                        Spacer()
                    }
                    .frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                    .safeTopEdgePadding()
                }
                
                if (self.screenState == .painting && self.isUserDrawing == false){
                    VStack{
                        HStack{
                            StrokeWidthSlider(selectedYCoord: self.editingViewModel.imagePainting.selectedStrokeWidthYCoord)
                                .frame(width: StrokeWidthSlider.minimumStrokeWidth + StrokeWidthSlider.strokeAmplification * 1.5)
                                .padding(EdgeInsets(top: 100, leading: 15, bottom: 0, trailing: 0))
                            
                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                    .safeTopEdgePadding()
                }
            }
            .gesture(
                DragGesture()
                    .onChanged({ (value) in
                        if (self.screenState == .painting){
                            self.isUserDrawing = true
                            self.editingViewModel.draw(atPoint: value.location)
                        }
                    })
                    .onEnded({ (value) in
                        if (self.screenState == .painting){
                            self.editingViewModel.draw(atPoint: value.location)
                            self.editingViewModel.startNewDrawing()
                            self.isUserDrawing = false
                        }
                    })
            )
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


enum ScreenState {
    case normal
    case painting
    case description
    case done
}
