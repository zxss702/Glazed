//
//  GlazedProgresViewModle.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

struct GlazedProgresViewModle: GlazedViewModle {
    @ObservedObject var value: GlazedHelperValue
    
    @Environment(\.glazedDismiss) var glazedDismiss
    
    @State var show = false
    @State var size:Double = 0.1
    @State var colors:[Color] = []
    
    var body: some View {
        ZStack {
            if show {
                Color.black.opacity(0.2 - size)
                    .ignoresSafeArea()
                    .transition(.blur)
                    .zIndex(1)
                
                ZStack {
                    ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                        WaveView(waveColor: color,
                                 waveHeight: Double(index) * Double.random(in: 0.007...0.008),
                                 progress: Double(index) * 10)
                        .transition(.move(edge: .bottom).combined(with: .blur))
                        .zIndex(Double(colors.count - index))
                    }
                }
                .background(.background)
                .clipShape(Circle())
                .frame(width: 100, height: 100)
                .compositingGroup()
                .drawingGroup()
                .scaleEffect(x: size + 1, y: size + 1)
                .modifier(Drag3DModifier())
                .shadow(radius: 8)
                .transition(.scale(scale: 0.8).combined(with: .blur))
                .zIndex(2)
            }
        }
        .onAppear {
            withAnimation(.autoAnimation) {
                show = true
            }
            for i in 1...8 {
                withAnimation(.autoAnimation.delay(Double(i) * Double.random(in: 0.17...0.34))) {
                    colors.append(Color(red: Double.random(in: 0.4...0.9), green: Double.random(in: 0.4...0.9), blue: Double.random(in: 0.5...0.9)))
                }
            }
            Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { Timer in
                withAnimation(.linear(duration: 3)) {
                    size = size == 0.1 ? 0 : 0.1
                    for (index, _) in colors.enumerated() {
                        colors[index] = Color(red: Double.random(in: 0.4...0.9), green: Double.random(in: 0.4...0.9), blue: Double.random(in: 0.5...0.9))
                    }
                }
            }
            DispatchQueue.global().async {
                value.progessDoAction()
                Task {
                    await value.progessAsyncAction()
                    withAnimation(.autoAnimation) {
                        show = false
                    }
                    glazedDismiss()
                }
            }
        }
    }
}

struct WaveShape: Shape {
    
    var offset: Angle
    var waveHeight: Double = 0.025
    var percent: Double
    
    var animatableData: Double {
        get { offset.degrees }
        set { offset = Angle(degrees: newValue) }
    }
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        
        let waveHeight = waveHeight * rect.height
        let yoffset = CGFloat(1.0 - percent) * (rect.height - 8 * waveHeight)
        let startAngle = offset
        let endAngle = offset + Angle(degrees: 361)
        
        p.move(to: CGPoint(x: 0, y: yoffset + waveHeight * CGFloat(sin(offset.radians))))
        
        for angle in stride(from: startAngle.degrees, through: endAngle.degrees, by: 8) {
            let x = CGFloat((angle - startAngle.degrees) / 360) * rect.width
            p.addLine(to: CGPoint(x: x, y: yoffset + waveHeight * CGFloat(sin(Angle(degrees: angle).radians))))
        }
        
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        p.closeSubpath()
        
        return p
    }
}

struct WaveView: View {
    
    var waveColor: Color = .accentColor
    var waveHeight: Double = 0.025
    var progress: Double
    
    @State private var waveOffset = Angle(degrees: Double.random(in: 0...360))
    
    var body: some View {
        WaveShape(offset: waveOffset, waveHeight: waveHeight, percent: Double(progress)/100)
            .fill(waveColor)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 0)
            .onAppear {
                let d = Double.random(in: 0.15...0.25)
                Timer.scheduledTimer(withTimeInterval: d, repeats: true) { Timer in
                    withAnimation(.linear(duration: d)) {
                        self.waveOffset.degrees += Double.random(in: 15...25)
                    }
                }
            }
    }
}



public struct Drag3DModifier: ViewModifier {
    
    @State var dragAmount = CGSize.zero
    
    public init(dragAmount: CoreFoundation.CGSize = CGSize.zero) {
        self.dragAmount = dragAmount
    }
    
    @GestureState var isDrag:Bool = false
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($isDrag) { Value, State, Transaction in
                State = true
            }
            .onChanged { value in
                withAnimation(.easeOut(duration: 0.12)) {
                    dragAmount = value.translation
                }
            }
            .onEnded { _ in
                withAnimation(.spring()) {
                    dragAmount = .zero
                }
            }
    }
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(x: isDrag ? 1.2: 1, y: isDrag ? 1.2: 1)
            .rotation3DEffect(.degrees(-Double(dragAmount.width) / 8), axis: (x: 0, y: 1, z: 0))
            .rotation3DEffect(.degrees(Double(dragAmount.height / 8)), axis: (x: 1, y: 0, z: 0))
            .offset(dragAmount)
            .gesture(drag)
            .animation(.autoAnimation, value: isDrag)
    }
}

public extension View {
    func Drag3D() -> some View {
        self
            .modifier(Drag3DModifier())
    }
}
