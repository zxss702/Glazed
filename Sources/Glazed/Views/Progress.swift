//
//  Progress.swift
//  Glazed
//
//  Created by 知阳 on 2024/11/2.
//

import SwiftUI

@MainActor
class ProgressShowPageViewWindow: UIView {
    
    let hosting:UIHostingController<AnyView>
    var isOpen = true
    init(content: AnyView) {
        self.hosting = UIHostingController(rootView: content)
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.hosting.view.backgroundColor = .clear
        self.hosting.sizingOptions = .intrinsicContentSize
        self.hosting.view.insetsLayoutMarginsFromSafeArea = false
        if #available(iOS 16.4, *) {
            self.hosting.safeAreaRegions = SafeAreaRegions()
        } else {
            if let window = self.window {
                self.hosting.additionalSafeAreaInsets = UIEdgeInsets(top: -window.safeAreaInsets.top, left: -window.safeAreaInsets.left, bottom: -window.safeAreaInsets.bottom, right: -window.safeAreaInsets.right)
            } else {
                self.hosting._disableSafeArea = true
            }
        }
        self.insetsLayoutMarginsFromSafeArea = false
        self.addSubview(hosting.view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return isOpen ? super.hitTest(point, with: event) : nil
    }
}

struct GlazedProgresView: View {
    @State var show = false
    @State var size:Double = 0.1
    @State var colors:[Color] = []
    
    var body: some View {
        ZStack {
            if show {
                ZStack {
                    ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                        WaveView(waveColor: color,
                                 waveHeight: Double(index) * Double.random(in: 0.007...0.008),
                                 progress: Double(index) * 10)
                        .transition(.move(edge: .bottom).combined(with: .blur))
                        .zIndex(Double(colors.count - index))
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .compositingGroup()
                .drawingGroup()
                .background(.background)
                .clipShape(Circle())
                .background(UIShaowd(radius: 8, cornerRaduiu: 50))
                .scaleEffect(x: size + 1, y: size + 1)
                .modifier(Drag3DModifier())
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
                Task {
                    await MainActor.run {
                        withAnimation(.linear(duration: 3)) {
                            size = size == 0.1 ? 0 : 0.1
                            for (index, _) in colors.enumerated() {
                                colors[index] = Color(red: Double.random(in: 0.4...0.9), green: Double.random(in: 0.4...0.9), blue: Double.random(in: 0.5...0.9))
                            }
                        }
                    }
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
                    Task {
                        await MainActor.run {
                            withAnimation(.linear(duration: d)) {
                                self.waveOffset.degrees += Double.random(in: 15...25)
                            }
                        }
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

struct blurModifier: ViewModifier {
    let state:Bool
    func body(content: Content) -> some View {
        content
            .blur(radius: state ? 20 : 0)
    }
}

extension AnyTransition {
    static var blur: AnyTransition {
        .modifier(
            active: blurModifier(state: true),
            identity: blurModifier(state: false)
        ).combined(with: .opacity)
    }
}
