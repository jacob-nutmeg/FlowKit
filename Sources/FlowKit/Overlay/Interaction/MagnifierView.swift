//
//  MagnifierView.swift
//  FlowKit (iOS)
//
//  Created by Jacob Whitehead on 04/01/2022.
//

import SwiftUI

public struct MagnifierModel {
    public struct Item: Identifiable {
        public let id: String
        public let text: Text
        public var spacing: CGFloat = 0
    }

    public var textItems: [Item]
}

public struct MagnifierView: View {

    public let model: MagnifierModel
    public var maxWidth: CGFloat = 100

    public var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: -6)
                .blendMode(.multiply)

            ZStack(alignment: .top) {
                VStack {
                    ForEach(model.textItems) {
                        $0.text
                            .multilineTextAlignment(.center)
                            .padding(.bottom, $0.spacing)
                    }.padding()
                }
            }
            .frame(maxWidth: maxWidth)

        }
        .fixedSize(horizontal: true, vertical: false)
        .coordinateSpace(name: "magnifier")
    }
}

struct MagnifierView_Previews: PreviewProvider {
    static var previews: some View {
        MagnifierView(model: MagnifierModel(textItems: [.init(id: "01", text: Text("Hello world")),
                                                        .init(id: "02", text: Text("Here is more text"))]))
    }
}
