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

    // ★接続系イベント
    var onConnect: ((UUID) -> Void)?
    var onFailToConnect: ((UUID, Error?) -> Void)?
    var onDisconnect: ((UUID, Error?) -> Void)?
    var onServicesUpdated: ((UUID, [CBService]) -> Void)?
    var onPeripheralError: ((UUID, Error) -> Void)?
    
    // ★Peripheralのキャッシュ（スキャンで見つかった個体）
    private var peripheralsById: [UUID: CBPeripheral] = [:]

    // キャラクタリスティック取得イベント
    var onCharacteristicsUpdated: ((UUID, CBUUID, [CBCharacteristic]) -> Void)?
    
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
    
    // ★UUIDからCBPeripheralを取り出す（見つかっていないIDは接続できない）
    func peripheral(for id: UUID) -> CBPeripheral? {
        peripheralsById[id]
    }

    // ★接続開始
    func connect(id: UUID) {
        guard central.state == .poweredOn else { return }
        guard let p = peripheralsById[id] else { return }

        // delegateはここで必ず設定（discoverServicesの結果を受けるため）
        p.delegate = self
        central.connect(p, options: nil)
    }

    // ★切断
    func disconnect(id: UUID) {
        guard let p = peripheralsById[id] else { return }
        central.cancelPeripheralConnection(p)
    }

    // ★サービス探索
    func discoverServices(id: UUID, serviceUUIDs: [CBUUID]? = nil) {
        guard let p = peripheralsById[id] else { return }
        p.discoverServices(serviceUUIDs) // nilなら全部
    }
    
    // キャラクタリスティック探索
    func discoverCharacteristics(id: UUID, serviceUUID: CBUUID, characteristicUUIDs: [CBUUID]? = nil) {
        guard let p = peripheralsById[id] else { return }
        guard let services = p.services else { return }
        guard let target = services.first(where: { $0.uuid == serviceUUID }) else { return }

        p.discoverCharacteristics(characteristicUUIDs, for: target)
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
        peripheralsById[peripheral.identifier] = peripheral
        onDiscover?(peripheral, RSSI)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        onConnect?(peripheral.identifier)
    }

    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        onFailToConnect?(peripheral.identifier, error)
    }

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        onDisconnect?(peripheral.identifier, error)
    }
}

extension BleCentralService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let id = peripheral.identifier

        if let error {
            onPeripheralError?(id, error)
            return
        }

        onServicesUpdated?(id, peripheral.services ?? [])
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        let id = peripheral.identifier
        if let error {
            onPeripheralError?(id, error)
            return
        }
        onCharacteristicsUpdated?(id, service.uuid, service.characteristics ?? [])
    }
}
