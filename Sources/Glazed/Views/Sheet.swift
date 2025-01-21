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
    
    @Environment(\.glazedView) var glazedView
    @State var showThisPage: SheetShowPageViewWindow? = nil
    
    @Environment(\.colorScheme) var colorScheme
    @State var bottomC: Bool = true
    @Environment(\.glazedAsyncAction) var glazedAsyncAction
    
    @EnvironmentObject var windowViewModel:WindowViewModel
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented, let glazedView {
                    let _ = showThisPage?.hosting.rootView = AnyView(pageStyle())
                    Color.clear
                        .onChange(of: windowViewModel.windowFrame) { _ in
                            if showThisPage?.isOpen ?? false {
                                setFrame()
                            }
                        }
                        .onChange(of: windowViewModel.windowSafeAreaInsets) { _ in
                            if showThisPage?.isOpen ?? false {
                                setFrame()
                            }
                        }
                        .onAppear {
                            showThisPage?.isOpen = true
                            
                            if showThisPage == nil {
                                showThisPage = SheetShowPageViewWindow(content: AnyView(pageStyle()), isOpen: true, dismiss: {
                                    isPresented = false
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
                                }
                            }
                            
                            setFrame(animation: true)
                        }
                        .onDisappear {
                            dismiss()
                        }
                        .transition(.identity)
                }
            }
    }
    
    func getFrame() -> (CGRect, Bool) {
        if let showThisPage {
            let idealSize = showThisPage.hosting.sizeThatFits(in: windowViewModel.windowFrame)
            if idealSize.width < windowViewModel.windowFrame.width {
                if windowViewModel.windowFrame.height <= idealSize.height {
                    showThisPage.defaultTransform = CGAffineTransform(translationX: 0, y: windowViewModel.windowFrame.height + windowViewModel.windowSafeAreaInsets.bottom)
                    return (CGRect(
                        origin: CGPoint(
                            x: windowViewModel.windowFrame.width / 2 - idealSize.width / 2,
                            y: windowViewModel.windowSafeAreaInsets.top + 20
                        ), size: CGSize(
                            width: idealSize.width,
                            height: windowViewModel.windowFrame.height - 20 + windowViewModel.windowSafeAreaInsets.bottom
                        )
                    ), false)
                } else {
                    showThisPage.defaultTransform = CGAffineTransform(translationX: 0, y: windowViewModel.windowFrame.height / 2 + idealSize.height / 2 + windowViewModel.windowSafeAreaInsets.bottom)
                    return(CGRect(
                        center: CGPoint(
                            x: windowViewModel.windowFrame.width / 2 + windowViewModel.windowSafeAreaInsets.leading,
                            y: windowViewModel.windowFrame.height / 2 + windowViewModel.windowSafeAreaInsets.top
                        ),
                        size: idealSize
                    ), true)
                }
            } else {
                let viewHeight = min(windowViewModel.windowFrame.height - 20, idealSize.height) //+ windowViewModel.windowSafeAreaInsets.bottom
                showThisPage.defaultTransform = CGAffineTransform(translationX: 0, y: viewHeight)
                return (CGRect(
                    x: windowViewModel.windowSafeAreaInsets.leading,
                    y: windowViewModel.windowSafeAreaInsets.top + windowViewModel.windowFrame.height - viewHeight,
                    width: windowViewModel.windowFrame.width,
                    height: viewHeight + windowViewModel.windowSafeAreaInsets.bottom
                ), false)
            }
        } else {
            return (.zero, false)
        }
    }
    
    func setFrame(animation: Bool = false) {
        if let showThisPage {
            let (frame, bc) = getFrame()
            bottomC = bc
            if animation {
                showThisPage.hosting.view.transform = .identity
                showThisPage.hosting.view.frame = frame
                showThisPage.hosting.view.transform = showThisPage.defaultTransform
                Animation {
                    showThisPage.backgroundColor = .black.withAlphaComponent(0.3)
                    showThisPage.hosting.view.transform = .identity
                }
            } else {
                if showThisPage.hosting.view.frame != frame {
                    Animation {
                        showThisPage.hosting.view.frame = frame
                    }
                }
            }
        }
    }
    
    func dismiss() {
        isPresented = false
        showThisPage?.isOpen = false
        if let showThisPage {
            Animation {
                showThisPage.backgroundColor = .clear
                showThisPage.hosting.view.transform = showThisPage.defaultTransform
            } completion: { Bool in
                if !showThisPage.isOpen {
                    showThisPage.removeFromSuperview()
                    self.showThisPage = nil
                }
            }
        }
    }
    
    @ViewBuilder
    func pageStyle() -> some View {
        content()
            .safeAreaInset(edge: .bottom, content: {
                if !bottomC {
                    Spacer()
                        .frame(width: 1, height: windowViewModel.windowSafeAreaInsets.bottom)
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
            .animation(.autoAnimation, value: bottomC)
            .environment(\.glazedDismiss, {
                self.isPresented = false
            })
            .environment(\.glazedSuper, UUID())
            .environment(\.safeAreaInsets, EdgeInsets(top: 16, leading: 0, bottom: max(windowViewModel.windowSafeAreaInsets.bottom, 16), trailing: 0))
    }
}


@MainActor
class SheetShowPageViewWindow: UIView {
    
    let hosting:UIHostingController<AnyView>
    let dismiss: () -> Void
    var isOpen: Bool
    var defaultTransform: CGAffineTransform = .identity
    
    lazy var gesture = UIPanGestureRecognizer(target: self, action: #selector(action(ges: )))
    init(content: AnyView, isOpen: Bool, dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
        self.hosting = UIHostingController(rootView: content)
        self.isOpen = isOpen
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.hosting.view.backgroundColor = .clear
        self.hosting.sizingOptions = .preferredContentSize
//        self.hosting.view.insetsLayoutMarginsFromSafeArea = false
        self.hosting.view.isUserInteractionEnabled = true
//        self.hosting.view.becomeFirstResponder()
        if #available(iOS 17.0, *) {
            self.hosting.safeAreaRegions = SafeAreaRegions()
        } else {
            if let window = self.window {
                self.hosting.additionalSafeAreaInsets = UIEdgeInsets(top: -window.safeAreaInsets.top, left: -window.safeAreaInsets.left, bottom: -window.safeAreaInsets.bottom, right: -window.safeAreaInsets.right)
            } else {
                self.hosting._disableSafeArea = true
            }
        }
//        self.insetsLayoutMarginsFromSafeArea = false
        self.addSubview(hosting.view)
        
//        self.hosting.view.becomeFirstResponder()
        
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
