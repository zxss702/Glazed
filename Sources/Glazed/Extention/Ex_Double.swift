//
//  File.swift
//  
//
//  Created by 张旭晟 on 2023/4/28.
//

import Foundation

extension Double {
    
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))

        return (self * divisor).rounded() / divisor

    }

}

extension CGFloat {
    
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))

        return (self * divisor).rounded() / divisor

    }

}


