//
//  Double+ChartHelpers.swift
//  FlowKit (iOS)
//
//  Created by Jacob Whitehead on 20/12/2021.
//

import SwiftUI

extension Double {

    func chartXPosition(minX: Double, maxX: Double,
                        frameWidth: CGFloat) -> CGFloat {
        let relativePos = self - minX
        guard relativePos > 0 else {
            return 0
        }

        let positionPercentage = relativePos / (maxX - minX)
        return frameWidth * positionPercentage
    }

    func chartYPosition(yRange: Double, frameHeight: CGFloat, offset: CGFloat) -> CGFloat {
        guard yRange > 0 else { return 0 }
        return frameHeight - (self - offset) * (frameHeight / CGFloat(yRange))
    }

}
