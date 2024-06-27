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
    @ObservedObject var value: GlazedHelperValue
    let edit:Bool
    var center:Bool = false
    
    let GeometryProxy: GeometryProxy
    
    @GestureState var isDrag:Bool = false
    
    let spacing:CGFloat = 8
    
    @State var scaleX:CGFloat = 0.5
    @State var scaleY:CGFloat = 0.5
    
    @State var showProgres:Double = 0
    @EnvironmentObject var glazedObserver: GlazedObserver
    
    @State var canSet = false
    
    @State var offsetY:CGFloat = 0
    @State var offsetX:CGFloat = 0
    
    var body: some View {
        HostingViewModle(hosting: value.content, value: value)
            .shadow(radius: 0.3)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.4), radius: 35)
            .scaleEffect(x: showProgres, y: showProgres, anchor: UnitPoint(x: scaleX, y: scaleY))
            .onFrameChange(closure: { CGRec in
                if value.Viewframe == .zero {
                    value.Viewframe = CGRec
                    setValue(onAppear: true, GeometryProxy: GeometryProxy)
                } else if showProgres == 1 {
                    value.Viewframe = CGRec
                    withAnimation(.autoAnimation) {
                        setValue(GeometryProxy: GeometryProxy)
                    }
                }
            })
            .blur(radius: 10 - showProgres * 10)
        
            .frame(maxWidth: GeometryProxy.size.width - spacing * 2, maxHeight: GeometryProxy.size.height - spacing * 2)
            .position(x: offsetX, y: offsetY)
            .environment(\.safeAreaInsets, EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            .onChange(of: value.buttonFrame) { value in
                if showProgres == 1 {
                    withAnimation(.autoAnimation) {
                        setValue(GeometryProxy: GeometryProxy)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                if !value.gluazedSuper {
                    Color.black.opacity(0.1 * showProgres).ignoresSafeArea()
                }
            }
    }
    enum PopoverEdge {
        case top, bottom, leading, trailing, center
    }
    func setValue(onAppear:Bool = false, GeometryProxy: GeometryProxy) {
        
        let buttonFrame = CGRect(x: value.buttonFrame.minX - GeometryProxy.safeAreaInsets.leading, y: value.buttonFrame.minY - GeometryProxy.safeAreaInsets.top, width: value.buttonFrame.width, height: value.buttonFrame.height)
        
        let edge:PopoverEdge = {
            if center {
                return .center
            } else {
                let leadingSpacing = buttonFrame.minX - value.Viewframe.width
                let topSpacing = buttonFrame.minY - value.Viewframe.height
                let bottomSpacing = GeometryProxy.size.height - buttonFrame.maxY - value.Viewframe.height
                let trailingSpacing = GeometryProxy.size.width - buttonFrame.maxX - value.Viewframe.width
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
        
        let rightWidth = min(GeometryProxy.size.width - spacing * 2, value.Viewframe.width)
        let rightHeight = min(GeometryProxy.size.height - spacing * 2, value.Viewframe.height)
        
        offsetX = min(max({
            switch edge {
            case .top:
                return buttonFrame.midX
            case .leading:
                return buttonFrame.minX - (rightWidth / 2) - spacing
            case .bottom:
                return buttonFrame.midX
            case .trailing:
                return buttonFrame.maxX + (rightWidth / 2) + spacing
            case .center:
                return buttonFrame.midX
            }
        }(), rightWidth / 2 + spacing), GeometryProxy.size.width - rightWidth / 2 - spacing)
        
        offsetY = min(max({
            switch edge {
            case .top:
                return buttonFrame.minY - (rightHeight / 2) - spacing
            case .leading:
                return buttonFrame.midY
            case .bottom:
                return buttonFrame.maxY + (rightHeight / 2) + spacing
            case .trailing:
                return buttonFrame.midY
            case .center:
                return buttonFrame.midY
            }
        }(), rightHeight / 2 + spacing), GeometryProxy.size.height - rightHeight / 2 - spacing)
        
        let ideaScaleX = (buttonFrame.midX - offsetX) / rightWidth
        scaleX = max(min(0.5 + ideaScaleX, 1.1), -0.1)
        let ideaScaleY = (buttonFrame.midY - offsetY) / rightHeight
        scaleY = max(min(0.5 + ideaScaleY, 1.1), -0.1)
        
        if onAppear {
            value.typeDismissAction = {
                withAnimation(.autoAnimation(speed: 1.2)) {
                    showProgres = 0
                }
            }
            withAnimation(.autoAnimation(speed: 1.5)) {
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

struct GlazedFullPopoverViewModle: GlazedViewModle {
    @ObservedObject var value: GlazedHelperValue
    
    
    let GeometryProxy: GeometryProxy
    
    @GestureState var isDrag:Bool = false
    
    @State var scaleX:CGFloat = 0.5
    @State var scaleY:CGFloat = 0.5
    
    @State var showProgres:Double = 0
    @State var showProgresX:Double = 0
    @State var showProgresY:Double = 0
    
    @EnvironmentObject var glazedObserver: GlazedObserver
    
    @State var canSet = false
    
    var body: some View {
        HostingViewModle(hosting: value.content, value: value)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.4), radius: 35)
            .clipShape(RoundedRectangle(cornerRadius: canSet ? 0 : 12, style: .continuous))
            .blur(radius: 10 * (1 - showProgres))
            .opacity(showProgres)
            .scaleEffect(x: showProgresX, y: showProgresY)
            .offset(x: scaleX, y: scaleY)
            .onFrameChange(closure: { CGRec in
                if canSet {
                    withAnimation(.autoAnimation) {
                        value.Viewframe = CGRec
                        setValue(GeometryProxy: GeometryProxy)
                    }
                } else {
                    value.Viewframe = CGRec
                    setValue(onAppear: showProgres == 0, GeometryProxy: GeometryProxy)
                }
            })
        
            .onChange(of: value.buttonFrame) { value in
                if showProgres == 1 {
                    withAnimation(.autoAnimation) {
                        setValue(GeometryProxy: GeometryProxy)
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .all)
    }
    
    func setValue(onAppear:Bool = false, GeometryProxy: GeometryProxy) {
        
        let buttonFrame = CGRect(x: value.buttonFrame.minX - GeometryProxy.safeAreaInsets.leading, y: value.buttonFrame.minY - GeometryProxy.safeAreaInsets.top, width: value.buttonFrame.width, height: value.buttonFrame.height)
        
        if onAppear {
            scaleX = buttonFrame.midX - GeometryProxy.size.width / 2
            scaleY = buttonFrame.midY - GeometryProxy.size.height / 2
            
            showProgresX = buttonFrame.width / GeometryProxy.size.width
            showProgresY = buttonFrame.height / GeometryProxy.size.height
            
            value.typeDismissAction = {
                withAnimation(.autoAnimation(speed: 1.2)) {
                    showProgres = 0
                    scaleX = buttonFrame.midX - GeometryProxy.size.width / 2
                    scaleY = buttonFrame.midY - GeometryProxy.size.height / 2
                    showProgresX = buttonFrame.width / GeometryProxy.size.width
                    showProgresY = buttonFrame.height / GeometryProxy.size.height
                }
            }
            withAnimation(.autoAnimation(speed: 1.5)) {
                scaleX = 0
                scaleY = 0
                showProgres = 1
                showProgresX = 1
                showProgresY = 1
            }
            DispatchQueue.main.async(0.5) {
                canSet = true
            }
        }
    }
}
