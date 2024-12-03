//
//  scale.swift
//  Glazed
//
//  Created by 知阳 on 2024/12/3.
//

import SwiftUI

struct scaleModifier: ViewModifier {
    let scale: CGFloat
    
    func body(content: Content) -> some View {
        GeometryReader { GeometryProxy in
            let imageRender = ImageRenderer(content: content.frame(width: GeometryProxy.size.width, height: GeometryProxy.size.height))
            let _ = imageRender.scale = scale
            
            if let renderImage = imageRender.cgImage {
                Image(renderImage, scale: UIScreen().scale, label: Text("\(renderImage.hashValue)"))
                    .resizable()
                    .frame(width: GeometryProxy.size.width, height: GeometryProxy.size.height)
                    .transition(.identity)
            }
        }
    }
}


public extension View {
    func scale(_ leave: CGFloat) -> some View {
        modifier(scaleModifier(scale: leave))
    }
}
