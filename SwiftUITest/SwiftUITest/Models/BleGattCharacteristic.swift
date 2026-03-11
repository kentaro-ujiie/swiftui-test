//
//  BleGattCharacteristic.swift
//  SwiftUITest
//
//  Created by k-ujiie on 2026/03/11.
//

import Foundation
import CoreBluetooth

struct BleGattCharacteristic: Identifiable, Hashable {
    var id: String { uuidString }

    let uuidString: String
    let propertiesText: String
    let isNotifying: Bool

    init(_ c: CBCharacteristic) {
        self.uuidString = c.uuid.uuidString
        self.isNotifying = c.isNotifying
        self.propertiesText = BleGattCharacteristic.describe(c.properties)
    }

    private static func describe(_ p: CBCharacteristicProperties) -> String {
        var parts: [String] = []
        if p.contains(.read) { parts.append("read") }
        if p.contains(.write) { parts.append("write") }
        if p.contains(.writeWithoutResponse) { parts.append("writeWithoutResponse") }
        if p.contains(.notify) { parts.append("notify") }
        if p.contains(.indicate) { parts.append("indicate") }
        if p.contains(.authenticatedSignedWrites) { parts.append("signedWrite") }
        if p.contains(.extendedProperties) { parts.append("extended") }
        if p.contains(.broadcast) { parts.append("broadcast") }
        return parts.isEmpty ? "-" : parts.joined(separator: ", ")
    }
}
