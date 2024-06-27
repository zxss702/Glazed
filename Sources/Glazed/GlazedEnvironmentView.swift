//
//  GlazedEnvironmentView.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/1.
//

import SwiftUI

class GlazedHelperType: Identifiable {
    var id: UUID = UUID()
    var type: GlazedType
    var value: GlazedHelperValue
    var hitTest: (CGPoint, GlazedHelperValue) -> Void
    
    var isDismiss = false
    
    init(id: UUID = UUID(), type: GlazedType, value: GlazedHelperValue, hitTest: @escaping (CGPoint, GlazedHelperValue) -> Void, isDismiss: Bool = false) {
        self.id = id
        self.type = type
        self.value = value
        self.hitTest = hitTest
        self.isDismiss = isDismiss
    }
}

public class GlazedObserver: ObservableObject {
    #if !os(macOS)
    @Published var superWindows: UIWindow? = nil
    #endif
    var contentView:[UUID:GlazedHelperType] = [:]
    @Published var contentViewList:[UUID] = []
    @Published var geometry: GeometryProxy?
    
    func dismissLast(last: UUID) {
        if let lastContent = contentView[last], !lastContent.isDismiss {
            switch lastContent.type {
            case .Sheet, .FullCover:
                contentView[last]?.value.isPrisentDismissAction()
                contentView[last]?.isDismiss = true
                if let int = contentViewList.firstIndex(of: last) {
                    withAnimation(.autoAnimation) {
                        _ = contentViewList.remove(at: int)
                    }
                }
                DispatchQueue.main.async(1) { [self] in
                    contentView.removeValue(forKey: last)
                }
            default :
                contentView[last]?.value.isPrisentDismissAction()
                contentView[last]?.value.typeDismissAction()
                contentView[last]?.isDismiss = true
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
    @ObservedObject var glazedObserver:GlazedObserver
    
    func body(content: Content) -> some View {
        
        content
            .environment(\.glazedDoAction) { [self] action in
                let Helper = GlazedHelperType(
                    
                    type: .Progres,
                    value: GlazedHelperValue(
                        buttonFrame: .zero,
                        gluazedSuper: false,
                        content: AnyView(EmptyView()),
                        isPrisentDismissAction: { },
                        progessDoAction: action
                    )) { point, value in
                        
                    }
                glazedObserver.contentView[Helper.id] = Helper
                DispatchQueue.main.async(0.01) {
                    withAnimation(.autoAnimation) {
                        glazedObserver.contentViewList.append(Helper.id)
                    }
                }
            }
            .environment(\.glazedAsyncAction) { [self] action in
                let Helper = GlazedHelperType(
                    
                    type: .Progres,
                    value: GlazedHelperValue(
                        buttonFrame: .zero,
                        gluazedSuper: false,
                        content: AnyView(EmptyView()),
                        isPrisentDismissAction: { },
                        progessAsyncAction: action
                    )) { point, value in
                        
                    }
                glazedObserver.contentView[Helper.id] = Helper
                DispatchQueue.main.async(0.01) {
                    withAnimation(.autoAnimation) {
                        glazedObserver.contentViewList.append(Helper.id)
                    }
                }
            }
    }
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
                    lastContent.hitTest(point, lastContent.value)
                }
            }
            .modifier(GlazedEnvironmentViewModle(glazedObserver: glazedObserver))
            .environmentObject(glazedObserver)
            #if !os(macOS)
            .environment(\.window, glazedObserver.superWindows)
            #endif
            .ignoresSafeArea()
            .environment(\.safeAreaInsets, geometry.safeAreaInsets)
            .onChange(connect: geometry.size) {
                glazedObserver.geometry = geometry
            }
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
                    GlazedInputView(type: Helper.type, helper: Helper, GeometryProxy: geometry, zindex: zindex * 3 + 1)
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
