//
//  GlazedEnvironment.swift
//  Glazed
//
//  Created by 知阳 on 2024/11/1.
//

import SwiftUI

public struct GlazedDismissKey: @preconcurrency EnvironmentKey {
    @MainActor public static var defaultValue:@MainActor @Sendable () -> Void = {}
}
public struct glazedSuperKey: @preconcurrency EnvironmentKey {
    @MainActor public static var defaultValue: UUID? = nil
}
#if !os(macOS)
public struct WindowKey: @preconcurrency EnvironmentKey {
    @MainActor public static var defaultValue: UIWindow? = nil
}
#endif
public struct GlazedAsyncActionKey: @preconcurrency EnvironmentKey {
    @MainActor public static var defaultValue: (_ action: @escaping @Sendable () async -> Void) -> Void = { action in
        Task.detached {
            await action()
        }
    }
}
public struct safeAreaInsetsKey: @preconcurrency EnvironmentKey {
    @MainActor public static var defaultValue: EdgeInsets = .init(top: 20, leading: 0, bottom: 20, trailing: 0)
}

extension EnvironmentValues {
    var glazedSuper:UUID? {
        get { self[glazedSuperKey.self] }
        set { self[glazedSuperKey.self] = newValue }
    }
    
    #if !os(macOS)
    var window:UIWindow? {
        get { self[WindowKey.self] }
        set { self[WindowKey.self] = newValue }
    }
    #endif
    public var glazedAsyncAction:(_ action: @escaping @Sendable () async -> Void) -> Void {
        get { self[GlazedAsyncActionKey.self] }
        set { self[GlazedAsyncActionKey.self] = newValue }
    }
    public var glazedDismiss:@MainActor @Sendable () -> Void {
        get { self[GlazedDismissKey.self] }
        set { self[GlazedDismissKey.self] = newValue }
    }
    public var safeAreaInsets:EdgeInsets {
        get { self[safeAreaInsetsKey.self] }
        set { self[safeAreaInsetsKey.self] = newValue }
    }
}
#if os(macOS)
func Animation(animation: @escaping () -> Void, completion: @escaping (Bool) -> Void = {_ in }) {
    let animationn = NSViewAnimation(duration: 0.4, animationCurve: .linear)
    animationn.start()
    animation()
    animationn.stop()
    completion(true)
}
#else
@MainActor func Animation(animation: @escaping () -> Void, completion: @escaping (Bool) -> Void = {_ in }) {
    if #available(iOS 18.0, *) {
        UIView.animate(.spring(duration: 0.5, bounce: 0.1, blendDuration: 0), changes: animation, completion: {
            completion(true)
        })
    } else {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.825, initialSpringVelocity: 0.6, options: UIView.AnimationOptions.allowUserInteraction, animations: animation, completion: completion)
    }
}
#endif

// 扩展 CGRect，提供根据中心点和大小初始化的功能
extension CGRect {
    init(center: CGPoint, size: CGSize) {
        // 计算矩形的原点，使其中心位于指定的 CGPoint
        self.init(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
    }
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

extension Animation {
    public static let autoAnimation = autoAnimation(speed: 1)
    
    public static func autoAnimation(speed: CGFloat = 1) -> Animation {
        if #available(iOS 17.0, *) {
            return .bouncy.speed(speed)// .smooth(duration: 0.4)
        } else {
            return .spring().speed(speed)
        }
    }
}
