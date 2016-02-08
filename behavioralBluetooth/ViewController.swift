//
//  ViewController.swift
//  behavioralBluetooth
//
//  Created by Casey Brittain on 1/18/16.
//  Copyright © 2016 Honeysuckle Hardware. All rights reserved.
//

import UIKit
import bluetoothBehave

var myRemote = RemoteBluetoothLEPeripheral()
var myLocal = LocalBluetoothLECentral()

class ViewController: UIViewController, LocalBehavioralSerialDeviceDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myLocal.delegate = self

        myLocal.reconnectOnDisconnect(tries: 3, timeBetweenTries: 1.5)
        myLocal.reconnectOnFail(tries: 3, timeBetweenTries: 2)
        myLocal.setDiscoverAdvertizingData(true)
        myLocal.verboseOutput(true)
        myLocal.addServiceOfInterest("FFE0")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

