//
//  Loader.swift
//  pinit
//
//  Created by Janmajaya Mall on 20/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct Loader: View {
    
    @State var animation = false
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.2)
            .stroke(Color.white, lineWidth: 3)
        .frame(width: 40, height:40)
            .rotationEffect(.init(degrees: self.animation ? 360 : 0))
            .animation(Animation.linear(duration: 0.7).repeatForever(autoreverses: false))
            .onAppear {
                self.animation.toggle()
        }
    }
}

struct Loader_Previews: PreviewProvider {
    static var previews: some View {
        Loader()
    }
}
