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

class GlazedHelperValue: ObservableObject {
    @Published var buttonFrame:CGRect
    @Published var Viewframe:CGRect = .zero
    
    let gluazedSuper:Bool
    
    var typeDismissAction:() -> Void = {}
    var isPrisentDismissAction:() -> Void
    var progessDoAction:() -> Void = {}
    
    init(buttonFrame: CGRect, Viewframe: CGRect = .zero, gluazedSuper: Bool, typeDismissAction: @escaping () -> Void = {}, isPrisentDismissAction: @escaping () -> Void, progessDoAction: @escaping () -> Void = {}) {
        self.buttonFrame = buttonFrame
        self.Viewframe = Viewframe
        self.gluazedSuper = gluazedSuper
        self.typeDismissAction = typeDismissAction
        self.isPrisentDismissAction = isPrisentDismissAction
        self.progessDoAction = progessDoAction
    }
}

enum GlazedType: Equatable {
    case Popover, Sheet, FullCover, EditPopover, PopoverWithOutButton, tipPopover, SharePopover, centerPopover, topBottom
    case Progres
}
