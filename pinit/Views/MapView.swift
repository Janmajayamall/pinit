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
            HStack{
                Spacer()
                Text("height")
                Spacer()
            }.frame(height: 100)
                .background(Color.black.opacity(0.5))
                .gesture(dragGesture)
            
            UIKitMapBox(mapAnnotations: self.$locations)
        }
        .frame(width: parentGeometrySize.width, height: parentGeometrySize.height, alignment: .top)
        .cornerRadius(20)
        .offset(self.screeOffset)
        .animation(.spring())
        .gesture(DragGesture())
    }
    
    static let viewTopMargin: CGFloat = 100
}

enum SwipeScreenState {
    case up
    case down
}
