//
//  RectPreferenceKey.swift
//  Components
//
//  Created by Szymon Lorenz on 10/2/21.
//

import SwiftUI

struct RectPreferenceKey: PreferenceKey {
    typealias Value = CGRect

    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
