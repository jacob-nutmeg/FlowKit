//
//  LineData.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 15/12/2021.
//

import SwiftUI

public struct ChartData: Identifiable {

    public init(id: String, xPoints: [Double], yPoints: [Double],
                lineColors: [Color] = [], isCurved: Bool = false,
                fillColors: [Color]? = nil) {
        self.id = id
        self.xPoints = xPoints
        self.yPoints = yPoints
        self.lineColors = lineColors
        self.isCurved = isCurved
        self.fillColors = fillColors
    }

    public let id: String
    public var xPoints: [Double]
    public var yPoints: [Double]
    public var lineColors: [Color] = []
    public var isCurved = false
    public var fillColors: [Color]?

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
}

extension Collection where Element == ChartData {

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
