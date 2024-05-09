//
//  GlazedPopoverViewModle.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

protocol GlazedViewModle: View where Body: View {
    @ViewBuilder @MainActor var body: Self.Body { get }
}

struct GlazedPopoverViewModle: GlazedViewModle {
    @ObservedObject var Helper:GlazedHelper
    let edit:Bool
    var center:Bool = false
    @GestureState var isDrag:Bool = false
    
    let spacing:CGFloat = 12
    
    @State var maxFrameX:CGFloat = .infinity
    @State var maxFrameY:CGFloat = .infinity
    @State var scaleX:CGFloat = 0.5
    @State var scaleY:CGFloat = 0.5
    
    @State var showProgres:Double = 0
    @Environment(\.safeAreaInsets) var safeAreaInsets
    @EnvironmentObject var glazedObserver: GlazedObserver
    
    @State var load = true
    @State var canSet = false
    
    var body: some View {
        GeometryReader { GeometryProxy in
            Helper.view
                .shadow(radius: 0.3)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.4), radius: 35)
            
                .scaleEffect(x: load ? 1 : showProgres, y: load ? 1 : showProgres, anchor: UnitPoint(x: scaleX, y: scaleY))
                .opacity(load ? 0.01 : 1)
                .onFrameChange(closure: { CGRec in
                    if canSet {
                        withAnimation(.autoAnimation) {
                            Helper.Viewframe = CGRec
                            setValue(GeometryProxy: GeometryProxy)
                        }
                    } else if load {
                        Helper.Viewframe = CGRec
                        setValue(onAppear: true, GeometryProxy: GeometryProxy)
//                        Helper.Viewframe = CGRect(x: Helper.offsetX - maxFrameX / 2, y: Helper.offsetY - maxFrameY / 2, width: maxFrameX, height: maxFrameY)
                    } else {
                        Helper.Viewframe = CGRec
                    }
                })
            
                .blur(radius: 10 - showProgres * 10)
            
                .frame(maxWidth: maxFrameX, maxHeight: maxFrameY)
                .position(x: Helper.offsetX, y: Helper.offsetY)
                .environment(\.glazedDismiss, {
                    Helper.dismissAction()
                })
                .environment(\.gluzedSuper, Helper.id)
                .environment(\.safeAreaInsets, EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                .onChange(of: Helper.buttonFrame) { value in
                    if showProgres == 1 {
                        withAnimation(.autoAnimation) {
                            setValue(GeometryProxy: GeometryProxy)
                        }
                    }
                }
        }
        .ignoresSafeArea()
    }
    enum PopoverEdge {
        case top, bottom, leading, trailing, center
    }
    func setValue(onAppear:Bool = false, GeometryProxy: GeometryProxy) {
        let edge:PopoverEdge = {
            if center {
                return .center
            } else {
                let leadingSpacing = Helper.buttonFrame.minX - Helper.Viewframe.width
                let topSpacing = Helper.buttonFrame.minY - Helper.Viewframe.height
                let bottomSpacing = GeometryProxy.size.height - Helper.buttonFrame.maxY - Helper.Viewframe.height
                let trailingSpacing = GeometryProxy.size.width - Helper.buttonFrame.maxX - Helper.Viewframe.width
                if edit {
                    let maxSpacing = max(bottomSpacing,topSpacing)
                    
                    switch maxSpacing {
                    case topSpacing: return .top
                    case bottomSpacing: return .bottom
                    default: return .bottom
                    }
                } else {
                    let maxSpacing = max(max(leadingSpacing,trailingSpacing), max(bottomSpacing,topSpacing))
                    
                    switch maxSpacing {
                    case leadingSpacing: return .leading
                    case topSpacing: return .top
                    case bottomSpacing: return .bottom
                    case trailingSpacing: return .trailing
                    default: return .bottom
                    }
                }
            }
        }()
        var ideaX:Double = {
            switch edge {
            case .top:
                return Helper.buttonFrame.midX
            case .leading:
                return Helper.buttonFrame.minX - (Helper.Viewframe.width / 2) - spacing
            case .bottom:
                return Helper.buttonFrame.midX
            case .trailing:
                return Helper.buttonFrame.maxX + (Helper.Viewframe.width / 2) + spacing
            case .center:
                return Helper.buttonFrame.midX
            }
        }()
        var ideaY:Double = {
            switch edge {
            case .top:
                return Helper.buttonFrame.minY - (Helper.Viewframe.height / 2) - spacing
            case .leading:
                return Helper.buttonFrame.midY
            case .bottom:
                return Helper.buttonFrame.maxY + (Helper.Viewframe.height / 2) + spacing
            case .trailing:
                return Helper.buttonFrame.midY
            case .center:
                return Helper.buttonFrame.midY
            }
        }()
        let YBottomSpacing = GeometryProxy.size.height - (ideaY + Helper.Viewframe.height * 0.5 + max(safeAreaInsets.bottom, 20))
        let YTopSpacing = (ideaY - Helper.Viewframe.height * 0.5) - max(safeAreaInsets.top, 20)
        let XLeftSpacing = (ideaX - Helper.Viewframe.width * 0.5) - max(safeAreaInsets.leading, 20)
        let XRightSpacing = GeometryProxy.size.width - (ideaX + Helper.Viewframe.width * 0.5 + max(safeAreaInsets.trailing, 20))
        if YBottomSpacing < 0 {
            ideaY -= abs(YBottomSpacing)
        }
        if YTopSpacing < 0 {
            ideaY += abs(YTopSpacing)
        }
        if XLeftSpacing < 0 {
            ideaX += abs(XLeftSpacing)
        }
        if XRightSpacing < 0 {
            ideaX -= abs(XRightSpacing)
        }
        Helper.offsetX = ideaX
        Helper.offsetY = ideaY
        
        let canUseWidth = GeometryProxy.size.width - spacing * 2
        let canUseHeight = GeometryProxy.size.height - spacing * 2
        
        switch edge {
        case .top:
            maxFrameX = canUseWidth
            maxFrameY = Helper.buttonFrame.minY - spacing * 2
        case .leading:
            maxFrameX = Helper.buttonFrame.minX - spacing * 2
            maxFrameY = canUseHeight
        case .bottom:
            maxFrameX = canUseWidth
            maxFrameY = canUseHeight - (Helper.buttonFrame.maxY - spacing)
        case .trailing:
            maxFrameX = canUseWidth - (Helper.buttonFrame.maxX - spacing)
            maxFrameY = canUseHeight
        case .center:
            maxFrameX = canUseWidth
            maxFrameY = canUseHeight
        }
        let width = min(maxFrameX, Helper.Viewframe.width)
        let height = min(maxFrameY, Helper.Viewframe.height)
        let ideaScaleX = (Helper.buttonFrame.midX - Helper.offsetX) / width
        scaleX = max(min(0.5 + ideaScaleX, 1.1), -0.1)
        let ideaScaleY = (Helper.buttonFrame.midY - Helper.offsetY) / height
        scaleY = max(min(0.5 + ideaScaleY, 1.1), -0.1)
        
        load = false
        if onAppear {
            Helper.dismiss = {
                withAnimation(.spring(dampingFraction: 1).speed(1.2)) {
                    showProgres = 0
                }
            }
            withAnimation(.spring(dampingFraction: 0.7).speed(1.5)) {
                showProgres = 1
            }
            DispatchQueue.main.async(0.5) {
                canSet = true
            }
        }
    }
}

struct RoundedCorners: InsettableShape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    var insetAmount: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.size.width
        let h = rect.size.height
        
        let tr = min(min(self.tr, h/2), w/2)
        let tl = min(min(self.tl, h/2), w/2)
        let bl = min(min(self.bl, h/2), w/2)
        let br = min(min(self.br, h/2), w/2)
        
        path.move(to: CGPoint(x: w / 2.0 + insetAmount, y: insetAmount))
        path.addLine(to: CGPoint(x: w - tr + insetAmount, y: insetAmount))
        path.addArc(center: CGPoint(x: w - tr + insetAmount, y: tr + insetAmount), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: w + insetAmount, y: h - br + insetAmount))
        path.addArc(center: CGPoint(x: w - br + insetAmount, y: h - br + insetAmount), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: bl + insetAmount, y: h + insetAmount))
        path.addArc(center: CGPoint(x: bl + insetAmount, y: h - bl + insetAmount), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: CGPoint(x: insetAmount, y: tl + insetAmount))
        path.addArc(center: CGPoint(x: tl + insetAmount, y: tl + insetAmount), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.closeSubpath()
        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var rectangle = self
        rectangle.insetAmount += amount
        return rectangle
    }
}

public struct Drag3DModifier: ViewModifier {
    
    @State var dragAmount = CGSize.zero
    
    public init(dragAmount: CoreFoundation.CGSize = CGSize.zero) {
        self.dragAmount = dragAmount
    }
    
    var drag: some Gesture {
        DragGesture()
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
            .rotation3DEffect(.degrees(-Double(dragAmount.width) / 8), axis: (x: 0, y: 1, z: 0))
            .rotation3DEffect(.degrees(Double(dragAmount.height / 8)), axis: (x: 1, y: 0, z: 0))
            .offset(dragAmount)
            .gesture(drag)
    }
}

public extension View {
    func Drag3D() -> some View {
        self
            .modifier(Drag3DModifier())
    }
}
