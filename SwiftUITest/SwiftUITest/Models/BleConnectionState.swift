//
//  BleConnectionState.swift
//  SwiftUITest
//
//  Created by k-ujiie on 2026/03/09.
//

import Foundation

enum BleConnectionState: Equatable {
    case idle
    case connecting
    case connected
    case discoveringServices
    case ready
    case failed(String)
    case disconnected
}
