//
//  PulseLoader.swift
//  pinit
//
//  Created by Janmajaya Mall on 25/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct PulseLoader: View {
    
    var parentSize: CGSize
    
    @State private var wave0: Bool = false
    @State private var wave1: Bool = false
    
    var circleDia: CGFloat = 2
    var maxScale: CGFloat = 8
    
    var body: some View {
        ZStack{
            Circle()
                .stroke(lineWidth: 20)
                .frame(width: self.circleDia, height: self.circleDia)
                .foregroundColor(Color.primaryColor)
                .scaleEffect(self.wave0 ? self.maxScale : 1)
                .opacity(self.wave0 ? 0 : 1)
                .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: false).speed(0.8))
                .onAppear {
                    self.wave0 = true
            }
            Circle()
                .stroke(lineWidth: 20)
                .frame(width: self.circleDia, height: self.circleDia)
                .foregroundColor(Color.primaryColor)
                .scaleEffect(self.wave0 ? self.maxScale : 1)
                .opacity(self.wave0 ? 0 : 1)
                .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: false).speed(1))
                .onAppear {
                    self.wave0 = true
            }
            Circle()
                .frame(width: self.circleDia, height: self.circleDia)
                .foregroundColor(Color.primaryColor)
                .shadow(radius: 12.5)
        }.frame(width: parentSize.width, height: parentSize.height)
            .background(Color.black.opacity(0.5))
    }
}

struct PulseLoader_Previews: PreviewProvider {
    static var previews: some View {
        PulseLoader(parentSize: .zero)
    }
}
