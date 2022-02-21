//
//  AxisView.swift
//  
//
//  Created by Jacob Whitehead on 13/01/2022.
//

import SwiftUI

public struct AxisView: View {

    let minMax: MinMax
    let isLegendLeading: Bool
    let yAxisModel: AxisModel
    let showYAxis: Bool
    let xAxisModel: AxisModel
    let showXAxis: Bool

    public var body: some View {
        GeometryReader { info in
            ZStack {
                if showYAxis {
                    GeometryReader { localProxy in
                        AxisOverlay(axisType: .horizontal(isLeading: isLegendLeading),
                                    frame: localProxy.frame(in: .local),
                                    minValue: minMax.minY,
                                    maxValue: minMax.maxY,
                                    model: yAxisModel)
                    }.padding(yAxisPadding(in: info.frame(in: .local)))
                }

                if showXAxis {
                    GeometryReader { localProxy in
                        AxisOverlay(axisType: .vertical(isLeading: isLegendLeading),
                                    frame: localProxy.frame(in: .local),
                                    minValue: minMax.minX,
                                    maxValue: minMax.maxX,
                                    model: xAxisModel)
                    }.padding(xAxisPadding(in: info.frame(in: .local)))
                }
            }
        }
        .drawingGroup()
        .allowsHitTesting(false)
    }

    private func xAxisPadding(in frame: CGRect) -> EdgeInsets {
        EdgeInsets(top: 0,
                   leading: isLegendLeading ? yAxisSize(in: frame) : 0,
                   bottom: 0,
                   trailing: isLegendLeading ? 0 : yAxisSize(in: frame))
    }

    private func yAxisPadding(in frame: CGRect) -> EdgeInsets {
        EdgeInsets(top: 0,
                   leading: 0,
                   bottom: xAxisSize(in: frame),
                   trailing: 0)
    }

    private func yAxisSize(in frame: CGRect) -> CGFloat {
        showYAxis ? yAxisModel.axisSize(in: frame, isHorizontal: true) : 0
    }

    private func xAxisSize(in frame: CGRect) -> CGFloat {
        showXAxis ? xAxisModel.axisSize(in: frame, isHorizontal: false) : 0
    }

}

struct AxisView_Previews: PreviewProvider {
    static let data = [PreviewData.potValueData]
    static let hModel = AxisModel(axisPaddingProportion: 0.125,
                                  axisTextFormat: .init(axisFormatType: .number(formatter: PreviewData.numberFormatter)))
    static let vModel = AxisModel(axisPaddingProportion: 0.125,
                                  axisTextFormat: .init(axisFormatType: .date(formatter: PreviewData.dateFormatter)))

    static var previews: some View {
        Group {
            AxisView(minMax: MinMax(minY: data.minYPoint(), maxY: data.minYPoint(),
                                    minX: data.minXPoint(), maxX: data.maxXPoint()),
                     isLegendLeading: false,
                     yAxisModel: hModel,
                     showYAxis: true,
                     xAxisModel: vModel,
                     showXAxis: false)
        }
    }
}
