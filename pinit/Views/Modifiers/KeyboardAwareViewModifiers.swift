//
//  KeyboardAwareViewModifiers.swift
//  pinit
//
//  Created by Janmajaya Mall on 21/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct KeyboardAwareMaximumHeightFrameModifier: ViewModifier {
    
    @Binding var viewHeight: CGFloat
    var parentSize: CGSize
    @State var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .frame(width: parentSize.width, height: self.calculatedHeight())
            .onReceive(Publishers.keyboardHeightPublisher , perform: {self.keyboardHeight = $0})
    }
    
    func calculatedHeight() -> CGFloat {
        let remainingHeight: CGFloat = self.parentSize.height - (self.viewBottomMargin + self.keyboardHeight)
        
        if (remainingHeight > self.viewHeight){
            return self.viewHeight
        }else{
            return remainingHeight
        }
    }
    
    var viewBottomMargin: CGFloat = 80
}

extension View {
    
    // func for implmenting keyboardAwareMaximumHeightFrameModifier modifier
    func applyKeyboardAwareMaximumHeightFrame(viewHeight: Binding<CGFloat>, parentSize: CGSize) -> some View {
        return ModifiedContent(content: self, modifier: KeyboardAwareMaximumHeightFrameModifier(viewHeight: viewHeight, parentSize: parentSize))
    }
}
