//
//  TextViewModifiers.swift
//  pinit
//
//  Created by Janmajaya Mall on 31/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import SwiftUI

struct TextHeaderViewDefaultThemeModifier: ViewModifier {
    var headerType: HeaderType
    
    func body(content: Content) -> some View {
        content
            .font(Font.custom("Avenir", size: CGFloat(self.headerType.rawValue)).bold())
            .foregroundColor(Color.black)
    }
}


extension View {
    func applyDefaultThemeToTextHeader(ofType headerType: HeaderType) -> some View {
        return ModifiedContent(content: self, modifier: TextHeaderViewDefaultThemeModifier(headerType: headerType))
    }

}



enum HeaderType: Int {
    case h1 = 30
    case h2 = 25
    case h3 = 20
}
