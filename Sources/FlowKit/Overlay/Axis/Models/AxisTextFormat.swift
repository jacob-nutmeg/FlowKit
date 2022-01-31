//
//  AxisTextFormat.swift
//  
//
//  Created by Jacob Whitehead on 11/01/2022.
//

import SwiftUI

public struct AxisTextFormat {
    public init(axisAlignment: Alignment = .center, axisFormatType: ValueFormatType = .value,
                axisTextColor: Color = .gray, axisTextFont: Font = .footnote, rotation: CGFloat = 0) {
        self.axisAlignment = axisAlignment
        self.axisFormatType = axisFormatType
        self.axisTextColor = axisTextColor
        self.axisTextFont = axisTextFont
        self.rotation = rotation
    }

    public let axisAlignment: Alignment
    public let axisFormatType: ValueFormatType
    public let axisTextColor: Color
    public let axisTextFont: Font
    public let rotation: CGFloat

    func formattedValue(from value: Double) -> String {
        switch axisFormatType {
        case .value:
            return "\(value)"
        case .date(let formatter):
            return formatter.string(from: Date(timeIntervalSince1970: value))
        case .number(let formatter):
            return formatter.string(from: NSNumber(value: value)) ?? ""
        case .text(let specifier):
            return "\(value)\(specifier)"
        }
    }

}
