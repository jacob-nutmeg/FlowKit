//
//  LineChart.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 15/12/2021.
//

import SwiftUI

public struct LineChart: View {
    public init(data: [ChartData], animation: Animation = .default, legendLeading: Bool = false,
                showVAxis: Bool = true, showVValues: Bool = true, showHAxis: Bool = true, showHValues: Bool = true,
                chartInset: EdgeInsets = EdgeInsets(top: 16, leading: 0, bottom: 60, trailing: 60),
                verticalInsets: EdgeInsets = EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 60),
                horizontalInsets: EdgeInsets = EdgeInsets(top: 16, leading: 0, bottom: 60, trailing: 0)) {
        self.data = data
        self.animation = animation
        self.legendLeading = legendLeading
        self.showVAxis = showVAxis
        self.showVValues = showVValues
        self.showHAxis = showHAxis
        self.showHValues = showHValues
        self.chartInset = chartInset
        self.verticalInsets = verticalInsets
        self.horizontalInsets = horizontalInsets
    }


    public let data: [ChartData]

    public var animation: Animation = .default

    public var legendLeading = false

    public var showVAxis = true
    public var showVValues = true

    public var showHAxis = true
    public var showHValues = true

    public var chartInset: EdgeInsets = EdgeInsets(top: 16, leading: 0,
                                            bottom: 60, trailing: 60)

    public var verticalInsets: EdgeInsets = EdgeInsets(top: 16, leading: 0,
                                                bottom: 0, trailing: 60)

    public var horizontalInsets: EdgeInsets = EdgeInsets(top: 16, leading: 0,
                                                  bottom: 60, trailing: 0)

    @State public var touchLocation: CGPoint = .zero

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

                if showHAxis {
                    AxisOverlay(axisType: .horizontal(isLeading: legendLeading),
                                distribution: 2,
                                frame: info.frame(in: .local),
                                insets: horizontalInsets,
                                minValue: .constant(minY),
                                maxValue: .constant(maxY),
                                axisSize: 60,
                                axisFormatType: .number(formatter: PreviewData.numberFormatter),
                                showValues: showHValues)
                }

                if showVAxis {
                    AxisOverlay(axisType: .vertical(isLeading: legendLeading),
                                distribution: 2,
                                frame: info.frame(in: .local),
                                insets: verticalInsets,
                                minValue: .constant(minX),
                                maxValue: .constant(maxX),
                                axisSize: 60,
                                axisFormatType: .date(formatter: PreviewData.dateFormatter),
                                showValues: showVValues)
                }
            }
        }
    }
}

struct LineChart_Previews: PreviewProvider {

    static var previews: some View {
        LineChart(data: [PreviewData.potValueData])
    }
}
