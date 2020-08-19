//
//  UIKitArSceneView.swift
//  pinit
//
//  Created by Janmajaya Mall on 17/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct UIKitArSceneView: UIViewRepresentable {
    
    var parentSize: CGSize
    
    func makeUIView(context: Context) -> AppArScnView {
        let aRScnView = AppArScnView(parentSize: self.parentSize)
        
        aRScnView.startSession()
        
        return aRScnView
    }
    
    func updateUIView(_ uiView: AppArScnView, context: Context) {
        
    }
        
}
