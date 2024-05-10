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

struct GlazedInputView<Content: View>: View {
    let type:GlazedType
    @Binding var value: GlazedHelperValue?
    @Binding var isPresented:Bool
    let gluazedSuper: Bool
    
    @ViewBuilder var content:() -> Content
    @ObservedObject var glazedObserver: GlazedObserver
    
    var body: some View {
            switch type {
            case .Popover, .SharePopover, .PopoverWithOutButton:
                Binding($value).map { value in
                    GlazedPopoverViewModle(value: value, edit: false, gluazedSuper: gluazedSuper, content: content)
                }
                .environment(\.glazedDismiss) {
                    isPresented = false
                }
                .environmentObject(glazedObserver)
            case .Sheet:
                Binding($value).map { value in
                    GlazedSheetViewModle(value: value, content: content)
                }
                .environment(\.glazedDismiss) {
                    isPresented = false
                }
                .environmentObject(glazedObserver)
            case .FullCover:
                Binding($value).map { value in
                    GlazedFullCoverViewModle(value: value, content: content)
                }
                .environment(\.glazedDismiss) {
                    isPresented = false
                }
                .environmentObject(glazedObserver)
            case .EditPopover, .tipPopover, .topBottom:
                Binding($value).map { value in
                    GlazedPopoverViewModle(value: value, edit: true, gluazedSuper: gluazedSuper, content: content)
                }
                .environment(\.glazedDismiss) {
                    isPresented = false
                }
                .environmentObject(glazedObserver)
            case .Progres:
                EmptyView()
            case .centerPopover:
                Binding($value).map { value in
                    GlazedPopoverViewModle(value: value, edit: false, center: true, gluazedSuper: gluazedSuper, content: content)
                }
                .environment(\.glazedDismiss) {
                    isPresented = false
                }
                .environmentObject(glazedObserver)
            }
    }
}

struct GlazedInputViewModle<Content1: View>: ViewModifier {
    let type:GlazedType
    @Binding var isPresented:Bool
    @ViewBuilder var content1:() -> Content1
    
    @EnvironmentObject var glazedObserver: GlazedObserver
    
    @Environment(\.gluzedSuper) var gluazedSuper
    
    @State var value: GlazedHelperValue? = nil
    @State var window: GlazedHelper? = nil
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    GeometryReader { GeometryProxy in
                       let _ = (window?.rootViewController as? UIHostingController<GlazedInputView>)?.rootView = GlazedInputView(type: type, value: $value, isPresented: $isPresented, gluazedSuper: gluazedSuper != nil, content: content1, glazedObserver: glazedObserver)
                        Color.clear
                            .preference(key: RectPreferenceKey.self, value: GeometryProxy.frame(in: .global))
                            .onAppear {
                                dismiss()
                                if let windowScene = glazedObserver.superWindows?.windowScene {
                                    value = GlazedHelperValue(buttonFrame: GeometryProxy.frame(in: .global))
                                    window = GlazedHelper(windowScene: windowScene) {
                                        GlazedInputView(type: type, value: $value, isPresented: $isPresented, gluazedSuper: gluazedSuper != nil, content: content1, glazedObserver: glazedObserver)
                                    } hitTist: { point in
                                        if let value = value {
                                            switch type {
                                            case .Popover, .topBottom:
                                                if value.Viewframe.contains(point) {
                                                    return true
                                                } else if value.buttonFrame.contains(point) {
                                                    return gluazedSuper != nil
                                                } else {
                                                    isPresented = false
                                                    return gluazedSuper != nil
                                                }
                                            case .Sheet:
                                                return true
                                            case .FullCover:
                                                return true
                                            case .EditPopover, .PopoverWithOutButton, .centerPopover:
                                                if value.Viewframe.contains(point) {
                                                    return true
                                                } else {
                                                    isPresented = false
                                                    return gluazedSuper == nil
                                                }
                                            case .tipPopover:
                                                return false
                                            case .Progres, .SharePopover:
                                                return true
                                            }
                                        }
                                        return true
                                    }
                                }
                            }
                            .transition(.identity)
                    }
                    .onPreferenceChange(RectPreferenceKey.self, perform: { rect in
                        value?.buttonFrame = rect
                    })
                    .onDisappear {
                        dismiss()
                    }
                    .transition(.identity)
                }
            }
    }
    func dismiss() {
        var helper = window
        if window != nil , let value = value {
            window = nil
            value.typeDismissAction()
            helper?.isDis = true
            DispatchQueue.main.async(1) {
                helper = nil
            }
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
