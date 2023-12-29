//
//  File.swift
//  
//
//  Created by 张旭晟 on 2023/4/28.
//

import Foundation
import CoreGraphics

extension CGContext {

    func strokeLines(points: [CGPoint]) {
        
        if points.count > 1 {
            
            for (index, point) in points.enumerated() {
                
                if index == 0 { self.move(to: point) }
                
                else { self.addLine(to: point) }
                
            }
            
            self.strokePath()
            
        }
        
    }
    

    func strokeLine(_ point1: CGPoint, _ point2: CGPoint) {
        
        self.strokeLines(points: [point1, point2])
        
    }
    
}
