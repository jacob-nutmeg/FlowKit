//
//  MinMax.swift
//  
//
//  Created by Jacob Whitehead on 27/01/2022.
//

import Foundation

struct MinMax: Equatable {
    static var zero = MinMax(minY: 0, maxY: 0, minX: 0, maxX: 0)

    var minY: Double
    var maxY: Double
    var minX: Double
    var maxX: Double
}
