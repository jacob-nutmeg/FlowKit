//
//  ScrollableLineChart.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 29/12/2021.
//

import SwiftUI

public struct LineChartView: View {

    public typealias HighlightBuilder = ((LineChartData.Highlight) -> AnyView)

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

    public var highlightBuilder: HighlightBuilder?
    @ObservedObject public var viewModel: LineChartModel

    public var showVAxis: Bool
    public var showHAxis: Bool

    var lineAnimation: Animation
    var dynamicAxisAnimation: Animation

    @State var isDragging = false
    @GestureState var firstDragLocation: CGPoint = .zero

    private let highlightGesture = TapGesture()
    private let longPressGesture = LongPressGesture(minimumDuration: 0.25, maximumDistance: 0)
    private var dragGesture = DragGesture(minimumDistance: 1, coordinateSpace: .local)
    private var secondDragGesture = DragGesture(minimumDistance: 1, coordinateSpace: .local)

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                scrollView(proxy: proxy)
                    .onAppear {
                        viewModel.onLoaded(in: proxy.frame(in: .local))
                        viewModel.isFirstLoad = false
                    }

                AxisView(minMax: viewModel.axisMinMax,
                         isLegendLeading: viewModel.isLegendLeading,
                         hAxisModel: viewModel.hAxisModel,
                         showHAxis: showHAxis,
                         vAxisModel: viewModel.vAxisModel,
                         showVAxis: showVAxis)

                if isDragging {
                    ZStack {
                        VStack {
                            GeometryReader { stackProxy in
                                Text(String(viewModel.closestValue(to: firstDragLocation) ?? 0))
                                    .position(x: stackProxy.frame(in: .local).width/2, y: 0)
                                Path.line(from: CGPoint(x: stackProxy.frame(in: .local).width/2, y: 30),
                                          to: CGPoint(x: stackProxy.frame(in: .local).width/2, y: stackProxy.frame(in: .local).height - 60))
                                    .stroke(.green)
                            }
                        }.position(x: firstDragLocation.x, y: proxy.frame(in: .local).height/2)
                    }
                }

                if let highlight = viewModel.highlightPopover, let builder = highlightBuilder {
                    HighlightPopover(currentFrame: proxy.frame(in: .named("scroll")),
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
            .onTapGesture {}
            .gesture(
                longPressGesture.onEnded { _ in
                    self.isDragging = true
                }.simultaneously(with: dragGesture.updating($firstDragLocation, body: { result, state, trans in
                    state = result.location
                    print("First")
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
                                          startingFrame: .zero,
                                          screenPortion: .custom(PreviewData.oneMonthInterval), canScroll: true)
    static var previews: some View {
        LineChartView(viewModel: viewModel)
    }
}
