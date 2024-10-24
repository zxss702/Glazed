//
//  SizePreferenceKey.swift
//  Components
//
//  Created by Szymon Lorenz on 10/2/21.
//

import SwiftUI

struct SizePreferenceKey: @preconcurrency PreferenceKey {
    typealias Value = CGSize

    @MainActor static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
