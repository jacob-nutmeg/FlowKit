//
//  PotProjectionData.swift
//  FlowKit
//
//  Created by Jacob Whitehead on 03/01/2022.
//

import SwiftUI

struct PotProjectionData: Decodable {

    struct CubicData {
        var dates: [Date]
        var performance: [Percentile: [Double]]
        var contributions: [Double]
    }

    enum Percentile: String, CaseIterable, Decodable, Comparable, Equatable {
        static func < (lhs: PotProjectionData.Percentile, rhs: PotProjectionData.Percentile) -> Bool {
            if highest.contains(lhs) { return false }
            if lowest.contains(lhs), highest.contains(rhs) { return false }
            return true
        }

        case P5, P25, P50, P75, P95

        static var lowest: [Percentile] = [.P5, .P25, .P95]
        static var highest: [Percentile] = [.P75, .P50]
    }

    let dates: [Date]
    let contributions: [Double]
    let performance: [Percentile: [Double]]

    enum CodingKeys: String, CodingKey {
        case dates, contributions, performance
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dates = try container.decode([Date].self, forKey: .dates)
        contributions = try container.decode([Double].self, forKey: .contributions)
        let performanceDict = try container.decode([String: [Double]].self, forKey: .performance)
        var performance = [Percentile: [Double]]()
        for (key, array) in performanceDict {
            guard let percentile = Percentile(rawValue: key) else {
                continue
            }
            performance[percentile] = array
        }

        self.performance = performance
    }
}

extension PotProjectionData {

    static func projectionLikelyFanData(from data: PotProjectionData) -> FanChartData {
        let cubicData = data.cubicData()
        let xPoints = cubicData.dates.map { $0.timeIntervalSince1970 }
        return FanChartData(id: "likely",
                            xValues: xPoints,
                            firstYValues: cubicData.performance[.P50] ?? [],
                            secondYValues: cubicData.performance[.P75] ?? [],
                            colors: [.blue.opacity(0.6)])
    }

    static func projectionUnlikelyHighFanData(from data: PotProjectionData) -> FanChartData {
        let cubicData = data.cubicData()
        let xPoints = cubicData.dates.map { $0.timeIntervalSince1970 }
        return FanChartData(id: "unlikelyHigh",
                            xValues: xPoints,
                            firstYValues: cubicData.performance[.P75] ?? [],
                            secondYValues: cubicData.performance[.P95] ?? [],
                            colors: [.blue.opacity(0.2)])
    }

    static func projectionUnlikelyLowFanData(from data: PotProjectionData) -> FanChartData {
        let cubicData = data.cubicData()
        let xPoints = cubicData.dates.map { $0.timeIntervalSince1970 }
        return FanChartData(id: "unlikelyLow",
                            xValues: xPoints,
                            firstYValues: cubicData.performance[.P50] ?? [],
                            secondYValues: cubicData.performance[.P25] ?? [],
                            colors: [.blue.opacity(0.2)])
    }

    func cubicData() -> CubicData {
        var filtered = performance
        var datesAdded = [(Int, Int)]()
        var filteredDates = dates
        var filteredContributions = contributions
        let calendar = Calendar.autoupdatingCurrent

        var addedFirst = false

        for date in dates {
            let components = calendar.dateComponents([.year, .month], from: date)

            guard let year = components.year, let month = components.month else {
                continue
            }

            if !addedFirst {
                datesAdded.append((month, year))
                addedFirst = true
            } else if datesAdded.contains(where: { $0.0 == month && $0.1 != year }) {
                datesAdded.append((month, year))
            } else if let index = filteredDates.firstIndex(of: date) {
                filteredDates.remove(at: index)
                filteredContributions.remove(at: index)
                for percentile in Percentile.allCases {
                    filtered[percentile]?.remove(at: index)
                }
            }
        }

        return CubicData(dates: filteredDates, performance: filtered, contributions: filteredContributions)
    }

}
