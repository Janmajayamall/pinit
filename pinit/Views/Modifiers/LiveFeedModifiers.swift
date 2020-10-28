//
//  LiveFeedModifiers.swift
//  pinit
//
//  Created by Janmajaya Mall on 29/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import SwiftUI

struct LiveFeedTextModifier: ViewModifier {
    
    var fontSize: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.white)
            .font(Font.custom("Avenir", size: self.fontSize).bold())
            .multilineTextAlignment(.center)
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .background(Color.black.opacity(0.3))
            .cornerRadius(10)
            .padding()
    }
}

extension View {
    func applyLiveFeedTextModifier(forTextSize fontSize: CGFloat = 20) -> some View {
        return ModifiedContent(content: self, modifier: LiveFeedTextModifier(fontSize: fontSize))
    }
}
