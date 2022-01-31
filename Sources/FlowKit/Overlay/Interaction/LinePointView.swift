//
//  LinePointView.swift
//  FlowKit (iOS)
//
//  Created by Jacob Whitehead on 20/12/2021.
//

import SwiftUI

public struct LinePointView: View {

    public var size: CGFloat = 8
    public var innerColor: Color = .green
    public var outerColor: Color = .green.opacity(0.2)

    public var body: some View {
        ZStack {
            Circle()
                .frame(width: size, height: size)
                .foregroundColor(outerColor)

            Circle()
                .frame(width: size/2, height: size/2)
                .foregroundColor(innerColor)
        }

    }
}

struct LinePointView_Previews: PreviewProvider {
    static var previews: some View {
        LinePointView()
    }
}
