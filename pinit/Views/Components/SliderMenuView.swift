//
//  SliderMenuView.swift
//  pinit
//
//  Created by Janmajaya Mall on 23/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct SliderMenuView: View {
    
    @State var showMenu: Bool = true
    
    var body: some View {
        VStack{
            Image(systemName: self.showMenu ? "chevron.up" : "chevron.down")
                .font(Font.system(size: 20, weight: .heavy))
                .onTapGesture {
                    print("dada")
                     self.showMenu = !self.showMenu
                    print(self.showMenu)
            }
//                .offset(CGSize(width: .zero, height: self.showMenu ? 190 : 0))
                .animation(.linear)
            
            if (self.showMenu == true){
                Image(systemName: "chevron.down")
                .font(Font.system(size: 20, weight: .heavy))
                    .padding(.bottom, 5)
                
                Image(systemName: "chevron.down")
                .font(Font.system(size: 20, weight: .heavy))
                    .padding(.bottom, 5)
                
                Image(systemName: "chevron.down")
                .font(Font.system(size: 20, weight: .heavy))
                    .padding(.bottom, 5)
                
                Image(systemName: "chevron.down")
                .font(Font.system(size: 20, weight: .heavy))
                    .padding(.bottom, 5)
            }
            
            
        }.frame(width: 50, height: 200, alignment: .top)
    }
}

struct SliderMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SliderMenuView()
    }
}
