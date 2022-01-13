//
//  LineChart.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 15/12/2021.
//

import SwiftUI

public struct LineChart: View {
    public init(model: LineChartModel,
                animation: Animation = .default,
                isLegendLeading: Bool = false,
                showVAxis: Bool = true, showHAxis: Bool = true,
                dynamicAxisAnimation: Animation = .interactiveSpring(response: 0.6, dampingFraction: 0.98, blendDuration: 0.5)) {
        self.model = model
        self.animation = animation
        self.isLegendLeading = isLegendLeading
        self.showVAxis = showVAxis
        self.showHAxis = showHAxis
        self.dynamicAxisAnimation = dynamicAxisAnimation
    }

    @ObservedObject private var model: LineChartModel

    public var animation: Animation

    private let isLegendLeading: Bool
    private let showVAxis: Bool
    private let showHAxis: Bool

    private let dynamicAxisAnimation: Animation

    @State public var touchLocation: CGPoint = .zero

    public var body: some View {
        GeometryReader { info in
            ZStack {
                Lines(data: model.data,
                      tapLocation: $touchLocation,
                      minXPoint: $model.minX,
                      maxXPoint: $model.maxX,
                      minYPoint: $model.minY,
                      maxYPoint: $model.maxY,
                      lineAnimation: animation)
                    .animation(dynamicAxisAnimation)
                    .padding(chartEdgeInsets(in: info.frame(in: .local)))

                AxisView(minX: model.minX, maxX: model.maxX,
                         minY: model.minY, maxY: model.maxY,
                         isLegendLeading: isLegendLeading,
                         hAxisModel: model.hAxisModel,
                         showHAxis: showHAxis,
                         vAxisModel: model.vAxisModel,
                         showVAxis: showVAxis)
            }
        }
    }

    private func chartInset(in frame: CGRect) -> CGFloat {
        model.vAxisModel.axisSize(in: frame, isHorizontal: false)
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

struct LineChart_Previews: PreviewProvider {

    static var model = LineChartModel(data: [PreviewData.potValueData], portion: .from(PreviewData.threeMonthsAgo))

    static var previews: some View {
        LineChart(model: model)
    }
}
