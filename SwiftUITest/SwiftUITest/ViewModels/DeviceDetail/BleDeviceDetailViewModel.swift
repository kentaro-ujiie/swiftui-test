//
//  BleDeviceDetailViewModel.swift
//  SwiftUITest
//
//  Created by k-ujiie on 2026/03/09.
//

import Foundation
import CoreBluetooth
import Combine

@MainActor
final class BleDeviceDetailViewModel: ObservableObject {
    @Published private(set) var state: BleConnectionState = .idle
    @Published private(set) var services: [BleGattService] = []
    @Published var selectedServiceUUID: String?

    private let deviceId: UUID
    private let service: BleCentralService

    init(deviceId: UUID, service: BleCentralService) {
        self.deviceId = deviceId
        self.service = service

        // イベント購読（必要なものだけ使う）
        service.onConnect = { [weak self] id in
            guard let self, id == self.deviceId else { return }
            Task { @MainActor in
                self.state = .connected
                self.state = .discoveringServices
                self.service.discoverServices(id: self.deviceId, serviceUUIDs: nil)
            }
        }

        service.onFailToConnect = { [weak self] id, error in
            guard let self, id == self.deviceId else { return }
            Task { @MainActor in
                self.state = .failed(error?.localizedDescription ?? "Failed to connect.")
            }
        }

        service.onDisconnect = { [weak self] id, error in
            guard let self, id == self.deviceId else { return }
            Task { @MainActor in
                self.state = .disconnected
            }
        }

        service.onServicesUpdated = { [weak self] id, cbServices in
            guard let self, id == self.deviceId else { return }
            Task { @MainActor in
                self.services = cbServices.map(BleGattService.init)
                self.state = .ready
            }
        }

        service.onPeripheralError = { [weak self] id, error in
            guard let self, id == self.deviceId else { return }
            Task { @MainActor in
                self.state = .failed(error.localizedDescription)
            }
        }
    }

    func onAppear() {
        guard case .idle = state else { return }
        state = .connecting
        service.connect(id: deviceId)
    }

    func disconnect() {
        service.disconnect(id: deviceId)
    }
    
    func selectService(_ uuidString: String) {
        selectedServiceUUID = uuidString
    }
}
