//
//  HighlightPopover.swift
//  
//
//  Created by Jacob Whitehead on 31/01/2022.
//

import SwiftUI

struct HighlightPopover<Label: View>: View {

    let frameSize: CGSize
    let highlight: LineHighlightData
    let minMax: MinMax
    let insets: EdgeInsets
    var maxWidth: CGFloat = 100
    var margin: CGFloat = 8

    @ViewBuilder var content: Label

    var body: some View {
        content
            .frame(maxWidth: maxWidth)
            .position(x: xPos(), y: yPos())
            .transition(.scale(scale: 0.975).combined(with: .opacity))
    }

    private func yPos() -> CGFloat {
        Double(highlight.point.y)
            .chartYPosition(yRange: (minMax.maxY - minMax.minY),
                            frameHeight: frameSize.height - insets.bottom,
                            offset: minMax.minY)
    }

    private func isToRightOfHighlight() -> Bool {
        let relativeMiddle = minMax.minX + (minMax.maxX - minMax.minX)/2
        let middleXPosition = relativeMiddle.chartXPosition(minX: minMax.minX, maxX: minMax.maxX,
                                                            frameWidth: frameSize.width)
        return proposedXPos() > middleXPosition
    }

    private func xPos() -> CGFloat {
        var proposedX = proposedXPos()
        let padding: CGFloat
        if isToRightOfHightlight() {
            padding = -maxWidth/2 - margin - highlight.size
        } else {
            padding = maxWidth/2 + margin + highlight.size
        }

        proposedX += padding
        return proposedX
    }

    private func proposedXPos() -> CGFloat {
        Double(highlight.point.x).chartXPosition(minX: minMax.minX, maxX: minMax.maxX,
                                                 frameWidth: frameSize.width)
    }
}
