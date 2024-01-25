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
        uiViewController.setContent()
    }
}
