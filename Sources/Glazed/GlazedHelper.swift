//
//  GlazedHelper.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/1.
//

import SwiftUI

public struct gluzedSuperKey: EnvironmentKey {
    public static var defaultValue: UUID? = nil
}

extension EnvironmentValues {
    var gluzedSuper:UUID? {
        get { self[gluzedSuperKey.self] }
        set { self[gluzedSuperKey.self] = newValue }
    }
}
#if os(macOS)
struct HostingViewModle: NSViewRepresentable {
    let hosting: NSHostingController<AnyView>
    @ObservedObject var value: GlazedHelperValue
    @EnvironmentObject var glazedObserver: GlazedObserver
    typealias NSViewType = NSView
    
    var onSizeThatFits: (CGSize) -> Void = { _ in }
    
    @Environment(\.safeAreaInsets) var safeAreaInsets
    func makeNSView(context: Context) -> NSView {
        return hosting.view
    }
    func updateNSView(_ uiView: NSView, context: Context) { }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: NSView, context: Context) -> CGSize? {
        let size = hosting.sizeThatFits(in: CGSize(width: proposal.width ?? glazedObserver.geometry?.size.width ?? 15, height: proposal.height ?? glazedObserver.geometry?.size.height ?? 15))
        onSizeThatFits(size)
        return size
    }
}

final class GlazedHelperValue: ObservableObject {
    @Published var content: NSHostingController<AnyView>
    @Published var buttonFrame:CGRect
    var Viewframe:CGRect = .zero
    
    let gluazedSuper:Bool
    
    var typeDismissAction:() -> Void = {}
    var isPrisentDismissAction:() -> Void
    var progessDoAction:() -> Void = {}
    var progessAsyncAction:() async -> Void = {}
    
    init(buttonFrame: CGRect, Viewframe: CGRect = .zero, gluazedSuper: Bool, content: AnyView, typeDismissAction: @escaping () -> Void = {}, isPrisentDismissAction: @escaping () -> Void, progessDoAction: @escaping () -> Void = {}, progessAsyncAction: @escaping () async -> Void = {}) {
        self.buttonFrame = buttonFrame
        self.Viewframe = Viewframe
        self.gluazedSuper = gluazedSuper
        self.typeDismissAction = typeDismissAction
        self.isPrisentDismissAction = isPrisentDismissAction
        self.progessDoAction = progessDoAction
        self.content = NSHostingController(rootView: content)
        self.progessAsyncAction = progessAsyncAction
    }
}
#else
struct HostingViewModle: UIViewRepresentable {
    let hosting: UIHostingController<AnyView>
    @ObservedObject var value: GlazedHelperValue
    @EnvironmentObject var glazedObserver: GlazedObserver
    typealias UIViewType = UIView
    
    var onSizeThatFits: (CGSize) -> Void = { _ in }
    
    @Environment(\.safeAreaInsets) var safeAreaInsets
    func makeUIView(context: Context) -> UIView {
        hosting.view.isUserInteractionEnabled = true
        hosting.view.backgroundColor = .clear
        return hosting.view
    }
    func updateUIView(_ uiView: UIView, context: Context) { }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIView, context: Context) -> CGSize? {
        let size = hosting.sizeThatFits(in: CGSize(width: proposal.width ?? glazedObserver.geometry?.size.width ?? 15, height: proposal.height ?? glazedObserver.geometry?.size.height ?? 15))
        onSizeThatFits(size)
        return size
    }
}

final class GlazedHelperValue: ObservableObject {
    @Published var content: UIHostingController<AnyView>
    @Published var buttonFrame:CGRect
    var Viewframe:CGRect = .zero
    
    let gluazedSuper:Bool
    
    var typeDismissAction:() -> Void = {}
    var isPrisentDismissAction:() -> Void
    var progessDoAction:() -> Void = {}
    var progessAsyncAction:() async -> Void = {}
    
    init(buttonFrame: CGRect, Viewframe: CGRect = .zero, gluazedSuper: Bool, content: AnyView, typeDismissAction: @escaping () -> Void = {}, isPrisentDismissAction: @escaping () -> Void, progessDoAction: @escaping () -> Void = {}, progessAsyncAction: @escaping () async -> Void = {}) {
        self.buttonFrame = buttonFrame
        self.Viewframe = Viewframe
        self.gluazedSuper = gluazedSuper
        self.typeDismissAction = typeDismissAction
        self.isPrisentDismissAction = isPrisentDismissAction
        self.progessDoAction = progessDoAction
        self.content = UIHostingController(rootView: content)
        self.progessAsyncAction = progessAsyncAction
    }
}
#endif

enum GlazedType: Equatable {
    case Popover, Sheet, FullCover, EditPopover, PopoverWithOutButton, tipPopover, SharePopover, centerPopover, fullPopover
    case Progres
}
