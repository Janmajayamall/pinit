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
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var screeOffset: CGSize {
        if(self.screenState == .up) {
            return CGSize(width: .zero, height: self.yDragTranslation + MapView.viewTopMargin)
        }else{
            return CGSize(width: .zero, height: parentGeometrySize.height + self.yDragTranslation)
        }
    }
    
    var body: some View {
        
        let dragGesture = DragGesture(minimumDistance: 10)
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
            UIKitMapBox(posts: self.$settingsViewModel.allPosts, user: self.$settingsViewModel.user)
            
            VStack{
                HStack{
                    Image(systemName: "xmark")
                        .applyDefaultIconTheme()
                        .onTapGesture {
                            self.closeView()
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    Spacer()
                }.frame(width: parentGeometrySize.width, height: 50)
                    .background(Color.black.opacity(0.5))
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
