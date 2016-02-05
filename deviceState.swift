//
//  deviceState.swift
//  behavioralBluetooth
//
//  Created by Casey Brittain on 1/20/16.
//  Copyright © 2016 Honeysuckle Hardware. All rights reserved.
//

import Foundation

public enum DeviceState: Int {
    case unknown = 0,
    disconnected,
    failedToConnect,
    purposefulDisconnect,
    lostConnection,
    connecting,
    connected,
    scanning,
    off,
    idle,
    resetting,
    unsupported,
    unauthorized
}