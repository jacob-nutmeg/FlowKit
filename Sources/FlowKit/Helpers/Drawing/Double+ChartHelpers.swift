//
//  Double+ChartHelpers.swift
//  FlowKit (iOS)
//
//  Created by Jacob Whitehead on 20/12/2021.
//

import SwiftUI

extension Double {

    func chartXPosition(minX: Double, maxX: Double, frame: CGRect) -> CGFloat {
        let relativePos = self - minX
        guard relativePos > 0 else {
            return 0
        }

        let positionPercentage = relativePos / (maxX - minX)
        return frame.width * positionPercentage
    }

    func chartYPosition(yRange: Double, frame: CGRect, offset: CGFloat) -> CGFloat {
        guard yRange > 0 else { return 0 }
        return frame.size.height - (self - offset) * (frame.size.height / CGFloat(yRange))
    }

}
