//
//  Lines.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 15/12/2021.
//

import SwiftUI

struct Lines: View {
    public init(data: [LineChartData],
                minMax: MinMax,
                lineAnimation: Animation = .default,
                highlightGesture: TapGesture = TapGesture(),
                tappedHighlight: Binding<LineHighlightData?>) {
        self.data = data
        self.lineAnimation = lineAnimation
        self.tappedHighlight = tappedHighlight
        self.highlightGesture = highlightGesture
        self.minMax = minMax
    }

    let data: [LineChartData]
    let minMax: MinMax

    let lineAnimation: Animation

    var tappedHighlight: Binding<LineHighlightData?>
    private var highlightGesture: TapGesture

    public var body: some View {
        GeometryReader { info in
            ZStack {
                ForEach(data) {
                    Line(frame: info.frame(in: .local),
                         data: $0,
                         minMax: minMax,
                         lineAnimation: lineAnimation,
                         highlightGesture: highlightGesture,
                         tappedHighlight: tappedHighlight)
                }
                .drawingGroup()
            }
        }
    }

}

struct Lines_Previews: PreviewProvider {
    static var previews: some View {
        Lines(data: [PreviewData.potValueData, PreviewData.potContributionData],
              minMax: PreviewData.potValueData.minMax, tappedHighlight: .constant(nil))
    }
}
