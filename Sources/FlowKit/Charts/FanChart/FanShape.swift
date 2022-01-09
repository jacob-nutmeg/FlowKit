//
//  FanShape.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 03/01/2022.
//

import SwiftUI

struct FanShape: Shape {
    let data: FanChartData
    let minXPoint: Double
    let maxXPoint: Double
    let minYPoint: Double
    let maxYPoint: Double

    var xMultiplier: CGFloat = 0
    var yMultiplier: CGFloat = 0

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(xMultiplier, yMultiplier) }
        set { xMultiplier = newValue.first; yMultiplier = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        Path { path in

            let yRange = maxYPoint - minYPoint
            var x = xMultiplier * data.xValues[0].chartXPosition(minX: minXPoint, maxX: maxXPoint, frame: rect)
            var y = yMultiplier * data.firstYValues[0].chartYPosition(yRange: yRange, frame: rect, offset: minYPoint)
            var p1 = CGPoint(x: x, y: y)
            path.move(to: p1)

            for pointIndex in 1..<data.xValues.count {
                x = xMultiplier * data.xValues[pointIndex].chartXPosition(minX: minXPoint, maxX: maxXPoint, frame: rect)
                y = yMultiplier * data.firstYValues[pointIndex].chartYPosition(yRange: yRange, frame: rect, offset: minYPoint)
                let p2 = CGPoint(x: x, y: y)
                path.addLine(to: p2)
                p1 = p2
            }

            x = xMultiplier * data.xValues[data.xValues.count - 1].chartXPosition(minX: minXPoint, maxX: maxXPoint, frame: rect)
            y = yMultiplier * data.secondYValues[data.secondYValues.count - 1].chartYPosition(yRange: yRange, frame: rect, offset: minYPoint)
            p1 = CGPoint(x: x, y: y)
            path.addLine(to: p1)

            for pointIndex in 1..<data.xValues.count {
                let index = data.xValues.count - pointIndex
                x = xMultiplier * data.xValues[index].chartXPosition(minX: minXPoint, maxX: maxXPoint, frame: rect)
                y = yMultiplier * data.secondYValues[index].chartYPosition(yRange: yRange, frame: rect, offset: minYPoint)
                let p2 = CGPoint(x: x, y: y)
                path.addLine(to: p2)
                p1 = p2
            }

            x = xMultiplier * data.xValues[0].chartXPosition(minX: minXPoint, maxX: maxXPoint, frame: rect)
            y = yMultiplier * data.secondYValues[0].chartYPosition(yRange: yRange, frame: rect, offset: minYPoint)
            p1 = CGPoint(x: x, y: y)
            path.addLine(to: p1)
            path.closeSubpath()
        }
    }

}