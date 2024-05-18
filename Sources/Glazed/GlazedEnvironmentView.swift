//
//  GlazedEnvironmentView.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/1.
//

import SwiftUI

class GlazedHelperType: Identifiable {
    var content: AnyView
    var id: UUID = UUID()
    var type: GlazedType
    var value: GlazedHelperValue
    var hitTest: (CGPoint, GlazedHelperValue) -> Bool
    
    var isDismiss = false
    
    init(content: AnyView, id: UUID = UUID(), type: GlazedType, value: GlazedHelperValue, hitTest: @escaping (CGPoint, GlazedHelperValue) -> Bool, isDismiss: Bool = false) {
        self.content = content
        self.id = id
        self.type = type
        self.value = value
        self.hitTest = hitTest
        self.isDismiss = isDismiss
    }
}

public class GlazedObserver: ObservableObject {
    @Published var superWindows: UIWindow? = nil
    var contentView:[UUID:GlazedHelperType] = [:]
    @Published var contentViewList:[UUID] = []
    
    func dismissLast(last: UUID) {
        if let lastContent = contentView[last], !lastContent.isDismiss {
            switch lastContent.type {
            case .Sheet, .FullCover:
                lastContent.value.isPrisentDismissAction()
                if let int = contentViewList.firstIndex(of: last) {
                    withAnimation(.autoAnimation) {
                        _ = contentViewList.remove(at: int)
                    }
                }
                DispatchQueue.main.async(1) { [self] in
                    contentView.removeValue(forKey: last)
                }
            default :
                lastContent.value.isPrisentDismissAction()
                lastContent.value.typeDismissAction()
                lastContent.isDismiss = true
                DispatchQueue.main.async(1) { [self] in
                    if let int = contentViewList.firstIndex(of: last) {
                        contentViewList.remove(at: int)
                    }
                    DispatchQueue.main.async(0.1) { [self] in
                        contentView.removeValue(forKey: last)
                    }
                }
            }
        }
    }
    
    func dismiss(helper: UUID) {
        dismissLast(last: helper)
    }
}

struct GlazedEnvironmentViewModle: ViewModifier {
//    @State var window: GlazedHelper? = nil
    @ObservedObject var glazedObserver:GlazedObserver
    
    func body(content: Content) -> some View {
        
        content
            .environment(\.glazedDoAction) { [self] action in
                
                let Helper = GlazedHelperType(
                    content: AnyView(EmptyView()),
                    type: .Progres,
                    value: GlazedHelperValue(
                        buttonFrame: .zero,
                        gluazedSuper: false,
                        isPrisentDismissAction: { },
                        progessDoAction: action
                    )) { point, value in
                        return true
                    }
                glazedObserver.contentView[Helper.id] = Helper
                DispatchQueue.main.async(0.01) {
                    withAnimation(.autoAnimation) {
                        glazedObserver.contentViewList.append(Helper.id)
                    }
                }
            }
    }
//    func dismiss() {
//        var helper = window
//        if window != nil {
//            window = nil
//            helper?.isDis = true
//            DispatchQueue.main.async(1) {
//                helper = nil
//            }
//        }
//    }
}
public struct GlazedEnvironmentView<Content: View>: View {
    let content:() -> Content
    @StateObject var glazedObserver = GlazedObserver()
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { geometry in
            GlazedEnvironmentViewHelper {
                GlazedEnvironmentViewCell(content: content, geometry: geometry)
            } hitTest: { point in
                if
                    let last = glazedObserver.contentViewList.last(where: { UUID in
                        !(glazedObserver.contentView[UUID]?.isDismiss ?? false)
                    }),
                    let lastContent = glazedObserver.contentView[last]
                {
                   return lastContent.hitTest(point, lastContent.value)
                }
                return true
            }
            .modifier(GlazedEnvironmentViewModle(glazedObserver: glazedObserver))
            .environmentObject(glazedObserver)
            .environment(\.window, glazedObserver.superWindows)
            .ignoresSafeArea()
            .environment(\.safeAreaInsets, geometry.safeAreaInsets)
        }
    }
}
struct GlazedEnvironmentViewCell<Content: View>: View {
    @EnvironmentObject var glazedObserver:GlazedObserver
    @ViewBuilder var content:() -> Content
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            content()
            ForEach(glazedObserver.contentViewList, id: \.self) { view in
                let zindex = glazedObserver.contentViewList.firstIndex(of: view) ?? 10000
                if let Helper = glazedObserver.contentView[view] {
                    GlazedInputView(type: Helper.type, helper: Helper, content: Helper.content, GeometryProxy: geometry, zindex: zindex * 3 + 1)
                        .environment(\.gluzedSuper, view)
                        .environment(\.glazedDismiss, {
                            glazedObserver.dismiss(helper: view)
                        })
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
extension View{
    @ViewBuilder
    func onChange(connect:some Equatable,action:@escaping () -> Void) -> some View {
        self
            .onAppear {
                action()
            }
            .onChange(of: connect){ newValue in
                action()
            }
    }
}

extension DispatchQueue {
    func async(_ name: String = "async", Action: @escaping () throws -> Void) {
        self.async(execute: DispatchWorkItem(block: {
            do {
                try Action()
            } catch {
                print(error)
            }
//            print(name)
        }))
    }
    func async(_ wate: Double = 0, name: String = "async", Action: @escaping () throws -> Void) {
        self.asyncAfter(deadline: .now() + wate) {
            do {
                try Action()
            } catch {
                print(error)
            }
//            print(name)
        }
    }
}

extension View {
    func ifMode(@ViewBuilder ifAction: (AnyView) -> some View) -> some View {
        ifAction(AnyView(self))
    }
    
    @ViewBuilder
    func provided(_ Bool: Bool, _ ifAction: (AnyView) -> some View, else elseAction: (AnyView) -> some View = { AnyView in return AnyView}) -> some View {
        if Bool {
            ifAction(AnyView(self))
        } else {
            elseAction(AnyView(self))
        }
    }
    
    func shadow(Ofset: CGPoint = .zero) -> some View {
        self
            .shadow(radius: 0.3)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.2), radius: 35, x: Ofset.x, y: Ofset.y)
    }
    func shadow(size: CGFloat, Ofset: CGPoint = .zero) -> some View {
        self
            .shadow(radius: size, x: Ofset.x, y: Ofset.y)
    }
    func shadow(color: Color, size: CGFloat, Ofset: CGPoint = .zero) -> some View {
        self
            .shadow(color: color, radius: size, x: Ofset.x, y: Ofset.y)
    }
}
