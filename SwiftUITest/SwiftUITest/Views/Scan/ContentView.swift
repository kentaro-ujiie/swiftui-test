//
//  ContentView.swift
//  SwiftUITest
//
//  Created by k-ujiie on 2026/03/03.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    
    @StateObject private var vm = BleScanViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                VStack(spacing: 8) {
                    Text(stateText(vm.bluetoothState))
                        .font(.caption)
                        .foregroundStyle(vm.bluetoothState == .poweredOn ? .green : .red)

                    HStack {
                        Button(vm.isScanning ? "Stop Scan" : "Start Scan") {
                            vm.toggleScan()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(vm.bluetoothState != .poweredOn)

                        if vm.isScanning { ProgressView() }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                List(vm.devices) { device in
                    Button {
                        vm.select(device)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(device.name).font(.headline)
                            Text(device.identifier.uuidString)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            HStack {
                                Text("RSSI: \(device.rssi)")
                                Spacer()
                                Text(device.lastSeen, style: .time)
                                    .foregroundStyle(.secondary)
                            }
                            .font(.caption)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Ble Scan")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") { vm.clear() }
                        .disabled(vm.isScanning)
                }
            }
            .navigationDestination(item: $vm.selectedDevice) { device in
                BleDeviceDetailView(device: device, centralService: vm.centralService)
            }
        }
    }

    private func stateText(_ state: CBManagerState) -> String {
        switch state {
        case .unknown: return "Bluetooth: unknown"
        case .resetting: return "Bluetooth: resetting"
        case .unsupported: return "Bluetooth: unsupported"
        case .unauthorized: return "Bluetooth: unauthorized"
        case .poweredOff: return "Bluetooth: powered off"
        case .poweredOn: return "Bluetooth: powered on"
        @unknown default: return "Bluetooth: (new state)"
        }
    }
}

#Preview {
    ContentView()
}
