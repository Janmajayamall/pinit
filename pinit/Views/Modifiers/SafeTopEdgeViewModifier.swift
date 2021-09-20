//
//  SafeTopEdgeViewModifier.swift
//  pinit
//
//  Created by Janmajaya Mall on 21/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import SwiftUI

struct SafeTopEdgeViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.top, 15)
    }
}

extension View {
    func safeTopEdgePadding() -> some View {
        ModifiedContent(content: self, modifier: SafeTopEdgeViewModifier())
    }
}
