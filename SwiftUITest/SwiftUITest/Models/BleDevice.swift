//
//  BleDevice.swift
//  SwiftUITest
//
//  Created by k-ujiie on 2026/03/04.
//

import Foundation
import CoreBluetooth

struct BleDevice: Identifiable, Hashable {
    var id: UUID { identifier }
    let identifier: UUID

    var name: String
    var rssi: Int
    var lastSeen: Date
    
    // Hashable（identifierだけでOK）
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    // Equatable も identifier だけで同一扱いにする（Hashableと整合）
    static func == (lhs: BleDevice, rhs: BleDevice) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
