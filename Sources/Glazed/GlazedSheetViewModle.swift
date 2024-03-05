//
//  GlazedSheetViewModle.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

struct GlazedSheetViewClliShape: Shape {
    let bool: Bool
    
    func path(in rect: CGRect) -> Path {
        return Path(UIBezierPath(roundedRect: rect, byRoundingCorners: bool ? [.topLeft, .topRight, .bottomLeft, .bottomRight] : [.topLeft, .topRight], cornerRadii: CGSize(width: 17, height: 17)).cgPath)
    }
}

struct GlazedSheetViewModle:View {
    @ObservedObject var Helper:GlazedHelper
    @GestureState var isDrag:Bool = false
    
    @State var show = false
    @EnvironmentObject var glazedObserver: GlazedObserver
    var body: some View {
        GeometryReader { GeometryProxy in
            ZStack {
                if show {
                    Color.black.opacity(0.2).transition(.opacity).ignoresSafeArea()
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if show {
                                        Helper.dismiss()
                                    }
                                }
                        )
                }
                Helper.view
                    .background(.regularMaterial)
                    .clipShape(GlazedSheetViewClliShape(bool: Helper.ViewSize.width < GeometryProxy.size.width))
                    .onSizeChange({ CGSize in
                        Helper.ViewSize = CGSize
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: Helper.ViewSize.width < GeometryProxy.size.width ? .center : .bottom)
                    .padding(.top, (Helper.ViewSize.width < GeometryProxy.size.width ? 20 : 0))
                    .ignoresSafeArea(.container, edges: Helper.ViewSize.width < GeometryProxy.size.width ? [.leading, .trailing] : [.leading, .trailing, .bottom])
                    .offset(
                        y: !show
                           ? (
                                Helper.ViewSize.width < GeometryProxy.size.width
                                ? ((GeometryProxy.size.height - Helper.ViewSize.height) / 2 + Helper.ViewSize.height + 50)
                                : (Helper.ViewSize.height + 50)
                            )
                        : Helper.offsetY
                    )
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
                    .environment(\.safeAreaInsets, EdgeInsets(top: 17, leading: 17, bottom: 17, trailing: 17))

                    .highPriorityGesture(
                        DragGesture(minimumDistance: 30)
                            .updating($isDrag) { Value, State, Transaction in
                                State = true
                                DispatchQueue.main.async {
                                    if Value.translation.height > 0 {
                                        Helper.offsetY = Value.translation.height
                                    } else {
                                        if Helper.ViewSize.width < GeometryProxy.size.width {
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
                    .opacity(Helper.ViewSize == .zero ? 0 : 1)
            }
        }
        .onAppear {
            Helper.dismiss = {
                withAnimation(.spring()) {
                    show = false
                    DispatchQueue.main.async(0.5) {
                        Helper.ViewSize = .zero
                    }
                }
            }
            DispatchQueue.main.async(0.1){
                withAnimation(.spring()) {
                    show = true
                }
            }
        }
    }
}
