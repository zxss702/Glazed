//
//  SwiftUIView.swift
//  Glazed
//
//  Created by 知阳 on 2024/11/1.
//

import SwiftUI

public struct popoverType {
    let backGround: AnyShapeStyle
    let clipedShape: AnyShape
    let isShadow: Bool
    let autoDimiss: Bool
    let isCenter: Bool
    let isTip: Bool
    let isOnlyTop: Bool
    
    public init<ShapeS: ShapeStyle, ClipShape: Shape>(
        backGround: ShapeS,
        clipedShape: ClipShape,
        isShadow: Bool = true,
        autoDimiss: Bool = true,
        isCenter: Bool = false,
        isTip: Bool = false,
        isOnlyTop: Bool = false
    ) {
        self.backGround = AnyShapeStyle(backGround)
        self.clipedShape = AnyShape(clipedShape)
        self.isShadow = isShadow
        self.autoDimiss = autoDimiss
        self.isCenter = isCenter
        self.isTip = isTip
        self.isOnlyTop = isOnlyTop
    }
    public init<ShapeS: ShapeStyle>(
        backGround: ShapeS,
        isShadow: Bool = true,
        autoDimiss: Bool = true,
        isCenter: Bool = false,
        isTip: Bool = false,
        isOnlyTop: Bool = false
    ) {
        self.backGround = AnyShapeStyle(backGround)
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
        self.backGround = AnyShapeStyle(.background)
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
        self.backGround = AnyShapeStyle(.background)
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
    func Popover<Content: View>(isPresented: Binding<Bool>, type: popoverType = popoverType(backGround: .background, clipedShape: RoundedRectangle(cornerRadius: 26.5, style: .continuous)), @ViewBuilder content: @escaping () -> Content) -> some View {
        if type.isCenter {
            self
                .scaleEffect(x: type.isCenter ? (isPresented.wrappedValue ? 1.5 : 1) : 1, y: type.isCenter ? (isPresented.wrappedValue ? 1.5 : 1) : 1)
                .blur(radius: type.isCenter ? (isPresented.wrappedValue ? 10 : 0) : 0)
                .opacity(type.isCenter ? (isPresented.wrappedValue ? 0 : 1) : 1)
                .animation(.autoAnimation, value: isPresented.wrappedValue)
                .modifier(PopoverViewModle(isPresented: isPresented, type: type, content: content))
        } else {
            self
                .modifier(PopoverViewModle(isPresented: isPresented, type: type, content: content))
        }
        
    }
}

let leftSpace:Double = 8

@MainActor
struct PopoverViewModle<Content2: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    let type: popoverType
    @ViewBuilder var content: () -> Content2
    
    @Environment(\.window) var window
    
    @State var showThisPage: PopoverShowPageViewWindow? = nil
    @State var isOpen = false
    
    @Environment(\.glazedSuper) var glazedSuper
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.safeAreaInsets2) var safeAreaInsets2
    @Environment(\.glazedAsyncAction) var glazedAsyncAction
    
    func body(content: Content) -> some View {

        content
            .overlay {
                GeometryReader { GeometryProxy in
                    let buttonRect = GeometryProxy.frame(in: .global)
                    
                    let _ = showThisPage?.isOpen = isOpen
                    
                    if isPresented, let window {
                        let _ = showThisPage?.hosting.rootView = AnyView(pageStyle())
                        let _ = showThisPage?.buttonFrame = buttonRect
                        let _ = {
                            if let showThisPage {
                                let frame = setFrame(window: window, showThisPage: showThisPage, buttonRect: buttonRect)
                                if showThisPage.hosting.view.frame != frame {
                                    Animation {
                                        if type.isShadow {
                                            showThisPage.hosting.view.layer.shadowPath = type.clipedShape.path(in: CGRect(origin: .zero, size: frame.size)).cgPath
                                        }
                                        showThisPage.hosting.view.frame = frame
                                    }
                                }
                            }
                        }()
                        Color.clear
                            .onChange(of: GeometryProxy.safeAreaInsets, perform: { newValue in
                                if let showThisPage {
                                    let frame = setFrame(window: window, showThisPage: showThisPage, buttonRect: buttonRect)
                                    if showThisPage.hosting.view.frame != frame {
                                        Animation {
                                            if type.isShadow {
                                                showThisPage.hosting.view.layer.shadowPath = type.clipedShape.path(in: CGRect(origin: .zero, size: frame.size)).cgPath
                                            }
                                            showThisPage.hosting.view.frame = frame
                                        }
                                    }
                                }
                            })
                            .onAppear {
                                if showThisPage == nil {
                                    showThisPage = PopoverShowPageViewWindow(windowScene: window.windowScene!, content: AnyView(pageStyle()), buttonFrame: buttonRect, glazedSuper: glazedSuper, isOpen: isOpen, isTip: type.isTip, isCenter: type.isCenter, dismiss: {
                                        if type.autoDimiss {
                                            self.isPresented = false
                                        }
                                    })
                                    if let showThisPage, let superController = window.rootViewController {
                                        superController.view.addSubview(showThisPage)
                                        NSLayoutConstraint.activate([
                                            showThisPage.topAnchor.constraint(equalTo: superController.view.topAnchor),
                                            showThisPage.bottomAnchor.constraint(equalTo: superController.view.bottomAnchor),
                                            showThisPage.leadingAnchor.constraint(equalTo: superController.view.leadingAnchor),
                                            showThisPage.trailingAnchor.constraint(equalTo: superController.view.trailingAnchor)
                                        ])
                                        switch colorScheme {
                                        case .dark:
                                            showThisPage.hosting.view.layer.shadowColor = UIColor.gray.withAlphaComponent(0.6).cgColor
                                        case .light:
                                            showThisPage.hosting.view.layer.shadowColor = UIColor.gray.withAlphaComponent(0.3).cgColor
                                        @unknown default:
                                            showThisPage.hosting.view.layer.shadowColor = UIColor.gray.withAlphaComponent(0.3).cgColor
                                        }
                                        
                                        showThisPage.hosting.view.frame = setFrame(window: window, showThisPage: showThisPage, buttonRect: buttonRect)
                                        if type.isShadow {
                                            showThisPage.hosting.view.layer.shadowOffset = CGSize(width: 0,height: 0)
                                            showThisPage.hosting.view.layer.shadowRadius = 35
                                            showThisPage.hosting.view.layer.shadowOpacity = 1
                                            showThisPage.hosting.view.layer.shadowPath = type.clipedShape.path(in: showThisPage.hosting.view.bounds).cgPath
                                        }
                                        showThisPage.hosting.view.transform = setUnOpenTransform(window: window, showThisPage: showThisPage, buttonRect: buttonRect)
                                    }
                                }
                                if let showThisPage {
                                    Animation {
                                        if (glazedSuper != nil || type.isCenter) && !type.isTip {
                                            showThisPage.backgroundColor = .black.withAlphaComponent(0.1)
                                        }
                                        showThisPage.hosting.view.alpha = 1
                                        showThisPage.hosting.view.transform = CGAffineTransform(scaleX: 1, y: 1)
                                    } completion: { Bool in
                                        
                                    }
                                }
                            }
                            .onDisappear {
                                isPresented = false
                                if let showThisPage {
                                    let unOpenTransform = setUnOpenTransform(window: window, showThisPage: showThisPage, buttonRect: buttonRect)
                                    
                                    Animation {
                                        showThisPage.hosting.view.transform = unOpenTransform
                                        showThisPage.backgroundColor = .clear
                                        UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.1) {
                                            showThisPage.hosting.view.alpha = 0
                                        }
                                    } completion: { Bool in
                                        if !isOpen {
                                            showThisPage.removeFromSuperview()
                                            self.showThisPage = nil
                                        }
                                    }
                                }
                            }
                            .transition(.identity)
                    }
                }
                .transition(.identity)
                .onChange(of: isPresented, perform: { newValue in
                    isOpen = newValue
                })
            }
    }
    
    enum PopoverEdge {
        case top, bottom, leading, trailing, center
    }
    
    func getEdge(buttonRect: CGRect, defaultSize: CGSize, windowSize: CGSize) -> PopoverEdge {
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
    
    func setFrame(window: UIWindow, showThisPage: PopoverShowPageViewWindow, buttonRect: CGRect) -> CGRect {
        let windowSize = window.frame.size
        
        let defaultSize = showThisPage.hosting.sizeThatFits(in: CGSize(
            width: window.frame.size.width - leftSpace * 2 - safeAreaInsets2.leading - safeAreaInsets2.trailing,
            height: window.frame.size.height - leftSpace * 2 - safeAreaInsets2.top - safeAreaInsets2.bottom
        ))
        
        let edge:PopoverEdge = getEdge(buttonRect: buttonRect, defaultSize: defaultSize, windowSize: windowSize)
        switch edge {
        case .top:
            return CGRect(center: CGPoint(
                x: max(min(buttonRect.midX, windowSize.width - leftSpace - defaultSize.width / 2), leftSpace + defaultSize.width / 2),
                y: min(max(buttonRect.minY - defaultSize.height / 2 - leftSpace, defaultSize.height / 2 + safeAreaInsets2.top + leftSpace), windowSize.height - defaultSize.height / 2 - leftSpace - safeAreaInsets2.bottom)
            ), size: defaultSize)
        case .bottom:
            return CGRect(center: CGPoint(
                x: max(
                    min(
                        buttonRect.midX,
                        windowSize.width - leftSpace - defaultSize.width / 2
                    ),
                    leftSpace + defaultSize.width / 2
                ),
                y: min(
                    max(
                        buttonRect.maxY + defaultSize.height / 2 + leftSpace,
                        defaultSize.height / 2 + safeAreaInsets2.top + leftSpace
                    ),
                    windowSize.height - leftSpace - safeAreaInsets2.bottom - defaultSize.height / 2
                )
            ), size: defaultSize)
        case .leading:
            let fuck = leftSpace + safeAreaInsets2.bottom
            return CGRect(center: CGPoint(
                x: max(
                    min(
                        buttonRect.minX - leftSpace - defaultSize.width / 2,
                        windowSize.width - leftSpace - defaultSize.width / 2
                    ),
                    leftSpace + defaultSize.width / 2
                ),
                y: max(
                    min(
                        buttonRect.midY,
                        windowSize.height - fuck - defaultSize.height / 2
                    ),
                    leftSpace + safeAreaInsets2.top + defaultSize.height / 2
                )
            ), size: defaultSize)
        case .trailing:
            let fuck = leftSpace + safeAreaInsets2.bottom
            return CGRect(center: CGPoint(
                x: max(
                    min(
                        buttonRect.maxX + leftSpace + defaultSize.width / 2,
                        windowSize.width - leftSpace - defaultSize.width / 2
                    ),
                    leftSpace + defaultSize.width / 2
                ),
                y: max(
                    min(
                        buttonRect.midY,
                        windowSize.height - fuck - defaultSize.height / 2
                    ),
                    leftSpace + safeAreaInsets2.top + defaultSize.height / 2
                )
            ), size: defaultSize)
        case .center:
            return CGRect(center: CGPoint(
                x: max(min(buttonRect.midX, windowSize.width - leftSpace - defaultSize.width / 2), leftSpace + defaultSize.width / 2),
                y: max(min(buttonRect.midY, windowSize.height - leftSpace - defaultSize.height / 2 - safeAreaInsets2.bottom), leftSpace + defaultSize.height / 2 + safeAreaInsets2.top)
            ), size: defaultSize)
        }
    }
    
    func setUnOpenTransform(window: UIWindow, showThisPage: PopoverShowPageViewWindow, buttonRect: CGRect) -> CGAffineTransform {
        let windowSize = window.bounds.size
        
        let defaultSize = showThisPage.hosting.sizeThatFits(in: CGSize(
            width: window.frame.size.width - leftSpace * 2 - safeAreaInsets2.leading - safeAreaInsets2.trailing,
            height: window.frame.size.height - leftSpace * 2 - safeAreaInsets2.top - safeAreaInsets2.bottom
        ))
        
        let edge:PopoverEdge = getEdge(buttonRect: buttonRect, defaultSize: defaultSize, windowSize: windowSize)
        
        switch edge {
        case .top:
            return CGAffineTransform(
                translationX: buttonRect.midX - showThisPage.hosting.view.frame.midX,
                y: defaultSize.height / 2).scaledBy(x: 0.00000001, y: 0.00000001)
        case .bottom:
            return CGAffineTransform(
                translationX: buttonRect.midX - showThisPage.hosting.view.frame.midX,
                y: -defaultSize.height / 2).scaledBy(x: 0.00000001, y: 0.00000001)
        case .leading:
            return CGAffineTransform(
                translationX: defaultSize.width / 2,
                y: buttonRect.midY - showThisPage.hosting.view.frame.midY
            ).scaledBy(x: 0.00000001, y: 0.00000001)
        case .trailing:
            return CGAffineTransform(
                translationX: -defaultSize.width / 2,
                y: buttonRect.midY - showThisPage.hosting.view.frame.midY
            ).scaledBy(x: 0.00000001, y: 0.00000001)
        case .center:
            return CGAffineTransform(
                translationX: buttonRect.midX - showThisPage.hosting.view.frame.midX,
                y: buttonRect.midY - showThisPage.hosting.view.frame.midY
            ).scaledBy(x: buttonRect.width / defaultSize.width, y: buttonRect.height / defaultSize.height)
        }
    }
    
    
    @ViewBuilder
    func pageStyle() -> some View {
        content()
            .background(type.backGround)
            .clipShape(type.clipedShape)
            .environment(\.glazedDismiss, {
                self.isPresented = false
            })
            .environment(\.glazedSuper, UUID())
            .environment(\.window, window)
            .environment(\.safeAreaInsets, EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
            .environment(\.safeAreaInsets2, safeAreaInsets2)
            .environment(\.glazedAsyncAction, glazedAsyncAction)
            .buttonStyle(TapButtonStyle())
            .font(.custom("Source Han Serif SC VF", size: 17))
    }
}

@MainActor
class PopoverShowPageViewWindow: UIView {
    
    let hosting:UIHostingController<AnyView>
    let dismiss: () -> Void
    var buttonFrame: CGRect
    let glazedSuper: UUID?
    var isOpen: Bool
    let isTip: Bool
    let isCenter: Bool
    
    init(windowScene: UIWindowScene, content: AnyView, buttonFrame: CGRect, glazedSuper: UUID?, isOpen: Bool, isTip: Bool, isCenter: Bool, dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
        self.buttonFrame = buttonFrame
        self.hosting = UIHostingController(rootView: content)
        self.glazedSuper = glazedSuper
        self.isOpen = isOpen
        self.isTip = isTip
        self.isCenter = isCenter
        
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.hosting.view.backgroundColor = .clear
        self.hosting.sizingOptions = .intrinsicContentSize
        self.hosting.view.insetsLayoutMarginsFromSafeArea = false
        
        if #available(iOS 17.0, *) {
            self.hosting.safeAreaRegions = SafeAreaRegions()
        } else {
            if let window = self.window {
                self.hosting.additionalSafeAreaInsets = UIEdgeInsets(top: -window.safeAreaInsets.top, left: -window.safeAreaInsets.left, bottom: -window.safeAreaInsets.bottom, right: -window.safeAreaInsets.right)
            } else {
                self.hosting._disableSafeArea = true
            }
        }
        self.insetsLayoutMarginsFromSafeArea = false
        hosting.view.alpha = 0
        self.addSubview(hosting.view)
        
        self.hosting.view.becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if event?.type != .touches {
            return super.hitTest(point, with: event)
        }
        
        if isOpen && !isTip {
            if self.hosting.view.frame.contains(point) {
                return super.hitTest(point, with: event)
            } else {
                if glazedSuper == nil && !isCenter {
                    if !self.buttonFrame.contains(point) {
                        dismiss()
                    }
                    return super.hitTest(point, with: event)
                } else {
                    if self.buttonFrame.contains(point) {
                        return super.hitTest(point, with: event)
                    } else {
                        dismiss()
                        return super.hitTest(point, with: event)
                    }
                }
            }
        } else {
            return nil
        }
    }
}
