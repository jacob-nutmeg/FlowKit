//
//  AxisTextFormat.swift
//  
//
//  Created by Jacob Whitehead on 11/01/2022.
//

import SwiftUI

public struct AxisTextFormat {
    public init(axisAlignment: Alignment = .center, axisFormatType: ValueFormatType = .value,
                axisTextColor: Color = .gray, axisTextFont: Font = .caption2) {
        self.axisAlignment = axisAlignment
        self.axisFormatType = axisFormatType
        self.axisTextColor = axisTextColor
        self.axisTextFont = axisTextFont
    }

    public let axisAlignment: Alignment
    public let axisFormatType: ValueFormatType
    public let axisTextColor: Color
    public let axisTextFont: Font
}
