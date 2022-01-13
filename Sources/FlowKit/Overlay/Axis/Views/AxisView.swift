//
//  AxisView.swift
//  
//
//  Created by Jacob Whitehead on 13/01/2022.
//

import SwiftUI

public struct AxisView: View {

    public let minX: Double
    public let maxX: Double
    public let minY: Double
    public let maxY: Double
    public let isLegendLeading: Bool
    public let hAxisModel: AxisModel
    public let showHAxis: Bool
    public let vAxisModel: AxisModel
    public let showVAxis: Bool

    public var body: some View {
        GeometryReader { info in
            ZStack {
                if showHAxis {
                    GeometryReader { localProxy in
                        AxisOverlay(axisType: .horizontal(isLeading: isLegendLeading),
                                    frame: localProxy.frame(in: .local),
                                    minValue: minY,
                                    maxValue: maxY,
                                    model: hAxisModel)
                    }.padding(hAxisPadding(in: info.frame(in: .local)))
                }

                if showVAxis {
                    GeometryReader { localProxy in
                    AxisOverlay(axisType: .vertical(isLeading: isLegendLeading),
                                frame: localProxy.frame(in: .local),
                                minValue: minX,
                                maxValue: maxX,
                                model: vAxisModel)
                    }.padding(vAxisPadding(in: info.frame(in: .local)))
                }
            }
        }
    }

    private func vAxisPadding(in frame: CGRect) -> EdgeInsets {
        EdgeInsets(top: 0,
                   leading: isLegendLeading ? hAxisSize(in: frame) : 0,
                   bottom: 0,
                   trailing: isLegendLeading ? 0 : hAxisSize(in: frame))
    }

    private func hAxisPadding(in frame: CGRect) -> EdgeInsets {
        EdgeInsets(top: 0,
                   leading: 0,
                   bottom: hAxisSize(in: frame),
                   trailing: 0)
    }

    private func hAxisSize(in frame: CGRect) -> CGFloat {
        showHAxis ? hAxisModel.axisSize(in: frame, isHorizontal: true) : 0
    }

    private func vAxisSize(in frame: CGRect) -> CGFloat {
        showVAxis ? vAxisModel.axisSize(in: frame, isHorizontal: false) : 0
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
            AxisView(minX: data.minXPoint(),
                     maxX: data.maxXPoint(),
                     minY: data.minYPoint(),
                     maxY: data.maxYPoint(),
                     isLegendLeading: false,
                     hAxisModel: hModel,
                     showHAxis: true,
                     vAxisModel: vModel,
                     showVAxis: false)
        }
    }
}
