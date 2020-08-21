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
                
                self.editingViewModel.selectedImage
                    .getViewRect(to: self.$editingViewModel.imageRect)
                
                // draw paths
                ForEach(self.editingViewModel.imagePainting.pathDrawings, content: {return $0})
                // draw current path
                self.editingViewModel.imagePainting.currentDrawing
                
                if (self.screenState == .normal){
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
                            
                            
                            Image(systemName: "scribble")
                                .font(Font.system(size: 15, weight: .bold))
                                .foregroundColor(Color.primaryColor)
                                .onTapGesture {
                                    self.screenState = .painting
                            }
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 10))
                            
                            Image(systemName: "checkmark")
                                .font(Font.system(size: 15, weight: .bold))
                                .foregroundColor(Color.primaryColor)
                                .onTapGesture {
                                    self.finalisePostImage()
                            }
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 10))
                            
                        }
                        Spacer()
                    }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                }
                
                if (self.screenState == .painting && self.isUserDrawing == false){
                    VStack{
                        HStack{
                            Image(systemName: "chevron.left")
                                .font(Font.system(size: 15, weight: .bold))
                                .foregroundColor(Color.primaryColor)
                                .onTapGesture {
                                    guard self.screenState == .painting else {return}
                                    self.screenState = .normal
                                }
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
                            
                            
                            Spacer()
                            
                            Image(systemName: "arrow.uturn.left.circle")
                                .font(Font.system(size: 15, weight: .bold))
                                .foregroundColor(Color.primaryColor)
                                .onTapGesture {
                                    guard self.screenState == .painting else {return}
                                    
                                    self.editingViewModel.imagePainting.undoPathDrawing()
                            }
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 10))
                            
                        }
                        
                        Spacer()
                    }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                }
                
                if (self.screenState == .painting && self.isUserDrawing == false){
                    VStack{
                        HStack{
                            Spacer()
                            ColorPickerSlider(selectedYCoord: self.editingViewModel.imagePainting.selectedColorYCoord)
                                .frame(width: ColorPickerSlider.colorPickerExpandedCircleDia * 1.5)
                                .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 15))
                        }
                        Spacer()
                    }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                }
                
                if (self.screenState == .painting && self.isUserDrawing == false){
                    VStack{
                        HStack{
                            StrokeWidthSlider(selectedYCoord: self.editingViewModel.imagePainting.selectedStrokeWidthYCoord)
                                .frame(width: StrokeWidthSlider.minimumStrokeWidth + StrokeWidthSlider.strokeAmplification * 1.5)
                                .padding(EdgeInsets(top: 30, leading: 15, bottom: 0, trailing: 0))
                                
                            Spacer()
                        }
                        Spacer()
                    }.frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
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
        }
    }
    
    func finalisePostImage() {
        // set screen state to done
        self.screenState = .done
        
        // capture view on screen after 0.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.editingViewModel.setFinalImage(withWindow: self.window)
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
