//
//  BleChracteristicsViewModel.swift
//  SwiftUITest
//
//  Created by k-ujiie on 2026/03/11.
//

import Foundation
import CoreBluetooth
import Combine

@MainActor
final class BleCharacteristicsViewModel: ObservableObject {
    @Published private(set) var characteristics: [BleGattCharacteristic] = []
    @Published private(set) var errorText: String?

    private let deviceId: UUID
    private let serviceUUID: CBUUID
    private let central: BleCentralService

    init(deviceId: UUID, serviceUUID: CBUUID, central: BleCentralService) {
        self.deviceId = deviceId
        self.serviceUUID = serviceUUID
        self.central = central

        central.onCharacteristicsUpdated = { [weak self] id, svcUUID, chars in
            guard let self else { return }
            guard id == self.deviceId, svcUUID == self.serviceUUID else { return }
            Task { @MainActor in
                self.characteristics = chars.map(BleGattCharacteristic.init)
            }
        }

        central.onPeripheralError = { [weak self] id, error in
            guard let self else { return }
            guard id == self.deviceId else { return }
            Task { @MainActor in
                self.errorText = error.localizedDescription
            }
        }
    }

    func onAppear() {
        central.discoverCharacteristics(id: deviceId, serviceUUID: serviceUUID, characteristicUUIDs: nil) // nilで全characteristic
    }
}
