//
//  StrokeWidthSlider.swift
//  pinit
//
//  Created by Janmajaya Mall on 19/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct StrokeWidthSlider: View {
    @EnvironmentObject var editingViewModel: EditingViewModel
    
    @State var selectedYCoord: CGFloat {
        didSet{
            
            let newStrokeWidth: CGFloat =  StrokeWidthSlider.minimumStrokeWidth + ((self.selectedYCoord/StrokeWidthSlider.strokeSliderHeight)*StrokeWidthSlider.strokeAmplification)
            
            self.editingViewModel.changeSelectedStrokeWidth(to: newStrokeWidth, withYCoord: self.selectedYCoord)
        }
    }
    
    var body: some View {
        
        let dragGesture = DragGesture(minimumDistance: 0)
            .onChanged({value in
                self.selectedYCoord = self.coordPostDrag(startedFromY: value.location.y)
            })
        
        return ZStack(alignment:.top){
            Rectangle()
                .fill(self.editingViewModel.imagePainting.selectedColor)
                .frame(width:3, height: StrokeWidthSlider.strokeSliderHeight)
                .cornerRadius(1.5)
                .shadow(radius:8)
                .gesture(dragGesture)
            Circle()
                .foregroundColor(self.editingViewModel.imagePainting.selectedColor)
                .frame(width:self.editingViewModel.imagePainting.selectedStrokeWidth, height: self.editingViewModel.imagePainting.selectedStrokeWidth)
                .offset(x:0, y:self.selectedYCoord)                
        }
    }
    
    func coordPostDrag(startedFromY: CGFloat) -> CGFloat {
        //getting new coordinate for calculating color
        var newY = startedFromY
        //y coordinate cannot be less than 0
        newY = max(newY, 0)
        //y coordinate cannot be greater than height of color picker
        newY = min(newY, StrokeWidthSlider.strokeSliderHeight)
        return newY
    }
    
    // MARK: vars for StrokeWidthSlider
    static private var strokeSliderHeight: CGFloat = 300
    static var minimumStrokeWidth: CGFloat = 15
    static var strokeAmplification: CGFloat = 15
}

struct StrokeWidthSlider_Previews: PreviewProvider {
    static var previews: some View {
        StrokeWidthSlider(selectedYCoord: 0)
    }
}
