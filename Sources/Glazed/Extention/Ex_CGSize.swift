//
//  File.swift
//  
//
//  Created by 张旭晟 on 2023/4/28.
//

import Foundation

extension CGSize {
    
    func aspectFit(_ size: CGSize) -> CGSize {
        
        let widthRatio = self.width / size.width
        
        let heightRatio = self.height / size.height
        
        let ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio
        
        let width = size.width * ratio
        
        let height = size.height * ratio
        
        return CGSize(width: width, height: height)
        
    }
    
    var aspectRatio: CGFloat { return self.width / self.height }
    
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
        
    }

    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
        
    }

    static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
        
        return CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
        
    }

    static func / (lhs: CGSize, rhs: CGSize) -> CGSize {
        
        return CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
        
    }
    
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
        
    }

    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
        
    }
    
    var point: CGPoint { return CGPoint.init(x: width, y: height) }

}
