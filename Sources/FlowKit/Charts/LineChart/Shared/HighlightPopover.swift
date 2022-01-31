//
//  HighlightPopover.swift
//  
//
//  Created by Jacob Whitehead on 31/01/2022.
//

import SwiftUI

struct HighlightPopover<Label: View>: View {

    let currentFrame: CGRect
    let highlight: LineChartData.Highlight
    let minMax: MinMax
    let insets: EdgeInsets

    @ViewBuilder var content: Label

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.white.opacity(0.8))
                    .shadow(radius: 8)

                content
            }
        }
        .frame(maxWidth: 140, maxHeight: 200, alignment: .top)
        .position(x: xPos(),
                  y: Double(highlight.point.y).chartYPosition(yRange: (minMax.maxY - minMax.minY),
                                                              frame: currentFrame, offset: minMax.minY) - insets.bottom)
        .transition(.opacity.combined(with: .scale(scale: 0.8)))
    }

    private func xPos() -> CGFloat {
        let minXPosition = minMax.minX.chartXPosition(minX: minMax.minX, maxX: minMax.maxX, frame: currentFrame)
        let maxXPosition = minMax.maxX.chartXPosition(minX: minMax.minX, maxX: minMax.maxX, frame: currentFrame)
        let relativeMiddle = minMax.minX + (minMax.maxX - minMax.minX)/2
        let middleXPosition = relativeMiddle.chartXPosition(minX: minMax.minX, maxX: minMax.maxX, frame: currentFrame)
        let proposedX = Double(highlight.point.x).chartXPosition(minX: minMax.minX, maxX: minMax.maxX, frame: currentFrame) + (insets.trailing) - (insets.leading)
        let padding: CGFloat = proposedX > middleXPosition ? -70 : 70
        return min(max(minXPosition, proposedX), maxXPosition) + padding
    }
}
