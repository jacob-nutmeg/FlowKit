//
//  LineData.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 15/12/2021.
//

import SwiftUI

public protocol LineHighlightData {
    var point: CGPoint { get }
    var size: CGFloat { get }
    var innerColor: Color { get }
    var outerColor: Color? { get }
}

public struct LineChartData: Identifiable {

    public init(id: String, xPoints: [Double], yPoints: [Double],
                highlights: [LineHighlightData] = [],
                lineColors: [Color] = [], isCurved: Bool = false,
                fillColors: [Color]? = nil) {
        self.id = id
        self.xPoints = xPoints
        self.yPoints = yPoints
        self.highlights = highlights
        self.lineColors = lineColors
        self.isCurved = isCurved
        self.fillColors = fillColors
    }

    public let id: String
    public var xPoints: [Double]
    public var yPoints: [Double]
    public var highlights: [LineHighlightData]
    public var lineColors: [Color] = []
    public var isCurved = false
    public var fillColors: [Color]?

    var minMax: MinMax {
        MinMax(minY: minY, maxY: maxY, minX: minY, maxX: maxX)
    }

    var minX: Double {
        xPoints.min() ?? 0
    }

    var maxX: Double {
        xPoints.max() ?? 0
    }

    var minY: Double {
        yPoints.min() ?? 0
    }

    var maxY: Double {
        yPoints.max() ?? 0
    }

    func points(fromXValue xValue: Double) -> ([Double], [Double]) {
        let minIndex = max(0, (xPoints.firstIndex(where: { $0 >= xValue }) ?? 0) - 1)
        let maxIndex = min(xPoints.count - 1, (xPoints.firstIndex(where: { $0 > maxX }) ?? xPoints.count - 1) + 1)
        let xVals = xPoints[minIndex...maxIndex]
        let yVals = yPoints[minIndex...maxIndex]
        return (Array(xVals), Array(yVals))
    }

}

extension Collection where Element == LineChartData {

    func combinedYPoints() -> [Double] {
        flatMap { $0.yPoints }
    }

    func combinedXPoints() -> [Double] {
        flatMap { $0.xPoints }
    }

    func minYPoint() -> Double {
        combinedYPoints().min() ?? 0
    }

    func maxYPoint() -> Double {
        combinedYPoints().max() ?? 0
    }

    func minXPoint() -> Double {
        combinedXPoints().min() ?? 0
    }

    func maxXPoint() -> Double {
        combinedXPoints().max() ?? 0
    }

}
