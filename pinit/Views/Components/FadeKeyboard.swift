//
//  FadeKeyboard.swift
//  pinit
//
//  Created by Janmajaya Mall on 21/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct FadeKeyboard: View {
    
    @EnvironmentObject var editingViewModel: EditingViewModel
    @State var textViewHeight: CGFloat = 0
    
    var parentSize: CGSize
    
    var body: some View {
        VStack{
            UIKitUITextView(text: self.$editingViewModel.descriptionText, textViewHeight: self.$textViewHeight, isFirstResponder: true)
                .applyKeyboardAwareMaximumHeightFrame(viewHeight: self.$textViewHeight, parentSize: self.parentSize)
                .padding(.top, 20)
                .onTapGesture {
                    
            }
            Spacer()
        }
        .frame(width: self.parentSize.width, height: self.parentSize.height)
        .safeTopEdgePadding()
        .background(Color.black.opacity(0.5))
    }
}

struct FadeKeyboard_Previews: PreviewProvider {
    static var previews: some View {
        FadeKeyboard(parentSize: CGSize(width: 375, height: 675)).environmentObject(EditingViewModel(selectedImage: UIImage(imageLiteralResourceName: "ProfileImage")))
        
    }
}
