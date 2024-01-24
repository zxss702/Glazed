//
//  GlazedEnvironmentView.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/1.
//

import SwiftUI

public class GlazedObserver: ObservableObject {
    public var view:UIView = UIView()
}
public struct GlazedEnvironmentView: View {
    @State var content:AnyView
    @StateObject var glazedObserver = GlazedObserver()
    
    public init(content: AnyView) {
        self.content = content
    }
    public var body: some View {
        GlazedEnvironmentViewHelper(content: content)
            .environmentObject(glazedObserver)
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
    GlazedEnvironmentView(content: AnyView(test()))
        .ignoresSafeArea()
}

struct test: View {
    @State var stack = false
    @State var stack2 = false
    @State var stack3 = false
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
                stack2.toggle()
            } label: {
                Color.green
                    .clipShape(Circle())
                    .frame(width:35, height: 35)
            }
            .Sheet(isPresented: $stack2) {
                Color.yellow
                    .frame(maxWidth: 400, maxHeight: stack3 ? 400 : 100)
                    .overlay {
                        Button {
                            withAnimation(.spring()) {
                                stack3.toggle()
                            }
                            
                        } label: {
                            Color.green
                                .clipShape(Circle())
                                .frame(width:35, height: 35)
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
       
    }
}
