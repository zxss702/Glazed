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
    func clearPopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .EditPopover, isPresented: isPresented, content1: {
            content()
        }))
    }
    func PopoverWithOutButton<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .PopoverWithOutButton, isPresented: isPresented, content1: content))
    }
    func tipPopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .tipPopover, isPresented: isPresented, content1: content))
    }
    func SharePopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .SharePopover, isPresented: isPresented, content1: content))
    }
    func centerPopover<Content: View>(isPresented: Binding<Bool>, ignorTouch:Bool = false, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .scaleEffect(x: isPresented.wrappedValue ? 0.8 : 1, y: isPresented.wrappedValue ? 0.8 : 1)
            .opacity(isPresented.wrappedValue ? 0 : 1)
            .animation(.spring(), value: isPresented.wrappedValue)
            .modifier(GlazedInputViewModle(type: .centerPopover, isPresented: isPresented, content1: content))
    }
}

struct GlazedInputViewModle<Content1: View>: ViewModifier {
    let type:GlazedType
    @Binding var isPresented:Bool
    @ViewBuilder var content1:() -> Content1
    
    @EnvironmentObject var glazedObserver: GlazedObserver
    
    @State var helper:GlazedHelper?
    
    func body(content: Content) -> some View {
        let _ = helper?.view = AnyView(content1().environmentObject(glazedObserver))
        content
            .overlay {
                GeometryReader { GeometryProxy in
                    Color.clear
                        .onChange(of: GeometryProxy.frame(in: .global)) { V in
                            helper?.buttonFrame = V
                        }
                        .onChange(connect: isPresented) {
                            if isPresented {
                                helper?.dismissAction()
                                let helper = GlazedHelper(type: type, buttonFrame: GeometryProxy.frame(in: .global), view: AnyView(content1().environmentObject(glazedObserver))) {
                                    Dismiss()
                                }
                                self.helper = helper
                                glazedObserver.view.addSubview(helper)
                                NSLayoutConstraint.activate([
                                    helper.topAnchor.constraint(equalTo: glazedObserver.view.topAnchor, constant: 0),
                                    helper.leadingAnchor.constraint(equalTo: glazedObserver.view.leadingAnchor, constant: 0),
                                    helper.bottomAnchor.constraint(equalTo: glazedObserver.view.bottomAnchor, constant: 0),
                                    helper.trailingAnchor.constraint(equalTo: glazedObserver.view.trailingAnchor, constant: 0)
                                ])
                            } else {
                                helper?.dismissAction()
                            }
                        }
                }
            }
    }
    
    func Dismiss() {
        if let h = helper {
            helper?.dismiss()
            helper = nil
            DispatchQueue.main.async(1) {
                h.removeFromSuperview()
            }
            DispatchQueue.main.async(0.1) {
                isPresented = false
            }
        }
    }
}
