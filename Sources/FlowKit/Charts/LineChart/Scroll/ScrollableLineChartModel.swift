//
//  ScrollHandler.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 31/12/2021.
//

import SwiftUI
import Combine

public struct HighlightedData {
    let rawValue: CGPoint
    let date: String
    let contributions: String
    let returns: String
    let position: CGPoint
}

public class ScrollableLineChartModel: ObservableObject {

    public init(data: [LineChartData], isDynamicAxis: Bool, dataPaddingProportion: CGFloat,
                screenPortionPublisher: CurrentValueSubject<Double, Never> = CurrentValueSubject<Double, Never>(0),
                touchLocation: CurrentValueSubject<CGPoint, Never> = CurrentValueSubject<CGPoint, Never>(.zero)) {
        self.data = data
        self.isDynamicAxis = isDynamicAxis
        self.dataPaddingProportion = dataPaddingProportion
        self.screenPortionPublisher = screenPortionPublisher
        self.touchLocation = touchLocation
    }

    private struct MinMaxData: Equatable {
        let minY: Double
        let maxY: Double
        let minX: Double
        let maxX: Double
    }

    typealias ScrollData = (position: CGPoint, frame: CGRect)

    public let data: [LineChartData]
    public let isDynamicAxis: Bool
    public let dataPaddingProportion: CGFloat

    public var screenPortionPublisher = CurrentValueSubject<Double, Never>(0)

    public var touchLocation = CurrentValueSubject<CGPoint, Never>(.zero)

    @Published public var scrollWidth: CGFloat = 0
    @Published public var minX: Double = 0
    @Published public var maxX: Double = 0
    @Published public var minY: Double = 0
    @Published public var maxY: Double = 0

    @Published public var highlighted: HighlightedData? = nil

    private var currentFrame: CGRect = .zero
    private var currentWidth: CGFloat = 0
    private var currentInset: CGFloat = 0

    private var cancellables = [AnyCancellable]()

    private var scrollDataPublisher = PassthroughSubject<ScrollData, Never>()

    public init(data: [LineChartData], screenPortion: Double,
         dynamicAxis: Bool = true, dataPaddingProportion: CGFloat = 0.01) {
        self.data = data
        self.screenPortionPublisher.value = screenPortion
        self.isDynamicAxis = dynamicAxis
        self.dataPaddingProportion = dataPaddingProportion
        bindToData()
    }

    func onScroll(to position: CGPoint, inFrame frame: CGRect) {
        scrollDataPublisher.send(ScrollData(position, frame))
    }

    func onLoaded(in frame: CGRect, inset: CGFloat = 0) {
        currentFrame = frame
        currentInset = inset
        scrollWidth = scrollWidth(for: frame, inset: inset)
    }

    private func updateScrollWidth() {
        scrollWidth = scrollWidth(for: currentFrame, inset: currentInset)
    }

    private func scrollWidth(for frame: CGRect, inset: CGFloat = 0) -> CGFloat {
        let range = data.maxXPoint() - data.minXPoint()
        let widthMultiplier = range/screenPortionPublisher.value
        currentWidth = (frame.width - inset) * widthMultiplier
        return currentWidth
    }

    private func bindToData() {
        scrollDataPublisher
            .combineLatest(screenPortionPublisher)
            .map { $0.0 }
            .throttle(for: .milliseconds(100), scheduler: DispatchQueue.global(qos: .userInitiated), latest: true)
            .map { self.minMaxValuesOnScreen(at: $0.position,
                                             in: $0.frame) }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] minMax in
                withAnimation(.easeInOut(duration: 0.1)) {
                    highlighted = nil
                }
                minY = minMax.minY
                maxY = minMax.maxY
                minX = minMax.minX
                maxX = minMax.maxX
            }.store(in: &cancellables)

        screenPortionPublisher
            .sink { [unowned self] _ in
                self.updateScrollWidth()
            }.store(in: &cancellables)

        touchLocation
            .removeDuplicates()
            .sink { location in
                self.closestValue(to: location)
        }.store(in: &cancellables)
    }

    private func closestValue(to location: CGPoint) {
        guard currentWidth > 0 else { return }

        let frameWidth = currentFrame.width
        let proportion = location.x/currentWidth
        let xVal = data.minXPoint() + ((data.maxXPoint() - data.minXPoint()) * proportion)
        let closestElement = data.combinedXPoints().enumerated().min( by: { abs($0.1 - xVal) < abs($1.1 - xVal) } )
        let dateValue = closestElement?.element ?? 0

        var contributionYVal: Double = 0
        var returnsYVal: Double = 0

        for dataSet in data {
            if dataSet.id == "potValue" {
                returnsYVal = dataSet.yPoints[closestElement?.offset ?? 0]
            } else if dataSet.id == "potContributions" {
                contributionYVal = dataSet.yPoints[closestElement?.offset ?? 0]
            }
        }

        let xValProportion = (xVal - minX)/(maxX - minX)
        let yPos = returnsYVal.chartYPosition(yRange: (maxY - minY), frame: currentFrame, offset: minY)
        var relativePos = location
        relativePos.y = yPos
        relativePos.x = max(-frameWidth/2, (xValProportion * frameWidth) - frameWidth/2)

        withAnimation {
            highlighted = HighlightedData(rawValue: CGPoint(x: dateValue, y: returnsYVal),
                                          date: PreviewData.dateFormatter.string(from: Date(timeIntervalSince1970: dateValue)),
                                          contributions: PreviewData.numberFormatter.string(from: NSNumber(value: contributionYVal)) ?? "",
                                          returns: PreviewData.numberFormatter.string(from: NSNumber(value: returnsYVal)) ?? "",
                                          position: relativePos)
        }
    }

    private func minMaxValuesOnScreen(at position: CGPoint, in frame: CGRect) -> MinMaxData {
        let screenPortion = screenPortionPublisher.value
        let frameWidth = frame.width - currentInset
        let index = max(0, floor(max(0, position.x) / frameWidth))
        let additionPercent = (position.x - (frameWidth * index)) / frameWidth
        let addition = additionPercent * screenPortion

        var yValues = [Double]()
        var xValues = [Double]()

        for dataSet in data {
            let minXVal = dataSet.minX + (index * screenPortion) + addition
            let maxXVal = dataSet.minX + ((index + 1) * screenPortion) + addition

            xValues.append(minXVal)
            xValues.append(maxXVal)

            let minIndex = max(0, (dataSet.xPoints.firstIndex(where: { $0 >= minXVal }) ?? 0) - 1)
            let maxIndex = min(dataSet.xPoints.count - 1, (dataSet.xPoints.firstIndex(where: { $0 > maxXVal }) ?? dataSet.xPoints.count - 1) + 1)
            let yVals = dataSet.yPoints[minIndex...maxIndex]
            yValues.append(contentsOf: yVals)
        }

        let minX = xValues.min() ?? 0
        let maxX = xValues.max() ?? 0
        var minY = isDynamicAxis ? yValues.min() ?? 0 : data.minYPoint()
        var maxY = isDynamicAxis ? yValues.max() ?? 0 : data.maxYPoint()
        let padding = (maxY - minY) * dataPaddingProportion
        minY -= padding
        maxY += padding

        return MinMaxData(minY: minY, maxY: maxY, minX: minX, maxX: maxX)
    }

}
