//
//  LineChartModel.swift
//  
//
//  Created by Jacob Whitehead on 13/01/2022.
//

import Foundation

public struct LineChartModel {
    public let data: [LineChartData]
    public var legendLeading = false
    public var hAxisTextFormat: AxisTextFormat = AxisTextFormat()
    public var vAxisTextFormat: AxisTextFormat = AxisTextFormat()
}
