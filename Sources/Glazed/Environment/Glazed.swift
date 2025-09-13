//
//  Glazed.swift
//  Glazed
//
//  Created by 知阳 on 2024/11/1.
//

import SwiftUI

@MainActor
public struct Glazed<Content: View>: View {
    public let view: () -> Content
    
    @StateObject var windowViewModel = WindowViewModel()
    
    public init(@ViewBuilder view: @escaping () -> Content) {
        self.view = view
    }
    
    @State var showThisPage: ProgressShowPageViewWindow? = nil
    @State var isOpen = false
    
    public var body: some View {
        GeometryReader { geometry in
            GlazedViewHandlerRepresentable(windowViewModel: windowViewModel, content: view)
                .environment(\.safeAreaInsets, geometry.safeAreaInsets)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea()
                .onAppear {
                    windowViewModel.windowFrame = geometry.size
                    windowViewModel.windowSafeAreaInsets = geometry.safeAreaInsets
                }
                .onChange(of: geometry.size) { newValue in
                    windowViewModel.windowFrame = newValue
                }
                .onChange(of: geometry.safeAreaInsets) { newValue in
                    windowViewModel.windowSafeAreaInsets = newValue
                }
        }
        .environment(\.window, windowViewModel.window)
        .environment(\.glazedView, windowViewModel.glazedView)
        .environment(\.glazedSuper, nil)
        .environmentObject(windowViewModel)
        .background(
            WindowHandlerRepresentable(windowViewModel: windowViewModel)
                .allowsHitTesting(false)
        )
        .environment(\.glazedAsyncAction, { action in
            showThisPage?.isOpen = true
            if showThisPage == nil, let window = windowViewModel.window {
                showThisPage = ProgressShowPageViewWindow(content: AnyView(GlazedProgresView()))
                if let showThisPage, let superController = window.rootViewController {
                    superController.view.addSubview(showThisPage)
                    NSLayoutConstraint.activate([
                        showThisPage.topAnchor.constraint(equalTo: superController.view.topAnchor),
                        showThisPage.bottomAnchor.constraint(equalTo: superController.view.bottomAnchor),
                        showThisPage.leadingAnchor.constraint(equalTo: superController.view.leadingAnchor),
                        showThisPage.trailingAnchor.constraint(equalTo: superController.view.trailingAnchor)
                    ])
                    showThisPage.hosting.view.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        showThisPage.hosting.view.topAnchor.constraint(equalTo: superController.view.topAnchor),
                        showThisPage.hosting.view.bottomAnchor.constraint(equalTo: superController.view.bottomAnchor),
                        showThisPage.hosting.view.leadingAnchor.constraint(equalTo: superController.view.leadingAnchor),
                        showThisPage.hosting.view.trailingAnchor.constraint(equalTo: superController.view.trailingAnchor)
                    ])
                }
            }
            Animate {
                showThisPage?.backgroundColor = .black.withAlphaComponent(0.3)
            }
            Task.detached {
                await action()
                await MainActor.run {
                    showThisPage?.isOpen = false
                    Animate {
                        showThisPage?.hosting.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                        showThisPage?.hosting.view.alpha = 0
                        showThisPage?.backgroundColor = .clear
                    } completion: { 
                        if !isOpen {
                            showThisPage?.removeFromSuperview()
                            self.showThisPage = nil
                        }
                    }
                }
            }
        })
        .allowsHitTesting(!isOpen)
        .buttonStyle(TapButtonStyle())
    }
    
    private struct WindowHandlerRepresentable: UIViewRepresentable {
        @ObservedObject var windowViewModel: WindowViewModel

        func makeUIView(context: Context) -> WindowHandler {
            return WindowHandler(windowViewModel: self.windowViewModel)
        }

        func updateUIView(_: WindowHandler, context _: Context) {}
    }

    private class WindowHandler: UIView {
        var windowViewModel: WindowViewModel

        init(windowViewModel: WindowViewModel) {
            self.windowViewModel = windowViewModel
            super.init(frame: .zero)
            backgroundColor = .clear
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("[Popovers] - Create this view programmatically.")
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.windowViewModel.window = self.window
            }
        }
    }
    
    private struct GlazedViewHandlerRepresentable: UIViewRepresentable {
        @ObservedObject var windowViewModel: WindowViewModel
        let content: () -> Content
        
        init(windowViewModel: WindowViewModel, @ViewBuilder content: @escaping () -> Content) {
            self.windowViewModel = windowViewModel
            self.content = content
        }
        
        func makeUIView(context: Context) -> UIView {
            self.windowViewModel.hostingController = UIHostingController(rootView: AnyView(content().frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea()))
            let uiview = UIView(frame: .zero)
            self.windowViewModel.hostingController!.view.translatesAutoresizingMaskIntoConstraints = false
            uiview.addSubview(self.windowViewModel.hostingController!.view)
            uiview.backgroundColor = .clear
            self.windowViewModel.hostingController!.view.backgroundColor = .clear
            NSLayoutConstraint.activate([
                self.windowViewModel.hostingController!.view.topAnchor.constraint(equalTo: uiview.topAnchor),
                self.windowViewModel.hostingController!.view.bottomAnchor.constraint(equalTo: uiview.bottomAnchor),
                self.windowViewModel.hostingController!.view.leadingAnchor.constraint(equalTo: uiview.leadingAnchor),
                self.windowViewModel.hostingController!.view.trailingAnchor.constraint(equalTo: uiview.trailingAnchor)
            ])
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                windowViewModel.glazedView = uiview
            }
            
            return uiview
        }

        func updateUIView(_: UIView, context: Context) {
            self.windowViewModel.hostingController?.rootView = AnyView(content().frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea())
        }
        
    }
}

class WindowViewModel: ObservableObject {
    @Published var window: UIWindow?
    @Published var glazedView: UIView?
    var hostingController:UIHostingController<AnyView>?
    @Published var windowFrame: CGSize = .zero
    @Published var windowSafeAreaInsets: EdgeInsets = .init()
}
