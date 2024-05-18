//
//  GlazedFullCoverViewModle.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

func avg(_ l: CGFloat...) -> CGFloat {
    var allcount: CGFloat = 0
    for i in l {
        allcount += i
    }
    return allcount / CGFloat(l.count)
}
struct GlazedFullCoverViewModle: GlazedViewModle {
    @ObservedObject var value: GlazedHelperValue
    let content: AnyView
    let zindex:Int
    let GeometryProxy: GeometryProxy
    
    @GestureState var isDrag:Bool = false
    @EnvironmentObject var glazedObserver: GlazedObserver
    
    @Environment(\.glazedDismiss) var glazedDismiss
    
    @State var offsetY:CGFloat = 0
    @State var offsetX:CGFloat = 0
    
    var body: some View {
        Color.black.opacity(0.2)
            .zIndex(Double(zindex))
            .transition(.opacity)
            .ignoresSafeArea()
        
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: avg(GeometryProxy.safeAreaInsets.top, GeometryProxy.safeAreaInsets.leading),
            bottomLeadingRadius: avg(GeometryProxy.safeAreaInsets.bottom, GeometryProxy.safeAreaInsets.leading),
            bottomTrailingRadius: avg(GeometryProxy.safeAreaInsets.bottom, GeometryProxy.safeAreaInsets.trailing),
            topTrailingRadius: avg(GeometryProxy.safeAreaInsets.top, GeometryProxy.safeAreaInsets.trailing),
            style: .circular
        )
        
        shape
            .fill(.background)
            .offset(y: offsetY)
            .zIndex(Double(zindex + 1))
            .ignoresSafeArea()
            .transition(.offset(y: GeometryProxy.size.height + GeometryProxy.safeAreaInsets.bottom).animation(.autoAnimation))
            .simultaneousGesture(
                DragGesture(minimumDistance: 15)
                    .updating($isDrag) { Value, State, Transaction in
                        State = true
                        DispatchQueue.main.async {
                            if Value.translation.height > 0 {
                                offsetY = Value.translation.height
                            } else {
                                offsetY = 0
                            }
                        }
                    }
            )
        
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(shape)
            .compositingGroup()
            .offset(y: offsetY)
            .transition(.offset(y: GeometryProxy.size.height + GeometryProxy.safeAreaInsets.bottom).animation(.autoAnimation))
            .simultaneousGesture(
                DragGesture(minimumDistance: 15)
                    .updating($isDrag) { Value, State, Transaction in
                        State = true
                        DispatchQueue.main.async {
                            if Value.translation.height > 0 {
                                offsetY = Value.translation.height
                            } else {
                                offsetY = 0
                            }
                        }
                    }
            )
            .onChange(of: isDrag) { v in
                if !v {
                    if offsetY > 130 {
                        glazedDismiss()
                    } else {
                        withAnimation(.autoAnimation(speed: 1.3)) {
                            offsetY = 0
                        }
                    }
                }
            }
            .zIndex(Double(zindex + 2))
            .environment(\.gluzedSuper, nil)
    }
}
