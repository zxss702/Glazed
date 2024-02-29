//
//  GlazedPopoverViewModle.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

struct GlazedPopoverViewModle:View {
    @ObservedObject var Helper:GlazedHelper
    let edit:Bool
    var center:Bool = false
    @GestureState var isDrag:Bool = false
    
    let spacing:CGFloat = 14
    
    @State var maxFrameX:CGFloat = .infinity
    @State var maxFrameY:CGFloat = .infinity
    @State var scaleX:CGFloat = 0.5
    @State var scaleY:CGFloat = 0.5
    
    @State var showProgres:Double = 0
    @Environment(\.safeAreaInsets) var safeAreaInsets
    @EnvironmentObject var glazedObserver: GlazedObserver
    var body: some View {
        GeometryReader { GeometryProxy in
            Helper.view
                .background(.regularMaterial)
                .provided(edit) { AnyView in
                    AnyView
                        .clipShape(Capsule(style: .continuous))
                } else: { AnyView in
                    AnyView
                        .clipShape(RoundedRectangle(cornerRadius: 17))
                }
                .shadow(radius: 0.3)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.2), radius: 35 * showProgres)
            
                .scaleEffect(x: max(showProgres, 0.2), y: max(showProgres, 0.2), anchor: UnitPoint(x: scaleX, y: scaleY))
                .opacity(showProgres)
                .blur(radius: 10 - showProgres * 10)
                .onFrameChange($Helper.Viewframe)
                .compositingGroup()
                .frame(maxWidth: maxFrameX, maxHeight: maxFrameY)
                .environment(\.glazedDismiss, {
                    Helper.dismiss()
                })
                .environment(\.glazedDoAction, { action in
                    var id:UUID = UUID()
                    let helper = GlazedHelper(type: .Progres, buttonFrame: .zero, view: AnyView(EmptyView())) {
                        for i in glazedObserver.view.subviews {
                            if let view = i as? GlazedHelper, view.id == id {
                                DispatchQueue.main.async(1) {
                                    view.removeFromSuperview()
                                }
                            }
                        }
                    } ProgresAction: {
                        await action()
                    }
                    id = helper.id
                    glazedObserver.view.addSubview(helper)
                    NSLayoutConstraint.activate([
                        helper.topAnchor.constraint(equalTo: glazedObserver.view.topAnchor, constant: 0),
                        helper.leadingAnchor.constraint(equalTo: glazedObserver.view.leadingAnchor, constant: 0),
                        helper.bottomAnchor.constraint(equalTo: glazedObserver.view.bottomAnchor, constant: 0),
                        helper.trailingAnchor.constraint(equalTo: glazedObserver.view.trailingAnchor, constant: 0)
                    ])
                })
                .environment(\.safeAreaInsets, EdgeInsets(top: 17, leading: 17, bottom: 17, trailing: 17))
                .position(x: Helper.offsetX, y: Helper.offsetY)
                .onChange(of: GeometryProxy.size) { value in
                    if showProgres == 1 {
                        withAnimation(.spring()) {
                            setValue(GeometryProxy: GeometryProxy)
                        }
                    }
                }
                .onChange(of: Helper.Viewframe) { value in
                    if showProgres == 1 {
                        withAnimation(.spring()) {
                            setValue(GeometryProxy: GeometryProxy)
                        }
                    }
                }
                .onChange(of: Helper.buttonFrame) { value in
                    if showProgres == 1 {
                        withAnimation(.spring()) {
                            setValue(GeometryProxy: GeometryProxy)
                        }
                    }
                }
                .onAppear {
                    setValue(onAppear: true, GeometryProxy: GeometryProxy)
                }
        }
        .ignoresSafeArea()
        .background {
            GeometryReader { Geometry in
                Color.clear
                    .onChange(of: Geometry.size) { value in
                        setValue(GeometryProxy: Geometry)
                    }
            }
        }
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
        scaleX = max(min(0.5 + ideaScaleX, 1), 0)
        let ideaScaleY = (Helper.buttonFrame.midY - Helper.offsetY) / height
        scaleY = max(min(0.5 + ideaScaleY, 1), 0)
        
        if onAppear {
            Helper.dismiss = {
                withAnimation(.spring(dampingFraction: 1).speed(1.3)) {
                    showProgres = 0
                    Helper.dismissDefaut()
                }
            }
            withAnimation(.spring(dampingFraction: 0.7).speed(1.7)) {
                showProgres = 1
            }
        }
    }
}
