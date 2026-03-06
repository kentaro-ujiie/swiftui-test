//
//  DeviceRow.swift
//  SwiftUITest
//
//  Created by k-ujiie on 2026/03/04.
//

import SwiftUI

struct DeviceRow: View {
    let device: BleDevice
    let emphasizeProximity: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(device.name)
                    .font(.headline)

                Spacer()

                Text("RSSI \(device.rssi)")
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(rssiColor)
            }

            // 近さの可視化（並び替えはしない）
            ProgressView(value: proximityNormalized)
                .tint(rssiColor)
                .opacity(emphasizeProximity ? 1.0 : 0.6)

            HStack {
                Text(device.identifier.uuidString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                Text(device.lastSeen, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    /// RSSI(-100...-40) を 0...1 に丸める（端末/環境でブレるので目安）
    private var proximityNormalized: Double {
        let minRSSI = -100.0
        let maxRSSI = -40.0
        let r = Double(device.rssi)

        // RSSIが変な値の時は0扱い
        guard r < 0 else { return 0 }

        let clamped = min(max(r, minRSSI), maxRSSI)
        return (clamped - minRSSI) / (maxRSSI - minRSSI)
    }

    private var rssiColor: Color {
        switch proximityNormalized {
        case 0.66...: return .green
        case 0.33...: return .yellow
        default: return .red
        }
    }
}
