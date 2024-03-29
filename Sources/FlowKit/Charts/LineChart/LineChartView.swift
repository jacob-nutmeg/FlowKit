//
//  ScrollableLineChart.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 29/12/2021.
//

import SwiftUI

public struct LineChartView: View {

    public init(viewModel: LineChartModel,
                showVAxis: Bool = true, showVValues: Bool = true,
                showHAxis: Bool = true, showHValues: Bool = true,
                dynamicAxisAnimation: Animation = .default,
                lineAnimation: Animation = .default) {
        self.viewModel = viewModel
        self.showVAxis = showVAxis
        self.showHAxis = showHAxis
        self.dynamicAxisAnimation = dynamicAxisAnimation
        self.lineAnimation = lineAnimation
    }

    @ObservedObject private var viewModel: LineChartModel

    public var showVAxis: Bool
    public var showHAxis: Bool

    var lineAnimation: Animation
    var dynamicAxisAnimation: Animation

    @State var chartOpacity: Double = 0
    @State var isDragging = false
    @GestureState var firstDragLocation: CGPoint = .zero

    private let highlightGesture = TapGesture()
    private let longPressGesture = LongPressGesture(minimumDuration: 0.15, maximumDistance: 0)
    private var dragGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                scrollView(proxy: proxy)
                    .opacity(chartOpacity)
                    .onAppear {
                        viewModel.onLoaded(in: proxy.frame(in: .local))
                        withAnimation(.easeIn.delay(0.25)) {
                            chartOpacity = 1
                        }
                    }

                AxisView(minMax: viewModel.axisMinMax,
                         isLegendLeading: viewModel.isLegendLeading,
                         yAxisModel: viewModel.yAxisModel,
                         showYAxis: showHAxis,
                         xAxisModel: viewModel.xAxisModel,
                         showXAxis: showVAxis)

                if isDragging {
                    ZStack {
                        VStack {
                            Text(String(viewModel.closestValue(to: firstDragLocation) ?? 0))
                                .position(x: proxy.frame(in: .local).width/2, y: 0)
                            Path.line(from: CGPoint(x: proxy.frame(in: .local).width/2,
                                                    y: -proxy.frame(in: .local).height/2 + 30),
                                      to: CGPoint(x: proxy.frame(in: .local).width/2,
                                                  y: proxy.frame(in: .local).height/2 - 60))
                                .stroke(.green)
                        }.position(x: firstDragLocation.x, y: proxy.frame(in: .local).height/2)
                    }
                }

                if viewModel.showHighlights,
                   let highlight = viewModel.highlightPopover,
                   let builder = viewModel.highlightBuilder {
                    HighlightPopover(frameSize: CGSize(width: viewModel.currentFrame.width,
                                                       height: viewModel.currentFrame.height),
                                     highlight: highlight, minMax: viewModel.axisMinMax,
                                     insets: viewModel.chartEdgeInsets(in: proxy.frame(in: .local))) {
                        builder(highlight)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func scrollView(proxy: GeometryProxy) -> some View {
        let scrollView = ScrollView(.horizontal, showsIndicators: false) { self.lines(proxy: proxy) }
            .clipped()
            .onTapGesture {}
            .gesture(
                longPressGesture.onEnded { _ in
                    self.isDragging = true
                }.simultaneously(with: dragGesture.updating($firstDragLocation, body: { result, state, trans in
                    state = result.location
                }).onEnded { _ in
                    self.isDragging = false
                }))

        if #available(iOS 15.0, *) {
            scrollView.accessibilityElement().accessibilityChartDescriptor(self)
        } else {
            scrollView
        }
    }

    @ViewBuilder
    private func lines(proxy: GeometryProxy) -> some View {
        Lines(data: viewModel.data,
              minMax: viewModel.linesMinMax,
              lineAnimation: lineAnimation,
              showHighlights: viewModel.showHighlights,
              highlightGesture: highlightGesture,
              tappedHighlight: $viewModel.highlightTapped.value)
            .animation(dynamicAxisAnimation)
            .padding(viewModel.chartEdgeInsets(in: proxy.frame(in: .local)))
            .frame(width: viewModel.scrollWidth)
            .coordinateSpace(name: "scroll")
            .readingScrollView(from: "scroll") { point in
                viewModel.onScroll(to: point, inFrame: proxy.frame(in: .local))
            }
    }

}

@available(iOS 15.0, *)
extension LineChartView: AXChartDescriptorRepresentable {

    public func makeChartDescriptor() -> AXChartDescriptor {
        viewModel.makeChartDescriptor()
    }

}

struct LineChartView_Previews: PreviewProvider {
    static var viewModel = LineChartModel(data: [PreviewData.potValueData,
                                                 PreviewData.potContributionData],
                                          screenPortion: .custom(PreviewData.oneMonthInterval), canScroll: true)
    static var previews: some View {
        LineChartView(viewModel: viewModel)
    }
}
