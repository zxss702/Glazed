//
//  GlazedEnvironmentViewHelper.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

struct GlazedEnvironmentViewHelper: UIViewControllerRepresentable {
    typealias UIViewControllerType = GlazedEnvironmentUIView
    
    @State var content:AnyView
    @EnvironmentObject var glazedObserver:GlazedObserver
    func makeUIViewController(context: Context) -> GlazedEnvironmentUIView {
        return GlazedEnvironmentUIView(RootView: self)
    }
    func updateUIViewController(_ uiViewController: GlazedEnvironmentUIView, context: Context) {
        uiViewController.HostVC?.rootView = AnyView(
            content
                .environment(\.window, uiViewController.view.window)
                .environment(\.glazedDoAction, { action in
                    var id:UUID = UUID()
                    let helper = GlazedHelper(type: .Progres, buttonFrame: .zero, view: AnyView(EmptyView())) {
                        for i in glazedObserver.view.subviews {
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
                    glazedObserver.view.addSubview(helper)
                    NSLayoutConstraint.activate([
                        helper.topAnchor.constraint(equalTo: glazedObserver.view.topAnchor, constant: 0),
                        helper.leadingAnchor.constraint(equalTo: glazedObserver.view.leadingAnchor, constant: 0),
                        helper.bottomAnchor.constraint(equalTo: glazedObserver.view.bottomAnchor, constant: 0),
                        helper.trailingAnchor.constraint(equalTo: glazedObserver.view.trailingAnchor, constant: 0)
                    ])
                })
        )
    }
}
