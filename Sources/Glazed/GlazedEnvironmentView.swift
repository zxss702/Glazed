//
//  GlazedEnvironmentView.swift
//  noteE
//
//  Created by 张旭晟 on 2023/11/1.
//

import SwiftUI

class GlazedObserver: ObservableObject {
    var view:UIView = UIView()
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
