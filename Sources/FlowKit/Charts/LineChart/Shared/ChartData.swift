//
//  LineData.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 15/12/2021.
//

import SwiftUI

struct ChartData: Identifiable {
    let id: String
    var xPoints: [Double]
    var yPoints: [Double]
    var lineColors: [Color] = []
    var isCurved = false
    var fillColors: [Color]?

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
