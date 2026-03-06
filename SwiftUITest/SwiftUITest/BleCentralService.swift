//
//  BleCentralService.swift
//  SwiftUITest
//
//  Created by k-ujiie on 2026/03/04.
//

import Foundation
import CoreBluetooth

final class BleCentralService: NSObject {
    private var central: CBCentralManager!

    var onDiscover: ((CBPeripheral, NSNumber) -> Void)?
    var onStateChange: ((CBManagerState) -> Void)?

    private(set) var isScanning: Bool = false

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    func startScan() {
        guard central.state == .poweredOn else { return }
        guard !isScanning else { return }
        isScanning = true

        // 重複検出を許可（RSSI更新を取り続ける）
        central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }

    func stopScan() {
        guard isScanning else { return }
        isScanning = false
        central.stopScan()
    }
}

extension BleCentralService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        onStateChange?(central.state)
        if central.state != .poweredOn {
            stopScan()
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        onDiscover?(peripheral, RSSI)
    }
}
