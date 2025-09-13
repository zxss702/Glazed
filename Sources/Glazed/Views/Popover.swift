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
            if isPresented {
                let buttonRectGlobal = GeometryProxy.frame(in: .global)
                let buttonRect = CGRect(
                    x: buttonRectGlobal.minX - windowViewModel.windowSafeAreaInsets.leading ,
                    y: buttonRectGlobal.minY - windowViewModel.windowSafeAreaInsets.top,
                    width: buttonRectGlobal.width,
                    height: buttonRectGlobal.height
                )
                
                let _ = {
                    if let showThisPage {
                        showThisPage.hosting.rootView = AnyView(pageStyle())
                        showThisPage.buttonFrame = buttonRectGlobal
                        let frame = setFrame(window: glazedView, showThisPage: showThisPage, buttonRect: buttonRect)
                        if showThisPage.hosting.view.frame != frame {
                            Animate {
                                showThisPage.hosting.view.frame = frame
                                if type.isShadow {
                                    showThisPage.hosting.view.layer.shadowPath = type.clipedShape.path(in: showThisPage.hosting.view.bounds).cgPath
                                }
                            }
                        }
                    }
                }()
                
                Color.clear
                    .onAppear {
                        showThisPage?.dismissTask?.cancel()
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
                            showThisPage.alpha = type.isCenter ? 0 : 1
                            if (glazedSuper != nil || type.isCenter) && !type.isTip {
                                showThisPage.backgroundColor = .black.withAlphaComponent(0.1)
                            }
                        }
                        
                        Animate {
                            showThisPage?.alpha = 1
                            showThisPage?.hosting.view.transform = .identity
                        }
                    }
                
                    .onDisappear {
                        isPresented = false
                        if let showThisPage {
                            let unOpenTransform = setUnOpenTransform(window: glazedView, showThisPage: showThisPage, buttonRect: buttonRect, openFrame: showThisPage.hosting.view.frame)
                            Animate {
                                showThisPage.hosting.view.transform = unOpenTransform
                                showThisPage.alpha = type.isCenter ? 0 : 1
                            } completion: {
                                showThisPage.dismissTask = Task {
                                    try await Task.sleep(nanoseconds: 500_000_000)
                                    if isPresented {
                                        showThisPage.removeFromSuperview()
                                        self.showThisPage = nil
                                    }
                                }
                            }
                        }
                    }
                    .transition(.identity)
            }
        }
        .task(id: isPresented) {
            showThisPage?.isPresented = isPresented
        }
        .transition(.identity)
        .allowsHitTesting(false)
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
            .clipShape(type.clipedShape)
            .glassRegularStyle(type.clipedShape, interactive: true)
            .blur(radius: isPresented ? 0 : 10)
            .environment(\.glazedDismiss, {
                self.isPresented = false
            })
            .environment(\.glazedSuper, UUID())
            .environment(\.safeAreaInsets, EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
            .buttonStyle(TapButtonStyle())
            .font(.custom("Source Han Serif SC VF", size: 17))
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
    
    var dismissTask: Task<Void, Error>? = nil
    
    init(content: AnyView, buttonFrame: CGRect, glazedSuper: UUID?, isPresented: Bool, type: popoverType, dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
        self.buttonFrame = buttonFrame
        self.hosting = UIHostingController(rootView: content)
        self.glazedSuper = glazedSuper
        self.type = type
        self.isPresented = isPresented
        
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.hosting.view.backgroundColor = .clear
        self.hosting.sizingOptions = .intrinsicContentSize
//        self.hosting.view.insetsLayoutMarginsFromSafeArea = false
        
//        if #available(iOS 17.0, *) {
//            self.hosting.safeAreaRegions = SafeAreaRegions()
//        } else {
//            if let window = self.window {
//                self.hosting.additionalSafeAreaInsets = UIEdgeInsets(top: -window.safeAreaInsets.top, left: -window.safeAreaInsets.left, bottom: -window.safeAreaInsets.bottom, right: -window.safeAreaInsets.right)
//            } else {
//                self.hosting._disableSafeArea = true
//            }
//        }
//        self.insetsLayoutMarginsFromSafeArea = false
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
    
    deinit {
         Task { @MainActor [weak self] in self?.removeFromSuperview() }
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
