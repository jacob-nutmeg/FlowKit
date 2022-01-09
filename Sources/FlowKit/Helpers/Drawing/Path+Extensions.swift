//
//  Path+Extensions.swift
//  FlowKit (iOS)
//
//  Created by Jacob Whitehead on 14/12/2021.
//

import SwiftUI

extension Path {

    static func line(from fromPoint: CGPoint, to toPoint: CGPoint) -> Path {
        Path { path in
            path.move(to: fromPoint)
            path.addLine(to: toPoint)
        }
    }

}

extension CGPoint {

    static func controlPointForPoints(p1: CGPoint, p2: CGPoint) -> CGPoint {
        var controlPoint = CGPoint.midPointForPoints(p1:p1, p2:p2)
        let diffY = abs(p2.y - controlPoint.y)

        if (p1.y < p2.y){
            controlPoint.y += diffY
        } else if (p1.y > p2.y) {
            controlPoint.y -= diffY
        }

        return controlPoint
    }

    static func midPointForPoints(p1:CGPoint, p2:CGPoint) -> CGPoint {
        CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }

}
