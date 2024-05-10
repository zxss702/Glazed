//
//  GlazedFullCoverViewModle.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

struct GlazedFullCoverViewModle<Content: View>: GlazedViewModle {
    @Binding var value: GlazedHelperValue
    @ViewBuilder var content: () -> Content
    
    @GestureState var isDrag:Bool = false
    @State var show = false
    @EnvironmentObject var glazedObserver: GlazedObserver
    
    @Environment(\.glazedDismiss) var glazedDismiss
    var body: some View {
        ZStack {
            if show {
               content()
                    .background(.background)
                    .clipShape(Rectangle())
                    .shadow(size: 40)
                    .compositingGroup()
                    .onFrameChange($value.Viewframe)
                    .offset(x: 0, y: value.offsetY)
                    .ignoresSafeArea(.all)
                    .transition(.move(edge: .bottom))
                    .environment(\.gluzedSuper, value.id)
            }
        }
        .highPriorityGesture(
            DragGesture(minimumDistance: 15)
                .updating($isDrag) { Value, State, Transaction in
                    State = true
                    DispatchQueue.main.async {
                        if Value.translation.height > 0 {
                            value.offsetY = Value.translation.height
                        } else {
                            value.offsetY = 0
                        }
                    }
                }
        )
        .onChange(of: isDrag) { v in
            if !v {
                if value.offsetY > 130 {
                    glazedDismiss()
                } else {
                    withAnimation(.autoAnimation(speed: 1.3)) {
                        value.offsetY = 0
                    }
                }
            }
        }
        .onAppear {
            value.typeDismissAction = {
                withAnimation(.autoAnimation(speed: 1.6)) {
                    show = false
                }
            }
            withAnimation(.autoAnimation(speed: 1.5)) {
                show = true
            }
        }
    }
}
