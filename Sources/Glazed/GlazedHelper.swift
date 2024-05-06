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

class GlazedHelper: UIView, Identifiable, ObservableObject {
    var superID: UUID = UUID()
    var superHelperID: UUID?
    var id: UUID = UUID()
    var type:GlazedType
    @Published var buttonFrame:CGRect
    @Published var Viewframe:CGRect = .zero
    @Published var ViewSize:CGSize = .zero
    
    var view: AnyView
    
    @Published var offsetY:CGFloat = 0
    @Published var offsetX:CGFloat = 0
    
    var dismiss:() -> Void = {}
    
    var dismissAction:() -> Void
    var dismissisPAction:() -> Void = {}
    
    var ProgresAction:() -> Void
    var HostVC:UIHostingController<AnyView>?
    var disTime:Date? = nil
    
    init(id: UUID = UUID(), superHelperID: UUID?, type: GlazedType, buttonFrame: CGRect, view: AnyView, offsetY: CGFloat = 0, offsetX: CGFloat = 0, dismiss: @escaping () -> Void, dismissisp: @escaping () -> Void = {}, ProgresAction: @escaping () -> Void = {}) {
        self.superID = id
        self.superHelperID = superHelperID
        self.type = type
        self.buttonFrame = buttonFrame
        self.view = view
        self.offsetY = offsetY
        self.offsetX = offsetX
        self.ProgresAction = ProgresAction
        self.dismissAction = dismiss
        self.dismissisPAction = dismissisp
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        HostVC = UIHostingController(rootView: getView())
        HostVC?.view.translatesAutoresizingMaskIntoConstraints = false
        HostVC!.view.isUserInteractionEnabled = true
        addSubview(HostVC!.view)
        NSLayoutConstraint.activate([
            HostVC!.view.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            HostVC!.view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            HostVC!.view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            HostVC!.view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        ])
        backgroundColor = .clear
        HostVC!.view.backgroundColor = .clear
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getView() -> AnyView {
        switch type {
        case .Popover:
            return AnyView(GlazedPopoverViewModle(Helper: self, edit: false).environment(\.gluzedSuper, self.id))
        case .Sheet:
            return AnyView(GlazedSheetViewModle(Helper: self).environment(\.gluzedSuper, self.id))
        case .FullCover:
            return AnyView(GlazedFullCoverViewModle(Helper: self).environment(\.gluzedSuper, self.id))
        case .EditPopover:
            return AnyView(GlazedPopoverViewModle(Helper: self, edit: true).environment(\.gluzedSuper, self.id))
        case .PopoverWithOutButton:
            return AnyView(GlazedPopoverViewModle(Helper: self, edit: false).environment(\.gluzedSuper, self.id))
        case .tipPopover:
            return AnyView(GlazedPopoverViewModle(Helper: self, edit: true).environment(\.gluzedSuper, self.id))
        case .SharePopover:
            return AnyView(GlazedPopoverViewModle(Helper: self, edit: false).environment(\.gluzedSuper, self.id))
        case .Progres:
            return AnyView(GlazedProgresViewModle(Helper: self).environment(\.gluzedSuper, self.id))
        case .centerPopover:
            return AnyView(GlazedPopoverViewModle(Helper: self, edit: false, center: true).environment(\.gluzedSuper, self.id))
        case .topBottom:
            return AnyView(GlazedPopoverViewModle(Helper: self, edit: true).environment(\.gluzedSuper, self.id))
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if (disTime?.timeIntervalSinceNow ?? 0) > 0 {
            return nil
        } else if event?.type != .hover {
            let hit1 = super.hitTest(point, with: event)
            switch type {
            case .Popover, .topBottom:
                if Viewframe.contains(point) {
                    return hit1
                } else if buttonFrame.contains(point) {
                    return nil
                } else {
                    self.dismissAction()
                    return nil
                }
            case .Sheet:
                return hit1
            case .FullCover:
                return hit1
            case .EditPopover, .PopoverWithOutButton, .centerPopover:
                if Viewframe.contains(point) {
                    return hit1
                } else {
                    self.dismissAction()
                    return nil
                }
            case .tipPopover:
                return nil
            case .Progres, .SharePopover:
                return hit1
            }
        }
        return nil
    }
}

enum GlazedType: Equatable {
    case Popover, Sheet, FullCover, EditPopover, PopoverWithOutButton, tipPopover, SharePopover, centerPopover, topBottom
    case Progres
}
