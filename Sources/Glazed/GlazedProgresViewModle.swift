//
//  GlazedProgresViewModle.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

struct GlazedProgresViewModle:View {
    @ObservedObject var Helper:GlazedHelper
    @GestureState var isDrag:Bool = false
    
    @State var show = false
    
    var body: some View {
        ZStack {
            if show {
                Color.black.opacity(0.2).allowsHitTesting(false).ignoresSafeArea()
                    .transition(.blur)
                Color("systemBackColor")
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(radius: 8)
                    .overlay {
                        ProgressView()
                            .controlSize(.large)
                            .foregroundColor(.accentColor)
                    }
                    .frame(width: 80, height: 80)
                    .transition(.scale(scale: 0.8).combined(with: .blur))
            }
        }
        .onAppear {
            Helper.dismiss = {
                withAnimation(.autoAnimation) {
                    show = false
                }
            }
            withAnimation(.autoAnimation.speed(1.5)) {
                show = true
            }
            DispatchQueue.global().async {
                Task {
                    await Helper.ProgresAction()
                    DispatchQueue.main.async {
                        Helper.dismissAction()
                    }
                }
            }
        }
    }
}
