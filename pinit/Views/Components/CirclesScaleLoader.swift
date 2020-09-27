//
//  CirclesScaleLoader.swift
//  pinit
//
//  Created by Janmajaya Mall on 28/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct CirclesScaleLoader: View {
    
    @State private var shouldAnimate = false
    
    var body: some View {
        HStack {
            Circle()
                .fill(self.circleColor)
                .frame(width: self.circleDia, height: self.circleDia)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever())
            Circle()
                .fill(self.circleColor)
                .frame(width: self.circleDia, height: self.circleDia)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.3))
            Circle()
                .fill(self.circleColor)
                .frame(width: self.circleDia, height: self.circleDia)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.6))            
        }
        .onAppear {
            self.shouldAnimate = true
        }
    }
    
    private let circleDia: CGFloat = 8
    private let circleColor: Color = .primaryColor
}

struct CirclesScaleLoader_Previews: PreviewProvider {
    static var previews: some View {
        CirclesScaleLoader()
    }
}
