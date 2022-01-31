//
//  FanChartView.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 03/01/2022.
//

import SwiftUI

public struct FanChartView: View {
    public init(data: [FanChartData],
                  hAxisModel: AxisModel = AxisModel(),
                  vAxisModel: AxisModel = AxisModel(),
                  isLegendLeading: Bool = true,
                  showVAxis: Bool = true,
                  showHAxis: Bool = true) {
        self.data = data
        self.hAxisModel = hAxisModel
        self.vAxisModel = vAxisModel
        self.isLegendLeading = isLegendLeading
        self.showVAxis = showVAxis
        self.showHAxis = showHAxis
    }


    let data: [FanChartData]
    let hAxisModel: AxisModel
    let vAxisModel: AxisModel

    var isLegendLeading = true

    var showVAxis = true
    var showHAxis = true

    var lineAnimation: Animation = .easeInOut(duration: 1)

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

    @State private var completion: CGFloat = 0

    public var body: some View {
        GeometryReader { info in
            ZStack {
                ForEach(data.indices) { index in
                    ZStack {
                        FanShape(data: data[index],
                                 minXPoint: minX,
                                 maxXPoint: maxX,
                                 minYPoint: minY,
                                 maxYPoint: maxY)
                            .stroke(.blue)

                        FanShape(data: data[index],
                                 minXPoint: minX,
                                 maxXPoint: maxX,
                                 minYPoint: minY,
                                 maxYPoint: maxY)
                            .fill(LinearGradient(colors: data[index].colors, startPoint: .bottom, endPoint: .top))
                    }
                }
                .padding(chartEdgeInsets(in: info.frame(in: .local)))

                AxisView(minMax: MinMax(minY: minY, maxY: maxY,
                                        minX: minX, maxX: maxX),
                         isLegendLeading: isLegendLeading,
                         hAxisModel: hAxisModel,
                         showHAxis: showHAxis,
                         vAxisModel: vAxisModel,
                         showVAxis: showVAxis)
            }
        }
        .onAppear {
            withAnimation(lineAnimation) {
                self.completion = 1
            }
        }
    }


    private func chartEdgeInsets(in frame: CGRect) -> EdgeInsets {
        let vSize = vAxisModel.axisSize(in: frame, isHorizontal: false)
        let hSize = hAxisModel.axisSize(in: frame, isHorizontal: true)
        return EdgeInsets(top: 0,
                          leading: isLegendLeading ? hSize : 0,
                          bottom: vSize,
                          trailing: isLegendLeading ? 0 : hSize)
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
