//
//  BarChartModel.swift
//  
//
//  Created by Jacob Whitehead on 18/01/2022.
//

import SwiftUI

public class BarChartModel: ObservableObject {

    public let data: BarChartData
    public let hAxisModel: AxisModel
    public let vAxisModel: AxisModel

    public init(data: BarChartData,
                hAxisModel: AxisModel = AxisModel(),
                vAxisModel: AxisModel = AxisModel()) {
        self.data = data
        self.vAxisModel = vAxisModel
        self.hAxisModel = hAxisModel
        minMax = MinMax(minY: data.minY, maxY: data.maxY,
                        minX: data.minX, maxX: data.maxX)
    }

    @Published var minMax: MinMax

    private func updateData() {
        minMax = MinMax(minY: data.minY, maxY: data.maxY,
                        minX: data.minX, maxX: data.maxX)
    }

}
