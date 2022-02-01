//
//  HighlightPopover.swift
//  
//
//  Created by Jacob Whitehead on 31/01/2022.
//

import SwiftUI

struct HighlightPopover<Label: View>: View {

    let currentFrame: CGRect
    let highlight: LineHighlightData
    let minMax: MinMax
    let insets: EdgeInsets
    var idealWidth: CGFloat = 120
    var margin: CGFloat = 12

    @ViewBuilder var content: Label

    var body: some View {
        GeometryReader { proxy in
            content.padding()
                .background(RoundedRectangle(cornerRadius: 4).fill(.white))
                .shadow(radius: 8)
        }
        .position(x: xPos(),
                  y: Double(highlight.point.y).chartYPosition(yRange: (minMax.maxY - minMax.minY),
                                                              frame: currentFrame, offset: minMax.minY) + insets.bottom)
        .transition(.scale(scale: 0.8, anchor: .center).combined(with: .opacity))
    }

    private func xPos() -> CGFloat {
        let minXPosition = minMax.minX.chartXPosition(minX: minMax.minX, maxX: minMax.maxX, frame: currentFrame)
        let maxXPosition = minMax.maxX.chartXPosition(minX: minMax.minX, maxX: minMax.maxX, frame: currentFrame)
        let relativeMiddle = minMax.minX + (minMax.maxX - minMax.minX)/2
        let middleXPosition = relativeMiddle.chartXPosition(minX: minMax.minX, maxX: minMax.maxX, frame: currentFrame)
        let proposedX = Double(highlight.point.x).chartXPosition(minX: minMax.minX, maxX: minMax.maxX, frame: currentFrame) + (insets.leading) - (insets.trailing)
        let padding: CGFloat = proposedX > middleXPosition ? -(idealWidth/2 + margin) : (idealWidth/2 + margin)
        return min(max(minXPosition, proposedX), maxXPosition) + padding
    }
}
