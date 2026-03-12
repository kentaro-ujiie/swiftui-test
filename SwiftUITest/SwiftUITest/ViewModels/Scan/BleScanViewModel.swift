//
//  BleScanViewModel.swift
//  SwiftUITest
//
//  Created by k-ujiie on 2026/03/04.
//

import Foundation
import CoreBluetooth
import Combine

@MainActor
final class BleScanViewModel: ObservableObject {
    @Published private(set) var devices: [BleDevice] = []
    @Published private(set) var bluetoothState: CBManagerState = .unknown
    @Published private(set) var isScanning: Bool = false

    private(set) var centralService: BleCentralService
    
    // ★追加：遷移用（選択されたデバイス）
    @Published var selectedDevice: BleDevice?

    // 検出データをためるバッファ（UI更新とは分離）
    private var bufferById: [UUID: BleDevice] = [:]

    // “検出順”を保持しておき、RSSIが同点のときの安定ソートに使う（任意だがおすすめ）
    private var firstSeenOrder: [UUID: Int] = [:]
    private var nextOrder: Int = 0

    // 1秒ごとの反映タスク
    private var flushTask: Task<Void, Never>?
    
    // ★自動停止（5秒）用
    private var autoStopTask: Task<Void, Never>?
    private let scanDurationSeconds: UInt64 = 5

    init(service: BleCentralService? = nil) {
        self.centralService = service ?? BleCentralService()

        self.centralService.onStateChange = { [weak self] state in
            guard let self else { return }
            Task { @MainActor in
                self.bluetoothState = state
                // Bluetoothが使えなくなったらスキャン停止（ついでに自動停止Taskも止める）
                if state != .poweredOn {
                    self.stopScan()
                }
            }
        }

        // ここは頻繁に呼ばれてOK（buffer更新のみで @Published は更新しない）
        self.centralService.onDiscover = { [weak self] peripheral, rssi in
            guard let self else { return }
            Task { @MainActor in
                self.updateBuffer(peripheral: peripheral, rssi: rssi.intValue)
            }
        }
    }

    func startScan() {
        // 二重開始防止
        guard !isScanning else { return }
        
        centralService.startScan()
        isScanning = true
        
        startFlushLoopIfNeeded()
        scheduleAutoStop()
    }

    func stopScan() {
        guard isScanning else {
            // 念のためタスクは止めておく
            stopAutoStop()
            stopFlushLoop()
            return
        }
        
        centralService.stopScan()
        isScanning = false
        
        stopAutoStop()
        stopFlushLoop()
    }

    func toggleScan() {
        isScanning ? stopScan() : startScan()
    }

    func clear() {
        devices.removeAll()
        bufferById.removeAll()
        firstSeenOrder.removeAll()
        nextOrder = 0
    }

    // BLEデバイスを選択（セルタップ時に呼ぶ）
    func select(_ device: BleDevice) {
        // 遷移時にスキャン停止
        stopScan()
        selectedDevice = device
    }
    
    private func updateBuffer(peripheral: CBPeripheral, rssi: Int) {
        let id = peripheral.identifier
        let name = peripheral.name ?? "Unknown"

        if firstSeenOrder[id] == nil {
            firstSeenOrder[id] = nextOrder
            nextOrder += 1
        }

        let updated = BleDevice(
            identifier: id,
            name: name,
            rssi: rssi,
            lastSeen: Date()
        )
        bufferById[id] = updated
    }

    private func startFlushLoopIfNeeded() {
        guard flushTask == nil else { return }

        flushTask = Task { [weak self] in
            guard let self else { return }
            
            flushTask = Task { @MainActor [weak self] in
                guard let self else { return }
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    self.flushToPublishedDevices()
                }
            }
        }
    }

    private func stopFlushLoop() {
        flushTask?.cancel()
        flushTask = nil
    }

    private func flushToPublishedDevices() {
        // bufferのスナップショットを配列化して、RSSI順にソート
        var list = Array(bufferById.values)

        list.sort { a, b in
            if a.rssi != b.rssi { return a.rssi > b.rssi } // RSSI強い順
            // 同点の場合は初回検出が早い方を上にして安定化
            return (firstSeenOrder[a.identifier] ?? Int.max) < (firstSeenOrder[b.identifier] ?? Int.max)
        }

        self.devices = list
    }

    private func scheduleAutoStop() {
        stopAutoStop() // 既存があればキャンセルして作り直す

        autoStopTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .seconds(scanDurationSeconds))

            await MainActor.run {
                // スキャン自動停止の時間が経っても、まだスキャン中なら停止
                if self.isScanning {
                    self.stopScan()
                }
            }
        }
    }

    private func stopAutoStop() {
        autoStopTask?.cancel()
        autoStopTask = nil
    }

    deinit {
        flushTask?.cancel()
        autoStopTask?.cancel()
    }
}
