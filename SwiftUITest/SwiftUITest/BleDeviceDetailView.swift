//
//  BleDeviceDetailView.swift
//  SwiftUITest
//
//  Created by k-ujiie on 2026/03/05.
//

import SwiftUI

struct BleDeviceDetailView: View {
    let device: BleDevice

    var body: some View {
        List {
            Section("Device") {
                LabeledContent("Name", value: device.name)
                LabeledContent("UUID", value: device.identifier.uuidString)
            }

            Section("Signal") {
                LabeledContent("RSSI", value: "\(device.rssi)")
                LabeledContent("Last Seen", value: device.lastSeen.formatted(date: .omitted, time: .standard))
            }
        }
        .navigationTitle("Device Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
