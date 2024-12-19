//
//  SwiftUIView.swift
//  Bears Health Daily
//
//  Created by xuanxuan on 12/19/24.
//

import SwiftUI

struct SwiftUIView: View {
//    var actualTimes: [Date]

    var body: some View {
        HStack {
            Button(action: {
//                actualTimes.append(Date())
            }) {
                Label("Add Actual Time", systemImage: "plus")
            }
            Spacer()
            Button(action: {
//                actualTimes.append(Date())
            }) {
                Label("Add Now", systemImage: "clock")
            }
        }
    }
}

#Preview {
    SwiftUIView()
}
