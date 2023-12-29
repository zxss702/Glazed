//
//  View+Geometry.swift
//  Components
//
//  Created by Szymon Lorenz on 10/2/21.
//

import SwiftUI

extension View {
    func onSizeChange(_ binding: Binding<CGSize>) -> some View {
        self.onSizeChange { size in
            binding.wrappedValue = size
        }
    }

    /// Notifies about views size changes
    /// - Parameter closure: view size change callback
    /// - Returns: view
    func onSizeChange(_ closure: @escaping (CGSize) -> Void) -> some View {
        self.overlay(
            GeometryReader { geo in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geo.size)
                    .onAppear {
                        closure(geo.size)
                    }
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: closure)
    }
    
    func onFrameChange(_ binding: Binding<CGRect>, in coordinateSpace: CoordinateSpace = .global) -> some View {
        return self.onFrameChange(in: coordinateSpace) { rect in
            binding.wrappedValue = rect
        }
    }

    /// Notifies about views rect changes
    /// - Parameters:
    ///   - coordinateSpace: Coordinate space in which rect should be return
    ///   - closure: view rect change callback
    /// - Returns: view
    func onFrameChange(in coordinateSpace: CoordinateSpace = .global, closure: @escaping (CGRect) -> Void) -> some View {
        self.overlay(
            GeometryReader { geo in
                Color.clear
                    .preference(key: RectPreferenceKey.self, value: geo.frame(in: coordinateSpace))
            }
        ).onPreferenceChange(RectPreferenceKey.self, perform: closure)
    }
}
