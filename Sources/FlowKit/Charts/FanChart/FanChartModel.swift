//
//  FanChartModel.swift
//  
//
//  Created by Jacob Whitehead on 21/02/2022.
//

import SwiftUI
import Combine

public class FanChartModel: ObservableObject {

    let data: [FanChartData]

    let xAxisModel: AxisModel
    let yAxisModel: AxisModel
    let isLegendLeading: Bool
    let showXAxis: Bool
    let showYAxis: Bool

    lazy var minMax: MinMax = {
        MinMax(minY: data.minYPoint(), maxY: data.maxYPoint(),
               minX: data.minXPoint(), maxX: data.maxXPoint())
    }()

    public init(data: [FanChartData],
         xAxisModel: AxisModel = AxisModel(),
         yAxisModel: AxisModel = AxisModel(),
         isLegendLeading: Bool = true,
         showXAxis: Bool = true,
         showYAxis: Bool = true) {
        self.data = data
        self.xAxisModel = xAxisModel
        self.yAxisModel = yAxisModel
        self.isLegendLeading = isLegendLeading
        self.showXAxis = showXAxis
        self.showYAxis = showYAxis
    }

    func closestIndex(to location: CGPoint?, frame: CGRect) -> Int? {
        guard let xLocation = location?.x else {
            return nil
        }

        let proportion = xLocation/frame.width
        let xVal = data.minXPoint() + ((data.maxXPoint() - data.minXPoint()) * proportion)
        let closestElement = data.combinedXPoints().enumerated().min(by: { abs($0.1 - xVal) < abs($1.1 - xVal) } )
        let closestIndex = closestElement?.offset
        return closestIndex
    }

}
