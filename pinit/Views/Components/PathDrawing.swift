//
//  PathDrawing.swift
//  pinit
//
//  Created by Janmajaya Mall on 19/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct PathDrawing: View, Identifiable {
    var id: String = UUID().uuidString
    var color: Color
    var points: Array<CGPoint>  = []
    var strokeWidth: CGFloat
    
    var body: some View {
        Path { path in
            self.makeDrawing(points: self.points
                , toPath: &path)
        }
        .stroke(self.color, style:
            StrokeStyle(
                lineWidth: self.strokeWidth,
                lineCap: .round,
                lineJoin: .round
        ))
            .background(Color.clear)
    }
    
    mutating func addPoint(point: CGPoint){
        self.points.append(point)
    }
    
    func makeDrawing(points: Array<CGPoint>, toPath path: inout Path){
        
        //if no points then return
        
        guard points.count>=1 else {
            return
        }
        
        for index in 0..<points.count-1 {
            let currentPoint = points[index]
            let nextPoint = points[index+1]
            path.move(to: currentPoint)
            path.addLine(to: nextPoint)
        }
    }
    
    func isEmpty() -> Bool {
        return self.points.isEmpty
    }
    
}
