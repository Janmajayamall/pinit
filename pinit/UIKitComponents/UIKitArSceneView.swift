//
//  UIKitArSceneView.swift
//  pinit
//
//  Created by Janmajaya Mall on 17/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct UIKitArSceneView: UIViewRepresentable {

    var appArScnView: AppArScnView
    
    func makeUIView(context: Context) -> AppArScnView {        
        return self.appArScnView
    }
    
    func updateUIView(_ uiView: AppArScnView, context: Context) {
        
    }
        
}
