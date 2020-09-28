//
//  CustomButtonStyles.swift
//  pinit
//
//  Created by Janmajaya Mall on 25/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import SwiftUI

struct SecondaryColorButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .font(Font.custom("Avenir", size: 20).bold())
            .foregroundColor(Color.white)
            .background(RoundedRectangle(cornerRadius: 25).foregroundColor(Color.primaryColor))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.easeInOut(duration: 0.2))
        
    }
}

struct LeanOutlineColoredButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        .font(Font.custom("Avenir", size: 18).bold())
        .foregroundColor(Color.primaryColor)
        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
            .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primaryColor, lineWidth: 1.5)
        )
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        .opacity(configuration.isPressed ? 0.7 : 1)
        .scaleEffect(configuration.isPressed ? 0.9 : 1)
        .animation(.easeInOut(duration: 0.2))
    }
}
