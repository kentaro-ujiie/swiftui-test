//
//  BleDeviceDetailView.swift
//  SwiftUITest
//
//  Created by k-ujiie on 2026/03/05.
//

import SwiftUI

struct BleDeviceDetailView: View {
    let device: BleDevice
    @StateObject private var vm: BleDeviceDetailViewModel

    init(device: BleDevice, centralService: BleCentralService) {
        self.device = device
        _vm = StateObject(wrappedValue: BleDeviceDetailViewModel(deviceId: device.identifier,
                                                                service: centralService))
    }

    var body: some View {
        List {
            Section("Device") {
                LabeledContent("Name", value: device.name)
                LabeledContent("UUID", value: device.identifier.uuidString)
                LabeledContent("State", value: stateText(vm.state))
            }

            Section("GATT Services") {
                if vm.services.isEmpty {
                    Text(vm.state == .ready ? "No services." : "Loading...")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(vm.services) { s in
                        HStack {
                            Text(s.uuidString).font(.body)
                            Spacer()
                            if s.isPrimary {
                                Text("Primary")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            Section {
                Button("Disconnect") {
                    vm.disconnect()
                }
                .disabled(vm.state == .disconnected || vm.state == .idle)
            }
        }
        .navigationTitle("Device Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.onAppear() }
    }

    private func stateText(_ state: BleConnectionState) -> String {
        switch state {
        case .idle: return "idle"
        case .connecting: return "connecting"
        case .connected: return "connected"
        case .discoveringServices: return "discovering services"
        case .ready: return "ready"
        case .failed(let msg): return "failed: \(msg)"
        case .disconnected: return "disconnected"
        }
    }
}
