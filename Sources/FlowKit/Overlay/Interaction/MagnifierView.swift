//
//  MagnifierView.swift
//  FlowKit (iOS)
//
//  Created by Jacob Whitehead on 04/01/2022.
//

import SwiftUI

struct MagnifierModel {
    struct Item: Identifiable {
        let id: String
        let text: Text
        var spacing: CGFloat = 0
    }

    var textItems: [Item]
}

public struct MagnifierView: View {

    public let model: MagnifierModel
    public var maxWidth: CGFloat = 100
    @State private var inset: CGFloat = 0

    public var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: -6)
                .blendMode(.multiply)

            VStack {
                ForEach(model.textItems) {
                    $0.text
                        .multilineTextAlignment(.center)
                        .padding(.bottom, $0.spacing)
                }
            }
            .frame(maxWidth: maxWidth)
            .padding()
        }
        .offset(x: -inset, y: 0)
        .fixedSize(horizontal: true, vertical: false)
        .coordinateSpace(name: "magnifier")
        .overlay(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        inset = 0
                    }
            })
    }
}

struct MagnifierView_Previews: PreviewProvider {
    static var previews: some View {
        MagnifierView(model: MagnifierModel(textItems: [.init(id: "01", text: Text("Hello world")),
                                                        .init(id: "02", text: Text("Here is more text"))]))
    }
}
