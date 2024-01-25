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
    
    override func viewDidAppear(_ animated: Bool) {
        while view.window == nil { }
        if view.window != nil {
            setContent()
        }
    }
    
    func setContent() {
        HostVC?.rootView = AnyView(
            RootView.content
                .environment(\.window, view.window)
                .environment(\.glazedDoAction, { [self] action in
                    var id:UUID = UUID()
                    let helper = GlazedHelper(type: .Progres, buttonFrame: .zero, view: AnyView(EmptyView())) { [self] in
                        for i in RootView.glazedObserver.view.subviews {
                            if let view = i as? GlazedHelper, view.id == id {
                                DispatchQueue.main.async(1) {
                                    view.removeFromSuperview()
                                }
                            }
                        }
                    } ProgresAction: {
                        action()
                    }
                    id = helper.id
                    RootView.glazedObserver.view.addSubview(helper)
                    NSLayoutConstraint.activate([
                        helper.topAnchor.constraint(equalTo: RootView.glazedObserver.view.topAnchor, constant: 0),
                        helper.leadingAnchor.constraint(equalTo: RootView.glazedObserver.view.leadingAnchor, constant: 0),
                        helper.bottomAnchor.constraint(equalTo: RootView.glazedObserver.view.bottomAnchor, constant: 0),
                        helper.trailingAnchor.constraint(equalTo: RootView.glazedObserver.view.trailingAnchor, constant: 0)
                    ])
                })
        )
    }
}
