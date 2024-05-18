//
//  GlazedEnvironmentViewHelper.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

struct GlazedEnvironmentViewHelper<Content: View>: UIViewControllerRepresentable {
    typealias UIViewControllerType = GlazedEnvironmentUIView<Content>
    
    @ViewBuilder var content:() -> Content
    var hitTest:(CGPoint) -> Bool
    
    @EnvironmentObject var glazedObserver:GlazedObserver
    func makeUIViewController(context: Context) -> GlazedEnvironmentUIView<Content> {
        return GlazedEnvironmentUIView(RootView: self)
    }
    func updateUIViewController(_ uiViewController: GlazedEnvironmentUIView<Content>, context: Context) {
        uiViewController.setContent()
    }
}
