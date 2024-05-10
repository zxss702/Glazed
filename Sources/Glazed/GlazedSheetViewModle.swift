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
        return Path(UIBezierPath(roundedRect: rect, byRoundingCorners: bool ? [.topLeft, .topRight, .bottomLeft, .bottomRight] : [.topLeft, .topRight], cornerRadii: CGSize(width: 17, height: 17)).cgPath)
    }
}

struct GlazedSheetViewModle<Content: View>: GlazedViewModle {
    @Binding var value: GlazedHelperValue
    @ViewBuilder var content: () -> Content
    @Environment(\.glazedDismiss) var glazedDismiss
    
    @GestureState var isDrag:Bool = false
    
    @State var show = false
    @EnvironmentObject var glazedObserver: GlazedObserver
    var body: some View {
        GeometryReader { GeometryProxy in
            ZStack {
                if show {
                    Color.black.opacity(0.2).transition(.opacity).ignoresSafeArea()
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    glazedDismiss()
                                }
                        )
                }
               content()
                    .background(.regularMaterial)
                    .clipShape(GlazedSheetViewClliShape(bool: value.Viewframe.size.width < GeometryProxy.size.width))
                    .shadow(radius: 0.3)
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.4), radius: 35)
                
                    .onSizeChange({ CGSize in
                        value.Viewframe.size = CGSize
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: value.Viewframe.size.width < GeometryProxy.size.width ? .center : .bottom)
                    .padding(.top, (value.Viewframe.size.width < GeometryProxy.size.width ? 20 : 0))
                    .ignoresSafeArea(.container, edges: value.Viewframe.size.width < GeometryProxy.size.width ? [.leading, .trailing] : [.leading, .trailing, .bottom])
                    .offset(
                        y: !show
                           ? (
                                value.Viewframe.size.width < GeometryProxy.size.width
                                ? ((GeometryProxy.size.height - value.Viewframe.size.height) / 2 + value.Viewframe.size.height + 50)
                                : (value.Viewframe.size.height + 50)
                            )
                        : value.offsetY
                    )
                    .environment(\.safeAreaInsets, EdgeInsets(top: 17, leading: 17, bottom: 17, trailing: 17))
                    .environment(\.gluzedSuper, value.id)
                    .gesture(
                        DragGesture(minimumDistance: 30)
                            .updating($isDrag) { Value, State, Transaction in
                                State = true
                                DispatchQueue.main.async {
                                    if Value.translation.height > 0 {
                                        value.offsetY = Value.translation.height
                                    } else {
                                        if value.Viewframe.size.width < GeometryProxy.size.width {
                                            value.offsetY = -sqrt(abs(Value.translation.height))
                                        } else {
                                            value.offsetY = 0
                                        }
                                    }
                                }
                            }
                    )
                    .onChange(of: isDrag) { v in
                        if !v {
                            if value.offsetY > 130 {
                                glazedDismiss()
                            } else {
                                withAnimation(.spring(dampingFraction: 1).speed(1.3)) {
                                    value.offsetY = 0
                                }
                            }
                        }
                    }
                    .opacity(value.Viewframe.size == .zero ? 0 : 1)
            }
        }
        .onAppear {
            value.typeDismissAction = {
                withAnimation(.autoAnimation) {
                    show = false
                }
            }
            withAnimation(.autoAnimation) {
                show = true
            }
        }
    }
}
