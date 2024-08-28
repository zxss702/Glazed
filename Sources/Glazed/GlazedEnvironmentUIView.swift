//
//  GlazedEnvironmentUIView.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

#if os(macOS)
class GlazedEnvironmentHitTest<Content: View>: NSView {
    let RootView:GlazedEnvironmentViewHelper<Content>
    
    init(RootView: GlazedEnvironmentViewHelper<Content>) {
        self.RootView = RootView
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func hitTest(_ point: NSPoint) -> NSView? {
        RootView.hitTest(point)
        return nil
    }
}

class GlazedEnvironmentUIView<Content: View>: NSViewController {
    var HostVC:NSHostingController<Content>?
    let RootView:GlazedEnvironmentViewHelper<Content>
    init(RootView: GlazedEnvironmentViewHelper<Content>) {
        self.RootView = RootView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        HostVC = NSHostingController(rootView: RootView.content())
        HostVC?.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(HostVC!.view)
        NSLayoutConstraint.activate([
            HostVC!.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            HostVC!.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            HostVC!.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            HostVC!.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
        let hittest = GlazedEnvironmentHitTest(RootView: RootView)
        view.addSubview(hittest)
        hittest.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hittest.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            hittest.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            hittest.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            hittest.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.titleVisibility = .hidden
    }
    
    func setContent() {
        HostVC?.rootView = RootView.content()
    }
}
#else
class GlazedEnvironmentHitTest<Content: View>: UIView {
    let RootView:GlazedEnvironmentViewHelper<Content>
    
    init(RootView: GlazedEnvironmentViewHelper<Content>) {
        self.RootView = RootView
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if event?.type == .scroll || event?.type == .presses || event?.type == .touches {
            RootView.hitTest(point)
        }
        return nil
    }
}

class GlazedEnvironmentUIView<Content: View>: UIViewController {
    var HostVC:UIHostingController<Content>?
    let RootView:GlazedEnvironmentViewHelper<Content>
    init(RootView: GlazedEnvironmentViewHelper<Content>) {
        self.RootView = RootView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        HostVC = UIHostingController(rootView: RootView.content())
        HostVC?.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(HostVC!.view)
        NSLayoutConstraint.activate([
            HostVC!.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            HostVC!.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            HostVC!.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            HostVC!.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
        let hittest = GlazedEnvironmentHitTest(RootView: RootView)
        view.addSubview(hittest)
        hittest.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hittest.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            hittest.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            hittest.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            hittest.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        while view.window == nil { }
        if view.window != nil {
            DispatchQueue.main.async { [self] in
                RootView.glazedObserver.superWindows = view.window
            }
        }
    }
    
    func setContent() {
        HostVC?.rootView = RootView.content()
    }
}
#endif

struct blurModifier: ViewModifier {
    let state:Bool
    func body(content: Content) -> some View {
        content
            .blur(radius: state ? 20 : 0)
    }
}

extension AnyTransition {
    static var blur: AnyTransition {
        .modifier(
            active: blurModifier(state: true),
            identity: blurModifier(state: false)
        ).combined(with: .opacity)
    }
}
