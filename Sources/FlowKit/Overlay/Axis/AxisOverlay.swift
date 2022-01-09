//
//  AxisOverlay.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 15/12/2021.
//

import SwiftUI
import UIKit

public enum AxisType {
    case horizontal(isLeading: Bool)
    case vertical(isLeading: Bool)
}

public enum AxisFormatType {
    case value
    case date(formatter: DateFormatter)
    case number(formatter: NumberFormatter)
    case text(specifier: String)
}

public struct AxisLineStyle {
    public enum LineLength {
        case full
        case constant(CGFloat)
        case proportion(CGFloat)
    }

    public enum LineStyle {
        case dashed([CGFloat])
        case solid
    }

    public var style: LineStyle
    public var length: LineLength
    public var color: Color = .gray.opacity(0.2)
    public var width: CGFloat = 1
}

public struct AxisOverlay: View {

    public let axisType: AxisType
    public let distribution: Int
    public let frame: CGRect
    public var insets: EdgeInsets

    @Binding public var minValue: Double
    @Binding public var maxValue: Double

    public var axisPadding: CGFloat = 0.15
    public var axisSize: CGFloat
    public var axisAlignment: Alignment = .center
    public var axisFormatType: AxisFormatType = .value
    public var axisTextColor: Color = .gray
    public var axisTextFont: Font = .footnote

    public var showValues = true
    public var showValueLines = true
    public var showAxisLines = true

    public var valueLineStyle: AxisLineStyle = AxisLineStyle(style: .solid, length: .constant(12), color: .gray.opacity(0.2))
    public var axisLineStyle: AxisLineStyle = AxisLineStyle(style: .dashed([4]), length: .full, color: .gray.opacity(0.8))

    public var axisBackground: AnyView = AnyView(Rectangle().fill(.white))

    private var isHorizontal: Bool {
        switch axisType {
        case .horizontal: return true
        case .vertical: return false
        }
    }

    private var isLegendLeading: Bool {
        switch axisType {
        case .horizontal(let isLeading): return isLeading
        case .vertical(let isLeading): return isLeading
        }
    }

    private var paddingValue: CGFloat {
        let range = maxValue - minValue
        return range * axisPadding
    }

    private var valueRange: Double {
        (maxValue - minValue) - (paddingValue * 2)
    }

    private var stepInterval: CGFloat {
        valueRange / CGFloat(distribution)
    }

    private var step: CGFloat {
        let orientatedSize = (isHorizontal ? frame.height : frame.width)
        let axisPadding = (orientatedSize * axisPadding) * 2
        let insetPadding = isHorizontal ? insets.top + insets.bottom : insets.leading + insets.trailing
        let padding = axisPadding + insetPadding
        guard valueRange > 0 else { return 0 }
        return (orientatedSize - padding) / valueRange
    }

    private var minPoint: CGFloat {
        CGFloat(minValue)
    }

    private var legendPoints: [Double] {
        var points = [Double]()
        for i in 0...distribution {
            points.append((minValue + paddingValue) + (CGFloat(i) * stepInterval))
        }
        return points
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            axisBackgroundView()
            axisLine()
            ForEach(0..<distribution + 1) { interval in
                stack(at: interval)
            }
        }.drawingGroup().allowsHitTesting(false)
    }

}

// MARK: - View Building

extension AxisOverlay {

    private func axisBackgroundView() -> some View {
        var xOffset: CGFloat = 0
        if isHorizontal {
            xOffset = isLegendLeading ? 0 : frame.width - axisSize
        }
        return axisBackground
            .frame(width: isHorizontal ? axisSize : nil,
                   height: isHorizontal ? nil : axisSize)
            .offset(x: xOffset,
                    y: isHorizontal ? 0 : frame.height)
    }

    private func axisLine() -> some View {
        let from: CGPoint
        if isHorizontal {
            from = CGPoint(x: isLegendLeading ? axisSize : frame.width - axisSize,
                           y: insets.top)
        } else {
            from = CGPoint(x: insets.leading, y: frame.maxY - (insets.bottom + axisSize))
        }
        var to = from
        if isHorizontal {
            to.y = frame.height - insets.bottom
        } else {
            to.x = frame.width - insets.trailing
        }
        let path = Path.line(from: from,
                         to: to)
        return strokePath(path, axisStyle: axisLineStyle)
    }

    @ViewBuilder private func stack(at interval: Int) -> some View {
        if isHorizontal {
            horizontalLegendStack(at: interval)
        } else {
            verticalLegendStack(at: interval)
        }
    }

    @ViewBuilder private func lineAtInterval(_ interval: Int) -> some View {
        GeometryReader { info in
            let frame = info.frame(in: .local)
            let path = Path { path in
                switch valueLineStyle.length {
                case .full:
                    path = Path.line(from: lineFromPoint(at: interval),
                                     to: lineToPoint(at: interval, frame: frame))

                case .constant(let length):
                    path = linePathWithLength(length, at: interval)
                case .proportion(let proportion):
                    let frameSize = isHorizontal ? frame.width : frame.height
                    let length = frameSize * proportion
                    path = linePathWithLength(length, at: interval)
                }
            }

            strokePath(path, axisStyle: valueLineStyle)
        }.clipped()
    }

    private func strokePath(_ path: Path, axisStyle: AxisLineStyle) -> some View {
        switch axisStyle.style {
        case .solid:
            return path.stroke(axisStyle.color, style: StrokeStyle(lineWidth: axisStyle.width,
                                                                        lineCap: .round,
                                                                        lineJoin: .round,
                                                                        dash: []))
        case .dashed(let dash):
            return path.stroke(axisStyle.color, style: StrokeStyle(lineWidth: axisStyle.width,
                                                                        lineCap: .round,
                                                                        lineJoin: .round,
                                                                        dash: dash))
        }
    }

    private func linePathWithLength(_ length: CGFloat, at interval: Int) -> Path {
        let x: CGFloat
        let y: CGFloat
        if isHorizontal {
            x = isLegendLeading ? insets.leading : frame.maxX - (axisSize + insets.trailing)
            y = ((legendPoints[interval] - minPoint) * step) + insets.top
        } else {
            x = (legendPoints[interval] - minPoint) * step
            y = frame.maxY - (insets.bottom + axisSize)
        }
        let fromPoint: CGPoint = CGPoint(x: x, y: y)
        var toPoint = fromPoint
        if isHorizontal {
            toPoint.x += isLegendLeading ? length : -length
        } else {
            toPoint.y -= length
        }

        return Path.line(from: fromPoint,
                         to: toPoint)
    }

    private func lineFromPoint(at interval: Int) -> CGPoint {
        let x = isHorizontal ? insets.leading : (legendPoints[interval] - minPoint) * step
        let y = isHorizontal ? ((legendPoints[interval] - minPoint) * step) + insets.top : insets.top
        return CGPoint(x: x, y: y)
    }

    private func lineToPoint(at interval: Int, frame: CGRect) -> CGPoint {
        let x = isHorizontal ? frame.maxX - insets.trailing : (legendPoints[interval] - minPoint) * step
        let y = isHorizontal ? ((legendPoints[interval] - minPoint) * step) + insets.top : frame.maxY - insets.bottom
        return CGPoint(x: x, y: y)
    }

    private func verticalLegendStack(at interval: Int) -> some View {
        VStack(spacing: 0) {
            if showValueLines { lineAtInterval(interval) } else { Spacer() }
            if showValues { text(at: interval) }
        }
    }

    private func horizontalLegendStack(at interval: Int) -> some View {
        HStack(spacing: 0) {
            if isLegendLeading {
                if showValues { text(at: interval) }
                if showValueLines { lineAtInterval(interval) } else { Spacer() }
            } else {
                if showValueLines { lineAtInterval(interval) } else { Spacer() }
                if showValues { text(at: interval) }
            }
        }
    }

}

// MARK: - Helpers

extension AxisOverlay {

    private func text(at interval: Int) -> some View {
        label(at: interval)
            .alignmentGuide(.trailing) { d in d[.trailing] }
            .foregroundColor(axisTextColor)
            .font(axisTextFont)
            .offset(x: labelXPos(at: interval),
                    y: labelYPos(at: interval))
            .frame(width: isHorizontal ? axisSize : nil,
                   height: isHorizontal ? nil : axisSize,
                   alignment: axisAlignment)
    }

    private func label(at interval: Int) -> Text {
        switch axisFormatType {
        case .value:
            return Text("\(legendValue(at: interval))")
        case .date(let formatter):
            return Text(formatter.string(from: Date(timeIntervalSince1970: legendValue(at: interval))))
        case .number(let formatter):
            return Text(formatter.string(from: NSNumber(value: legendValue(at: interval))) ?? "")
        case .text(let specifier):
            let intervalValue = legendValue(at: interval)
            return Text("\(intervalValue, specifier: "\(specifier)")")
        }
    }

    private func legendValue(at interval: Int) -> Double {
        let array = isHorizontal ? legendPoints.reversed() : legendPoints
        return array[interval]
    }

    private func labelXPos(at interval: Int) -> CGFloat {
        guard isHorizontal == false else { return 0 }
        let xPos = legendPoints[interval]
        return ((xPos - minPoint) * step) - frame.size.width/2 + insets.leading
    }

    private func labelYPos(at interval: Int) -> CGFloat {
        guard isHorizontal else { return 0 }
        let yPos = CGFloat(legendPoints[interval] - minPoint)
        return (yPos * step) - (frame.height/2) + insets.top
    }

}

struct AxisOverlayHorizontal_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { info in
            AxisOverlay(axisType: .horizontal(isLeading: false),
                        distribution: 3,
                        frame: info.frame(in: .local),
                        insets: EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0),
                        minValue: .constant([PreviewData.lineData].minYPoint()),
                        maxValue: .constant([PreviewData.lineData].maxYPoint()),
                        axisSize: 60,
                        axisFormatType: .text(specifier: "%.0f"))
        }.padding(EdgeInsets(top: 16, leading: 0, bottom: 8, trailing: 0))
    }
}
