//
//  ContentView.swift
//  Shared
//
//  Created by Jacob Whitehead on 14/12/2021.
//

import SwiftUI

struct Line: View {

    let frame: CGRect
    let data: LineChartData
    var lineWidth: CGFloat = 2

    let minMax: MinMax

    var lineAnimation: Animation = .default

    var highlightGesture: TapGesture
    @Binding var tappedHighlight: LineHighlightData?

    private var lineGradient: LinearGradient {
        LinearGradient(colors: data.lineColors,
                       startPoint: .leading, endPoint: .trailing)
    }

    private var fillGradient: LinearGradient {
        LinearGradient(colors: data.fillColors ?? [],
                       startPoint: completion == 1 ? .top : .bottom, endPoint: .bottom)
    }

    private var strokeStyle: StrokeStyle {
        StrokeStyle(lineWidth: lineWidth,
                    lineJoin: data.isCurved ? .round : .bevel)
    }

    @State private var completion: CGFloat = 0

    var body: some View {
        ZStack {
            LineShape(data: data, isClosed: true,
                      minXPoint: minMax.minX, maxXPoint: minMax.maxX,
                      minYPoint: minMax.minY, maxYPoint: minMax.maxY)
                .fill(fillGradient).hueRotation(.degrees(45))
                .opacity(completion)
                .animation(lineAnimation, value: completion)

            LineShape(data: data, isClosed: false,
                      minXPoint: minMax.minX, maxXPoint: minMax.maxX,
                      minYPoint: minMax.minY, maxYPoint: minMax.maxY)
                .trim(from: 0, to: completion)
                .stroke(lineGradient, style: strokeStyle)
                .animation(lineAnimation, value: completion)

            ForEach(data.highlights, id: \.point.x) { highlight in
                Button(action: {
                    guard self.tappedHighlight?.point.x != highlight.point.x else { self.tappedHighlight = nil; return }
                    self.tappedHighlight = highlight
                }) {
                    LinePointView(size: highlight.size, innerColor: highlight.innerColor, outerColor: highlight.outerColor ?? .clear)
                }
                .position(x: Double(highlight.point.x).chartXPosition(minX: minMax.minX, maxX: minMax.maxX, frame: frame),
                          y: Double(highlight.point.y).chartYPosition(yRange: (minMax.maxY - minMax.minY),
                                                                      frame: frame, offset: minMax.minY))
            }
        }
        .onAppear {
            self.completion = 1
        }
        .drawingGroup()
    }

}

struct Line_Previews: PreviewProvider {

    static var previews: some View {
        GeometryReader { info in
            Line(frame: info.frame(in: .local),
                 data: PreviewData.lineData,
                 minMax: PreviewData.lineData.minMax,
                 highlightGesture: TapGesture(),
                 tappedHighlight: .constant(nil))
        }
    }
}
