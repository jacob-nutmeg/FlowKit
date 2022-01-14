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

    @Binding var minXPoint: Double
    @Binding var maxXPoint: Double
    @Binding var minYPoint: Double
    @Binding var maxYPoint: Double

    var lineAnimation: Animation = .default
    var highlightAnimation: Animation = .default
    var highlight: CGPoint? = nil

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
                      minXPoint: minXPoint, maxXPoint: maxXPoint,
                      minYPoint: minYPoint, maxYPoint: maxYPoint)
                .fill(fillGradient).hueRotation(.degrees(45))
                .opacity(completion)

            LineShape(data: data, isClosed: false,
                      minXPoint: minXPoint, maxXPoint: maxXPoint,
                      minYPoint: minYPoint, maxYPoint: maxYPoint)
                .trim(from: 0, to: completion)
                .stroke(lineGradient, style: strokeStyle)

            if let highlight = highlight {
                LinePointView()
                    .position(x: Double(highlight.x).chartXPosition(minX: minXPoint, maxX: maxXPoint, frame: frame),
                              y: Double(highlight.y).chartYPosition(yRange: (maxYPoint - minYPoint),
                                                                     frame: frame, offset: minYPoint))
            }
            
        }
        .drawingGroup()
        .onAppear {
            withAnimation(lineAnimation) {
                self.completion = 1
            }
        }
    }
}

struct Line_Previews: PreviewProvider {

    static var previews: some View {
        GeometryReader { info in
            Line(frame: info.frame(in: .local),
                 data: PreviewData.lineData,
                 minXPoint: .constant([PreviewData.potValueData].minXPoint()),
                 maxXPoint: .constant([PreviewData.potValueData].maxXPoint()),
                 minYPoint: .constant([PreviewData.lineData].minYPoint()),
                 maxYPoint: .constant([PreviewData.lineData].maxYPoint()))
        }
    }
}
