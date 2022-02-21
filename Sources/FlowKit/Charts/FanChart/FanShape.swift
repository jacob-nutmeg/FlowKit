//
//  FanShape.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 03/01/2022.
//

import SwiftUI

struct FanShape: Shape {
    let data: FanChartData
    let minMax: MinMax

    func path(in rect: CGRect) -> Path {
        Path { path in
            let yRange = minMax.maxY - minMax.minY
            var x = data.xValues[0].chartXPosition(minX: minMax.minX, maxX: minMax.maxX, frameWidth: rect.width)
            var y = data.firstYValues[0].chartYPosition(yRange: yRange, frameHeight: rect.height, offset: minMax.minY)
            var p1 = CGPoint(x: x, y: y)
            path.move(to: p1)

            for pointIndex in 1..<data.xValues.count {
                x = data.xValues[pointIndex].chartXPosition(minX: minMax.minX, maxX: minMax.maxX, frameWidth: rect.width)
                y = data.firstYValues[pointIndex].chartYPosition(yRange: yRange, frameHeight: rect.height, offset: minMax.minY)
                let p2 = CGPoint(x: x, y: y)
                path.addLine(to: p2)
                p1 = p2
            }

            x = data.xValues[data.xValues.count - 1].chartXPosition(minX: minMax.minX, maxX: minMax.maxX,
                                                                    frameWidth: rect.width)
            y = data.secondYValues[data.secondYValues.count - 1].chartYPosition(yRange: yRange, frameHeight: rect.height, offset: minMax.minY)
            p1 = CGPoint(x: x, y: y)
            path.addLine(to: p1)

            for pointIndex in 1..<data.xValues.count {
                let index = data.xValues.count - pointIndex
                x = data.xValues[index].chartXPosition(minX: minMax.minX, maxX: minMax.maxX, frameWidth: rect.width)
                y = data.secondYValues[index].chartYPosition(yRange: yRange, frameHeight: rect.height, offset: minMax.minY)
                let p2 = CGPoint(x: x, y: y)
                path.addLine(to: p2)
                p1 = p2
            }

            x = data.xValues[0].chartXPosition(minX: minMax.minX, maxX: minMax.maxX, frameWidth: rect.width)
            y = data.secondYValues[0].chartYPosition(yRange: yRange, frameHeight: rect.height, offset: minMax.minY)
            p1 = CGPoint(x: x, y: y)
            path.addLine(to: p1)
            path.closeSubpath()
        }
    }

}
