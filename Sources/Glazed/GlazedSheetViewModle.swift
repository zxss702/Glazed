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
    
    @GestureState var isDrag:Bool = false
    
    @State var show = true
    
    @State var offsetY:CGFloat = 0
    
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
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        
        value.content
            .clipShape(shape)
            .background(shape.fill(.background).ignoresSafeArea())
            
            .shadow(radius: 0.3)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.4), radius: 35)

            .onSizeChange({ CGSize in
                value.Viewframe.size = CGSize
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: cneterORbottom ? .center : .bottom)
            .padding(.top, (cneterORbottom ? 0 : 20 + GeometryProxy.safeAreaInsets.top))
            .offset(y: offsetY)
            .gesture(
                DragGesture(minimumDistance: 30)
                    .updating($isDrag) { Value, State, Transaction in
                        State = true
                        DispatchQueue.main.async {
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
                    }
            )
            .transition(.offset(y: GeometryProxy.size.height + GeometryProxy.safeAreaInsets.bottom).animation(.autoAnimation))
            .onChange(of: isDrag) { v in
                if !v {
                    if offsetY > 130 {
                        glazedDismiss()
                    } else {
                        withAnimation(.spring(dampingFraction: 1).speed(1.3)) {
                            offsetY = 0
                        }
                    }
                }
            }
            .environment(\.safeAreaInsets, EdgeInsets(top: 17, leading: 17, bottom: 17, trailing: 17))
            .zIndex(Double(zindex + 1))
            .environment(\.gluzedSuper, nil)
    }
}
