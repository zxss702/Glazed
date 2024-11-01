//
//  GlazedEnvironmentKey.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

#if os(macOS)
import Foundation
import Cocoa

// Step 1: Typealias UIImage to NSImage
typealias UIImage = NSImage

// Step 2: You might want to add these APIs that UIImage has but NSImage doesn't.
extension NSImage {
    var cgImage: CGImage? {
        var proposedRect = CGRect(origin: .zero, size: size)

        return cgImage(forProposedRect: &proposedRect,
                       context: nil,
                       hints: nil)
    }

    convenience init?(named name: String) {
        self.init(named: Name(name))
    }
}

#endif


public struct GlazedDismissKey: @preconcurrency EnvironmentKey {
    @MainActor public static var defaultValue:@MainActor @Sendable () -> Void = {}
}
public extension EnvironmentValues {
    var glazedDismiss:@MainActor @Sendable () -> Void {
        get { self[GlazedDismissKey.self] }
        set { self[GlazedDismissKey.self] = newValue }
    }
    #if !os(macOS)
    var window:UIWindow? {
        get { self[WindowKey.self] }
        set { self[WindowKey.self] = newValue }
    }
    #endif
    var glazedDoAction:(_ action: @escaping @Sendable () -> Void) -> Void {
        get { self[GlazedDoActionKey.self] }
        set { self[GlazedDoActionKey.self] = newValue }
    }
    var glazedAsyncAction:(_ action: @escaping @Sendable () async -> Void) -> Void {
        get { self[GlazedAsyncActionKey.self] }
        set { self[GlazedAsyncActionKey.self] = newValue }
    }
}
#if !os(macOS)
public struct WindowKey: @preconcurrency EnvironmentKey {
    @MainActor public static var defaultValue: UIWindow? = nil
}
#endif
public struct GlazedDoActionKey: @preconcurrency EnvironmentKey {
    @MainActor public static var defaultValue: (_ action: @escaping @Sendable () -> Void) -> Void = { action in
        DispatchQueue.global().async {
            action()
        }
    }
}
public struct GlazedAsyncActionKey: @preconcurrency EnvironmentKey {
    @MainActor public static var defaultValue: (_ action: @escaping @Sendable () async -> Void) -> Void = { action in
        Task.detached {
            await action()
        }
    }
}

public extension EnvironmentValues {
    var safeAreaInsets:EdgeInsets {
        get { self[safeAreaInsetsKey.self] }
        set { self[safeAreaInsetsKey.self] = newValue }
    }
}

public struct safeAreaInsetsKey: @preconcurrency EnvironmentKey {
    @MainActor public static var defaultValue: EdgeInsets = .init(top: 20, leading: 0, bottom: 20, trailing: 0)
}

public struct safeAreaPaddingHelper:ViewModifier {
    @Environment(\.safeAreaInsets) var safeAreaInsets
    var top:Bool = false
    var trailing:Bool = false
    var leading:Bool = false
    var bottom:Bool = false
    public func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top: top ? max(safeAreaInsets.top, 16) : 0, leading: leading ? max(safeAreaInsets.leading, 16) : 0, bottom: bottom ? max(safeAreaInsets.bottom, 16) : 0, trailing: trailing ? max(safeAreaInsets.trailing, 16) : 0))
    }
}

public extension View {
    func safePadding(_ edges: Edge...) -> some View {
        self
            .modifier(safeAreaPaddingHelper(top: edges.contains(.top), trailing: edges.contains(.trailing), leading: edges.contains(.leading), bottom: edges.contains(.bottom)))
    }
    func safePadding(_ edges: [Edge]) -> some View {
        self
            .modifier(safeAreaPaddingHelper(top: edges.contains(.top), trailing: edges.contains(.trailing), leading: edges.contains(.leading), bottom: edges.contains(.bottom)))
    }
}
