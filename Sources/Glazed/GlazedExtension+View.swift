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
    
    @State var helper:GlazedHelper?
    
    func body(content: Content) -> some View {
        content
            .shadow(color: isPresented ? Color(.sRGBLinear, white: 0, opacity: 0.2) : .clear, size: 12)
            .animation(.autoAnimation, value: isPresented)
            .overlay {
                GeometryReader { GeometryProxy in
                    let _ = helper?.view = AnyView(content1().environmentObject(glazedObserver))
                    Color.clear
                        .onChange(connect: isPresented) {
                            if isPresented {
                                helper?.dismissAction()
                                let helper = GlazedHelper(type: type, buttonFrame: GeometryProxy.frame(in: .global), view: AnyView(content1().environmentObject(glazedObserver))) {
                                    Dismiss()
                                }
                                glazedObserver.disIDs.append(helper.id)
                                self.helper = helper
                                glazedObserver.view.addSubview(helper)
                                NSLayoutConstraint.activate([
                                    helper.topAnchor.constraint(equalTo: glazedObserver.view.topAnchor, constant: 0),
                                    helper.leadingAnchor.constraint(equalTo: glazedObserver.view.leadingAnchor, constant: 0),
                                    helper.bottomAnchor.constraint(equalTo: glazedObserver.view.bottomAnchor, constant: 0),
                                    helper.trailingAnchor.constraint(equalTo: glazedObserver.view.trailingAnchor, constant: 0)
                                ])
                            } else {
                                Dismiss2()
                            }
                        }
                        .onChange(of: GeometryProxy.frame(in: .global)) { V in
                            helper?.buttonFrame = V
                        }
                        .onDisappear {
                            Dismiss()
                        }
                }
            }
    }
    
    func Dismiss() {
        if glazedObserver.disIDs.last == helper?.id {
            isPresented = false
            if let h = helper {
                helper = nil
                h.dismiss()
                h.isDis = true
                DispatchQueue.main.async(0.1) {
                    glazedObserver.disIDs.removeLast()
                }
                DispatchQueue.main.async(1) {
                    h.removeFromSuperview()
                }
            }
        }
    }
    func Dismiss2() {
        if let int = glazedObserver.disIDs.lastIndex(of: helper?.id ?? UUID()) {
            glazedObserver.disIDs.removeLast(int)
        }
        if let h = helper {
            helper = nil
            h.dismiss()
            h.isDis = true
            DispatchQueue.main.async(1) {
                h.removeFromSuperview()
            }
        }
    }
}



extension Animation {
    static var autoAnimation = autoAnimation(speed: 1)
    
    static func autoAnimation(speed: CGFloat = 1) -> Animation {
        if #available(iOS 17.0, *) {
            return .snappy
        } else {
            return .spring().speed(speed)
        }
    }
}
