//
//  ViewRectViewModifier.swift
//  pinit
//
//  Created by Janmajaya Mall on 21/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct ViewRectViewModifier: ViewModifier {
    
    @Binding var viewRect: CGRect
    
    func body(content: Content) -> some View {
        content
            .background(GetRectOfView(viewRect: self.$viewRect))
    }
}

struct GetRectOfView: View {
    
    @Binding var viewRect: CGRect
    
    var body: some View {
        GeometryReader { geometryProxy in
            self.createView(proxy: geometryProxy)
        }
    }
    
    func createView(proxy: GeometryProxy) -> some View{
        
        DispatchQueue.main.async {
            self.viewRect = proxy.frame(in: .global)
        }
        
        return Rectangle().background(Color.clear)
    }
    
}


// Mark: View extension for ContentRectViewModifier
extension View {
    func getViewRect(to rect: Binding<CGRect>) -> some View {
        return ModifiedContent(content: self, modifier: ViewRectViewModifier(viewRect: rect))
    }
}
