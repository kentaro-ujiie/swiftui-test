//
//  BleCharacteristicsView.swift
//  SwiftUITest
//
//  Created by k-ujiie on 2026/03/11.
//

import SwiftUI
import CoreBluetooth

struct BleCharacteristicsView: View {
    let deviceId: UUID
    let serviceUUIDString: String
    let centralService: BleCentralService

    @StateObject private var vm: BleCharacteristicsViewModel

    init(deviceId: UUID, serviceUUIDString: String, centralService: BleCentralService) {
        self.deviceId = deviceId
        self.serviceUUIDString = serviceUUIDString
        self.centralService = centralService

        let cbUUID = CBUUID(string: serviceUUIDString)
        _vm = StateObject(wrappedValue: BleCharacteristicsViewModel(deviceId: deviceId,
                                                                   serviceUUID: cbUUID,
                                                                   central: centralService))
    }

    var body: some View {
        List {
            if let error = vm.errorText {
                Section {
                    Text(error).foregroundStyle(.red)
                }
            }

            Section("Service UUID") {
                Text(serviceUUIDString)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Characteristics") {
                if vm.characteristics.isEmpty {
                    Text("Loading...")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(vm.characteristics) { c in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(c.uuidString).font(.body)
                            HStack {
                                Text("properties: \(c.propertiesText)")
                                Spacer()
                                if c.isNotifying {
                                    Text("notifying")
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Characteristics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.onAppear() }
    }
}
