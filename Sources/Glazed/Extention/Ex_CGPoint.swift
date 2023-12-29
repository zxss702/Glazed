//
//  File.swift
//  
//
//  Created by 张旭晟 on 2023/4/28.
//

import Foundation

extension CGPoint {

    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
        
    }

    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
        
    }

    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
        
    }

    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
        
    }
    
    var length²: CGFloat {
        
        return (x * x) + (y * y)
        
    }

    var length: CGFloat {
        
        return sqrt(self.length²)
        
    }

    var normalized: CGPoint {
        
        let length = self.length
        
        return CGPoint(x: x/length, y: y/length)
        
    }

    var size: CGSize { return CGSize(width: x, height: y) }
    
}
