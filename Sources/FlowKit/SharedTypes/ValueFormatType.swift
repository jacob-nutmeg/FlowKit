//
//  ValueFormatType.swift
//  
//
//  Created by Jacob Whitehead on 13/01/2022.
//

import Foundation

public enum ValueFormatType {
    case value
    case date(formatter: DateFormatter)
    case number(formatter: NumberFormatter)
    case text(specifier: String)
}
