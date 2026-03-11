//
//  BleDeviceDetailView.swift
//  SwiftUITest
//
//  Created by k-ujiie on 2026/03/05.
//

import SwiftUI
import CoreBluetooth

struct BleDeviceDetailView: View {
    let device: BleDevice
    let centralService: BleCentralService

    @StateObject private var vm: BleDeviceDetailViewModel

    init(device: BleDevice, centralService: BleCentralService) {
        self.device = device
        self.centralService = centralService
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
                ForEach(vm.services) { s in
                    Button {
                        vm.selectService(s.uuidString)
                    } label: {
                        HStack {
                            Text(s.uuidString)
                            Spacer()
                            if s.isPrimary {
                                Text("Primary")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                if vm.services.isEmpty {
                    Text(vm.state == .ready ? "No services." : "Loading...")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Device Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.onAppear() }
        .navigationDestination(item: $vm.selectedServiceUUID) { serviceUUIDString in
            BleCharacteristicsView(deviceId: device.identifier,
                                   serviceUUIDString: serviceUUIDString,
                                   centralService: centralService)
        }
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
