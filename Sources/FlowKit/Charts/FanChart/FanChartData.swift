//
//  FanChartData.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 03/01/2022.
//

import SwiftUI

public struct FanChartData: Identifiable {
    public init(id: String, xValues: [Double], firstYValues: [Double], secondYValues: [Double], colors: [Color]) {
        self.id = id
        self.xValues = xValues
        self.firstYValues = firstYValues
        self.secondYValues = secondYValues
        self.colors = colors
    }

    public let id: String
    public let xValues: [Double]
    public let firstYValues: [Double]
    public let secondYValues: [Double]
    public let colors: [Color]

    var minX: Double {
        xValues.min() ?? 0
    }

    var maxX: Double {
        xValues.max() ?? 0
    }

    var yPoints: [Double] {
        (firstYValues + secondYValues)
    }

    var minY: Double {
        yPoints.min() ?? 0
    }

    var maxY: Double {
        yPoints.max() ?? 0
    }
}

extension Collection where Element == FanChartData {

    func combinedYPoints() -> [Double] {
        flatMap { $0.yPoints }
    }

    func combinedXPoints() -> [Double] {
        flatMap { $0.xValues }
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
