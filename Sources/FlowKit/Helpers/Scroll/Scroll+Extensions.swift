//
//  Scroll+Extensions.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 29/12/2021.
//

import SwiftUI

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGPoint

    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

struct ScrollViewOffsetModifier: ViewModifier {
    let coordinateSpace: String
    var onChange: (CGPoint) -> Void

    func body(content: Content) -> some View {
        ZStack {
            content
            GeometryReader { proxy in
                let x = proxy.frame(in: .named(coordinateSpace)).minX
                let y = proxy.frame(in: .named(coordinateSpace)).minY
                Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self,
                                       value: CGPoint(x: x * -1, y: y * -1))
            }
        }
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
            onChange(value)
        }
    }
}

extension View {
    func readingScrollView(from coordinateSpace: String, onChange: @escaping (CGPoint) -> Void) -> some View {
        modifier(ScrollViewOffsetModifier(coordinateSpace: coordinateSpace, onChange: onChange))
    }
}
