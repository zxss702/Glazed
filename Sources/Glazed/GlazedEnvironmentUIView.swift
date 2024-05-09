//
//  GlazedEnvironmentUIView.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

class GlazedEnvironmentUIView: UIViewController {
    let RootView:GlazedEnvironmentViewHelper
    init(RootView: GlazedEnvironmentViewHelper) {
        self.RootView = RootView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        while view.window == nil { }
        if view.window != nil {
            DispatchQueue.main.async { [self] in
                RootView.glazedObserver.superWindows = view.window
            }
        }
    }
}

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
