//
//  PotValueData.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 22/12/2021.
//

import Foundation

public struct PotValueData: Decodable {

    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }

    struct DataPoint: Decodable {
        let overallValue: Double
        let returnValue: Double
        let simpleReturnPercent: Double
        let date: Date
        let totalContribution: Double
    }

    let points: [DataPoint]
}

extension LineChartData {

    static func createFromPotValue(_ potValue: PotValueData) -> LineChartData {
        var yVals = [Double]()
        var uniqueXPoints = Array(Set(potValue.points.map { $0.date.timeIntervalSince1970 }))
        uniqueXPoints.sort()

        for xPoint in uniqueXPoints {
            guard let yPoint = potValue.points.first(where: { $0.date.timeIntervalSince1970 == xPoint }) else { continue }
            yVals.append(yPoint.overallValue)
        }

        return LineChartData(id: "potValue",
                         xPoints: uniqueXPoints,
                         yPoints: yVals,
                         lineColors: [.green, .blue],
                         isCurved: true,
                         fillColors: [.blue.opacity(0.01), .blue.opacity(0.1)])
    }

    static func contributionsData(from potValue: PotValueData) -> LineChartData {
        var yVals = [Double]()
        var uniqueXPoints = Array(Set(potValue.points.map { $0.date.timeIntervalSince1970 }))
        uniqueXPoints.sort()

        for xPoint in uniqueXPoints {
            guard let yPoint = potValue.points.first(where: { $0.date.timeIntervalSince1970 == xPoint }) else { continue }
            yVals.append(yPoint.totalContribution)
        }

        return LineChartData(id: "potContributions",
                         xPoints: uniqueXPoints,
                         yPoints: yVals,
                         lineColors: [.blue.opacity(0.4), .blue.opacity(0.8)],
                         isCurved: true,
                         fillColors: [])
    }

}
