//
//  GlazedEnvironmentView.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/1.
//

import SwiftUI

public class GlazedObserver: ObservableObject {
    @Published public var view:UIView = UIView()
    var disIDs:[UUID] = []
    
}
public struct GlazedEnvironmentView<Content: View>: View {
    let content:() -> Content
    @StateObject var glazedObserver = GlazedObserver()
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    public var body: some View {
        GlazedEnvironmentViewHelper(content: content)
            .environmentObject(glazedObserver)
            .environment(\.window, glazedObserver.view.window)
            .environment(\.glazedDoAction, { [self] action in
                var id:UUID = UUID()
                let helper = GlazedHelper(type: .Progres, buttonFrame: .zero, view: AnyView(EmptyView())) { [self] in
                    for i in glazedObserver.view.subviews {
                        if let view = i as? GlazedHelper, view.id == id {
                            DispatchQueue.main.async(1) {
                                view.removeFromSuperview()
                            }
                        }
                    }
                } ProgresAction: {
                    await action()
                }
                id = helper.id
                glazedObserver.view.addSubview(helper)
                NSLayoutConstraint.activate([
                    helper.topAnchor.constraint(equalTo: glazedObserver.view.topAnchor, constant: 0),
                    helper.leadingAnchor.constraint(equalTo: glazedObserver.view.leadingAnchor, constant: 0),
                    helper.bottomAnchor.constraint(equalTo: glazedObserver.view.bottomAnchor, constant: 0),
                    helper.trailingAnchor.constraint(equalTo: glazedObserver.view.trailingAnchor, constant: 0)
                ])
            })
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

#Preview {
    GlazedEnvironmentView {
        test()
    }
        .ignoresSafeArea()
}

struct test: View {
    @State var stack = false
    @State var stack2 = false
    @State var stack3 = false
    @Environment(\.glazedDoAction) var glazedDoAction
    
    var body: some View {
        VStack {
//            Button {
//                stack.toggle()
//            } label: {
//                Color.green
//                    .clipShape(Circle())
//                    .frame(width:35, height: 35)
//            }
//            .Popover(isPresented: $stack) {
//                Color.yellow
//                    .frame(width: 100, height: 100)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
            Button {
                glazedDoAction {
                    sleep(100)
                }
//                stack2.toggle()
            } label: {
                Color.green
                    .clipShape(Circle())
                    .frame(width:35, height: 35)
            }
            .Sheet(isPresented: $stack2) {
                Color.clear
                    .frame(maxWidth: 100, maxHeight: 100)
                    .overlay {
                        Button {
                            withAnimation(.autoAnimation) {
                                stack3.toggle()
                            }
                        } label: {
                            (stack3 ? Color.green : .black)
                                .clipShape(Circle())
                                .frame(width:35, height: 35)
                        }
                        .Popover(isPresented: $stack3) {
                            Color.clear
                                .frame(maxWidth: 400, maxHeight: 100)
                        }
                    }
            }
            .frame(maxWidth: 250, maxHeight: 450, alignment: .top)
        }
       
    }
}
