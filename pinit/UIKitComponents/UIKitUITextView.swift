//
//  UIKitUITextView.swift
//  pinit
//
//  Created by Janmajaya Mall on 21/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct UIKitUITextView : UIViewRepresentable {
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        @Binding var text: String
        @Binding var textViewHeight: CGFloat
    
        
        init(text: Binding<String>, textViewHeight: Binding<CGFloat>) {
            _text = text
            _textViewHeight = textViewHeight
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.text = textView.text
                self.textViewHeight = textView.contentSize.height
            }
        }
                
    }
    
    @Binding var text: String
    @Binding var textViewHeight: CGFloat    
    var isFirstResponder: Bool
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.white
        textView.font = UIFont(name: "Avenir", size: 20)
        textView.isScrollEnabled = true
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = self.text
        if(self.isFirstResponder){
            uiView.becomeFirstResponder()
        }
    }
    
    func makeCoordinator() -> UIKitUITextView.Coordinator {
        return UIKitUITextView.Coordinator(text: self.$text, textViewHeight: self.$textViewHeight)
    }
    
    
}

