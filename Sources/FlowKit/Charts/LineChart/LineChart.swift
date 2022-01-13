//
//  LineChart.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 15/12/2021.
//

import SwiftUI

public struct LineChart: View {
    public init(data: [LineChartData],
                hAxisModel: AxisModel = AxisModel(),
                vAxisModel: AxisModel = AxisModel(),
                animation: Animation = .easeIn(duration: 2), legendLeading: Bool = false,
                showVAxis: Bool = true, showHAxis: Bool = true,
                chartInset: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 60),
                verticalInsets: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 60),
                horizontalInsets: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0)) {
        self.data = data
        self.animation = animation
        self.hAxisModel = hAxisModel
        self.vAxisModel = vAxisModel
        self.legendLeading = legendLeading
        self.showVAxis = showVAxis
        self.showHAxis = showHAxis
        self.chartInset = chartInset
        self.verticalInsets = verticalInsets
        self.horizontalInsets = horizontalInsets
    }


    public let data: [LineChartData]
    public let hAxisModel: AxisModel
    public let vAxisModel: AxisModel

    public var animation: Animation

    public var legendLeading = false

    public var showVAxis = true
    public var showHAxis = true

    public var chartInset: EdgeInsets = EdgeInsets(top: 0, leading: 0,
                                            bottom: 30, trailing: 60)

    public var verticalInsets: EdgeInsets = EdgeInsets(top: 0, leading: 0,
                                                bottom: 0, trailing: 60)

    public var horizontalInsets: EdgeInsets = EdgeInsets(top: 0, leading: 0,
                                                  bottom: 0, trailing: 0)

    @State public var touchLocation: CGPoint = .zero

    // MARK: - Helpers

    private var maxY: Double {
        data.maxYPoint()
    }

    private var minY: Double {
        data.minYPoint()
    }

    private var maxX: Double {
        data.maxXPoint()
    }

    private var minX: Double {
        data.minXPoint()
    }

    public var body: some View {
        GeometryReader { info in
            ZStack {
                Lines(data: data,
                      tapLocation: $touchLocation,
                      minYPoint: .constant(minY),
                      maxYPoint: .constant(maxY),
                      lineAnimation: animation)
                    .padding(chartInset)

                AxisView(minX: minX, maxX: maxX,
                         minY: minY, maxY: maxY,
                         isLegendLeading: legendLeading,
                         hAxisModel: hAxisModel,
                         showHAxis: showHAxis,
                         vAxisModel: vAxisModel,
                         showVAxis: showVAxis)
            }
        }
    }
}

struct LineChart_Previews: PreviewProvider {

    static var data = [PreviewData.potValueData]

    static var previews: some View {
        LineChart(data: [PreviewData.potValueData])
    }
}
