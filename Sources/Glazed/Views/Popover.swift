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
    
    @Environment(\.glazedView) var glazedView
    
    @State var showThisPage: PopoverShowPageViewWindow? = nil
    
    @Environment(\.glazedSuper) var glazedSuper
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.safeAreaInsets2) var safeAreaInsets2
    
    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { GeometryProxy in
                    if isPresented, let glazedView {
                        let buttonRect = GeometryProxy.frame(in: .global)
                        let _ = {
                            if let showThisPage, showThisPage.isOpen {
                                showThisPage.hosting.rootView = AnyView(pageStyle())
                                showThisPage.buttonFrame = buttonRect
                                let frame = setFrame(window: glazedView, showThisPage: showThisPage, buttonRect: buttonRect)
                                if showThisPage.hosting.view.frame != frame {
                                    Animation {
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
                                showThisPage?.isOpen = true
                                if showThisPage == nil {
                                    showThisPage = PopoverShowPageViewWindow(content: AnyView(pageStyle()), buttonFrame: buttonRect, glazedSuper: glazedSuper, isOpen: true, isTip: type.isTip, isCenter: type.isCenter, dismiss: {
                                        if type.autoDimiss {
                                            self.isPresented = false
                                        }
                                    })
                                    if let showThisPage {
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
                                        showThisPage.hosting.view.transform = setUnOpenTransform(window: glazedView, showThisPage: showThisPage, buttonRect: buttonRect)
                                        showThisPage.hosting.view.alpha = type.isCenter ? 0 : 1
                                    }
                                }
                                Animation {
                                    if (glazedSuper != nil || type.isCenter) && !type.isTip {
                                        showThisPage?.backgroundColor = .black.withAlphaComponent(0.1)
                                    }
                                    showThisPage.hosting.view.alpha = 1
                                    showThisPage?.hosting.view.transform = .identity
                                } completion: { Bool in
                                    
                                }
                            }
                            .onDisappear {
                                isPresented = false
                                if let showThisPage {
                                    showThisPage.isOpen = false
                                    let unOpenTransform = setUnOpenTransform(window: glazedView, showThisPage: showThisPage, buttonRect: buttonRect)
                                    Animation {
                                        showThisPage.hosting.view.transform = unOpenTransform
                                        showThisPage.backgroundColor = .clear
                                        showThisPage.hosting.view.alpha = type.isCenter ? 0 : 1
                                    } completion: { Bool in
                                        if !showThisPage.isOpen {
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
                .allowsHitTesting(false)
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
    
    func setFrame(window: UIView, showThisPage: PopoverShowPageViewWindow, buttonRect: CGRect) -> CGRect {
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
    
    func setUnOpenTransform(window: UIView, showThisPage: PopoverShowPageViewWindow, buttonRect: CGRect) -> CGAffineTransform {
        let windowSize = window.frame.size
        
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
            .environment(\.safeAreaInsets, EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
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
    
    init(content: AnyView, buttonFrame: CGRect, glazedSuper: UUID?, isOpen: Bool, isTip: Bool, isCenter: Bool, dismiss: @escaping () -> Void) {
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
        if isOpen && !isTip {
            if self.hosting.view.frame.contains(point) {
                return super.hitTest(point, with: event)
            } else {
                if event?.type == .touches {
                    if isCenter {
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
