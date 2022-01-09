//
//  LinePointView.swift
//  FlowKit (iOS)
//
//  Created by Jacob Whitehead on 20/12/2021.
//

import SwiftUI

struct LinePointView: View {

    var size: CGFloat = 10
    var innerColor: Color = .green
    var outerColor: Color = .green.opacity(0.4)
    var shouldAnimate = true
    var animation: Animation = .linear(duration: 2)
        .delay(1)
        .repeatForever(autoreverses: false)

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Circle()
                .frame(width: size * 3, height: size * 3, alignment: .center)
                .foregroundColor(outerColor)
                .scaleEffect(isAnimating ? 2.5 : 0.001)
                .opacity(isAnimating ? 0.001 : 1)
                .animation(animation)

            Circle()
                .frame(width: size, height: size, alignment: .center)
                .foregroundColor(innerColor)
        }
        .onAppear {
            isAnimating = true
        }

    }
}

struct LinePointView_Previews: PreviewProvider {
    static var previews: some View {
        LinePointView()
    }
}