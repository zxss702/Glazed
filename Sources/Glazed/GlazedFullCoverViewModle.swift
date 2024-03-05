//
//  GlazedFullCoverViewModle.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

struct GlazedFullCoverViewModle:View {
    @ObservedObject var Helper:GlazedHelper
    @GestureState var isDrag:Bool = false
    @State var show = false
    @EnvironmentObject var glazedObserver: GlazedObserver
    var body: some View {
        GeometryReader { GeometryProxy in
            if show {
                Helper.view
                    .background(.regularMaterial)
                    .clipShape(Rectangle())
                    .shadow(size: 40)
                    .compositingGroup()
                    .onFrameChange($Helper.Viewframe)
                    .offset(x: 0, y: Helper.offsetY)
                    .ignoresSafeArea(.container)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                
                    .environment(\.glazedDismiss, {
                        Helper.dismissAction()
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
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 15)
                            .updating($isDrag) { Value, State, Transaction in
                                State = true
                                DispatchQueue.main.async {
                                    if Value.translation.height > 0 {
                                        Helper.offsetY = Value.translation.height
                                    } else {
                                        Helper.offsetY = 0
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
        .onAppear {
            Helper.dismiss = {
                withAnimation(.spring().speed(1.6)) {
                    show = false
                }
            }
            withAnimation(.spring().speed(1.5)) {
                show = true
            }
        }
    }
}
