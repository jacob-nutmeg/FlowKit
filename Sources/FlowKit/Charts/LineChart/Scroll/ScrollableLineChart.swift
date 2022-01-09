//
//  ScrollableLineChart.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 29/12/2021.
//

import SwiftUI

public struct ScrollableLineChart: View {

    public init(viewModel: ScrollableLineChartModel,
                legendLeading: Bool = false, showVAxis: Bool = true, showVValues: Bool = true,
                showHAxis: Bool = true, showHValues: Bool = true,
                chartInset: EdgeInsets = EdgeInsets(top: 16, leading: 0, bottom: 60, trailing: 60),
                verticalInsets: EdgeInsets = EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 60),
                horizontalInsets: EdgeInsets = EdgeInsets(top: 16, leading: 0, bottom: 60, trailing: 0),
                dynamicAxisAnimation: Animation = .interactiveSpring(response: 0.8, dampingFraction: 0.95, blendDuration: 1)) {
        self.viewModel = viewModel
        self.legendLeading = legendLeading
        self.showVAxis = showVAxis
        self.showVValues = showVValues
        self.showHAxis = showHAxis
        self.showHValues = showHValues
        self.chartInset = chartInset
        self.verticalInsets = verticalInsets
        self.horizontalInsets = horizontalInsets
        self.dynamicAxisAnimation = dynamicAxisAnimation
    }

    @ObservedObject public var viewModel: ScrollableLineChartModel

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

    public var dynamicAxisAnimation: Animation = .interactiveSpring(response: 0.8, dampingFraction: 0.95, blendDuration: 1)

    public var body: some View {
        GeometryReader { info in
            ZStack {
                ScrollViewReader { reader in
                    ScrollView(.horizontal, showsIndicators: false) {
                        Lines(data: viewModel.data,
                              tapLocation: $viewModel.touchLocation.value,
                              minYPoint: $viewModel.minY,
                              maxYPoint: $viewModel.maxY,
                              lineAnimation: dynamicAxisAnimation,
                              highlight: viewModel.highlighted?.rawValue)
                            .animation(dynamicAxisAnimation)
                            .padding(chartInset)
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
                                           inset: verticalInsets.leading + verticalInsets.trailing)
                    }
                }

                ZStack {
                    if showHAxis {
                        AxisOverlay(axisType: .horizontal(isLeading: legendLeading),
                                    distribution: 2,
                                    frame: info.frame(in: .local),
                                    insets: horizontalInsets,
                                    minValue: $viewModel.minY,
                                    maxValue: $viewModel.maxY,
                                    axisSize: 60,
                                    axisFormatType: .number(formatter: PreviewData.numberFormatter),
                                    showValues: showHValues)
                    }

                    if showVAxis {
                        AxisOverlay(axisType: .vertical(isLeading: legendLeading),
                                    distribution: 2,
                                    frame: info.frame(in: .local),
                                    insets: verticalInsets,
                                    minValue: $viewModel.minX,
                                    maxValue: $viewModel.maxX,
                                    axisSize: 60,
                                    axisFormatType: .date(formatter: PreviewData.dateFormatter),
                                    showValues: showVValues)
                    }

                    if let data = viewModel.highlighted {
                        MagnifierView(model: data.magnifierModel())
                            .frame(width: 80)
                            .padding(.bottom, chartInset.bottom + 16)
                            .allowsHitTesting(false)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            .offset(x: data.position.x - 40, y: 0)
                    }
                }
            }
        }
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
