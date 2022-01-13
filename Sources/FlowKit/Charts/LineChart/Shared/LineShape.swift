//
//  LineShape.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 29/12/2021.
//

import SwiftUI

struct LineShape: Shape {
    let data: LineChartData
    let isClosed: Bool

    var minXPoint: Double
    var maxXPoint: Double
    var minYPoint: Double
    var maxYPoint: Double

    var animatableData: AnimatablePair<AnimatablePair<Double, Double>, AnimatablePair<Double, Double>> {
        get { AnimatablePair(AnimatablePair(minXPoint, maxXPoint), AnimatablePair(minYPoint, maxYPoint)) }
        set { minXPoint = newValue.first.first; maxXPoint = newValue.first.second; minYPoint = newValue.second.first; maxYPoint = newValue.second.second }
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            let yRange = maxYPoint - minYPoint

            let xPoints = data.xPoints
            let yPoints = data.yPoints

            var p1 = CGPoint(x: 0, y: yPoints[0].chartYPosition(yRange: yRange, frame: rect, offset: minYPoint))

            if isClosed {
                path.move(to: .zero)
                path.addLine(to: p1)
            } else {
                path.move(to: p1)
            }

            for pointIndex in 1..<xPoints.count {
                let x = xPoints[pointIndex].chartXPosition(minX: minXPoint, maxX: maxXPoint, frame: rect)
                let p2 = CGPoint(x: x, y: yPoints[pointIndex].chartYPosition(yRange: yRange, frame: rect, offset: minYPoint))

                if data.isCurved {
                    let midPoint = CGPoint.midPointForPoints(p1: p1, p2: p2)
                    path.addQuadCurve(to: midPoint, control: CGPoint.controlPointForPoints(p1: midPoint, p2: p1))
                    path.addQuadCurve(to: p2, control: CGPoint.controlPointForPoints(p1: midPoint, p2: p2))
                } else {
                    path.addLine(to: p2)
                }

                p1 = p2
            }

            if isClosed {
                path.addLine(to: CGPoint(x: p1.x, y: rect.height))
                path.addLine(to: CGPoint(x: 0, y: rect.height))
                path.closeSubpath()
            }
        }
    }

}
