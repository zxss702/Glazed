//
//  GlazedExtension+View.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI

public extension View {
    func Sheet<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .modifier(GlazedInputViewModle(type: .Sheet, isPresented: isPresented, content1: content))
    }
    func FullCover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .FullCover, isPresented: isPresented, content1: content))
    }
    func Popover<Content: View>(isPresented: Binding<Bool>, ignorTouch:Bool = false, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .Popover, isPresented: isPresented, content1: {
            content()
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 26.5, style: .continuous))
        }))
    }
    func EditPopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .EditPopover, isPresented: isPresented, content1: {
            content()
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 26.5, style: .continuous))
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
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 26.5, style: .continuous))
                
        }))
    }
    func tipPopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .tipPopover, isPresented: isPresented, content1: {
            content()
                .background(.background)
                .clipShape(Capsule(style: .continuous))
        }))
    }
    func SharePopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .SharePopover, isPresented: isPresented, content1: {
            content()
                .clipShape(RoundedRectangle(cornerRadius: 26.5, style: .continuous))
        }))
    }
    func centerPopover<Content: View>(isPresented: Binding<Bool>, ignorTouch:Bool = false, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .scaleEffect(x: isPresented.wrappedValue ? 0.95 : 1, y: isPresented.wrappedValue ? 0.95 : 1)
            .blur(radius: isPresented.wrappedValue ? 20 : 0)
            .animation(.spring(), value: isPresented.wrappedValue)
            .modifier(GlazedInputViewModle(type: .centerPopover, isPresented: isPresented, content1: {
                content()
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 26.5, style: .continuous))
            }))
    }
    func centerClearPopover<Content: View>(isPresented: Binding<Bool>, ignorTouch:Bool = false, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .scaleEffect(x: isPresented.wrappedValue ? 0.95 : 1, y: isPresented.wrappedValue ? 0.95 : 1)
            .blur(radius: isPresented.wrappedValue ? 20 : 0)
            .animation(.spring(), value: isPresented.wrappedValue)
            .modifier(GlazedInputViewModle(type: .centerPopover, isPresented: isPresented, content1: {
                content()
            }))
    }
    func fullPopover<Content: View>(isPresented: Binding<Bool>, ignorTouch:Bool = false, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .scaleEffect(x: isPresented.wrappedValue ? 0.95 : 1, y: isPresented.wrappedValue ? 0.95 : 1)
            .blur(radius: isPresented.wrappedValue ? 20 : 0)
            .animation(.spring(), value: isPresented.wrappedValue)
            .modifier(GlazedInputViewModle(type: .fullPopover, isPresented: isPresented, content1: {
                content()
                    .background(.background)
                    .clipped()
            }))
    }
}

struct GlazedInputView: View {
    let type: GlazedType
    let helper: GlazedHelperType
    
    let GeometryProxy: GeometryProxy
    let zindex:Int
    
    var body: some View {
        switch type {
        case .Popover, .SharePopover, .PopoverWithOutButton:
            GlazedPopoverViewModle(value: helper.value, edit: false, GeometryProxy: GeometryProxy)
                .zIndex(Double(zindex))
        case .Sheet:
            GlazedSheetViewModle(value: helper.value, GeometryProxy: GeometryProxy, zindex: zindex)
        case .FullCover:
            GlazedFullCoverViewModle(value: helper.value, zindex: zindex, GeometryProxy: GeometryProxy)
        case .EditPopover, .tipPopover:
            GlazedPopoverViewModle(value: helper.value, edit: true, GeometryProxy: GeometryProxy)
                .zIndex(Double(zindex))
        case .Progres:
            GlazedProgresViewModle(value: helper.value)
                .zIndex(10000000000)
        case .centerPopover:
            GlazedPopoverViewModle(value: helper.value, edit: false, center: true, GeometryProxy: GeometryProxy)
                .zIndex(Double(zindex))
        case .fullPopover:
            GlazedFullPopoverViewModle(value: helper.value, GeometryProxy: GeometryProxy)
                .zIndex(Double(zindex))
        }
    }
}
#if os(macOS)
func animation(animation: @escaping () -> Void, completion: @escaping (Bool) -> Void = {_ in }) {
    let animationn = NSViewAnimation(duration: 0.4, animationCurve: .linear)
    animationn.start()
    animation()
    animationn.stop()
    completion(true)
}
#else
@MainActor func animation(animation: @escaping () -> Void, completion: @escaping (Bool) -> Void = {_ in }) {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.825, initialSpringVelocity: 0.6, options: UIView.AnimationOptions.allowUserInteraction, animations: animation, completion: completion)
}
#endif
struct GlazedInputViewModle<Content1: View>: ViewModifier {
    
    let type:GlazedType
    @Binding var isPresented:Bool
    @ViewBuilder var content1:() -> Content1
    
    @EnvironmentObject var glazedObserver: GlazedObserver
    
    @Environment(\.gluzedSuper) var gluazedSuper
    
    @State var id: UUID = UUID()
    @State var viewFrame:CGRect = .zero
    func body(content: Content) -> some View {
        let _ = {
            if isPresented {
                glazedObserver.contentView[id]?.value.content.rootView = AnyView(content1())
                glazedObserver.contentView[id]?.value.objectWillChange.send()
            }
        }()
        
        content
            .overlay {
                if isPresented {
                    GeometryReader { GeometryProxy in
                        Color.clear
                            .preference(key: RectPreferenceKey.self, value: GeometryProxy.frame(in: .global))
                            .onAppear {
                                glazedObserver.dismiss(helper: id)
                                id = UUID()
                                let Helper = GlazedHelperType(
                                    id: id,
                                    type: type,
                                    value: GlazedHelperValue(
                                        buttonFrame: GeometryProxy.frame(in: .global),
                                        gluazedSuper: gluazedSuper == nil,
                                        content: AnyView(content1()),
                                        isPrisentDismissAction: {
                                            isPresented = false
                                        }
                                    )) { point, value in
                                        switch type {
                                        case .Popover, .centerPopover:
                                            if !value.Viewframe.padding(8).contains(point) && !value.buttonFrame.padding(8).contains(point) {
                                                isPresented = false
                                            }
                                        case .Sheet:
                                            break
                                        case .FullCover:
                                            break
                                        case .EditPopover, .PopoverWithOutButton:
                                            if !value.Viewframe.padding(8).contains(point) {
                                                isPresented = false
                                            }
                                        case .tipPopover:
                                            break
                                        case .Progres, .SharePopover:
                                            break
                                        case .fullPopover:
                                            break
                                        }
                                    }
                                glazedObserver.contentView[id] = Helper
                                glazedObserver.contentView[id]?.value.content.sizingOptions = .intrinsicContentSize
                                
                                DispatchQueue.main.async(0.00001) {
                                    withAnimation(.autoAnimation) {
                                        glazedObserver.contentViewList.append(Helper.id)
                                    }
                                }
                            }
                            .onDisappear {
                                glazedObserver.dismiss(helper: id)
                            }
                            .transition(.identity)
                    }
                    .onPreferenceChange(RectPreferenceKey.self, perform: { rect in
                        viewFrame = rect
                        glazedObserver.contentView[id]?.value.buttonFrame = rect
                    })
                    .allowsHitTesting(false)
                    .transition(.identity)
                }
            }
    }
}


extension Animation {
    public static let autoAnimation = autoAnimation(speed: 1)
    
    public static func autoAnimation(speed: CGFloat = 1) -> Animation {
        if #available(iOS 17.0, *) {
            return .bouncy.speed(speed)// .smooth(duration: 0.4)
        } else {
            return .spring().speed(speed)
        }
    }
}

extension CGRect {
    func padding(_ float: CGFloat) -> CGRect {
        return CGRect(x: self.origin.x - float, y: self.origin.y - float, width: self.width + 2 * float, height: self.height + 2 * float)
    }
}
