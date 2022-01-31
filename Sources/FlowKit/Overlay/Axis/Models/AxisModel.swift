//
//  AxisModel.swift
//  
//
//  Created by Jacob Whitehead on 13/01/2022.
//

import SwiftUI

public struct AxisModel {

    public init(title: String = "",
                displayMode: AxisDisplayMode = .all,
                distribution: Int = 3,
                axisSizeType: SizeType = .constant(60),
                axisPaddingProportion: CGFloat = 0.1,
                axisTextFormat: AxisTextFormat = .init(),
                axisLineStyle: AxisLineStyle = .init(lineStyle: .solid, color: .black),
                valueLineStyle: AxisLineStyle = .init(lineStyle: .dashed([8, 8]), color: .gray.opacity(0.5)),
                valueLineLength: SizeType = .proportion(1)) {
        self.title = title
        self.displayMode = displayMode
        self.distribution = distribution
        self.axisSizeType = axisSizeType
        self.axisPaddingProportion = axisPaddingProportion
        self.axisTextFormat = axisTextFormat
        self.axisLineStyle = axisLineStyle
        self.valueLineStyle = valueLineStyle
        self.valueLineLength = valueLineLength
    }

    public let title: String
    public let displayMode: AxisDisplayMode
    public let distribution: Int
    public let axisSizeType: SizeType
    public let axisPaddingProportion: CGFloat
    public let axisTextFormat: AxisTextFormat
    public let axisLineStyle: AxisLineStyle
    public let valueLineStyle: AxisLineStyle
    public let valueLineLength: SizeType
}

// MARK: - Calculated properties

extension AxisModel {

    func legendPoints(minValue: Double, maxValue: Double) -> [Double] {
        var points = [Double]()
        let interval = valueInterval(min: minValue, max: maxValue)
        let padding = paddingValue(min: minValue, max: maxValue)

        for i in 0...distribution - 1 {
            points.append((minValue + padding) + (CGFloat(i) * interval))
        }

        return points
    }

    var showValues: Bool {
        switch displayMode {
        case .all, .justValues: return true
        case .justAxis: return false
        }
    }

    func axisSize(in frame: CGRect, isHorizontal: Bool) -> CGFloat {
        guard displayMode != .justAxis else {
            return 0
        }

        switch axisSizeType {
        case .constant(let size):
            return size
        case .proportion(let proportion):
            return isHorizontal ? frame.size.width * proportion : frame.size.height * proportion
        }
    }

    func frameStep(in frame: CGRect, isHorizontal: Bool, min: Double, max: Double) -> CGFloat {
        let valueRange = valueRange(min: min, max: max)
        guard valueRange > 0 else { return 0 }
        let orientatedSize = (isHorizontal ? frame.height : frame.width)
        let axisPadding = (orientatedSize * axisPaddingProportion) * 2
        return (orientatedSize - axisPadding) / valueRange
    }

    private func valueInterval(min: Double, max: Double) -> CGFloat {
        valueRange(min: min, max: max) / CGFloat(distribution - 1)
    }

    private func valueRange(min: Double, max: Double) -> Double {
        (max - min) - (paddingValue(min: min, max: max) * 2)
    }

    private func paddingValue(min: Double, max: Double) -> CGFloat {
        (max - min) * axisPaddingProportion
    }

}
