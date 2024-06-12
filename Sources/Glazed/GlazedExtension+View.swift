//
//  GlazedExtension+View.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/25.
//

import SwiftUI
import AudioToolbox

struct TapButtonStyle: ButtonStyle {
    @State var scale:CGFloat = 1
    @State var time:Date = Date()
   
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(x: scale, y: scale)
            .foregroundColor(.accentColor)
            .contentShape(Rectangle())
        #if !os(macOS)
            .hoverEffect(.automatic)
        #endif
            .onChange(of: configuration.isPressed, perform: { newValue in
                if newValue {
                    AudioServicesPlaySystemSound(1519)
                    time = Date()
                    withAnimation(.autoAnimation.speed(2)) {
                        scale = 0.9
                    }
                } else {
                    if time.distance(to: Date()) > 0.15 {
                        AudioServicesPlaySystemSound(1519)
                        withAnimation(.autoAnimation.speed(1.5)) {
                            scale = 1
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.autoAnimation.speed(1.5)) {
                                scale = 1
                            }
                        }
                    }
                    
                }
            })
    }
}

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
                .buttonStyle(TapButtonStyle())
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }))
    }
    func EditPopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .EditPopover, isPresented: isPresented, content1: {
            content()
                .buttonStyle(TapButtonStyle())
                .background(.regularMaterial)
                .clipShape(Capsule(style: .continuous))
        }))
    }
    func topBottomPopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .topBottom, isPresented: isPresented, content1: {
            content()
                .buttonStyle(TapButtonStyle())
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }))
    }
    func clearPopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .Popover, isPresented: isPresented, content1: {
            content()
                .buttonStyle(TapButtonStyle())
        }))
    }
    func PopoverWithOutButton<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .PopoverWithOutButton, isPresented: isPresented, content1: {
            content()
                .buttonStyle(TapButtonStyle())
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                
        }))
    }
    func tipPopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .tipPopover, isPresented: isPresented, content1: {
            content()
                .buttonStyle(TapButtonStyle())
                .background(.regularMaterial)
                .clipShape(Capsule(style: .continuous))
        }))
    }
    func SharePopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(GlazedInputViewModle(type: .SharePopover, isPresented: isPresented, content1: {
            content()
                .buttonStyle(TapButtonStyle())
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
                    .buttonStyle(TapButtonStyle())
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                    
            }))
    }
    func fullPopover<Content: View>(isPresented: Binding<Bool>, ignorTouch:Bool = false, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .scaleEffect(x: isPresented.wrappedValue ? 0.95 : 1, y: isPresented.wrappedValue ? 0.95 : 1)
            .blur(radius: isPresented.wrappedValue ? 20 : 0)
            .animation(.autoAnimation, value: isPresented.wrappedValue)
            .modifier(GlazedInputViewModle(type: .fullPopover, isPresented: isPresented, content1: {
                content()
                    .buttonStyle(TapButtonStyle())
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
        case .EditPopover, .tipPopover, .topBottom:
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

struct GlazedInputViewModle<Content1: View>: ViewModifier {
    let type:GlazedType
    @Binding var isPresented:Bool
    @ViewBuilder var content1:() -> Content1
    
    @EnvironmentObject var glazedObserver: GlazedObserver
    
    @Environment(\.gluzedSuper) var gluazedSuper
    
    @State var id: UUID = UUID()
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    GeometryReader { GeometryProxy in
                        let _ = DispatchQueue.main.async {
                            withAnimation(.autoAnimation) {
                                glazedObserver.contentView[id]?.value.content = AnyView(content1())
                            }
                        }
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
                                        case .Popover, .topBottom, .centerPopover:
                                            if !value.Viewframe.contains(point) && !value.buttonFrame.contains(point) {
                                                isPresented = false
                                            }
                                        case .Sheet:
                                            break
                                        case .FullCover:
                                            break
                                        case .EditPopover, .PopoverWithOutButton:
                                            if !value.Viewframe.contains(point) {
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
                                DispatchQueue.main.async(0.01) {
                                    withAnimation(.autoAnimation) {
                                        glazedObserver.contentViewList.append(Helper.id)
                                    }
                                }
                            }
                            .transition(.identity)
                    }
                    .onPreferenceChange(RectPreferenceKey.self, perform: { rect in
                        glazedObserver.contentView[id]?.value.buttonFrame = rect
                    })
                    .onDisappear {
                        glazedObserver.dismiss(helper: id)
                    }
                    .transition(.identity)
                    .allowsHitTesting(false)
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
