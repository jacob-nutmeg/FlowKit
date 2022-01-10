//
//  ContentView.swift
//  Shared
//
//  Created by Jacob Whitehead on 14/12/2021.
//

import SwiftUI

struct Line: View {

    let frame: CGRect
    let data: ChartData
    var lineWidth: CGFloat = 2

    var minXPoint: Double?
    var maxXPoint: Double?
    @Binding var minYPoint: Double
    @Binding var maxYPoint: Double

    var lineAnimation: Animation = .default
    var highlightAnimation: Animation = .default
    var highlight: CGPoint? = nil

    private var minX: Double {
        minXPoint ?? data.xPoints.min() ?? 0
    }

    private var maxX: Double {
        maxXPoint ?? data.xPoints.max() ?? 0
    }

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
                      minXPoint: minX, maxXPoint: maxX,
                      minYPoint: minYPoint, maxYPoint: maxYPoint)
                .fill(fillGradient).hueRotation(.degrees(45))
                .opacity(completion)

            LineShape(data: data, isClosed: false,
                      minXPoint: minX, maxXPoint: maxX,
                      minYPoint: minYPoint, maxYPoint: maxYPoint)
                .trim(from: 0, to: completion)
                .stroke(lineGradient, style: strokeStyle)

            if let highlight = highlight {
                LinePointView()
                    .offset(x: Double(highlight.x).chartXPosition(minX: minX, maxX: maxX, frame: frame) - frame.width/2,
                            y: Double(highlight.y).chartYPosition(yRange: (maxYPoint - minYPoint),
                                                                  frame: frame, offset: minYPoint) - frame.height/2)
                    .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
            }
            
        }
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
                 minYPoint: .constant([PreviewData.lineData].minYPoint()),
                 maxYPoint: .constant([PreviewData.lineData].maxYPoint()))
        }
    }
}
