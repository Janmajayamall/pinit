//
//  CustomTextFieldView.swift
//  pinit
//
//  Created by Janmajaya Mall on 31/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct CustomTextFieldView: View {
    
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        ZStack(alignment: .leading){
            if (self.text.isEmpty){
                Text(self.placeholder)                    
                    .foregroundColor(Color.textfieldColor)
            }
            TextField("", text: self.$text, onCommit: {
                print("committed")
            })
        }
    }
}
//
//struct CustomTextFieldView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomTextFieldView(text:)!, placeholder: "Testing")
//    }
//}
