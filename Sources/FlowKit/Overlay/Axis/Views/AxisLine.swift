//
//  SwiftUIView.swift
//  
//
//  Created by Jacob Whitehead on 10/01/2022.
//

import SwiftUI

public struct AxisLine: View {

    public var from: CGPoint
    public var to: CGPoint
    public var style: AxisLineStyle

    private var strokeStyle: StrokeStyle {
        let dash: [CGFloat]
        switch style.lineStyle {
        case .dashed(let array):
            dash = array
        case .solid:
            dash = []
        }
        return StrokeStyle(lineWidth: style.width,
                           lineCap: style.lineCap,
                           lineJoin: .bevel,
                           dash: dash)
    }

    public var body: some View {
        Path.line(from: from, to: to)
            .strokedPath(strokeStyle)
            .foregroundColor(style.color)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AxisLine(from: CGPoint(x: 100, y: 100), to: CGPoint(x: 300, y: 100), style: AxisLineStyle())
    }
}
