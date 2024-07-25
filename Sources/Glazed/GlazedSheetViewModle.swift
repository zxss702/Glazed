//
//  GlazedSheetViewModle.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

struct GlazedSheetViewClliShape: Shape {
    let bool: Bool
    
    func path(in rect: CGRect) -> Path {
        return Path(roundedRect: rect, cornerRadii: RectangleCornerRadii(topLeading: 17, bottomLeading: bool ? 17 : 0, bottomTrailing: bool ? 17 : 0, topTrailing: 17), style: .continuous)
        
    }
}

struct GlazedSheetViewModle: GlazedViewModle {
    @ObservedObject var value: GlazedHelperValue
    let GeometryProxy: GeometryProxy
    let zindex:Int
    
    @Environment(\.glazedDismiss) var glazedDismiss
    

    @State var show = true
    
    @GestureState var offsetY:CGFloat = 0
    
    var body: some View {
        Color.black.opacity(0.2)
            .zIndex(Double(zindex))
            .transition(.opacity)
            .ignoresSafeArea()
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        glazedDismiss()
                    }
            )
        
        let cneterORbottom = value.Viewframe.size.width < GeometryProxy.size.width
        let radius = min(max(max(GeometryProxy.safeAreaInsets.top, GeometryProxy.safeAreaInsets.leading), max(GeometryProxy.safeAreaInsets.top, GeometryProxy.safeAreaInsets.trailing)), max(max(GeometryProxy.safeAreaInsets.bottom, GeometryProxy.safeAreaInsets.trailing), max(GeometryProxy.safeAreaInsets.bottom, GeometryProxy.safeAreaInsets.leading)))
        let shape = UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
            topLeading: 26.5,
            bottomLeading: cneterORbottom ? min(max(radius, 26.5), 60) : 0,
            bottomTrailing: cneterORbottom ? min(max(radius, 26.5), 60) : 0,
            topTrailing: 26.5
        ), style: .continuous)
        
        value.content.rootView
            .background(.background)
            .onFrameChange { Rect in
                value.Viewframe.size =  Rect.size
            }
            .clipShape(shape)
        
            .shadow(radius: 0.3)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.4), radius: 35)

            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: cneterORbottom ? .center : .bottom)
            .padding({
                if cneterORbottom {
                    return EdgeInsets(top:  GeometryProxy.safeAreaInsets.top + 20, leading: 0, bottom:  GeometryProxy.safeAreaInsets.bottom + 20, trailing: 0)
                } else {
                    return EdgeInsets(top:  GeometryProxy.safeAreaInsets.top + 20, leading: 0, bottom:  0, trailing: 0)
                }
            }())
            .offset(y: offsetY)
            .gesture(
                DragGesture(minimumDistance: 30)
                    .updating($offsetY) { Value, offsetY, Transaction in
                        if Value.translation.height > 0 {
                            offsetY = Value.translation.height
                        } else {
                            if cneterORbottom {
                                offsetY = -sqrt(abs(Value.translation.height))
                            } else {
                                offsetY = 0
                            }
                        }
                    }
                    .onEnded { Value in
                        if Value.translation.height > 130 {
                            glazedDismiss()
                        }
                    }
            )
            .animation(.autoAnimation, value: offsetY)
            .transition(.offset(y: GeometryProxy.size.height + GeometryProxy.safeAreaInsets.bottom + 50).animation(.autoAnimation))
            .environment(\.safeAreaInsets, EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .zIndex(Double(zindex + 1))
            .environment(\.gluzedSuper, nil)
            .ignoresSafeArea()
    }
}
