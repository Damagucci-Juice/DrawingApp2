//
//  Alpha.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/07/05.
//

import Foundation
import UIKit

enum Alpha {
    case one, two, three, four, five, six, seven, eight, nine, ten
    
    var value: Double {
        switch self {
        case .one:
            return 0.1
        case .two:
            return 0.2
        case .three:
            return 0.3
        case .four:
            return 0.4
        case .five:
            return 0.5
        case .six:
            return 0.6
        case .seven:
            return 0.7
        case .eight:
            return 0.8
        case .nine:
            return 0.9
        case .ten:
            return 1.0
        }
    }
}


