//
//  LineChart.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 15/12/2021.
//

import SwiftUI

struct LineChart: View {

    let data: [ChartData]

    var animation: Animation = .default
    
    var legendLeading = false

    var showVAxis = true
    var showVValues = true

    var showHAxis = true
    var showHValues = true

    var chartInset: EdgeInsets = EdgeInsets(top: 16, leading: 0,
                                            bottom: 60, trailing: 60)

    var verticalInsets: EdgeInsets = EdgeInsets(top: 16, leading: 0,
                                                bottom: 0, trailing: 60)

    var horizontalInsets: EdgeInsets = EdgeInsets(top: 16, leading: 0,
                                                  bottom: 60, trailing: 0)

    @State var touchLocation: CGPoint = .zero

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

    var body: some View {
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
