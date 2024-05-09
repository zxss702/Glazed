//
//  GlazedExtension+View.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

public extension View {
    func Sheet<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .Sheet, isPresented: isPresented, content1: content))
    }
    func FullCover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .FullCover, isPresented: isPresented, content1: content))
    }
    func Popover<Content: View>(isPresented: Binding<Bool>, ignorTouch:Bool = false, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .Popover, isPresented: isPresented, content1: {
            content()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }))
    }
    func EditPopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .EditPopover, isPresented: isPresented, content1: {
            content()
                .background(.regularMaterial)
                .clipShape(Capsule(style: .continuous))
        }))
    }
    func topBottomPopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .topBottom, isPresented: isPresented, content1: {
            content()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }))
    }
    func clearPopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .Popover, isPresented: isPresented, content1: {
            content()
        }))
    }
    func PopoverWithOutButton<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .PopoverWithOutButton, isPresented: isPresented, content1: {
            content()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                
        }))
    }
    func tipPopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .tipPopover, isPresented: isPresented, content1: {
            content()
                .background(.regularMaterial)
                .clipShape(Capsule(style: .continuous))
        }))
    }
    func SharePopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .SharePopover, isPresented: isPresented, content1: {
            content()
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }))
    }
    func centerPopover<Content: View>(isPresented: Binding<Bool>, ignorTouch:Bool = false, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .scaleEffect(x: isPresented.wrappedValue ? 0.95 : 1, y: isPresented.wrappedValue ? 0.95 : 1)
            .blur(radius: isPresented.wrappedValue ? 20 : 0)
            .animation(.spring(), value: isPresented.wrappedValue)
            .modifier(GlazedInputViewModle(type: .centerPopover, isPresented: isPresented, content1: {
                content()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                    
            }))
    }
}

struct GlazedInputViewModle<Content1: View>: ViewModifier {
    let type:GlazedType
    @Binding var isPresented:Bool
    @ViewBuilder var content1:() -> Content1
    
    @EnvironmentObject var glazedObserver: GlazedObserver
    
    @Environment(\.gluzedSuper) var gluazedSuper
    let helperID: UUID = UUID()
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    GeometryReader { GeometryProxy in
                        let _ = {
                            if let int = glazedObserver.Helpers.lastIndex(where: { GlazedHelper in
                                GlazedHelper.superID == helperID && GlazedHelper.disTime == nil
                            }) {
                                glazedObserver.Helpers[glazedObserver.Helpers.count - int - 1].view = AnyView(content1().environmentObject(glazedObserver))
                            }
                        }()
                        Color.clear
                            .onAppear {
                                if !glazedObserver.Helpers.contains(where: { GlazedHelper in
                                    GlazedHelper.superID == helperID &&  GlazedHelper.disTime == nil
                                }) && gluazedSuper == glazedObserver.Helpers.last(where: { GlazedHelper in
                                    GlazedHelper.disTime == nil
                                })?.id, let window = glazedObserver.superWindows?.windowScene {
                                    glazedObserver.Helpers.append(GlazedHelper(
                                        id: helperID,
                                        superHelperID: gluazedSuper,
                                        windowScene: window,
                                        type: type,
                                        buttonFrame: GeometryProxy.frame(in: .global),
                                        view: AnyView(content1().environmentObject(glazedObserver))
                                    ) {
                                        Dismiss()
                                    } dismissisp: {
                                        isPresented = false
                                    })
                                }
                            }
                            .onChange(of: GeometryProxy.frame(in: .global)) { V in
                                if let int = glazedObserver.Helpers.lastIndex(where: { GlazedHelper in
                                    GlazedHelper.superID == helperID && GlazedHelper.disTime == nil
                                }) {
                                    glazedObserver.Helpers[glazedObserver.Helpers.count - int - 1].buttonFrame = V
                                }
                            }
                            .onDisappear {
                                Dismiss2()
                            }
                            .transition(.identity)
                    }
                    .transition(.identity)
                }
            }
    }

    
    func Dismiss() {
        if !glazedObserver.Helpers.contains(where: { GlazedHelper in
            abs(GlazedHelper.disTime?.timeIntervalSinceNow ?? 1) < 0.1
        }) ,let h = glazedObserver.Helpers.last(where: { GlazedHelper in
            GlazedHelper.disTime == nil
        }), h.superID == helperID {
            h.dismiss()
            h.dismissisPAction()
            h.disTime = .now
            h.superRemoveCell(glazedObserver: glazedObserver)
            DispatchQueue.main.async(1) {
                h.removeFromSuperview()
                h.superRemove(glazedObserver: glazedObserver)
            }
        }
    }
    func Dismiss2() {
        if let h = glazedObserver.Helpers.last(where: { GlazedHelper in
            GlazedHelper.superID == helperID && GlazedHelper.disTime == nil
        }) {
            h.dismiss()
            h.dismissisPAction()
            h.disTime = .now
            h.superRemoveCell(glazedObserver: glazedObserver)
            DispatchQueue.main.async(1) {
                h.removeFromSuperview()
                h.superRemove(glazedObserver: glazedObserver)
            }
        }
    }
}

extension GlazedHelper {
    func superRemoveCell(glazedObserver: GlazedObserver) {
        glazedObserver.Helpers.forEach { GlazedHelper in
            if GlazedHelper.superHelperID == id {
                GlazedHelper.dismiss()
                GlazedHelper.dismissisPAction()
                GlazedHelper.disTime = .now
                GlazedHelper.superRemoveCell(glazedObserver: glazedObserver)
                DispatchQueue.main.async(1) {
                    GlazedHelper.removeFromSuperview()
                    GlazedHelper.superRemove(glazedObserver: glazedObserver)
                }
            }
        }
    }
    func superRemove(glazedObserver: GlazedObserver) {
        glazedObserver.Helpers.removeAll { GlazedHelper in
            if GlazedHelper.id == id {
                GlazedHelper.removeFromSuperview()
            }
            return GlazedHelper.id == id
        }
    }
}


extension Animation {
    public static var autoAnimation = autoAnimation(speed: 1)
    
    public static func autoAnimation(speed: CGFloat = 1) -> Animation {
        if #available(iOS 17.0, *) {
            return .snappy
        } else {
            return .spring().speed(speed)
        }
    }
}
