//
//  BarChartData.swift
//  
//
//  Created by Jacob Whitehead on 18/01/2022.
//

import Foundation

public struct BarChartData: Identifiable {
    public let id: String
    public let xPoints: [Double]
    public let yPoints: [Double]
}

extension BarChartData {

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
