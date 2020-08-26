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
            .font(Font.system(size: 20, weight: .heavy))
        .foregroundColor(Color.white)
    }
}

struct TopLeftPaddingIconViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
        .padding(EdgeInsets(top: 45, leading: 20, bottom: 0, trailing: 0))
    }
}

struct TopRightPaddingIconViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
        .padding(EdgeInsets(top: 45, leading: 0, bottom: 0, trailing: 20))
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
}
