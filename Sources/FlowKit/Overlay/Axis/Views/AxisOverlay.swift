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

public enum AxisLineLength {
    case full
    case constant(CGFloat)
    case proportion(CGFloat)
}

public struct AxisOverlay: View {

    public init(axisType: AxisType,
                frame: CGRect,
                minValue: Double,
                maxValue: Double,
                model: AxisModel = AxisModel(),
                axisBackground: AnyView = AnyView(Rectangle().fill(.white))) {
        self.axisType = axisType
        self.frame = frame
        self.minValue = minValue
        self.maxValue = maxValue
        self.model = model
        self.axisBackground = axisBackground
    }

    // MARK: - Public properties

    public let axisType: AxisType
    public let frame: CGRect
    public var minValue: Double
    public var maxValue: Double

    public var model: AxisModel = AxisModel()
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

    private var minPoint: CGFloat { CGFloat(minValue) }

    private var axisSize: CGFloat {
        model.axisSize(in: frame, isHorizontal: isHorizontal)
    }

    private var frameStep: CGFloat {
        model.frameStep(in: frame,
                        isHorizontal: isHorizontal,
                        min: minValue, max: maxValue)
    }

    private var legendPoints: [Double] {
        model.legendPoints(minValue: minValue, maxValue: maxValue)
    }

    // MARK: - Body
    public var body: some View {
        ZStack(alignment: .topLeading) {
            axisBackgroundView()
            ForEach(0..<model.distribution) { interval in
                stack(at: interval)
            }
            axisLine()
        }.allowsHitTesting(false)
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
                           y: 0)
        } else {
            from = CGPoint(x: 0, y: frame.maxY - axisSize)
        }
        var to = from
        if isHorizontal {
            to.y = frame.height
        } else {
            to.x = frame.width
        }

        return AxisLine(from: from, to: to, style: model.axisLineStyle)
    }

    @ViewBuilder private func stack(at interval: Int) -> some View {
        if isHorizontal {
            horizontalLegendStack(at: interval)
        } else {
            verticalLegendStack(at: interval)
        }
    }

    private func verticalLegendStack(at interval: Int) -> some View {
        VStack(spacing: 0) {
            GeometryReader { info in
                lineAtInterval(interval, frame: info.frame(in: .local))
            }
            if model.showValues { text(at: interval) }
        }
    }

    private func horizontalLegendStack(at interval: Int) -> some View {
        HStack {
            if isLegendLeading {
                if model.showValues { text(at: interval) }
                GeometryReader { info in
                    lineAtInterval(interval, frame: info.frame(in: .local))
                }
            } else {
                GeometryReader { info in
                    lineAtInterval(interval, frame: info.frame(in: .local))
                }
                if model.showValues { text(at: interval) }
            }
        }
    }

}

// MARK: - Helpers

extension AxisOverlay {

    private func lineAtInterval(_ interval: Int, frame: CGRect) -> some View {
        let length: CGFloat

        switch model.valueLineLength {
        case .constant(let constant):
            length = constant
        case .proportion(let proportion):
            let frameSize = isHorizontal ? frame.width : frame.height
            length = frameSize * proportion
        }
        let from = lineFromPoint(at: interval)
        let to = lineToPoint(from: from, length: length)
        return AxisLine(from: from, to: to, style: model.valueLineStyle)
    }

    private func lineFromPoint(at interval: Int) -> CGPoint {
        let x: CGFloat
        let y: CGFloat
        if isHorizontal {
            x = isLegendLeading ? 0 : frame.maxX - axisSize
            y = ((legendPoints[interval] - minPoint) * frameStep)
        } else {
            x = (legendPoints[interval] - minPoint) * frameStep
            y = frame.maxY - axisSize
        }

        return CGPoint(x: x, y: y)
    }

    private func lineToPoint(from: CGPoint, length: CGFloat) -> CGPoint {
        var toPoint = from
        if isHorizontal {
            toPoint.x += isLegendLeading ? length : -length
        } else {
            toPoint.y -= length
        }
        return toPoint
    }

    private func text(at interval: Int) -> some View {
        label(at: interval)
            .rotationEffect(Angle(degrees: model.axisTextFormat.rotation))
            .foregroundColor(model.axisTextFormat.axisTextColor)
            .font(model.axisTextFormat.axisTextFont)
            .offset(x: labelXPos(at: interval),
                    y: labelYPos(at: interval))
            .frame(width: isHorizontal ? axisSize : nil,
                   height: isHorizontal ? nil : axisSize,
                   alignment: model.axisTextFormat.axisAlignment)
    }

    private func label(at interval: Int) -> Text {
        Text(model.axisTextFormat.formattedValue(from: legendValue(at: interval)))
    }

    private func legendValue(at interval: Int) -> Double {
        let array = isHorizontal ? legendPoints.reversed() : legendPoints
        return array[interval]
    }

    private func labelXPos(at interval: Int) -> CGFloat {
        guard isHorizontal == false else { return 0 }
        let xPos = legendPoints[interval]
        return ((xPos - minPoint) * frameStep) - frame.size.width/2
    }

    private func labelYPos(at interval: Int) -> CGFloat {
        guard isHorizontal else {
            return model.axisTextFormat.rotation > 0 ? model.axisSize(in: frame, isHorizontal: isHorizontal)/2 : 0
        }

        let yPos = CGFloat(legendPoints[interval] - minPoint)
        return (yPos * frameStep) - (frame.height/2)
    }

}

struct AxisOverlayHorizontal_Previews: PreviewProvider {
    static var axisData = [PreviewData.potValueData]

    static var previews: some View {
        GeometryReader { info in
            AxisOverlay(axisType: .vertical(isLeading: false),
                        frame: info.frame(in: .local),
                        minValue: axisData.minYPoint(),
                        maxValue: axisData.maxYPoint())
        }.padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
    }
}
