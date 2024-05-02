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
                        WaveView()
                    }
                    .frame(width: 80, height: 80)
                    .modifier(Drag3DModifier())
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
public struct P23_Waves: View {
    
    let colors = [Color(hex: 0x1D427B), Color(hex: 0x285D99), Color(hex: 0x3476BA), Color(hex: 0x4091DA), Color(hex: 0x54A7E2), Color(hex: 0x71BDEB), Color(hex: 0x91D3F3), Color(hex: 0xB5E8FC)]
    
    public init() {}
    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.clear
                ZStack {
                    ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                        WaveView(waveColor: color,
                                 waveHeight: Double(colors.count - index) * Double.random(in: 0.007...0.008),
                                 progress: Double(colors.count - index) * 10)
                    }
                }
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 0)
                .frame(width: proxy.minSize * 0.8, height: proxy.minSize  * 0.8)
                .overlay(
                    Circle()
                        .stroke(Color(hex: 0x17356B), lineWidth: 20)
                        .frame(width: proxy.minSize * 0.8 + 20, height: proxy.minSize * 0.8 + 20)
                        .shadow(color: Color.black.opacity(0.5), radius: proxy.minSize * 0.025, x: proxy.minSize * 0.005, y: proxy.minSize * 0.005)
                )
//                .mask(
//                    Circle()
//                )
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

fileprivate
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

fileprivate
struct WaveView: View {
    
    var waveColor: Color
    var waveHeight: Double = 0.025
    var progress: Double
    
    @State private var waveOffset = Angle(degrees: 0)
    
    var body: some View {
        ZStack {
            WaveShape(offset: waveOffset, waveHeight: waveHeight, percent: Double(progress)/100)
                .fill(waveColor)
        }
        .onAppear {
            DispatchQueue.main.async {
                withAnimation(Animation.linear(duration: CGFloat(waveHeight * 100)).repeatForever(autoreverses: false)) {
                    self.waveOffset = Angle(degrees: 360)
                }
            }
        }
    }
}
