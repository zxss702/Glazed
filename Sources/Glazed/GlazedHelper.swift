//
//  GlazedHelper.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/1.
//

import SwiftUI

class GlazedHelper: UIView, Identifiable, ObservableObject {
    var id: UUID = UUID()
    var type:GlazedType
    @Published var buttonFrame:CGRect
    @Published var Viewframe:CGRect = .zero
    @Published var ViewSize:CGSize = .zero
    
    @Published var view: AnyView
    
    @Published var offsetY:CGFloat = 0
    @Published var offsetX:CGFloat = 0
    
    var dismiss:() -> Void = {}
    
    var dismissAction:() -> Void
    
    var ProgresAction:() async -> Void
    var HostVC:UIHostingController<AnyView>?
    
    init(id: UUID = UUID(), type: GlazedType, buttonFrame: CGRect, view: AnyView, offsetY: CGFloat = 0, offsetX: CGFloat = 0, dismiss: @escaping () -> Void, ProgresAction: @escaping () async -> Void = {}) {
        self.id = id
        self.type = type
        self.buttonFrame = buttonFrame
        self.view = view
        self.offsetY = offsetY
        self.offsetX = offsetX
        self.ProgresAction = ProgresAction
        self.dismissAction = dismiss
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
            return AnyView(GlazedPopoverViewModle(Helper: self, edit: false).environment(\.window, window))
        case .Sheet:
            return AnyView(GlazedSheetViewModle(Helper: self).environment(\.window, window))
        case .FullCover:
            return AnyView(GlazedFullCoverViewModle(Helper: self).environment(\.window, window))
        case .EditPopover:
            return AnyView(GlazedPopoverViewModle(Helper: self, edit: true).environment(\.window, window))
        case .PopoverWithOutButton:
            return AnyView(GlazedPopoverViewModle(Helper: self, edit: false).environment(\.window, window))
        case .tipPopover:
            return AnyView(GlazedPopoverViewModle(Helper: self, edit: true).environment(\.window, window))
        case .SharePopover:
            return AnyView(GlazedPopoverViewModle(Helper: self, edit: false).environment(\.window, window))
        case .Progres:
            return AnyView(GlazedProgresViewModle(Helper: self).environment(\.window, window))
        case .centerPopover:
            return AnyView(GlazedPopoverViewModle(Helper: self, edit: false, center: true).environment(\.window, window))
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit1 = super.hitTest(point, with: event)
        if event?.type != .hover {
            if Viewframe == .zero && type != .Sheet {
                return nil
            } else {
                if type == .Sheet {
                    return hit1
                } else if type == .EditPopover || type == .PopoverWithOutButton {
                    if Viewframe.contains(point) {
                        return hit1
                    } else {
                        self.dismiss()
                        return nil
                    }
                } else if type == .tipPopover, case .Progres = type {
                    return nil
                } else if type == .SharePopover {
                    return hit1
                } else {
                    if Viewframe.contains(point) {
                        return hit1
                    } else {
                        if !buttonFrame.contains(point) {
                            self.dismissAction()
                        }
                        return nil
                    }
                }
            }
        } else {
            return nil
        }
    }
}

enum GlazedType: Equatable {
    case Popover, Sheet, FullCover, EditPopover, PopoverWithOutButton, tipPopover, SharePopover, centerPopover
    case Progres
}
