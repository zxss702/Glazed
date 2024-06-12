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


struct HostingViewModle: UIViewRepresentable {
    let hosting: UIHostingController<AnyView>
    
    typealias UIViewType = UIView
    
    @Environment(\.safeAreaInsets) var safeAreaInsets
    func makeUIView(context: Context) -> UIView {
        hosting.additionalSafeAreaInsets = UIEdgeInsets(top: safeAreaInsets.top, left: safeAreaInsets.leading, bottom: safeAreaInsets.bottom, right: safeAreaInsets.trailing)
        return hosting.view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

final class GlazedHelperValue: ObservableObject {
    @Published var content: UIHostingController<AnyView>
    @Published var buttonFrame:CGRect
    @Published var Viewframe:CGRect = .zero
    
    let gluazedSuper:Bool
    
    var typeDismissAction:() -> Void = {}
    var isPrisentDismissAction:() -> Void
    var progessDoAction:() -> Void = {}
    
    init(buttonFrame: CGRect, Viewframe: CGRect = .zero, gluazedSuper: Bool, content: AnyView, typeDismissAction: @escaping () -> Void = {}, isPrisentDismissAction: @escaping () -> Void, progessDoAction: @escaping () -> Void = {}) {
        self.buttonFrame = buttonFrame
        self.Viewframe = Viewframe
        self.gluazedSuper = gluazedSuper
        self.typeDismissAction = typeDismissAction
        self.isPrisentDismissAction = isPrisentDismissAction
        self.progessDoAction = progessDoAction
        self.content = UIHostingController(rootView: content)
    }
}

enum GlazedType: Equatable {
    case Popover, Sheet, FullCover, EditPopover, PopoverWithOutButton, tipPopover, SharePopover, centerPopover, topBottom, fullPopover
    case Progres
}
