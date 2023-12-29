//
//  GlazedSheetViewModle.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

struct GlazedSheetViewModle:View {
    @ObservedObject var Helper:GlazedHelper
    @GestureState var isDrag:Bool = false
    
    @State var show = false
    @EnvironmentObject var glazedObserver: GlazedObserver
    var body: some View {
        GeometryReader { GeometryProxy in
            ZStack {
                if show {
                    Color.black.opacity(0.2).allowsHitTesting(false).transition(.opacity).ignoresSafeArea()
                    Helper.view
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 17))
                        .onFrameChange($Helper.Viewframe)
                        .offset(x: 0, y: Helper.offsetY)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: Helper.Viewframe.width < GeometryProxy.size.width ? .center : .bottom)
                        .padding(.top, (Helper.Viewframe.width < GeometryProxy.size.width ? 20 : 0))
                        .ignoresSafeArea(.container, edges: Helper.Viewframe.width < GeometryProxy.size.width ? [.leading, .trailing] : [.leading, .trailing, .bottom])
                        .transition(.move(edge: .bottom).combined(with: .scale(scale: 1.2)))
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
                                action()
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
                    
                        .gesture(
                            DragGesture(minimumDistance: 15)
                                .updating($isDrag) { Value, State, Transaction in
                                    State = true
                                    DispatchQueue.main.async {
                                        if Value.translation.height > 0 {
                                            Helper.offsetY = Value.translation.height
                                        } else {
                                            if Helper.Viewframe.width < GeometryProxy.size.width {
                                                Helper.offsetY = -sqrt(abs(Value.translation.height))
                                            } else {
                                                Helper.offsetY = 0
                                            }
                                        }
                                    }
                                }
                        )
                        .onChange(of: isDrag) { v in
                            if !v {
                                if Helper.offsetY > 130 {
                                    Helper.dismiss()
                                } else {
                                    withAnimation(.spring(dampingFraction: 1).speed(1.3)) {
                                        Helper.offsetY = 0
                                    }
                                }
                            }
                        }
                }
            }
        }
        .onAppear {
            Helper.dismiss = {
                withAnimation(.spring()) {
                    show = false
                    Helper.Viewframe = .zero
                    Helper.dismissDefaut()
                }
            }
            withAnimation(.spring()) {
                show = true
            }
        }
    }
}
