//
//  ScrollableLineChart.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 29/12/2021.
//

import SwiftUI

public struct ScrollableLineChart: View {

    public init(viewModel: ScrollableLineChartModel,
                hAxisModel: AxisModel = AxisModel(),
                vAxisModel: AxisModel = AxisModel(),
                legendLeading: Bool = false, showVAxis: Bool = true, showVValues: Bool = true,
                showHAxis: Bool = true, showHValues: Bool = true,
                dynamicAxisAnimation: Animation = .interactiveSpring(response: 0.6, dampingFraction: 0.98, blendDuration: 2)) {
        self.viewModel = viewModel
        self.legendLeading = legendLeading
        self.hAxisModel = hAxisModel
        self.vAxisModel = vAxisModel
        self.showVAxis = showVAxis
        self.showHAxis = showHAxis
        self.dynamicAxisAnimation = dynamicAxisAnimation
    }

    @ObservedObject public var viewModel: ScrollableLineChartModel

    public let hAxisModel: AxisModel
    public let vAxisModel: AxisModel

    public var legendLeading = false
    public var showVAxis = true
    public var showHAxis = true

    public var dynamicAxisAnimation: Animation = .interactiveSpring(response: 0.8, dampingFraction: 0.95, blendDuration: 1)

    public var body: some View {
        GeometryReader { info in
            ZStack {
                ScrollViewReader { reader in
                    ScrollView(.horizontal, showsIndicators: false) {
                        Lines(data: viewModel.data,
                              tapLocation: $viewModel.touchLocation.value,
                              minXPoint: .constant(viewModel.data.minXPoint()),
                              maxXPoint: .constant(viewModel.data.maxXPoint()),
                              minYPoint: $viewModel.minY,
                              maxYPoint: $viewModel.maxY,
                              lineAnimation: dynamicAxisAnimation,
                              highlight: viewModel.highlighted?.rawValue)
                            .animation(dynamicAxisAnimation)
                            .padding(chartEdgeInsets(in: info.frame(in: .local)))
                            .coordinateSpace(name: "lines")
                            .frame(width: viewModel.scrollWidth)
                            .readingScrollView(from: "scroll") { point in
                                viewModel.onScroll(to: point, inFrame: info.frame(in: .local))
                            }
                    }
                    .clipped()
                    .coordinateSpace(name: "scroll")
                    .onAppear {
                        viewModel.onLoaded(in: info.frame(in: .local),
                                           inset: chartInset(in: info.frame(in: .local)))
                    }
                }

                ZStack {
                    AxisView(minX: viewModel.minX, maxX: viewModel.maxX,
                             minY: viewModel.minY, maxY: viewModel.maxY,
                             isLegendLeading: legendLeading,
                             hAxisModel: hAxisModel,
                             showHAxis: showHAxis,
                             vAxisModel: vAxisModel,
                             showVAxis: showVAxis)

                    if let data = viewModel.highlighted {
                        MagnifierView(model: data.magnifierModel())
                            .frame(width: 80)
                            .padding(.bottom, chartInset(in: info.frame(in: .local)) + 16)
                            .allowsHitTesting(false)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            .offset(x: data.position.x - 40, y: 0)
                    }
                }
            }
        }
    }

    private func chartInset(in frame: CGRect) -> CGFloat {
        vAxisModel.axisSize(in: frame, isHorizontal: false)
    }

    private func chartEdgeInsets(in frame: CGRect) -> EdgeInsets {
        let vSize = vAxisModel.axisSize(in: frame, isHorizontal: false)
        let hSize = hAxisModel.axisSize(in: frame, isHorizontal: true)
        return EdgeInsets(top: 0,
                          leading: legendLeading ? hSize : 0,
                          bottom: vSize,
                          trailing: legendLeading ? 0 : hSize)
    }

}

extension HighlightedData {

    func magnifierModel() -> MagnifierModel {
        let returnTitle = Text("Returns:")
            .font(.caption2)
            .foregroundColor(.gray)
        let returnsText = Text(returns)
            .font(.body)
            .bold()
            .foregroundColor(returns < contributions ? .red : .green)
        let contTitle = Text("Contributions:")
            .font(.caption2)
            .foregroundColor(.gray)
        let contText = Text(contributions)
            .font(.callout)
            .bold()
            .foregroundColor(.blue)
        let dateText = Text("On \(date)")
            .font(.caption2)
            .foregroundColor(.gray)

        return MagnifierModel(textItems: [.init(id: "rTitle", text: returnTitle),
                                          .init(id: "returns", text: returnsText, spacing: 8),
                                          .init(id: "cTitle", text: contTitle),
                                          .init(id: "contributions", text: contText, spacing: 8),
                                          .init(id: "date", text: dateText)])
    }

}

struct ScrollableLineChart_Previews: PreviewProvider {
    static var viewModel = ScrollableLineChartModel(data: [PreviewData.potValueData,
                                                           PreviewData.potContributionData],
                                                    screenPortion: PreviewData.oneMonthInterval)
    static var previews: some View {
        ScrollableLineChart(viewModel: viewModel)
    }
}
