//
//  IconViewModifiers.swift
//  pinit
//
//  Created by Janmajaya Mall on 23/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import SwiftUI

struct IconDefaultThemeViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: 25, weight: .heavy))
            .foregroundColor(Color.white)
            .frame(width: 40, height: 40, alignment: .center)
            .background(Color.white.opacity(0.0001))
    }
}

struct TopLeftPaddingIconViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top: 30, leading: 10, bottom: 0, trailing: 0))
    }
}

struct TopRightPaddingIconViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 10))
    }
}

struct EdgePaddingIconViewModifier: ViewModifier {
    
    var edgePaddingType: EdgePaddingType
    
    func body(content: Content) -> some View {
        content
            .padding(self.getPadding())
    }
    
    func getPadding() -> EdgeInsets {
        switch self.edgePaddingType {
        case .topRight:
            return EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 10)
        case .topLeft:
            return EdgeInsets(top: 30, leading: 10, bottom: 0, trailing: 0)
        case .bottomRight:
            return EdgeInsets(top: 0, leading: 10, bottom: 30, trailing: 0)
        case .bottomLeft:
            return EdgeInsets(top: 0, leading: 10, bottom: 30, trailing: 0)
        }
    }
}

extension View {
    func applyDefaultIconTheme() -> some View {
        return ModifiedContent(content: self, modifier: IconDefaultThemeViewModifier())
    }
    
    func applyTopLeftPaddingToIcon() -> some View {
        return ModifiedContent(content: self, modifier: TopLeftPaddingIconViewModifier())
    }
    
    func applyTopRightPaddingToIcon() -> some View {
        return ModifiedContent(content: self, modifier: TopRightPaddingIconViewModifier())
    }
    
    func applyEdgePadding(for edgePaddingType: EdgePaddingType) -> some View {
        return ModifiedContent(content: self, modifier: EdgePaddingIconViewModifier(edgePaddingType: edgePaddingType))
    }
}


enum EdgePaddingType {
    case topRight
    case topLeft
    case bottomRight
    case bottomLeft
}
