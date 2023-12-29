//
//  section.swift
//  noteX
//
//  Created by 张旭晟 on 2022/11/19.
//

import SwiftUI

struct section: View {
    var title = ""
    init(title: String = "") {
        self.title = title
    }
    var body: some View {
        HStack{
            Text(title)
                .font(.callout)
                .padding(.top)
                .padding(.leading)
                .foregroundColor(.gray)
            Spacer()
        }
    }
}
