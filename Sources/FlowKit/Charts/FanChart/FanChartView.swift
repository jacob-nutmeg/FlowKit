//
//  FanChartView.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 03/01/2022.
//

import SwiftUI

struct FanChartView: View {

    let data: [FanChartData]

    var startFromZero = true

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

    var fillGradient: LinearGradient {
        LinearGradient(colors: [.blue.opacity(0.2)],
                       startPoint: .top, endPoint: .bottom)
    }

    private var maxX: Double {
        data.maxXPoint()
    }

    private var minX: Double {
        data.minXPoint()
    }

    private var maxY: Double {
        data.maxYPoint()
    }

    private var minY: Double {
        data.minYPoint()
    }

    @State private var xMultiplier: CGFloat = 0.75
    @State private var yMultiplier: CGFloat = 0
    var delay: Double = 0.1

    var body: some View {
        GeometryReader { info in
            ZStack {
                ForEach(data.indices) { index in
                    FanShape(data: data[index],
                             minXPoint: minX,
                             maxXPoint: maxX,
                             minYPoint: minY,
                             maxYPoint: maxY,
                             xMultiplier: xMultiplier,
                             yMultiplier: yMultiplier)
                        .fill(LinearGradient(colors: data[index].colors,
                                             startPoint: .top, endPoint: .bottom))
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .animation(.spring(response: 0.4, dampingFraction: 0.9, blendDuration: 1).delay(delay * Double(index)))
                }
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
                        .drawingGroup()
                }

                if showVAxis {
                    AxisOverlay(axisType: .vertical(isLeading: legendLeading),
                                distribution: 3,
                                frame: info.frame(in: .local),
                                insets: verticalInsets,
                                minValue: .constant(minX),
                                maxValue: .constant(maxX),
                                axisSize: 60,
                                axisFormatType: .date(formatter: PreviewData.dateYearFormatter),
                                showValues: showVValues)
                        .drawingGroup()
                }
            }
        }
        .onAppear {
            withAnimation {
                xMultiplier = 1
                yMultiplier = 1
            }
        }
    }

}

struct FanChartView_Previews: PreviewProvider {
    static var previews: some View {
        FanChartView(data: [PreviewData.likelyFanData,
                            PreviewData.unlikelyFanDataLow,
                            PreviewData.unlikelyFanDataHigh])
    }
}
