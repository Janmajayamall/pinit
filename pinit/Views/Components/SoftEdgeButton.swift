//
//  SoftEdgeButton.swift
//  pinit
//
//  Created by Janmajaya Mall on 25/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct SoftEdgeButton: View {
    
    var buttonText: String
    
    var body: some View {
        HStack{
            Spacer()
            Text("Done").font(Font.custom("Avenir", size: 20)).bold().foregroundColor(Color.white)
            Spacer()
        }
        .frame(width: 100, height: 50)
        .clipped()
        .background(Color.secondaryColor)
        .cornerRadius(25)
    }
}

//struct SoftEdgeButton_Previews: PreviewProvider {
//    static var previews: some View {
//        SoftEdgeButton()
//    }
//}

