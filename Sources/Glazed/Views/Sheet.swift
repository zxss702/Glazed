//
//  Sheet.swift
//  Glazed
//
//  Created by 知阳 on 2024/11/2.
//

import SwiftUI

public struct sheetType {
    let backGround: AnyShapeStyle
    
    public init<ShapeS: ShapeStyle>(
        backGround: ShapeS
    ) {
        self.backGround = AnyShapeStyle(backGround)
    }
}

public extension View {
    
    @ViewBuilder
    func Sheet<Content: View>(
        isPresented: Binding<Bool>,
        type: sheetType = .init(backGround: .background),
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self
            .modifier(SheetViewModle(isPresented: isPresented, type: type, content: content))
    }
}

@MainActor
struct SheetViewModle<Content2: View>: ViewModifier {
    @Binding var isPresented: Bool
    let type: sheetType
    @ViewBuilder var content: () -> Content2
    
    @Environment(\.window) var window
    @State var showThisPage: SheetShowPageViewWindow? = nil
    @State var isOpen = false
    @State var isBottom = false
    
    @Environment(\.colorScheme) var colorScheme
    @State var bottomC: Bool = true
    @Environment(\.safeAreaInsets2) var safeAreaInsets2
    @Environment(\.glazedAsyncAction) var glazedAsyncAction
    
    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { GeometryProxy in
                    let _ = showThisPage?.isOpen = isOpen
                    if isPresented, let window {
                        let _ = showThisPage?.hosting.rootView = AnyView(pageStyle())
                        let _ = {
                            if let showThisPage, isPresented, showThisPage.gesture.state != .changed {
                                let idealSize = showThisPage.hosting.sizeThatFits(in: CGSize(width: window.frame.size.width, height: window.frame.size.height - safeAreaInsets2.top - safeAreaInsets2.bottom))
                                let frame = {
                                    if idealSize.width < window.frame.size.width {
                                        
                                        if window.frame.size.height <= idealSize.height {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                                isBottom = false
                                                bottomC = false
                                            }
                                            return CGRect(
                                                origin: CGPoint(
                                                    x: window.frame.width / 2 - idealSize.width / 2,
                                                    y: safeAreaInsets2.top + 20
                                                ), size: CGSize(
                                                    width: idealSize.width,
                                                    height: window.frame.size.height - safeAreaInsets2.top - safeAreaInsets2.bottom - 20
                                                )
                                            )
                                        } else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                                isBottom = false
                                                bottomC = true
                                            }
                                            return CGRect(center: CGPoint(x: window.frame.midX, y: window.frame.midY - (safeAreaInsets2.bottom - window.safeAreaInsets.bottom) / 2) , size: idealSize)
                                        }
                                    } else {
                                       
                                        let fitSize = CGSize(
                                            width: window.frame.size.width,
                                            height: min(window.frame.size.height - safeAreaInsets2.top - safeAreaInsets2.bottom - 20, idealSize.height)
                                        )
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                            bottomC = false
                                            isBottom = true
                                        }
                                        return CGRect(
                                            origin: CGPoint(
                                                x: 0,
                                                y: window.frame.size.height - safeAreaInsets2.bottom + window.safeAreaInsets.bottom - fitSize.height
                                            ), size: fitSize
                                        )
                                    }
                                }()
                                if showThisPage.hosting.view.frame != frame {
                                    Animation {
                                        showThisPage.hosting.view.frame = frame
                                    }
                                }
                            }
                        }()
                    }
                }
                .onChange(of: isPresented) { newValue in
                    isOpen = newValue
                    showThisPage?.isOpen = isOpen
                    if newValue, let window {
                        if showThisPage == nil {
                            showThisPage = SheetShowPageViewWindow(windowScene: window.windowScene!, content: AnyView(pageStyle()), isOpen: isOpen, dismiss: {
                                DispatchQueue.main.async {
                                    dismiss()
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
                                
                                let idealSize = showThisPage.hosting.sizeThatFits(in: CGSize(width: window.frame.size.width, height: window.frame.size.height - safeAreaInsets2.top - safeAreaInsets2.bottom))
                                
                                if idealSize.width < window.frame.size.width {
                                    isBottom = false
                                    if window.frame.size.height - safeAreaInsets2.top - safeAreaInsets2.bottom <= idealSize.height {
                                        showThisPage.hosting.view.frame = CGRect(
                                            origin: CGPoint(
                                                x: window.frame.width / 2 - idealSize.width / 2,
                                                y: safeAreaInsets2.top + 20
                                            ), size: CGSize(
                                                width: idealSize.width,
                                                height: window.frame.size.height - safeAreaInsets2.top - safeAreaInsets2.bottom - 20
                                            )
                                        )
                                        showThisPage.hosting.view.transform = CGAffineTransform(translationX: 0, y: window.frame.size.height - safeAreaInsets2.top - safeAreaInsets2.bottom - 10)
                                        bottomC = false
                                    } else {
                                        showThisPage.hosting.view.frame = CGRect(center: CGPoint(x: window.frame.midX, y: window.frame.midY - (safeAreaInsets2.bottom - window.safeAreaInsets.bottom) / 2) , size: idealSize)
                                        showThisPage.hosting.view.transform = CGAffineTransform(translationX: 0, y: window.frame.height / 2 + idealSize.height / 2 + 10)
                                        bottomC = true
                                    }
                                } else {
                                    isBottom = true
                                    let fitSize = CGSize(
                                        width: window.frame.size.width,
                                        height: min(window.frame.size.height - safeAreaInsets2.top - safeAreaInsets2.bottom  - 20, idealSize.height))
                                    showThisPage.hosting.view.frame = CGRect(
                                        origin: CGPoint(
                                            x: 0,
                                            y: window.frame.size.height - safeAreaInsets2.bottom + window.safeAreaInsets.bottom - fitSize.height
                                        ), size: fitSize)
                                    showThisPage.hosting.view.transform = CGAffineTransform(translationX: 0, y: fitSize.height + 10)
                                    bottomC = false
                                }
                            }
                        }
                        showThisPage?.isAnimationed = false
                        Animation {
                            showThisPage?.backgroundColor = .black.withAlphaComponent(0.3)
                            showThisPage?.hosting.view.transform = CGAffineTransform(translationX: 0, y: 0)
                        }
                    } else {
                        dismiss()
                    }
                }
            }
            .onDisappear {
                isPresented = false
                isOpen = false
                showThisPage?.isOpen = false
                dismiss()
            }
    }
    
    func dismiss() {
        if let window, let showThisPage, !showThisPage.isAnimationed {
            let idealSize = showThisPage.hosting.sizeThatFits(in: window.frame.size)
            showThisPage.isAnimationed = true
            Animation {
                showThisPage.backgroundColor = .clear
                if idealSize.width < window.frame.size.width {
                    if window.frame.size.height - safeAreaInsets2.top - safeAreaInsets2.bottom < idealSize.height {
                        showThisPage.hosting.view.transform = CGAffineTransform(translationX: 0, y: window.frame.size.height - safeAreaInsets2.top - safeAreaInsets2.bottom - 10)
                    } else {
                        showThisPage.hosting.view.transform = CGAffineTransform(translationX: 0, y: window.frame.height / 2 + idealSize.height / 2 + 10)
                    }
                } else {
                    let fitSize = CGSize(
                        width: window.frame.size.width,
                        height: min(window.frame.size.height - safeAreaInsets2.top - safeAreaInsets2.bottom - 20, idealSize.height))
                    showThisPage.hosting.view.transform = CGAffineTransform(translationX: 0, y: fitSize.height + 10)
                }
            } completion: { Bool in
                if !showThisPage.isOpen {
                    showThisPage.removeFromSuperview()
                    self.showThisPage = nil
                }
            }
        }
        self.isPresented = false
    }
    
    @ViewBuilder
    func pageStyle() -> some View {
        content()
            .safeAreaInset(edge: .bottom, content: {
                if isBottom {
                    Spacer()
                        .frame(height: safeAreaInsets2.bottom)
                }
            })
            .background(type.backGround)
            .buttonStyle(TapButtonStyle())
            .clipShape(UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                topLeading: 26.5,
                bottomLeading: bottomC ? 26.5 : 0,
                bottomTrailing: bottomC ? 26.5 : 0,
                topTrailing: 26.5
            ), style: .continuous))
            .environment(\.glazedDismiss, {
                self.isPresented = false
            })
            .environment(\.glazedSuper, nil)
            .environment(\.window, window)
            .environment(\.safeAreaInsets2, safeAreaInsets2)
            .environment(\.safeAreaInsets, EdgeInsets(top: 16, leading: 0, bottom: max(safeAreaInsets2.bottom, 16), trailing: 0))
            .environment(\.glazedAsyncAction, glazedAsyncAction)
               .font(.custom("Source Han Serif SC VF", size: 17))
    }
}


@MainActor
class SheetShowPageViewWindow: UIView {
    
    let hosting:UIHostingController<AnyView>
    let dismiss: () -> Void
    var isOpen: Bool
    var isAnimationed = false
    
    lazy var gesture = UIPanGestureRecognizer(target: self, action: #selector(action(ges: )))
    init(windowScene: UIWindowScene, content: AnyView, isOpen: Bool, dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
        self.hosting = UIHostingController(rootView: content)
        self.isOpen = isOpen
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.hosting.view.backgroundColor = .clear
        self.hosting.sizingOptions = .intrinsicContentSize
        self.hosting.view.insetsLayoutMarginsFromSafeArea = false
        if #available(iOS 16.4, *) {
            self.hosting.safeAreaRegions = SafeAreaRegions()
        } else {
            if let window = self.window {
                self.hosting.additionalSafeAreaInsets = UIEdgeInsets(top: -window.safeAreaInsets.top, left: -window.safeAreaInsets.left, bottom: -window.safeAreaInsets.bottom, right: -window.safeAreaInsets.right)
            } else {
                self.hosting._disableSafeArea = true
            }
        }
        self.insetsLayoutMarginsFromSafeArea = false
        self.addSubview(hosting.view)
        
        gesture.delaysTouchesBegan = false
        self.addGestureRecognizer(gesture)
    }
    
    var defTr = CGAffineTransform(translationX: 0, y: 0)
    
    @objc func action(ges: UIPanGestureRecognizer) {
        switch ges.state {
        case .possible:
            defTr = self.hosting.view.transform
        case .began:
            defTr = self.hosting.view.transform
        case .changed:
            let translation = ges.translation(in: self)
            let newT = defTr.translatedBy(x: 0, y: translation.y)
                if newT.ty > 0 {
                    self.hosting.view.transform = newT
                } else {
                    let sc = 2 - 1 / pow((abs(newT.ty) + 1.0), 1 / pow(2.718, 5.5))
                    self.hosting.view.transform = CGAffineTransform(scaleX: 1, y: sc).translatedBy(x: 0, y: -(self.hosting.view.frame.height * sc - self.hosting.view.frame.height) / 2)
                }
        default:
            if self.hosting.view.transform.ty < 100 {
                Animation {
                    self.hosting.view.transform = CGAffineTransform(translationX: 0, y: 0)
                }
            } else {
                dismiss()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if event?.type != .touches {
            return super.hitTest(point, with: event)
        }
        if isOpen {
            if !self.hosting.view.frame.contains(point) {
                dismiss()
            }
            return super.hitTest(point, with: event)
        } else {
            return nil
        }
    }
}
