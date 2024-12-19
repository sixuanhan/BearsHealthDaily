//
//  SwiftUIView.swift
//  Bears Health Daily
//
//  Created by xuanxuan on 12/19/24.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        HStack {
            Spacer()
            Button("Cancel") {
                print("clicked cancel")
            }
            Spacer()
            Button("Save") {
                print("clicked save")
            }
            Spacer()
        }
    }
}

#Preview {
    SwiftUIView()
}
