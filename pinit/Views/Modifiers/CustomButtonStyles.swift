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
            .font(Font.custom("Avenir", size: 16).bold())
            .foregroundColor(Color.primaryColor)
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            .background(Color.white)
            .cornerRadius(5)
            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 1, y: 1)
            .shadow(color: Color.black.opacity(0.2), radius: 1, x: -1, y: -1)
            .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.easeInOut(duration: 0.2))
    }
}


//
//           .background(Color.white)
//       .overlay(
//           RoundedRectangle(cornerRadius: 10)
//              .fill(Color.white)
//       )
//
//           .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
//                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
//       .opacity(configuration.isPressed ? 0.7 : 1)
//       .scaleEffect(configuration.isPressed ? 0.9 : 1)
//
