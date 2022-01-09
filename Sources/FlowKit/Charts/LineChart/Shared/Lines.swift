//
//  Lines.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 15/12/2021.
//

import SwiftUI

struct Lines: View {
    let data: [ChartData]

    @Binding var tapLocation: CGPoint
    @Binding var minYPoint: Double
    @Binding var maxYPoint: Double

    var lineAnimation: Animation = .default

    var highlight: CGPoint? = nil
    
    var body: some View {
        GeometryReader { info in
            ZStack {
                ForEach(data) {
                    Line(frame: info.frame(in: .local),
                         data: $0,
                         minXPoint: data.minXPoint(),
                         maxXPoint: data.maxXPoint(),
                         minYPoint: $minYPoint,
                         maxYPoint: $maxYPoint,
                         lineAnimation: lineAnimation,
                         highlight: highlight)
                }.drawingGroup()
                Rectangle().fill(.clear)
                    .onTouch { location in
                        tapLocation = location
                    }
            }
        }
    }
}

struct Lines_Previews: PreviewProvider {
    static var previews: some View {
        Lines(data: [PreviewData.potValueData,
                     PreviewData.potContributionData],
              tapLocation: .constant(.zero),
              minYPoint: .constant([PreviewData.potValueData].minYPoint()),
              maxYPoint: .constant([PreviewData.potValueData].maxYPoint()))
    }
}
