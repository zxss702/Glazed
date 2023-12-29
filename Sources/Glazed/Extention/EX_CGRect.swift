//
//  EX_CGRect.swift
//  noteE
//
//  Created by 张旭晟 on 2023/1/14.
//

import Foundation
import CoreGraphics

extension CGRect{
    
    func Rotated(Rad:CGFloat) -> CGRect{
        let origRect = CGRect(origin: .zero, size: CGSize(width: self.width, height: self.height))
        let rotatedRect = origRect.applying(CGAffineTransform(rotationAngle: Rad))
        return CGRect(origin: self.origin, size: rotatedRect.size)
    }
    
    var cgPath: CGPath {
        
        return CGPath(rect: self, transform: nil)
        
    }
    
    func cgPath(cornerRadius: CGFloat) -> CGPath {

        //    +7-------------6+
        //    0                5
        //    |                |
        //    1                4
        //    +2-------------3+
    
        let cornerRadius = min(self.size.width * 0.5, self.size.height * 0.5, cornerRadius)
        
        let path = CGMutablePath()
        
        path.move(to: self.minXmidY + CGPoint(x: 0, y: cornerRadius)) // (0)
        
        path.addLine(to: self.minXmaxY - CGPoint(x: 0, y: cornerRadius)) // (1)
        
        path.addQuadCurve(to: self.minXmaxY + CGPoint(x: cornerRadius, y: 0), control: self.minXmaxY) // (2)
        
        path.addLine(to: self.maxXmaxY - CGPoint(x: cornerRadius, y: 0)) // (3)
        
        path.addQuadCurve(to: self.maxXmaxY - CGPoint(x: 0, y: cornerRadius), control: self.maxXmaxY) // (4)
        
        path.addLine(to: self.maxXminY + CGPoint(x: 0, y: cornerRadius)) // (5)
        
        path.addQuadCurve(to: self.maxXminY - CGPoint(x: cornerRadius, y: 0), control: self.maxXminY) // (6)
        
        path.addLine(to: self.minXminY + CGPoint(x: cornerRadius, y: 0)) // (7)
        
        path.addQuadCurve(to: self.minXminY + CGPoint(x: 0, y: cornerRadius), control: self.minXminY) // (0)
        
        path.closeSubpath()
        
        return path
        
    }

    var minXminY: CGPoint { return CGPoint(x: self.minX, y: self.minY) }
    
    var midXminY: CGPoint { return CGPoint(x: self.midX, y: self.minY) }
    
    var maxXminY: CGPoint { return CGPoint(x: self.maxX, y: self.minY) }
    
    var minXmidY: CGPoint { return CGPoint(x: self.minX, y: self.midY) }
    
    var midXmidY: CGPoint { return CGPoint(x: self.midX, y: self.midY) }
    
    var maxXmidY: CGPoint { return CGPoint(x: self.maxX, y: self.midY) }
    
    var minXmaxY: CGPoint { return CGPoint(x: self.minX, y: self.maxY) }
    
    var midXmaxY: CGPoint { return CGPoint(x: self.midX, y: self.maxY) }
    
    var maxXmaxY: CGPoint { return CGPoint(x: self.maxX, y: self.maxY) }
    
    func aspectFill(_ size: CGSize) -> CGRect {
        
        let result: CGRect
        
        let margin: CGFloat
        
        let horizontalRatioToFit = self.size.width / size.width
        
        let verticalRatioToFit = self.size.height / size.height
        
        let imageHeightWhenItFitsHorizontally = horizontalRatioToFit * size.height
        
        let imageWidthWhenItFitsVertically = verticalRatioToFit * size.width
        
        let minX = self.minX
        
        let minY = self.minY
        
        if (imageHeightWhenItFitsHorizontally > self.size.height) {
            
            margin = (imageHeightWhenItFitsHorizontally - self.size.height) * 0.5
            
            result = CGRect(x: minX, y: minY - margin, width: size.width * horizontalRatioToFit, height: size.height * horizontalRatioToFit)
            
        }
        
        else {
            
            margin = (imageWidthWhenItFitsVertically - self.size.width) * 0.5
            
            result = CGRect(x: minX - margin, y: minY, width: size.width * verticalRatioToFit, height: size.height * verticalRatioToFit)
            
        }
        
        return result
        
    }
    
    func aspectFit(_ size: CGSize) -> CGRect {
        
        let minX = self.minX
        
        let minY = self.minY
        
        let widthRatio = self.size.width / size.width
        
        let heightRatio = self.size.height / size.height
        
        let ratio = min(widthRatio, heightRatio)
        
        let width = size.width * ratio
        
        let height = size.height * ratio
        
        let xmargin = (self.size.width - width) / 2.0
        
        let ymargin = (self.size.height - height) / 2.0
        
        return CGRect(x: minX + xmargin, y: minY + ymargin, width: width, height: height)
        
    }

    func transform(to rect: CGRect) -> CGAffineTransform {
        
        var t = CGAffineTransform.identity
        
        t = t.translatedBy(x: -self.minX, y: -self.minY)
        
        t = t.scaledBy(x: 1 / self.width, y: 1 / self.height)
        
        t = t.scaledBy(x: rect.width, y: rect.height)
        
        t = t.translatedBy(x: rect.minX * self.width / rect.width, y: rect.minY * self.height / rect.height)
        
        return t
        
    }
    
    var center: CGPoint {
        
        get { return self.midXmidY }
        
        set { self.origin = newValue - (CGPoint(x: self.width, y: self.height) * 0.5) }
        
    }

    func centered(at point: CGPoint) -> CGRect {
        
        return CGRect(origin: CGPoint(x: -self.width * 0.5, y: -self.height * 0.5), size: self.size)
        
    }
    
    static var A4: CGRect { return CGRect.init(x: 0, y: 0, width: 1654, height: 2339) }
    
    static var USLetter: CGRect { return CGRect.init(x: 0, y: 0, width: 1700, height: 2200) }
    

    static func + (lhs: CGRect, rhs: CGPoint) -> CGRect {
        
        return CGRect(origin: lhs.origin + rhs, size: lhs.size)
        
    }
    
    static func - (lhs: CGRect, rhs: CGPoint) -> CGRect {
        
        
        return CGRect(origin: lhs.origin - rhs, size: lhs.size)
    }
    
    static func += (lhs: inout CGRect, rhs: CGPoint) {
        
        lhs = lhs + rhs
        
    }
    
    static func -= (lhs: inout CGRect, rhs: CGPoint) {
        
        lhs = lhs - rhs
        
    }
    
}

