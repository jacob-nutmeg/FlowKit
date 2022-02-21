//
//  ScrollHandler.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 31/12/2021.
//

import SwiftUI
import Combine

public class LineChartModel: ObservableObject {

    public typealias HighlightBuilder = ((LineHighlightData) -> AnyView)

    typealias ScrollData = (position: CGPoint, frame: CGRect)

    public let data: [LineChartData]

    var touchLocation = CurrentValueSubject<CGPoint?, Never>(nil)
    var holdLocations = CurrentValueSubject<[CGPoint], Never>([])
    var highlightTapped = CurrentValueSubject<LineHighlightData?, Never>(nil)

    @Published var scrollWidth: CGFloat = 1
    @Published var axisMinMax: MinMax
    @Published var linesMinMax: MinMax
    @Published var canScroll: Bool

    @Published var highlightedPoints = [String: [CGPoint]]()
    @Published var highlightPopover: LineHighlightData? = nil

    var highlightBuilder: HighlightBuilder?

    let yAxisModel: AxisModel
    let xAxisModel: AxisModel

    let isLegendLeading: Bool

    let showHighlights: Bool

    private(set) var currentFrame: CGRect = .zero
    private(set) var currentWidth: CGFloat = 1

    private lazy var screenPortionPublisher = CurrentValueSubject<Double, Never>(1)
    private lazy var scrollDataPublisher = CurrentValueSubject<ScrollData, Never>((CGPoint.zero, CGRect.zero))

    private var lineIdToHighlight: String?
    private let isDynamicAxis: Bool
    private let dataPaddingProportion: CGFloat
    private var updateThrottle: Double
    private var accessibilityTitle: String?
    private var accessibilitySummary: String?
    private var audioAccessibilityId: String?

    private var cancellables = [AnyCancellable]()

    public init(data: [LineChartData],
                screenPortion: DataPortion = .all,
                yAxisModel: AxisModel = AxisModel(),
                xAxisModel: AxisModel = AxisModel(),
                isLegendLeading: Bool = true,
                lineIdToHighlight: String? = nil,
                dynamicAxis: Bool = true,
                dataPaddingProportion: CGFloat = 0,
                updateThrottle: Double = 0.1,
                canScroll: Bool = false,
                showHighlights: Bool = true,
                highlightBuilder: HighlightBuilder? = nil,
                accessibilityTitle: String? = nil,
                accessibilitySummary: String? = nil,
                audioAccessibilityId: String? = nil) {
        self.data = data
        self.isDynamicAxis = dynamicAxis
        self.yAxisModel = yAxisModel
        self.xAxisModel = xAxisModel
        self.isLegendLeading = isLegendLeading
        self.lineIdToHighlight = lineIdToHighlight
        self.updateThrottle = updateThrottle
        self.dataPaddingProportion = dataPaddingProportion
        self.canScroll = canScroll
        self.highlightBuilder = highlightBuilder
        self.showHighlights = showHighlights
        self.accessibilityTitle = accessibilityTitle
        self.accessibilitySummary = accessibilitySummary
        self.audioAccessibilityId = audioAccessibilityId
        self.axisMinMax = MinMax(minY: 0, maxY: 0, minX: 0, maxX: 0)
        self.linesMinMax = MinMax(minY: data.maxYPoint(), maxY: data.maxYPoint(),
                                  minX: data.minXPoint(), maxX: data.maxXPoint())
        updatePortion(to: screenPortion)
        axisMinMax = minMaxValuesOnScreen(at: .zero, in: currentFrame)
        linesMinMax = MinMax(minY: axisMinMax.minY, maxY: axisMinMax.maxY,
                             minX: data.minXPoint(), maxX: data.maxXPoint())

        bindToData()
    }

    public func updatePortion(to screenPortion: DataPortion) {
        switch screenPortion {
        case .all:
            self.screenPortionPublisher.value = data.maxXPoint() - data.minXPoint()
        case .custom(let portion):
            self.screenPortionPublisher.value = portion
        }
    }

    func onScroll(to position: CGPoint, inFrame frame: CGRect) {
        currentFrame = frame
        scrollDataPublisher.send(ScrollData(position, frame))
    }

    func onLoaded(in frame: CGRect) {
        currentFrame = frame
        withAnimation(nil) {
            updateScrollWidth()
            axisMinMax = minMaxValuesOnScreen(at: .zero, in: frame)
            linesMinMax = MinMax(minY: axisMinMax.minY, maxY: axisMinMax.maxY,
                                 minX: data.minXPoint(), maxX: data.maxXPoint())
        }
    }

    func chartEdgeInsets(in frame: CGRect) -> EdgeInsets {
        let vSize = xAxisModel.axisSize(in: frame, isHorizontal: false)
        let hSize = yAxisModel.axisSize(in: frame, isHorizontal: true)
        return EdgeInsets(top: 0,
                          leading: isLegendLeading ? hSize : 0,
                          bottom: vSize,
                          trailing: isLegendLeading ? 0 : hSize)
    }

    private func updateScrollWidth() {
        scrollWidth = scrollWidth(for: currentFrame)
    }

    private func scrollWidth(for frame: CGRect) -> CGFloat {
        currentWidth = (frame.width) * widthMultiplier()
        return currentWidth
    }

    private func widthMultiplier() -> CGFloat {
        let range = data.maxXPoint() - data.minXPoint()
        return max(1, range/screenPortionPublisher.value)
    }

    private func bindToData() {
        scrollDataPublisher
            .combineLatest(screenPortionPublisher)
            .map { $0.0 }
            .throttle(for: .seconds(updateThrottle), scheduler: DispatchQueue.global(qos: .userInitiated), latest: true)
            .map { self.minMaxValuesOnScreen(at: $0.position,
                                             in: $0.frame) }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] minMax in
                self.highlightTapped.value = nil
                self.axisMinMax = minMax
                self.linesMinMax = MinMax(minY: minMax.minY, maxY: minMax.maxY,
                                          minX: data.minXPoint(), maxX: data.maxXPoint())
            }.store(in: &cancellables)

        holdLocations.sink { locations in
            print(locations)
        }.store(in: &cancellables)

        screenPortionPublisher
            .sink { [unowned self] _ in
                self.updateScrollWidth()
            }.store(in: &cancellables)

        highlightTapped.sink { data in
            withAnimation(data == nil ? .easeOut(duration: 0.2) : .spring()) {
                self.highlightPopover = data
            }
        }.store(in: &cancellables)
    }

    func closestValue(to location: CGPoint?) -> Double? {
        guard var xLocation = location?.x,
              currentWidth > 0,
              let idToHighlight = lineIdToHighlight,
              let setToHighlight = data.first(where: { $0.id == idToHighlight }) else {
                  return nil
              }

        xLocation += scrollDataPublisher.value.position.x
        let inset = chartEdgeInsets(in: currentFrame)
        let proportion = xLocation/(currentWidth - (inset.trailing + inset.leading))
        let xVal = data.minXPoint() + ((data.maxXPoint() - data.minXPoint()) * proportion)
        let closestElement = data.combinedXPoints().enumerated().min(by: { abs($0.1 - xVal) < abs($1.1 - xVal) } )
        let closestIndex = closestElement?.offset ?? 0
        return setToHighlight.yPoints[closestIndex]
    }

    private func minMaxValuesOnScreen(at position: CGPoint, in frame: CGRect) -> MinMax {
        let screenPortion = screenPortionPublisher.value
        let frameWidth = max(frame.width, 1)
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

        return MinMax(minY: minY, maxY: maxY, minX: minX, maxX: maxX)
    }


    @available(iOS 15.0, *)
    func makeChartDescriptor() -> AXChartDescriptor {
        let dataToHighlight = data.first(where: { $0.id == audioAccessibilityId ?? "" }) ?? data[0]
        let values = dataToHighlight.points(fromXValue: linesMinMax.minX)
        let xValues = values.0
        let yValues = values.1

        let xAxis = AXNumericDataAxisDescriptor(
            title: xAxisModel.title,
            range: (xValues.min() ?? 0)...(xValues.max() ?? 0),
            gridlinePositions: [],
            valueDescriptionProvider: { self.xAxisModel.axisTextFormat.formattedValue(from: $0) })

        let yAxis = AXNumericDataAxisDescriptor(
            title: yAxisModel.title,
            range: (yValues.min() ?? 0)...(yValues.max() ?? 0),
            gridlinePositions: [],
            valueDescriptionProvider: { self.yAxisModel.axisTextFormat.formattedValue(from: $0) })

        var dataPoints = [AXDataPoint]()
        for (index, xPoint) in dataToHighlight.xPoints.enumerated() {
            dataPoints.append(AXDataPoint(x: xPoint, y: dataToHighlight.yPoints[index]))
        }

        let series = AXDataSeriesDescriptor(
            attributedName: NSAttributedString(string: "Chart description"),
            isContinuous: true,
            dataPoints: dataPoints)

        return AXChartDescriptor(
            title: accessibilityTitle,
            summary: generateAccessibilitySummary(),
            xAxis: xAxis,
            yAxis: yAxis,
            additionalAxes: [],
            series: [series]
        )
    }

    private func generateAccessibilitySummary() -> String {
        if let summary = accessibilitySummary { return summary }

        guard let dataId = audioAccessibilityId,
              let dataToHighlight = data.first(where: { $0.id == dataId }) else {
                  return "No summary"
              }

        let minXFormatted = xAxisModel.axisTextFormat.formattedValue(from: linesMinMax.minX)
        let maxXFormatted = xAxisModel.axisTextFormat.formattedValue(from: linesMinMax.maxX)
        let minYFormatted = yAxisModel.axisTextFormat.formattedValue(from: linesMinMax.minY)
        let maxYFormatted = yAxisModel.axisTextFormat.formattedValue(from: linesMinMax.maxY)

        return "From \(minXFormatted) to \(maxXFormatted), value changed from \(minYFormatted) to \(maxYFormatted)"
    }

    private func minIndexForXValue(_ xValue: Double, in dataSet: LineChartData) -> Int {
        max(0, (dataSet.xPoints.firstIndex(where: { $0 >= xValue }) ?? 0) - 1)
    }

}
