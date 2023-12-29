
import Foundation
import UIKit

extension UIBezierPath {
    
    convenience init?(catmullRomPoints: [CGPoint], alpha: CGFloat) {
        self.init()
        
        if catmullRomPoints.count < 4 {
            return nil
        }
        
        for i in 1..<catmullRomPoints.count - 2  {
            let p0 = catmullRomPoints[i-1 < 0 ? catmullRomPoints.count - 1 : i - 1]
            let p1 = catmullRomPoints[i]
            let p2 = catmullRomPoints[(i+1)%catmullRomPoints.count]
            let p3 = catmullRomPoints[(i+1)%catmullRomPoints.count + 1]
            
            let d1 = p1.deltaTo(a: p0).length
            let d2 = p2.deltaTo(a: p1).length
            let d3 = p3.deltaTo(a: p2).length
            
            var b1 = p2.multiplyBy(value: pow(d1, 2 * alpha))
            b1 = b1.deltaTo(a: p0.multiplyBy(value: pow(d2, 2 * alpha)))
            b1 = b1.addTo(a: p1.multiplyBy(value: 2 * pow(d1, 2 * alpha) + 3 * pow(d1, alpha) * pow(d2, alpha) + pow(d2, 2 * alpha)))
            b1 = b1.multiplyBy(value: 1.0 / (3 * pow(d1, alpha) * (pow(d1, alpha) + pow(d2, alpha))))
            
            var b2 = p1.multiplyBy(value: pow(d3, 2 * alpha))
            b2 = b2.deltaTo(a: p3.multiplyBy(value: pow(d2, 2 * alpha)))
            b2 = b2.addTo(a: p2.multiplyBy(value: 2 * pow(d3, 2 * alpha) + 3 * pow(d3, alpha) * pow(d2, alpha) + pow(d2, 2 * alpha)))
            b2 = b2.multiplyBy(value: 1.0 / (3 * pow(d3, alpha) * (pow(d3, alpha) + pow(d2, alpha))))
            
            if i == 1 {
                move(to: p1)
            }
            
            addCurve(to: p2, controlPoint1: b1, controlPoint2: b2)
        }
    }
}
