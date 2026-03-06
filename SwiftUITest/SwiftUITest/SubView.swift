//
//  SubView.swift
//  SwiftUITest
//
//  Created by k-ujiie on 2026/03/04.
//

import SwiftUI

struct SubView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Color.yellow.edgesIgnoringSafeArea(.all)
            Button("閉じる") {
                dismiss()
            }
        }
    }
}
