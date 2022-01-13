//
//  PreviewData.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 15/12/2021.
//

import UIKit

struct StubDataLoadError: Error { }

public class PreviewData {

    public static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "en_GB")
        return formatter
    }

    public static var dateYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        formatter.locale = Locale(identifier: "en_GB")
        return formatter
    }

    public static var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.locale = Locale(identifier: "en_GB")
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter
    }

    public static var oneMonthInterval: Double {
        let date = Date()
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: date) ?? Date()
        return date.timeIntervalSince1970 - monthAgo.timeIntervalSince1970
    }

    public static var threeMonthInterval: Double {
        let date = Date()
        let monthAgo = Calendar.current.date(byAdding: .month, value: -3, to: date) ?? Date()
        return date.timeIntervalSince1970 - monthAgo.timeIntervalSince1970
    }

    public static let pointsY: [Double] = [40, 50, 44, 22, 25, 2, 40,
                                    29, 24, 30, 32, 33, 34, 32]

    public static let pointsY2: [Double] = [222, 343, 444, 342, 444, 222, 123,
                                     73, 43, 66, 34, 54, 66, 88]

    public static let pointsX: [Double] = [10, 20, 30, 40, 50, 60, 70,
                                       80, 90, 100, 110, 120, 130, 140]

    public static let pointsX2: [Double] = [10, 20, 30, 40, 50, 60, 70,
                                        80, 90, 100, 110, 120, 130, 140]

    public static let pointsXUneven: [Double] = [10, 12, 15, 25, 33, 45, 70,
                                          80, 90, 100, 110, 150, 165, 250]

    public static let lineDataHighlights = [CGPoint(x: 50, y: 25), CGPoint(x: 120, y: 33)]

    public static let lineData = LineChartData(id: "data",
                                    xPoints: pointsX,
                                    yPoints: pointsY,
                                    lineColors: [.blue],
                                    isCurved: true,
                                    fillColors: [.blue.opacity(0.01), .blue.opacity(0.4)])

    public static let lineData2 = LineChartData(id: "data2",
                                     xPoints: pointsX2,
                                     yPoints: pointsY2,
                                     lineColors: [.green],
                                     isCurved: true,
                                     fillColors: [.blue.opacity(0.2)])

    public static let lineDataUneven = LineChartData(id: "data2",
                                          xPoints: pointsXUneven,
                                          yPoints: pointsY,
                                          lineColors: [.green],
                                          isCurved: true,
                                          fillColors: [.blue.opacity(0.2)])

    public static var potValue: PotValueData {
        let data = try! jsonData(fileName: "potValue")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(PotValueData.dateFormatter)
        return try! decoder.decode(PotValueData.self, from: data)
    }

    public static var potProjection: PotProjectionData {
        let data = try! jsonData(fileName: "getProjectedPerformance")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(PotValueData.dateFormatter)
        return try! decoder.decode(PotProjectionData.self, from: data)
    }

    public static var potValueData: LineChartData = LineChartData.createFromPotValue(potValue)
    public static var potContributionData: LineChartData = LineChartData.contributionsData(from: potValue)

    public static var likelyFanData = PotProjectionData.projectionLikelyFanData(from: potProjection)
    public static var unlikelyFanDataLow = PotProjectionData.projectionUnlikelyLowFanData(from: potProjection)
    public static var unlikelyFanDataHigh = PotProjectionData.projectionUnlikelyHighFanData(from: potProjection)
}

extension PreviewData {

    static func jsonData(fileName: String) throws -> Data {
        guard let path = Bundle.module.path(forResource: fileName, ofType: "json") else {
            throw StubDataLoadError()
        }

        do {
            let string = try String(contentsOfFile: path, encoding: .utf8)
            guard let data = string.data(using: .utf8) else { throw StubDataLoadError() }
            return data
        } catch {
            throw error
        }
    }

}
