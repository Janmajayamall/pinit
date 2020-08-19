//
//  ColorPickerSlider.swift
//  pinit
//
//  Created by Janmajaya Mall on 19/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct ColorPickerSlider: View {
    // initiated variables
    @EnvironmentObject var editingViewModel: EditingViewModel
    
    @State var selectedYCoord: CGFloat {
        didSet{
            self.editingViewModel.changeSelectedColor(to: Color(UIColor(hue: self.selectedYCoord/ColorPickerSlider.colorPickerHeight,saturation: 1, brightness: 1, alpha: 1) ), withYCoord: self.selectedYCoord)
            
        }
    }
    @State var isDragging: Bool = false
    
    var circleDia: CGFloat  {
        self.isDragging ? ColorPickerSlider.colorPickerExpandedCircleDia : ColorPickerSlider.colorPickerCircleDia
    }
    
    var colors: Array<Color> = {
        let hueValues = Array(0...359)
        return hueValues.map {
            Color(UIColor(hue: CGFloat($0) / 359.0 ,
                          saturation: 1.0,
                          brightness: 1.0,
                          alpha: 1.0))
        }
    }()
    
    var body: some View {
        ZStack(alignment: .top){
            LinearGradient(gradient: Gradient(colors: colors), startPoint: .top, endPoint: .bottom)
                .frame(width: ColorPickerSlider.colorPickerWidth, height:ColorPickerSlider.colorPickerHeight)
                .cornerRadius(5)
                .shadow(radius:8)
                .overlay(
                    RoundedRectangle(cornerRadius:5).stroke(Color.white, lineWidth: 2)
            )
                .gesture(DragGesture()
                    .onChanged({value in
                        self.selectedYCoord = self.coordPostDrag(startedFromY: value.location.y)
                        self.isDragging = true
                    })
                    .onEnded({value in
                        self.isDragging = false
                    })
            )
            
            Circle()
                .foregroundColor(self.editingViewModel.imagePainting.selectedColor)
                .frame(width:self.circleDia, height:self.circleDia, alignment: .center)
                .overlay(
                    RoundedRectangle(cornerRadius:self.circleDia/2)
                        .stroke(Color.white, lineWidth: 2)
            )
                .offset(x:isDragging ? -self.circleDia : 0 , y: self.selectedYCoord - (self.circleDia/2))
                .animation(Animation.spring().speed(2))
        }
    }
    
    func coordPostDrag(startedFromY: CGFloat) -> CGFloat {
        //getting new coordinate for calculating color
        var newY = startedFromY
        //y coordinate cannot be less than 0
        newY = max(newY, 0)
        //y coordinate cannot be greater than height of color picker
        newY = min(newY, ColorPickerSlider.colorPickerHeight)
        return newY
    }
        
    // MARK: vars for Colorpicker
    static var colorPickerWidth: CGFloat = 15
    static var colorPickerHeight: CGFloat = 300
    static var colorPickerCircleDia: CGFloat = 15
    static var colorPickerExpandedCircleDia: CGFloat = 30
}

struct ColorPickerSlider_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerSlider(selectedYCoord: 0)
    }
}
