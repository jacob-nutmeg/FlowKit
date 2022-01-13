//
//  LineChartModel.swift
//  
//
//  Created by Jacob Whitehead on 13/01/2022.
//

import SwiftUI

public class LineChartModel: ObservableObject {

    public init(data: [LineChartData],
                hAxisModel: AxisModel = AxisModel(),
                vAxisModel: AxisModel = AxisModel(),
                portion: LineChartModel.PortionToShow = .all,
                dataPaddingProportion: CGFloat = 0) {
        self.data = data
        self.hAxisModel = hAxisModel
        self.vAxisModel = vAxisModel
        self.portion = portion
        self.dataPaddingProportion = dataPaddingProportion
        updateData()
    }

    public enum PortionToShow {
        case all
        case from(Double)
    }

    let data: [LineChartData]
    let hAxisModel: AxisModel
    let vAxisModel: AxisModel
    private let dataPaddingProportion: CGFloat
    private var portion: PortionToShow

    @Published var maxY: Double = 0
    @Published var minY: Double = 0
    @Published var maxX: Double = 0
    @Published var minX: Double = 0

    public func updatePortion(to portion: PortionToShow) {
        self.portion = portion
        updateData()
    }

    private func updateData() {
        switch portion {
        case .all:
            minX = data.minXPoint()
            maxX = data.maxXPoint()
            minY = data.minYPoint()
            maxY = data.maxYPoint()
            return
        case .from(let minXVal):
            var yValues = [Double]()
            var xValues = [Double]()

            for dataSet in data {
                let minXVal = minXVal
                let maxXVal = dataSet.maxX

                let minIndex = max(0, (dataSet.xPoints.firstIndex(where: { $0 >= minXVal }) ?? 0) - 1)
                let maxIndex = min(dataSet.xPoints.count - 1, (dataSet.xPoints.firstIndex(where: { $0 > maxXVal }) ?? dataSet.xPoints.count - 1) + 1)

                let xVals = dataSet.xPoints[minIndex...maxIndex]
                let yVals = dataSet.yPoints[minIndex...maxIndex]
                yValues.append(contentsOf: yVals)
                xValues.append(contentsOf: xVals)
            }

            var minYVal = yValues.min() ?? 0
            var maxYVal = yValues.max() ?? 0

            let padding = (maxYVal - minYVal) * dataPaddingProportion
            minYVal -= padding
            maxYVal += padding

            minX = xValues.min() ?? 0
            maxX = xValues.max() ?? 0
            minY = minYVal
            maxY = maxYVal
        }
    }

}
