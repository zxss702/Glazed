//
//  Ex_NSRange.swift
//  noteE
//
//  Created by 张旭晟 on 2023/4/1.
//

import Foundation

extension NSRange {
    var isEmpty: Bool {
        return self.upperBound == self.lowerBound
    }
}
