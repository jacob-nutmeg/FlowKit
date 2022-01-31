//
//  BarChart.swift
//  
//
//  Created by Jacob Whitehead on 16/01/2022.
//

import SwiftUI

public struct BarChart: View {
    public init(model: BarChartModel,
                isLegendLeading: Bool = true,
                showVAxis: Bool = true, showHAxis: Bool = true) {
        self.model = model
        self.isLegendLeading = isLegendLeading
        self.showVAxis = showVAxis
        self.showHAxis = showHAxis
    }


    @ObservedObject var model: BarChartModel

    private let isLegendLeading: Bool
    private let showVAxis: Bool
    private let showHAxis: Bool

    public var body: some View {
        ZStack {
            GeometryReader { info in

                HStack(spacing: 8) {
                    ForEach(model.data.xPoints, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundColor(.blue)
                    }
                }.padding(chartEdgeInsets(in: info.frame(in: .local)))
            }

            AxisView(minMax: model.minMax,
                     isLegendLeading: isLegendLeading,
                     hAxisModel: model.hAxisModel, showHAxis: showHAxis,
                     vAxisModel: model.vAxisModel, showVAxis: showVAxis)
        }
    }

    private func chartEdgeInsets(in frame: CGRect) -> EdgeInsets {
        let vSize = model.vAxisModel.axisSize(in: frame, isHorizontal: false)
        let hSize = model.hAxisModel.axisSize(in: frame, isHorizontal: true)
        return EdgeInsets(top: 0,
                          leading: isLegendLeading ? hSize : 0,
                          bottom: vSize,
                          trailing: isLegendLeading ? 0 : hSize)
    }
}

struct BarChart_Previews: PreviewProvider {
    static let vAxisText = AxisTextFormat(rotation: 90)
    static let vAxisModel = AxisModel(axisTextFormat: vAxisText, valueLineLength: .constant(0))
    static let hAxisModel = AxisModel(valueLineLength: .constant(0))
    static var previews: some View {
        BarChart(model: BarChartModel(data: PreviewData.barData, hAxisModel: hAxisModel, vAxisModel: vAxisModel))
    }
}
