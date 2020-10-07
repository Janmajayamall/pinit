//
//  FadeKeyboard.swift
//  pinit
//
//  Created by Janmajaya Mall on 21/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct FadeKeyboard: View {
       
    @State var textViewHeight: CGFloat = 0
    @Binding var descriptionText: String
    
    var parentSize: CGSize
    
    var body: some View {
        VStack{
            Text("What's on your mind?").foregroundColor(Color.white).applyDefaultThemeToTextHeader(ofType: .h2).padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0 ))
            UIKitUITextView(text: self.$descriptionText, textViewHeight: self.$textViewHeight, textColor: UIColor.white, isFirstResponder: true)
                .applyKeyboardAwareMaximumHeightFrame(viewHeight: self.$textViewHeight, parentSize: self.parentSize)
                .onTapGesture {
                    
            }
            Spacer()
        }
        .frame(width: self.parentSize.width, height: self.parentSize.height)
        .safeTopEdgePadding()
        .background(Color.black.opacity(0.5))
    }
}
//
//struct FadeKeyboard_Previews: PreviewProvider {
//    static var previews: some View {
//        FadeKeyboard(descriptionText: Binding<String>, parentSize: CGSize(width: 375, height: 675))
//    }
//}
