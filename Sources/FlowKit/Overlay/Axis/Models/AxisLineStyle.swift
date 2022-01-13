//
//  AxisLineStyle.swift
//  
//
//  Created by Jacob Whitehead on 13/01/2022.
//

import SwiftUI

public struct AxisLineStyle {
    public init(lineStyle: LineStyle = .solid, color: Color = .gray.opacity(0.8),
                width: CGFloat = 2, lineCap: CGLineCap = .round) {
        self.lineStyle = lineStyle
        self.color = color
        self.width = width
        self.lineCap = lineCap
    }

    public var lineStyle: LineStyle = .solid
    public var color: Color = .gray.opacity(0.8)
    public var width: CGFloat = 2
    public var lineCap: CGLineCap = .round
}
