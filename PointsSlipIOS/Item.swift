//
//  Item.swift
//  PointsSlipIOS
//
//  Created by Ari Greene Cummings on 7/16/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
