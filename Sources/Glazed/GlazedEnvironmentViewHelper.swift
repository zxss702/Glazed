//
//  GlazedEnvironmentViewHelper.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI
#if os(macOS)
struct GlazedEnvironmentViewHelper<Content: View>: NSViewControllerRepresentable {
    typealias NSViewControllerType = GlazedEnvironmentUIView<Content>
    
    @ViewBuilder var content:() -> Content
    var hitTest:(CGPoint) -> Void
    
    @EnvironmentObject var glazedObserver:GlazedObserver
    func makeNSViewController(context: Context) -> GlazedEnvironmentUIView<Content> {
        return GlazedEnvironmentUIView(RootView: self)
    }
    func updateNSViewController(_ nsViewController: GlazedEnvironmentUIView<Content>, context: Context) {
        nsViewController.setContent()
    }
}
#else
struct GlazedEnvironmentViewHelper<Content: View>: UIViewControllerRepresentable {
    typealias UIViewControllerType = GlazedEnvironmentUIView<Content>
    
    @ViewBuilder var content:() -> Content
    var hitTest:(CGPoint) -> Void
    
    @EnvironmentObject var glazedObserver:GlazedObserver
    func makeUIViewController(context: Context) -> GlazedEnvironmentUIView<Content> {
        return GlazedEnvironmentUIView(RootView: self)
    }
    func updateUIViewController(_ uiViewController: GlazedEnvironmentUIView<Content>, context: Context) {
        uiViewController.setContent()
    }
}
#endif
