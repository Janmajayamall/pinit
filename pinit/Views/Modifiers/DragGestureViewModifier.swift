////
////  DragGestureViewModifier.swift
////  pinit
////
////  Created by Janmajaya Mall on 31/8/2020.
////  Copyright © 2020 Janmajaya Mall. All rights reserved.
////
//
//import Foundation
//import SwiftUI
//
//struct SliderViewDragGestureViewModifier: ViewModifier {
//    
//    func body(content: Content) -> some View {
//        content
//        .gesture(DragGesture(minimumDistance: 20)
//            .onChanged({value in
//                guard self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.activeType == .normal else {return}
//                
//                guard (self.mapViewScreenState == .up && value.translation.height > 0) || (self.mapViewScreenState == .down && value.translation.height < 0) else {return}
//                
//                self.mapViewYDragTranslation = value.translation.height
//            })
//            .onEnded({value in
//                
//                guard self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.activeType == .normal else {return}
//                
//                if (self.mapViewScreenState == .up && value.translation.height > 0) {
//                    self.mapViewScreenState = .down
//                }else if (self.mapViewScreenState == .down && value.translation.height < 0){
//                    self.mapViewScreenState = .up
//                }
//                
//                self.mapViewYDragTranslation = 0
//                }
//        ))
//    }
//}
