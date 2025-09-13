//
//  SwiftUIView.swift
//  Glazed
//
//  Created by 知阳 on 2024/11/1.
//

import SwiftUI

public struct popoverType {
    let clipedShape: AnyShape
    let isShadow: Bool
    let autoDimiss: Bool
    let isCenter: Bool
    let isTip: Bool
    let isOnlyTop: Bool
    
    public init<ShapeS: ShapeStyle>(
        backGround: ShapeS,
        isShadow: Bool = true,
        autoDimiss: Bool = true,
        isCenter: Bool = false,
        isTip: Bool = false,
        isOnlyTop: Bool = false
    ) {
        self.clipedShape = AnyShape(RoundedRectangle(cornerRadius: 26.5, style: .continuous))
        self.isShadow = isShadow
        self.autoDimiss = autoDimiss
        self.isCenter = isCenter
        self.isTip = isTip
        self.isOnlyTop = isOnlyTop
    }
    public init<ClipShape: Shape>(
        clipedShape: ClipShape,
        isShadow: Bool = true,
        autoDimiss: Bool = true,
        isCenter: Bool = false,
        isTip: Bool = false,
        isOnlyTop: Bool = false
    ) {
        self.clipedShape = AnyShape(clipedShape)
        self.isShadow = isShadow
        self.autoDimiss = autoDimiss
        self.isCenter = isCenter
        self.isTip = isTip
        self.isOnlyTop = isOnlyTop
    }
    public init(
        isShadow: Bool = true,
        autoDimiss: Bool = true,
        isCenter: Bool = false,
        isTip: Bool = false,
        isOnlyTop: Bool = false
    ) {
        self.clipedShape = AnyShape(RoundedRectangle(cornerRadius: 26.5, style: .continuous))
        self.isShadow = isShadow
        self.autoDimiss = autoDimiss
        self.isCenter = isCenter
        self.isTip = isTip
        self.isOnlyTop = isOnlyTop
    }
}

public extension View {
    
    @ViewBuilder
    func Popover<Content: View>(isPresented: Binding<Bool>, type: popoverType = popoverType(clipedShape: RoundedRectangle(cornerRadius: 26.5, style: .continuous)), @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .modifier(PopoverViewModle(isPresented: isPresented, type: type, content: content))
    }
}

let leftSpace:Double = 8

@MainActor
struct PopoverViewModle<Content2: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    let type: popoverType
    @ViewBuilder var content: () -> Content2
    
    @Environment(\.glazedView) var glazedView
    
    @State var showThisPage: PopoverShowPageViewWindow? = nil
    
    @Environment(\.glazedSuper) var glazedSuper
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var windowViewModel:WindowViewModel
    
    @State var anchor: UnitPoint = .center
    @State var dismissTask: Task<Void, Error>? = nil
    func body(content: Content) -> some View {
        Group {
            if type.isCenter {
                content
                    .scaleEffect(x: type.isCenter ? (isPresented ? 1.5 : 1) : 1, y: type.isCenter ? (isPresented ? 1.5 : 1) : 1, anchor: anchor)
                    .blur(radius: type.isCenter ? (isPresented ? 10 : 0) : 0)
                    .opacity(type.isCenter ? (isPresented ? 0 : 1) : 1)
                    .animation(.autoAnimation, value: isPresented)
            } else {
                content
            }
        }
        .overlay {
            if let glazedView {
                overlayDataHelper(glazedView: glazedView)
            }
        }
    }
    
    func overlayDataHelper(glazedView: UIView) -> some View {
        GeometryReader { GeometryProxy in
            let buttonRectGlobal = GeometryProxy.frame(in: .global)
            let buttonRect = CGRect(
                x: buttonRectGlobal.minX - windowViewModel.windowSafeAreaInsets.leading ,
                y: buttonRectGlobal.minY - windowViewModel.windowSafeAreaInsets.top,
                width: buttonRectGlobal.width,
                height: buttonRectGlobal.height
            )
            
            let _ = {
                Task { @MainActor in
                    if isPresented {
                        showThisPage?.hosting.rootView = AnyView(pageStyle())
                        showThisPage?.buttonFrame = buttonRectGlobal
                        
                        guard let showThisPage else { return }
                        let frame = setFrame(window: glazedView, showThisPage: showThisPage, buttonRect: buttonRect)
                        if showThisPage.hosting.view.frame != frame {
                            Animate {
                                self.showThisPage?.hosting.view.frame = frame
                                if type.isShadow {
                                    self.showThisPage?.hosting.view.layer.shadowPath = type.clipedShape.path(in: showThisPage.hosting.view.bounds).cgPath
                                }
                            }
                        }
                    }
                }
            }()
            
            Color.clear
                .onChange(of: isPresented, initial: true) {
                    showThisPage?.isPresented = isPresented
                    dismissTask?.cancel()
                    if isPresented {
                        if showThisPage == nil {
                            let showThisPage = PopoverShowPageViewWindow(
                                content: AnyView(pageStyle()),
                                buttonFrame: buttonRectGlobal,
                                glazedSuper: glazedSuper,
                                isPresented: isPresented,
                                type: type) {
                                    if type.autoDimiss {
                                        Task { @MainActor in
                                            self.isPresented = false
                                        }
                                    }
                                }
                            self.showThisPage = showThisPage
                            
                            glazedView.addSubview(showThisPage)
                            glazedView.bringSubviewToFront(showThisPage)
                            
                            NSLayoutConstraint.activate([
                                showThisPage.topAnchor.constraint(equalTo: glazedView.topAnchor),
                                showThisPage.bottomAnchor.constraint(equalTo: glazedView.bottomAnchor),
                                showThisPage.leadingAnchor.constraint(equalTo: glazedView.leadingAnchor),
                                showThisPage.trailingAnchor.constraint(equalTo: glazedView.trailingAnchor)
                            ])
                            
                            showThisPage.hosting.view.frame = setFrame(window: glazedView, showThisPage: showThisPage, buttonRect: buttonRect)
                            if type.isShadow {
                                switch colorScheme {
                                case .dark:
                                    showThisPage.hosting.view.layer.shadowColor = UIColor.gray.withAlphaComponent(0.6).cgColor
                                case .light:
                                    showThisPage.hosting.view.layer.shadowColor = UIColor.gray.withAlphaComponent(0.3).cgColor
                                @unknown default:
                                    showThisPage.hosting.view.layer.shadowColor = UIColor.gray.withAlphaComponent(0.3).cgColor
                                }
                                showThisPage.hosting.view.layer.shadowOffset = CGSize(width: 0,height: 0)
                                showThisPage.hosting.view.layer.shadowRadius = 35
                                showThisPage.hosting.view.layer.shadowOpacity = 1
                                showThisPage.hosting.view.layer.shadowPath = type.clipedShape.path(in: showThisPage.hosting.view.bounds).cgPath
                            }
                            showThisPage.hosting.view.transform = setUnOpenTransform(window: glazedView, showThisPage: showThisPage, buttonRect: buttonRect, openFrame: showThisPage.hosting.view.frame)
                            showThisPage.alpha = 0
                            
                            if (glazedSuper != nil || type.isCenter) && !type.isTip {
                                showThisPage.backgroundColor = .black.withAlphaComponent(0.1)
                            } else {
                                showThisPage.backgroundColor = .clear
                            }
                        }
                        
                        if showThisPage?.animator?.isRunning ?? false {
                            showThisPage?.animator?.stopAnimation(true)
                        }
                        showThisPage?.animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1)
                        // 2. 添加动画闭包
                        showThisPage?.animator?.addAnimations {
                            showThisPage?.alpha = 1
                            showThisPage?.hosting.view.transform = .identity
                            showThisPage?.hosting.view.blur(radius: 0)
                        }
                        showThisPage?.animator?.startAnimation()
                        
                    } else {
                        dismissPopover(buttonRect: buttonRect, glazedView: glazedView)
                    }
                }
                .onDisappear {
                    isPresented = false
                    dismissPopover(buttonRect: buttonRect, glazedView: glazedView)
                }
                .transition(.identity)
        }
        .transition(.identity)
        .allowsHitTesting(false)
    }
    
    func dismissPopover(buttonRect: CGRect, glazedView: UIView) {
        if let showThisPage {
            let unOpenTransform = setUnOpenTransform(window: glazedView, showThisPage: showThisPage, buttonRect: buttonRect, openFrame: showThisPage.hosting.view.frame)
            
            if showThisPage.animator?.isRunning ?? false {
                showThisPage.animator?.stopAnimation(true)
            }
            showThisPage.animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1)
            // 2. 添加动画闭包
            showThisPage.animator?.addAnimations {
                showThisPage.hosting.view.transform = unOpenTransform
                showThisPage.alpha = 0
                showThisPage.hosting.view.blur(radius: 10)
            }
            showThisPage.animator?.addCompletion { position in
                switch position {
                case .end:
                    dismissTask = Task { @MainActor in
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        if !isPresented {
                            self.showThisPage = nil
                            showThisPage.removeFromSuperview()
                        }
                    }
                default: break
                }
            }
            showThisPage.animator?.startAnimation()
        }
    }
    enum PopoverEdge {
        case top, bottom, leading, trailing, center
    }
    
    func getEdge(buttonRect: CGRect, defaultSize: CGSize) -> PopoverEdge {
        let windowSize = windowViewModel.windowFrame
        
        if type.isOnlyTop {
            return .top
        } else if type.isCenter {
            return .center
        } else if type.isTip {
            return .top
        } else {
            let bottomRect = CGRect(x: 0, y: windowSize.height * 0.75, width: windowSize.width, height: windowSize.height * 0.25)
            let topRect = CGRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height * 0.25)
            let leftRect = CGRect(x: 0, y: windowSize.height * 0.25, width: windowSize.width * 0.25, height: windowSize.height * 0.5)
            let rightRect = CGRect(x: windowSize.width * 0.75, y: windowSize.height * 0.25, width: windowSize.width * 0.25, height: windowSize.height * 0.5)
            
            if bottomRect.contains(CGPoint(x: buttonRect.midX, y: buttonRect.midY)) {
                return .top
            } else if topRect.contains(CGPoint(x: buttonRect.midX, y: buttonRect.midY)) {
                return .bottom
            } else if leftRect.contains(CGPoint(x: buttonRect.midX, y: buttonRect.midY)) {
                return .trailing
            } else if rightRect.contains(CGPoint(x: buttonRect.midX, y: buttonRect.midY)) {
                return .leading
            } else {
                let leadingSpacing = buttonRect.minX - defaultSize.width
                let topSpacing = buttonRect.minY - defaultSize.height
                let bottomSpacing = windowSize.height - buttonRect.maxY - defaultSize.height
                let trailingSpacing = windowSize.width - buttonRect.maxX - defaultSize.width
                let maxSpacing = max(max(leadingSpacing,trailingSpacing), max(bottomSpacing,topSpacing))
                
                switch maxSpacing {
                case leadingSpacing: return .leading
                case topSpacing: return .top
                case bottomSpacing: return .bottom
                case trailingSpacing: return .trailing
                default: return .bottom
                }
            }
        }
    }
    
    func setFrame(window: UIView, showThisPage: PopoverShowPageViewWindow, buttonRect: CGRect) -> CGRect {
        let windowSize = windowViewModel.windowFrame
        let defaultSize = showThisPage.hosting.sizeThatFits(in: windowSize.padding(x: leftSpace, y: leftSpace))
        let edge:PopoverEdge = getEdge(buttonRect: buttonRect, defaultSize: defaultSize)
        
        func inWidth(_ value: CGFloat) -> CGFloat {
            windowViewModel.windowSafeAreaInsets.leading + min(
                windowSize.width - defaultSize.width / 2 - leftSpace,
                max(
                    leftSpace + defaultSize.width / 2,
                    value
                )
            )
        }
        func inHeight(_ value: CGFloat) -> CGFloat {
            windowViewModel.windowSafeAreaInsets.top + min(
                windowSize.height - defaultSize.height / 2 - leftSpace,
                max(
                    leftSpace + defaultSize.height / 2,
                    value
                )
            )
        }
        
        switch edge {
        case .top:
            return CGRect(
                center: CGPoint(
                    x: inWidth(buttonRect.midX),
                    y: inHeight(buttonRect.minY - defaultSize.height / 2 - leftSpace)
                ),
                size: defaultSize
            )
        case .bottom:
            return CGRect(
                center: CGPoint(
                    x: inWidth(buttonRect.midX),
                    y: inHeight(buttonRect.maxY + defaultSize.height / 2 +  leftSpace)
                ),
                size: defaultSize
            )
        case .leading:
            return CGRect(
                center: CGPoint(
                    x: inWidth(buttonRect.minX - defaultSize.width / 2 - leftSpace),
                    y: inHeight(buttonRect.midY)
                ),
                size: defaultSize
            )
        case .trailing:
            return CGRect(
                center: CGPoint(
                    x: inWidth(buttonRect.maxX + defaultSize.width / 2 + leftSpace),
                    y: inHeight(buttonRect.midY)
                ),
                size: defaultSize
            )
        case .center:
            let iW = inWidth(buttonRect.midX)
            let iH = inHeight(buttonRect.midY)
            Task { @MainActor in
                anchor = UnitPoint(x: iW / windowSize.width, y: iH / windowSize.height)
            }
            return CGRect(
                center: CGPoint(
                    x: iW,
                    y: iH
                ),
                size: defaultSize
            )
        }
    }
    
    func setUnOpenTransform(window: UIView, showThisPage: PopoverShowPageViewWindow, buttonRect: CGRect, openFrame: CGRect) -> CGAffineTransform {
        let windowSize = windowViewModel.windowFrame
        
        let defaultSize = showThisPage.hosting.sizeThatFits(in: windowSize)
        let edge:PopoverEdge = getEdge(buttonRect: buttonRect, defaultSize: defaultSize)
        let buttonRectGlobal = CGRect(
            x: buttonRect.minX + windowViewModel.windowSafeAreaInsets.leading ,
            y: buttonRect.minY + windowViewModel.windowSafeAreaInsets.top,
            width: buttonRect.width,
            height: buttonRect.height
        )
        
        switch edge {
        case .top:
            return CGAffineTransform(
                translationX: buttonRectGlobal.midX - openFrame.midX,
                y: buttonRectGlobal.minY - openFrame.midY
            ).scaledBy(x: 0.00000001, y: 0.00000001)
        case .bottom:
            return CGAffineTransform(
                translationX: buttonRectGlobal.midX - openFrame.midX,
                y: buttonRectGlobal.maxY - openFrame.midY
            ).scaledBy(x: 0.00000001, y: 0.00000001)
        case .leading:
            return CGAffineTransform(
                translationX: buttonRectGlobal.minX - openFrame.midX,
                y: buttonRectGlobal.midY - openFrame.midY
            ).scaledBy(x: 0.00000001, y: 0.00000001)
        case .trailing:
            return CGAffineTransform(
                translationX: buttonRectGlobal.maxX - openFrame.midX,
                y: buttonRectGlobal.midY - openFrame.midY
            ).scaledBy(x: 0.00000001, y: 0.00000001)
        case .center:
            return CGAffineTransform(
                translationX: buttonRectGlobal.midX - openFrame.midX,
                y: buttonRectGlobal.midY - openFrame.midY
            ).scaledBy(x: buttonRect.width / defaultSize.width, y: buttonRect.height / defaultSize.height)
        }
    }
    
    
    @ViewBuilder
    func pageStyle() -> some View {
        content()
            .geometryGroup()
            .clipShape(type.clipedShape)
            .glassRegularStyle(type.clipedShape, interactive: true)
            .environment(\.glazedDismiss, {
                self.isPresented = false
            })
            .environment(\.glazedSuper, UUID())
            .environment(\.safeAreaInsets, EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
            .buttonStyle(TapButtonStyle())
            .font(.custom("Source Han Serif SC VF", size: 17))
            .allowsHitTesting(isPresented)
    }
}

extension CGSize {
    func padding(x: CGFloat, y: CGFloat) -> CGSize {
        return .init(width: self.width - x * 2, height: self.height - y * 2)
    }
}

@MainActor
class PopoverShowPageViewWindow: UIView {
    
    let hosting:UIHostingController<AnyView>
    var isPresented: Bool
    var type: popoverType
    let dismiss: () -> Void
    var buttonFrame: CGRect
    let glazedSuper: UUID?
    
    var animator: UIViewPropertyAnimator?
    
    init(content: AnyView, buttonFrame: CGRect, glazedSuper: UUID?, isPresented: Bool, type: popoverType, dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
        self.buttonFrame = buttonFrame
        self.hosting = UIHostingController(rootView: content)
        self.glazedSuper = glazedSuper
        self.type = type
        self.isPresented = isPresented
        
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.hosting.view.backgroundColor = .clear
        self.hosting.sizingOptions = .intrinsicContentSize
        backgroundColor = .clear
        alpha = 0
        self.addSubview(hosting.view)
        
        self.hosting.view.becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isPresented && !type.isTip {
            if self.hosting.view.frame.contains(point) {
                return super.hitTest(point, with: event)
            } else {
                if event?.type == .touches {
                    if type.isCenter {
                        dismiss()
                        return super.hitTest(point, with: event)
                    } else if glazedSuper == nil {
                        if !self.buttonFrame.contains(point) {
                            dismiss()
                        }
                        return nil
                    } else if self.buttonFrame.contains(point) {
                        return nil
                    } else {
                        dismiss()
                        return super.hitTest(point, with: event)
                    }
                }
            }
        }
        return nil
    }
}


extension View {
    
    @ViewBuilder
    func glassRegularStyle(_ shape: some Shape, color: Color? = nil, interactive: Bool = false) -> some View {
        if #available(iOS 26, *) {
            background {
                Color.clear
                    .glassEffect(.regular.tint(color).interactive(interactive), in: shape)
            }
        } else {
            if let color {
                background {
                    shape.foregroundStyle(color)
                }
            } else {
                background {
                    shape.foregroundStyle(.background)
                }
            }
        }
    }
}

// 为关联对象定义一个键
@MainActor private var animatorKey: UInt8 = 54

extension UIView {
    private var blurAnimator: UIViewPropertyAnimator? {
        get {
            return objc_getAssociatedObject(self, &animatorKey) as? UIViewPropertyAnimator
        }
        set {
            objc_setAssociatedObject(self, &animatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 为视图添加一个可自定义“半径”的模糊效果。
    /// - Parameter radius: 模糊半径，建议范围 0.0 到 1.0。值越大，模糊越强。
    func blur(radius: CGFloat) {
        // 确保视图是可见的
        guard self.superview != nil else { return }
        
        // 移除旧的动画和效果，以防重复调用
        removeBlur()
        
        // 关键步骤：创建一个 UIViewPropertyAnimator
        // duration 和 curve 只是占位符，因为我们不会真正“运行”这个动画
        let animator = UIViewPropertyAnimator(duration: 1.0, curve: .linear)
        
        // 创建一个模糊效果的容器
        let blurView = UIVisualEffectView(effect: nil)
        blurView.frame = self.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 将模糊视图添加到目标视图中
        self.addSubview(blurView)
        self.clipsToBounds = true // 确保模糊效果不会超出视图边界
        
        // 将模糊效果添加到 animator 中
        animator.addAnimations {
            blurView.effect = UIBlurEffect(style: .regular) // 可以选择 .light, .dark 等
        }
        
        // 通过 fractionComplete 控制模糊的强度（半径）
        // fractionComplete 的范围是 0.0 到 1.0
        animator.fractionComplete = min(1.0, max(0.0, radius))
        
        // 保存 animator，以便之后可以移除效果
        self.blurAnimator = animator
    }

    /// 移除通过 .blur(radius:) 添加的模糊效果
    func removeBlur() {
        // 停止动画并移除关联的视图
        self.blurAnimator?.stopAnimation(true)
        
        // 遍历子视图，找到 UIVisualEffectView 并移除
        self.subviews.filter { $0 is UIVisualEffectView }.forEach { $0.removeFromSuperview() }
        
        self.blurAnimator = nil
    }
}
