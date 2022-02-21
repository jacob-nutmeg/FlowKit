//
//  FanChartView.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 03/01/2022.
//

import SwiftUI

public struct FanChartView: View {

    public init(model: FanChartModel,
                lineAnimation: Animation = .default) {
        self.model = model
        self.lineAnimation = lineAnimation
    }

    private let model: FanChartModel
    private let lineAnimation: Animation

    private let longPressGesture = LongPressGesture(minimumDuration: 0.15, maximumDistance: 0)
    private var dragGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)

    @State private var completion: CGFloat = 0
    @State var isDragging = false
    @GestureState var firstDragLocation: CGPoint = .zero

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(model.data) { fanData in
                    ZStack {
                        if let color = fanData.lineColor {
                            FanShape(data: fanData,
                                     minMax: model.minMax)
                                .stroke(color)
                        }

                        FanShape(data: fanData,
                                 minMax: model.minMax)
                            .fill(LinearGradient(colors: fanData.colors, startPoint: .bottom, endPoint: .top))
                    }
                }.padding(chartEdgeInsets(in: proxy.frame(in: .local)))

                AxisView(minMax: model.minMax,
                         isLegendLeading: model.isLegendLeading,
                         yAxisModel: model.yAxisModel,
                         showYAxis: model.showYAxis,
                         xAxisModel: model.xAxisModel,
                         showXAxis: model.showXAxis)

                if isDragging {
                    ZStack {
                        VStack {
                            Text(String("Hello!"))
                                .position(x: proxy.frame(in: .local).width/2, y: 0)
                            Path.line(from: CGPoint(x: proxy.frame(in: .local).width/2,
                                                    y: -proxy.frame(in: .local).height/2 + 30),
                                      to: CGPoint(x: proxy.frame(in: .local).width/2,
                                                  y: proxy.frame(in: .local).height/2 - 60))
                                .stroke(.green)
                        }.position(x: firstDragLocation.x, y: proxy.frame(in: .local).height/2)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(lineAnimation) {
                self.completion = 1
            }
        }
        .gesture(
            longPressGesture.onEnded { _ in
                self.isDragging = true
            }.simultaneously(with: dragGesture.updating($firstDragLocation, body: { result, state, trans in
                state = result.location
            }).onEnded { _ in
                self.isDragging = false
            }))
    }


    private func chartEdgeInsets(in frame: CGRect) -> EdgeInsets {
        let xSize = model.xAxisModel.axisSize(in: frame, isHorizontal: false)
        let ySize = model.yAxisModel.axisSize(in: frame, isHorizontal: true)
        return EdgeInsets(top: 0,
                          leading: model.isLegendLeading ? ySize : 0,
                          bottom: xSize,
                          trailing: model.isLegendLeading ? 0 : ySize)
    }

}

struct FanChartView_Previews: PreviewProvider {
    static var data = [PreviewData.likelyFanData,
                       PreviewData.unlikelyFanDataLow,
                       PreviewData.unlikelyFanDataHigh]

    static var model = FanChartModel(data: data)

    static var previews: some View {
        FanChartView(model: model)
    }
}
