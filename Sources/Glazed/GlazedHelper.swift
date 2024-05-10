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

struct GlazedHelperValue {
    var id: UUID = UUID()
    
    var buttonFrame:CGRect
    var Viewframe:CGRect = .zero
    
    var offsetY:CGFloat = 0
    var offsetX:CGFloat = 0
    
    var typeDismissAction:() -> Void = {}
}
class GlazedHelper: UIWindow, Identifiable, ObservableObject {
    var isDis = false
    var hitTist:(CGPoint) -> Bool
    
    init<Content: View>(
        windowScene: UIWindowScene,
        @ViewBuilder view: @escaping () -> Content,
        hitTist: @escaping (CGPoint) -> Bool
    ) {
        self.hitTist = hitTist
        super.init(windowScene: windowScene)
        self.rootViewController = UIHostingController(rootView: view())
        self.rootViewController?.view.backgroundColor = .clear
        self.windowLevel = .alert
        self.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit1 = super.hitTest(point, with: event)
        if isDis {
            return nil
        } else if event?.type != .hover {
            return hitTist(point) ? hit1 : nil
        } else {
            return hit1
        }
    }
}

enum GlazedType: Equatable {
    case Popover, Sheet, FullCover, EditPopover, PopoverWithOutButton, tipPopover, SharePopover, centerPopover, topBottom
    case Progres
}
