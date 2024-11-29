//
//  GlazedEnvironment.swift
//  Glazed
//
//  Created by 知阳 on 2024/11/1.
//

import SwiftUI
import AudioToolbox

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
    public var window:UIWindow? {
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
    var safeAreaInsets2:EdgeInsets {
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
        UIView.animate(.spring(duration: 0.4, bounce: 0.1, blendDuration: 0), changes: animation, completion: {
            completion(true)
        })
    } else {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.825, initialSpringVelocity: 0.6, options: UIView.AnimationOptions.allowUserInteraction, animations: animation, completion: completion)
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

public extension View {
    @ViewBuilder
    func shadow(Ofset: CGPoint = .zero) -> some View {
        self.modifier(shadowViewModle(size: 0.3)).modifier(shadowViewModle(size: 35))
    }

    @ViewBuilder
    func shadow(size: CGFloat, Ofset: CGPoint = .zero) -> some View {
        self
            .modifier(shadowViewModle(size: size, offset: Ofset))
    }
    @ViewBuilder
    func shadow(color: Color, size: CGFloat, Ofset: CGPoint = .zero) -> some View {
        self
            .modifier(shadowViewModle(color: color, size: size, offset: Ofset))
    }

    func shadow(color: Color? = nil, size: CGFloat, offset: CGPoint = .zero) -> some View {
        self
            .modifier(shadowViewModle(color: color, size: size, offset: offset))
    }
    func shadow2(color: CGFloat? = nil, size: CGFloat, offset: CGPoint = .zero) -> some View {
        self
            .modifier(shadowViewModle2(color: color, size: size, offset: offset))
    }
}

struct shadowViewModle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    var color: Color?
    var size: CGFloat
    var offset: CGPoint = .zero
    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content
                .shadow(color: color ?? Color(.sRGBLinear, white: 1, opacity: 0.2), radius: size, x: offset.x, y: offset.y)
        } else {
            content
                .shadow(color: color ?? Color(.sRGBLinear, white: 0, opacity: 0.2), radius: size, x: offset.x, y: offset.y)
        }
    }
}
struct shadowViewModle2: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    var color: CGFloat?
    var size: CGFloat
    var offset: CGPoint = .zero
    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content
                .shadow(color: Color(.sRGBLinear, white: 1, opacity: color ?? 0.2), radius: size, x: offset.x, y: offset.y)
        } else {
            content
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: color ?? 0.2), radius: size, x: offset.x, y: offset.y)
        }
    }
}

public struct TapButtonStyle: ButtonStyle {
    @State var scale:CGFloat = 1
    @State var time:Date = Date()
    
    @State var sc2: Double = 1.02
    @State var sc: Double = 1.02
    
    @State var paly: UUID = UUID()
    
    public init() {}
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(x: scale, y: scale)
            .foregroundColor(.accentColor)
            .contentShape(Rectangle())
            .compositingGroup()
            .onHover(perform: { Bool in
                if Bool {
                    withAnimation(.autoAnimation.speed(2)) {
                        scale = sc
                    }
                } else {
                    withAnimation(.autoAnimation.speed(2)) {
                        scale = 1
                    }
                }
            })
            .onChange(of: configuration.isPressed, perform: { newValue in
                if newValue {
                    if #available(iOS 17.0, *) {
                        paly = UUID()
                    } else {
                        AudioServicesPlaySystemSound(1519)
                    }
                    time = Date()
                    withAnimation(.autoAnimation.speed(2)) {
                        scale = sc2
                    }
                } else {
                    if time.distance(to: Date()) > 0.15 {
                        if #available(iOS 17.0, *) {
                            paly = UUID()
                        } else {
                            AudioServicesPlaySystemSound(1519)
                        }
                        withAnimation(.autoAnimation.speed(1.5)) {
                            scale = 1
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.autoAnimation.speed(1.5)) {
                                scale = 1
                            }
                        }
                    }
                    
                }
            })
            .background {
                GeometryReader(content: { geometry in
                    
                    if #available(iOS 17.0, *) {
                        Color.clear
                            .sensoryFeedback(
                                {
                                    if #available(iOS 17.5, *) {
                                        SensoryFeedback.pathComplete
                                    } else {
                                        SensoryFeedback.alignment
                                    }
                                }(), trigger: paly)
                            .onChange(of: geometry.size) { _ in
                                let av = avg(geometry.size.width, geometry.size.height)
                                sc2 = (av - 4) / av
                                sc = (av + 4) / av
                            }
                            .onAppear {
                                let av = avg(geometry.size.width, geometry.size.height)
                                sc2 = (av - 4) / av
                                sc = (av + 4) / av
                            }
                    } else {
                        Color.clear
                            .onChange(of: geometry.size) { _ in
                                let av = avg(geometry.size.width, geometry.size.height)
                                sc2 = (av - 4) / av
                                sc = (av + 4) / av
                            }
                            .onAppear {
                                let av = avg(geometry.size.width, geometry.size.height)
                                sc2 = (av - 4) / av
                                sc = (av + 4) / av
                            }
                    }
                })
            }
    }
}

// 计算平均值的函数
func avg(_ Element: CGFloat...) -> CGFloat {
    var counts: CGFloat = 0
    for i in Element {
        counts += i
    }
    return counts / CGFloat(Element.count)
}

// 计算平均值的函数（数组版本）
func avg(_ Element: [CGFloat]) -> CGFloat {
    var counts: CGFloat = 0
    for i in Element {
        counts += i
    }
    return counts / CGFloat(Element.count)
}
