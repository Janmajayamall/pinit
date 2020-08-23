//
//  MapView.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI
import CoreLocation

struct MapView: View {
    
    var parentGeometrySize: CGSize
    @Binding var screenState: SwipeScreenState
    @Binding var yDragTranslation: CGFloat
    @State var locations: Array<CLLocationCoordinate2D> = []
    
    var screeOffset: CGSize {
        if(self.screenState == .up) {
            return CGSize(width: .zero, height: self.yDragTranslation + MapView.viewTopMargin)
        }else{
            return CGSize(width: .zero, height: parentGeometrySize.height + self.yDragTranslation)
        }
    }
    
    var body: some View {
        
        let dragGesture = DragGesture()
            .onChanged({value in
                guard (self.screenState == .up && value.translation.height > 0) || (self.screenState == .down && value.translation.height < 0) else {return}
                
                self.yDragTranslation = value.translation.height
            })
            .onEnded({value in
                if (self.screenState == .up && value.translation.height > 0) {
                    self.screenState = .down
                }else if (self.screenState == .down && value.translation.height < 0){
                    self.screenState = .up
                }
                
                self.yDragTranslation = 0
                }
        )
        
        return ZStack{
            UIKitMapBox(mapAnnotations: self.$locations)
            
            VStack{
                HStack{
                    Image(systemName: "xmark")
                        .applyDefaultIconTheme()
                        .onTapGesture {
                            self.closeView()
                    }
                    .applyTopLeftPaddingToIcon()
                    Spacer()
                }.frame(width: parentGeometrySize.width, height: 50)
                    .background(Color.white.opacity(0.7))
                    .gesture(dragGesture)
                Spacer()
            }
        }
        .frame(width: parentGeometrySize.width, height: parentGeometrySize.height, alignment: .top)
        .cornerRadius(20)
        .offset(self.screeOffset)
        .animation(.spring())
        .gesture(DragGesture())
    }
    
    func closeView(){
        self.yDragTranslation = 0
        self.screenState = .down
    }
    
    static let viewTopMargin: CGFloat = 100
}

enum SwipeScreenState {
    case up
    case down
}
