//
//  ImagePaintingModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 19/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import SwiftUI

struct ImagePaintingModel {
    var selectedColor: Color = ImagePaintingModel.initialSelectedColor
    var selectedColorYCoord: CGFloat = 0
    var selectedStrokeWidth: CGFloat = ImagePaintingModel.initialStrokeWidth
    var selectedStrokeWidthYCoord: CGFloat = 0
    var pathDrawings: Array<PathDrawing> = []
    var currentDrawing: PathDrawing
    
    init() {
        self.currentDrawing = PathDrawing(color: self.selectedColor, strokeWidth: self.selectedStrokeWidth)
    }
    
    mutating func changeSelectedColor(to selectedColor: Color, withYCoord yCoord: CGFloat){
        self.selectedColor = selectedColor
        self.selectedColorYCoord = yCoord
        self.newDrawing()
    }
    
    mutating func changeSelectedStrokeWidth(to selectedStrokeWidth: CGFloat, withYCoord yCoord: CGFloat){
        self.selectedStrokeWidth = selectedStrokeWidth
        self.selectedStrokeWidthYCoord = yCoord
        self.newDrawing()
    }
    
    mutating func draw(atPoint point: CGPoint){
        self.currentDrawing.addPoint(point: point)
    }
    
    mutating func newDrawing() -> Void {
        if(!self.currentDrawing.isEmpty()){
            self.pathDrawings.append(self.currentDrawing)
        }
        
        self.currentDrawing = PathDrawing(color: self.selectedColor, strokeWidth: self.selectedStrokeWidth)
    }
    
    mutating func undoPathDrawing(){
        //For undo action simply remove the last drawing object from drawings array
        if (self.pathDrawings.count>0){
            self.pathDrawings.removeLast()
        }
    }
    
    private static var initialSelectedColor: Color = Color(UIColor(hue: 0, saturation: 1, brightness: 1, alpha: 1))
    private static var initialStrokeWidth: CGFloat = 15
}
