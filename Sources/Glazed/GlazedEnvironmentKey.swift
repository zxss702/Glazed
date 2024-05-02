//
//  GlazedEnvironmentKey.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

public struct GlazedDismissKey: EnvironmentKey {
    public static var defaultValue: () -> Void = {}
}
public extension EnvironmentValues {
    var glazedDismiss:() -> Void {
        get { self[GlazedDismissKey.self] }
        set { self[GlazedDismissKey.self] = newValue }
    }
    var window:UIWindow? {
        get { self[WindowKey.self] }
        set { self[WindowKey.self] = newValue }
    }
    var glazedDoAction:(_ action: @escaping () -> Void) -> Void {
        get { self[GlazedDoActionKey.self] }
        set { self[GlazedDoActionKey.self] = newValue }
    }
}

public struct WindowKey: EnvironmentKey {
    public static var defaultValue: UIWindow? = nil
}
public struct GlazedDoActionKey: EnvironmentKey {
    public static var defaultValue: (_ action: @escaping () -> Void) -> Void = { action in
        DispatchQueue.global().async {
            action()
        }
    }
}

public extension EnvironmentValues {
    var safeAreaInsets:EdgeInsets {
        get { self[safeAreaInsetsKey.self] }
        set { self[safeAreaInsetsKey.self] = newValue }
    }
}

public struct safeAreaInsetsKey: EnvironmentKey {
    public static var defaultValue: EdgeInsets = .init(top: 20, leading: 0, bottom: 20, trailing: 0)
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
