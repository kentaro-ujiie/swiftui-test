//
//  BleGattService.swift
//  SwiftUITest
//
//  Created by k-ujiie on 2026/03/09.
//

import Foundation
import CoreBluetooth

struct BleGattService: Identifiable, Hashable {
    var id: String { uuidString }
    let uuidString: String
    let isPrimary: Bool

    init(_ service: CBService) {
        self.uuidString = service.uuid.uuidString
        self.isPrimary = service.isPrimary
    }
}
