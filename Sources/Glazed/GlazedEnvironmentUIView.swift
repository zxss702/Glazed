//
//  GlazedEnvironmentUIView.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

class GlazedEnvironmentUIView: UIViewController {
    var HostVC:UIHostingController<AnyView>?
    let RootView:GlazedEnvironmentViewHelper
    init(RootView: GlazedEnvironmentViewHelper) {
        self.RootView = RootView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        RootView.glazedObserver.view = view
        HostVC = UIHostingController(rootView: AnyView(EmptyView()))
        HostVC?.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(HostVC!.view)
        NSLayoutConstraint.activate([
            HostVC!.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            HostVC!.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            HostVC!.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            HostVC!.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
    }
}
