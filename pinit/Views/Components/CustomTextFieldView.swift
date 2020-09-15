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
    @Binding var noteText: String
    
    var body: some View {
        return VStack{
            ZStack(alignment: .leading){
                if (self.text.isEmpty){
                    Text(self.placeholder)
                        .foregroundColor(Color.textfieldColor)
                }
                TextField("", text: self.$text, onCommit: {
                    print("committed")
                })
             
            }
            Divider().background(Color.secondaryColor)
            HStack{
//                if (!self.noteText.isEmpty){
                    Text(self.noteText)
                        .font(Font.custom("Avenir", size: 10).bold())
                        .foregroundColor(Color.red)
//                }
                Spacer()
            }
        }
    }
}


