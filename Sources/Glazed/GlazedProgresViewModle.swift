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
    @State var canShow = true
    
    var body: some View {
        ZStack {
            if show {
                Color.black.opacity(0.2).allowsHitTesting(false).ignoresSafeArea()
                    .transition(.opacity)
                Color("systemBackColor")
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(radius: 8)
                    .overlay {
                        ProgressView()
                            .controlSize(.large)
                            .foregroundColor(.accentColor)
                    }
                    .frame(width: 70, height: 70)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .onAppear {
            Helper.dismiss = {
                canShow = false
                withAnimation(.spring().speed(1.6)) {
                    show = false
                    Helper.dismissDefaut()
                }
            }
            DispatchQueue.main.async(0.3) {
                if canShow {
                    withAnimation(.spring().speed(1.5)) {
                        show = true
                    }
                }
            }
            
            DispatchQueue.global().async {
                Task {
                    await Helper.ProgresAction()
                    DispatchQueue.main.async {
                        Helper.dismiss()
                    }
                }
            }
        }
    }
}
