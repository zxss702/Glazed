//
//  RectPreferenceKey.swift
//  Components
//
//  Created by Szymon Lorenz on 10/2/21.
//

import SwiftUI

struct RectPreferenceKey: @preconcurrency PreferenceKey {
    typealias Value = CGRect

    @MainActor static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
