//
//  FanChartView.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 03/01/2022.
//

import SwiftUI

struct FanChartView: View {
    internal init(data: [FanChartData],
                  hAxisModel: AxisModel = AxisModel(),
                  vAxisModel: AxisModel = AxisModel(),
                  isLegendLeading: Bool = true,
                  showVAxis: Bool = true,
                  showHAxis: Bool = true,
                  chartInset: EdgeInsets = EdgeInsets(top: 16, leading: 0,
                                                      bottom: 60, trailing: 60),
                  verticalInsets: EdgeInsets = EdgeInsets(top: 16, leading: 0,
                                                          bottom: 0, trailing: 60),
                  horizontalInsets: EdgeInsets = EdgeInsets(top: 16, leading: 0,
                                                            bottom: 60, trailing: 0)) {
        self.data = data
        self.hAxisModel = hAxisModel
        self.vAxisModel = vAxisModel
        self.isLegendLeading = isLegendLeading
        self.showVAxis = showVAxis
        self.showHAxis = showHAxis
        self.chartInset = chartInset
        self.verticalInsets = verticalInsets
        self.horizontalInsets = horizontalInsets
    }


    let data: [FanChartData]
    let hAxisModel: AxisModel
    let vAxisModel: AxisModel

    var isLegendLeading = true

    var showVAxis = true
    var showHAxis = true

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
                        .animation(.spring(response: 0.4, dampingFraction: 0.9, blendDuration: 1).delay(delay * Double(index)))
                }
                .padding(chartInset)

                AxisView(minX: minX, maxX: maxX,
                         minY: minY, maxY: maxY,
                         isLegendLeading: isLegendLeading,
                         hAxisModel: hAxisModel,
                         showHAxis: showHAxis,
                         vAxisModel: vAxisModel,
                         showVAxis: showVAxis)
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
    static var data = [PreviewData.likelyFanData,
                       PreviewData.unlikelyFanDataLow,
                       PreviewData.unlikelyFanDataHigh]

    static var previews: some View {
        FanChartView(data: [PreviewData.likelyFanData,
                            PreviewData.unlikelyFanDataLow,
                            PreviewData.unlikelyFanDataHigh])
    }
}
