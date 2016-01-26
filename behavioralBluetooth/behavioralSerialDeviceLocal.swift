//
//  ViewController.swift
//  behavioralBluetooth
//
//  Created by Casey Brittain on 1/18/16.
//  Copyright © 2016 Honeysuckle Hardware. All rights reserved.
//

import Foundation
import CoreBluetooth

// #MARK: Optional protocol for LocalBehavioralSerialDevice
@objc protocol LocalBehavioralSerialDeviceDelegate {
    optional func searchTimerExpired()
    optional func deviceStatusChanged(nsuuidOfDevice: NSUUID, deviceState: Int)
    optional func connectedToDevice()
}

/// This hopefully provides some info
public class LocalBehavioralSerialDevice: NSObject, RemoteBehavioralSerialDeviceDelegate {
    
    // Device lists
    public var discoveredDeviceList: Dictionary<NSUUID, RemoteBehavioralSerialDevice>?
    
    // Device information
    private var connectedRemotes: Dictionary<NSUUID, RemoteBehavioralSerialDevice>?
    private var state = DeviceState()
    private var hardwareID: NSUUID?
    private var lastConnectedDevice: NSUUID?
    private var allowConnectionInBackground: Bool?
    private var rxSerialBuffer: String?
    private var purposefulDisconnect = false
    
    // Behavioral
    private var connectionsLimit: Int?
    private var reconnectOnLostConnection: Bool?
    private var automaticConnectionRetryOnFail: Bool?
    private var retriesAfterConnectionFail: Int = 0
    private var retriesOnDisconnect: Int = 0
    private var automaticReconnectOnDisconnect: Bool = false
    // Behavioral: Durations.
    private var searchTimeout: Double?
    private var reconnectTimerDuration: Double?
    private var timeBeforeAttemptingReconnectOnConnectionFail: Double = 0.0
    private var timeBeforeAttemptingReconnectOnDisconnect: Double = 0.0
    // Behavioral: Indexes
    private var retryIndexOnFail: Int = 0
    private var retryIndexOnDisconnect: Int = 0

    
    // Delegate for search updates.
    var delegate:LocalBehavioralSerialDeviceDelegate? = nil
    
    //  CoreBluetooth Classes
    private var activeCentralManager = CBCentralManager()
    private var activePeripheralManager = CBPeripheralManager()
    private var peripheralDevice: CBPeripheral?
    private var lastConnectedPeripheralNSUUID: NSUUID?
    
    // Search properities.
    private var searchComplete: Bool = false
    private var searchTimeoutTimer: NSTimer = NSTimer()
    private var reconnectTimer: NSTimer = NSTimer()
    
    override init(){
        
    }
    
    func update() {
        
    }
    
    // #MARK: Internal
    /** 
    ###Set the ID for the desired connected device. The device passed to this function will become the local device's new sought device.  If this will affect autoreconnect scenarios.
    - parameter device: The behavioralBluetooth RemoteSerialDevice desired.
    */
    public func setConnectedDevice(nsuuidAsKey: NSUUID, device: RemoteBehavioralSerialDevice){
        connectedRemotes?.updateValue(device, forKey: nsuuidAsKey)
    }
    
    // #MARK: Behavioral Mutators
    /**
     ###Sets whether the connected serial device should be dismissed when the app enters the background.
     - parameter allow: Bool
     */
    public func setBackgroundConnection(allow: Bool){
        
    }
    
    /**
     ###Limits the local device as to how many remote devices can be connected at one time.
     - parameter connectionLimit: Integer representining the device connection limit.
     */
    public func setNumberOfConnectionsAllowed(connectionLimit: Int){
        
    }
    
    /**
    ###Controls automatica reconnect behavior.  If this option is set to true, the local device will attempt to automatically reconnect to all remote devices which lose connection.
    - parameter enabled: Should the reconnection be attempted.
    - parameter tries: An integer representing how many attempts should be made to reconnect before foreiting the connection.
    - parameter timeBetweenTries: Double representing how long of a delay is made before another attempt to reconnect is made.
    */
    public func setAutomaticReconnectOnDisconnect(enabled: Bool, tries: Int, timeBetweenTries: Double){
        
    }
    
    /**
    ###Controls automatic behavior for reconnecting to a remote device after failing to initially connect.  If this option is set to true, the local device will attempt to automatically reconnect to all remote devices which lose connection.
    - parameter enabled: Should the reconnection be attempted.
    - parameter tries: An integer representing how many attempts should be made to reconnect before foreiting the connection.
    - parameter timeBetweenTries: Double representing how long of a delay is made before another attempt to reconnect is made.
    */
    public func setRetryConnectAfterFail(enabled: Bool, tries: Int, timeBetweenTries: Double){
        
    }

    /**
     ###Attempts to last connected device, without discovery.
     */
    public func connectToLastConnected(){
        
    }
    
    // #MARK: Read and Write
    
    /**
     ###Writes data to a particular RemoteDevice
     */
    public func writeToDevice(deviceOfInterest: NSUUID, data: String){
        
    }
    
    /**
     ###Clears all received data for a particular device from its respective local buffer.  Each remote device has its own received buffer contained within the LocalDevice object.
     - parameter deviceOfInterest: NSUUID of device buffer which should be flushed.
     */
    public func clearRxBuffer(deviceOfInterest: NSUUID){
        
    }
    
    /**
     ###Returns the first Character (as Swift object) from the rxBuffer.  It then removes the character from the buffer.
     - parameter deviceOfInterest: NSUUID of the device which you would like to get a Character from its sent data.
     */
    public func getRxBufferChar(deviceOfInterest: NSUUID)->Character{
        var returnCharacter: Character?
        returnCharacter = "c"
        return returnCharacter!
    }
    
    /**
     ###Check to see if any serial data has arrived from device of interest.
     - parameter deviceOfInterest: The NSUUID of the device which you would like to obtain serial data.
     */
    public func serialDataAvailable(deviceOfInterest: NSUUID){
        
    }
    
    // #MARK: Discovered but not Connected Info
    /**
    Returns a Dictionary object of discovered peripheral devices.
    */
    public func getdiscoveredDeviceDictionary()->Dictionary<NSUUID, RemoteBehavioralSerialDevice>{
        if let discoveredDeviceList = discoveredDeviceList {
            return discoveredDeviceList
        }
    }
    
    /**
    Returns number of discovered devices
    
    ```swift
    if(bbObject.getNumberOfDiscoveredDevices() > 0){
        connectDevice()
    }
    ```
    
    */
    public func getNumberOfDiscoveredDevices()->Int{
        if let discoveredDeviceList = discoveredDeviceList {
            return discoveredDeviceList.count
        }
        else {
            return 0
        }
    }
    
    /**
    Returns the discovered devices as an array.
    */
    public func getDeviceListAsArray()->Array<NSUUID>{
        if let discoveredDeviceList = discoveredDeviceList {
            let deviceListArray = Array(discoveredDeviceList.keys)
            return deviceListArray
        }
    }
    
    /**
    Provides the name of a particular discovered device as a String object.

     ```swift
    println(getDeviceName(myDeviceNSUUID))
    ```
     
    ```xml
    Output: myDevice
    ```
     
    */
    public func getDeviceName(deviceOfInterest: NSUUID)->String{
        if let deviceName = discoveredDeviceList?[deviceOfInterest]?.getName() {
            return deviceName
        }
        else {
            return ""
        }
    }
    
    /**
     Returns the device's [NSUUID](http://nshipster.com/uuid-udid-unique-identifier/) as a String object.
     
     ```swift
     println(getDeviceUUIDAsString(myDeviceNSUUID)
     ```
     
     ```xml
     Output: BE5BA3D0-971C-4418-9ECF-E2D1ABCB66BE
     ```
     
    */
    public func getDeviceUUIDAsString(deviceOfInterest: NSUUID)->String{
        if let hardwareID = discoveredDeviceList?[deviceOfInterest]?.getHardwareID(){
            return hardwareID
        }
        else {
            return ""
        }
    }
    
    /**
     Returns the device of interest's [Radio Signal Strength Indicator (RSSI)](https://en.wikipedia.org/wiki/Received_signal_strength_indication) as an integer.
     
     ```swift
     println(getDeviceRSSI(myDeviceNSUUID))
     ```
     
     ```xml
     Output: -56
     ```
     This option is key for NFC imitation.  For example,
     
     [![iPhone Connects Based on Proximity](https://i.ytimg.com/vi/vcrPdhN9MJw/mqdefault.jpg)](https://youtu.be/vcrPdhN9MJw)
     
     */
    public func getDeviceRSSI(deviceOfInterest: NSUUID)->Int {
        if let rssi = discoveredDeviceList?[deviceOfInterest]?.getRSSI() {
            return rssi
        }
        else {
            return 0
        }
    }
    
    
    private func discoveredDeviceRSSIDictionary()->Dictionary<NSUUID, Int>{
        
        if let discoveredDeviceList = discoveredDeviceList {
            let arrayOfDevices = Array(discoveredDeviceList.keys)
            var dict: Dictionary<NSUUID, Int>?
            for key in arrayOfDevices {
                if let rssiForDevice = discoveredDeviceList[key]?.getRSSI() {
                    dict?.updateValue(rssiForDevice, forKey: key)
                }
            }
            if let dict = dict {
                return dict
            }
        }
        
    }
    
    /**
     Returns an array of two arrays, i.e., <Array<NSUUID>, Array<NSNumber>> sorted by ascending RSSI.  Helpful for connecting to the closest device.
     
     ```swift
     let devicesSortedByRSSI = getSortedArraysBasedOnRSSI()
     connectToDevice(devicesSortedByRSSI[0])
     ```
     
     ```xml
     This should result in connecting to the nearest device. 
     (More accurately, connecting to the device with the greatest RSSI.)
     ```
     
     */
    private func getAscendingSortedArraysBasedOnRSSI()-> (nsuuids: Array<NSUUID>, rssies: Array<NSNumber>){
        
        let discoveredDeviceListRSSI: Dictionary<NSUUID, Int> = discoveredDeviceRSSIDictionary()
        
        // Bubble-POP! :)
        var rssies = Array(discoveredDeviceListRSSI.values)
        var nsuuids = Array(discoveredDeviceListRSSI.keys)
        let countOfKeys = discoveredDeviceListRSSI.keys.count
        
        var x = 0
        var y = 0
        //var bubblePop = true
        
        while(x < countOfKeys)
        {
            while(y < countOfKeys - 1)
            {
                if(Int(rssies[y]) < Int(rssies[y+1]))
                {
                    let temp1 = Int(rssies[y+1])
                    let temp2 = nsuuids[y+1]
                    
                    rssies[y+1] = Int(rssies[y]);
                    nsuuids[y+1] = nsuuids[y]
                    
                    rssies[y] = temp1
                    nsuuids[y] = temp2
                }
                y++
            }
            x++
        }
        return (nsuuids, rssies)
    }
    
    /**
     Returns the full Behavioral DeviceState object.
     */
    public func getDeviceState()->DeviceState{
        // Provide the raw state of the device.
        return self.state
    }
    
    private func searchTimerExpire(){
        searchTimeoutTimer.invalidate()
        searchComplete = true
        printDiscoveredDeviceListInfo()
        if let searchTimerExpired = delegate?.searchTimerExpired?(){
            searchTimerExpired
        }
        else {
            // THROW ERROR
        }
    }
    
    /**
     Returns true if already connected to the deviceOfInterest.
     */
    public func alreadyConnected(deviceNSUUID: NSUUID) -> Bool {
        // Checks if we are already connected to a device.
        if let connectedRemotes = connectedRemotes {
            return connectedRemotes[deviceNSUUID] != nil
        }
    }
    
    
    private func clearDiscoveredDevices(){
        // Device descriptors for discovered devices.
        discoveredDeviceList?.removeAll()
    }

    private func clearConnectedDevices(){
        discoveredDeviceList?.removeAll()
    }
    
    // #MARK: Debug info.
    public func printDiscoveredDeviceListInfo(){
        // Check to make sure we're done searching, then print the all devices info.
        if(searchComplete){
            if let discoveredDeviceList = discoveredDeviceList {
                for ID in discoveredDeviceList.keys {
                    if let name = discoveredDeviceList[ID]?.getName(){
                        print("Device UUID: \(name)")
                    }
                    if let thisUUID = discoveredDeviceList[ID]?.getName() {
                        print("\t\tUUID: \(String(thisUUID))")
                    }
                    if let RSSI = discoveredDeviceList[ID]?.getRSSI() {
                        print("\t\tRRSI: \(RSSI)")
                    }
                }
                
            }
        }
        else{
            print("Search for devices is not yet complete")
        }
    }
    
    public func printConnectedDevices(){
        if let connectedRemotes = connectedRemotes {
            print("Number of connected devices: \(connectedRemotes.count)")
        }
        else {
            print("0")
        }

    }
}

public class LocalCentral: LocalBehavioralSerialDevice {
    
}

public class LocalPeripheral: LocalBehavioralSerialDevice {
    
}

class LocalBluetoothCentral: LocalPeripheral {
    
}

/// ##The Local Bluetooth LE Object
class LocalBluetoothLECentral: LocalPeripheral, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var conectedPeripherals: RemoteBluetoothLEPeripheral?
    var discoveredPeripheral: Dictionary<NSUUID, RemoteBluetoothLEPeripheral>?

    // Behavioral: Variables.
    var discoverAdvertizingDataOnSearch: Bool = false;
    
    // Behavioral: Methods.
    internal func obtainAdvertizingDataOnConnect(enable: Bool){
        discoverAdvertizingDataOnSearch = enable
    }
    
    // #MARK: Remote Device update delegate method
    /**
    Delegate method called from Remote objects.
    - parameter more on this later: more on this later.
    */
    internal override func update() {
        //
    }
    
    
    // #MARK: Central Manager init.
    /**
    ###Updates the the state of the Local Bluetooth LE device.
    - parameter
    */
    internal func centralManagerDidUpdateState(central: CBCentralManager) {
        
        // Make sure the BLE device is on.
        switch activeCentralManager.state {
        case CBCentralManagerState.Unknown:
            print("Unknown")
            //self.state = central.state.rawValue
            break
        case CBCentralManagerState.Resetting:
            print("Resetting")
            break
        case CBCentralManagerState.Unsupported:
            print("Unsupported")
            break
        case CBCentralManagerState.Unauthorized:
            print("Unauthorized")
            break
        case CBCentralManagerState.PoweredOff:
            print("PoweredOff")
            break
        case CBCentralManagerState.PoweredOn:
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil)
            print("Searching for BLE Devices")
            break
        }
    }
    
    // #MARK: Connect to device
    /**
    Requests the Local Device connect to a Bluetooth LE Remote device of interest.  The call will assure a connection to the particular device doesn't exist.  If the `connectionsLimit` has not been reached.
    */
    internal func connectToDevice(deviceNSUUID: NSUUID) -> Bool {
        
        // Remember NSUUID
        lastConnectedPeripheralNSUUID = deviceNSUUID
        
        // Check if if we have discovered anything, if so, make sure we are not already connected.
        if let discoveredDeviceList = discoveredDeviceList {
            if(discoveredDeviceList.isEmpty || alreadyConnected(deviceNSUUID)){
                print("Already connected, silly")
                return false
            }
            else {
                if let connectedRemotes = connectedRemotes {
                    if(connectedRemotes.count < connectionsLimit){
                        if let deviceToConnect = discoveredPeripheral?[deviceNSUUID]?.peripheral {
                            activeCentralManager.connectPeripheral(deviceToConnect, options: nil)
                        }
                        else {
                            return false
                        }
                    }
                    else
                    {
                        print("Too many connections")
                    }
                    if(automaticReconnectOnDisconnect){
                        retryIndexOnDisconnect = 0
                    }
                }
            }
        }
        
        return true
    }
    
    // #MARK: CoreBluetooth Central Manager
    internal func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        // 1. Creates RemotebBluetoothLE object and populates its data.
        // 2. Add the remote object to our Remote object Dictioanry.
        
        let thisRemoteDevice = RemoteBluetoothLEPeripheral()
        
        // Populate the object.
        thisRemoteDevice.ID = peripheral.identifier
        // Each peripheral may have mutiple services.
        if let services = peripheral.services {
            for service in services {
                thisRemoteDevice.services?.append(service)
                thisRemoteDevice.serviceUUIDString?.append(String(service))
            }
        }
        // Set its name.
        if let name = peripheral.name {
            thisRemoteDevice.setName(name)
        }
        thisRemoteDevice.setRSSI(Int(RSSI))


        
        
        // Search its characteristics
        //      Search its descriptors
        
        // Let's get all the information about the discovered devices.
//        discoveredDeviceList.updateValue(peripheral, forKey: peripheral.identifier)
//        discoveredDeviceListRSSI.updateValue(RSSI, forKey: peripheral.identifier)
//        discoveredDeviceListAdvertisementData.updateValue(advertisementData, forKey: peripheral.identifier)
//        discoveredDeviceListUUIDString.updateValue(peripheral.identifier.UUIDString, forKey: peripheral.identifier)

        // Advertising data.
        if(discoverAdvertizingDataOnSearch){
            
            // Get DataLocalNameKey
            let advertisementDataLocalNameKey = advertisementData[CBAdvertisementDataLocalNameKey]
            if let advertisementDataLocalNameKey = advertisementDataLocalNameKey {
                if var thisDeviceNameKey = thisRemoteDevice.discoveredDevicekCBAdvDataLocalName {
                    thisDeviceNameKey = String(advertisementDataLocalNameKey)
                }
            }
            else
            {
                print("Nil found unwrapping AdvertisementDataLocalNameKey")
            }

            // Get ManufacturerDataKey
            let advertisementDataManufacturerDataKey = advertisementData[CBAdvertisementDataManufacturerDataKey]
            if let advertisementDataManufacturerDataKey = advertisementDataManufacturerDataKey {
                thisRemoteDevice.discoveredDevicekCBAdvDataManufacturerData = String(advertisementDataManufacturerDataKey)
            }
            else
            {
                print("Nil found unwrapping AdvertisementDataManufacturerDataKey")
            }
            
            // Get ServiceDataKeys
            let advertisementDataServiceDataKeys = advertisementData[CBAdvertisementDataServiceDataKey] as? Dictionary<CBUUID, NSData>
            if let advertisementDataServiceDataKeys = advertisementDataServiceDataKeys {
                // Get an array of the Data Service Data Keys Keys :)
                let cbuuidArray = Array(advertisementDataServiceDataKeys.keys)
                // Itterate.
                for cbuuid in cbuuidArray {
                    // Convert each to a string
                    if let data = advertisementDataServiceDataKeys[cbuuid]{
                        if let advString = String(data: data, encoding: NSUTF8StringEncoding) {
                            thisRemoteDevice.discoveredDevicekCBAdvDataServiceUUIDs?.updateValue(advString, forKey: cbuuid)
                        }
                    }
                }
            }
            else
            {
                print("Nil found unwrapping AdvertisementDataServiceDataKey")
            }
            
            // Get OverflowServiceUUIDsKey
            if let advertisementDataOverflowServiceUUIDsKey = advertisementData[CBAdvertisementDataOverflowServiceUUIDsKey] as? Array<String> {
                    for item in advertisementDataOverflowServiceUUIDsKey {
                        thisRemoteDevice.discoveredDevicekOverflowServiceUUIDsKey?.append(item)
                    }
                }
            }
            else
            {
                print("Nil found unwrapping AdvertisementDataOverflowServiceUUIDsKey")
            }
        
            if let advertisementDataTxPowerLevelKey = advertisementData[CBAdvertisementDataTxPowerLevelKey] {
                if let txInt = advertisementDataTxPowerLevelKey as? Int{
                    thisRemoteDevice.discoveredDevicekCBAdvDataTxPowerLevel = txInt
                }
            }
            else
            {
                print("Nil found unwrapping AdvertisementDataTxPowerLevelKey")
            }
        
            // Get IsConnectable
            let advertisementDataIsConnectable = advertisementData[CBAdvertisementDataIsConnectable]
            if let advertisementDataIsConnectable = advertisementDataIsConnectable {
                thisRemoteDevice.discoveredDevicekCBAdvDataIsConnectable = String(advertisementDataIsConnectable)
            }
            else
            {
                print("Nil found unwrapping AdvertisementDataIsConnectable")
            }
        
            if let advertisementDataSolicitedServiceUUIDsKey = advertisementData[CBAdvertisementDataSolicitedServiceUUIDsKey] as? Array<String> {
                for item in advertisementDataSolicitedServiceUUIDsKey {
                    thisRemoteDevice.discoveredDevicekCBAdvSolicitedServiceUUID?.append(item)
                }
            }
            else
            {
                print("Nil found unwrapping AdvertisementDataSolicitedServiceUUIDsKey")
            }
        }

        // Clear any connections.  (Strangely, if a search is initiated, all devices are disconnected without
        // didDisconnectPeripheral() being called.
        if let discov
    
        discoveredPeripheral?.updateValue(thisRemoteDevice, forKey: thisRemoteDevice.)
    }
    
    private func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        // Add peripheral to connectedPeripheral dictionary.
        connectedPeripherals.updateValue(peripheral, forKey: peripheral.identifier)
        
        peripheralDevice = peripheral
        peripheralDevice?.delegate = self
        
        // Look for set services
        // #MARK: ADD
        // If not, do below.
        
        if let peripheralDevice = peripheralDevice {
            peripheralDevice.discoverServices(nil)
        }
        
        if let connectedToDevice = delegate?.connectedToDevice?(){
            connectedToDevice
        }
        else {
            // #MARK: ADD
            // Handle if no delegate is setup.
        }
    }
    
    private func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        // Look for set characteristics.
        
        // If not, do below.
        
        if let peripheralDevice = peripheralDevice {
            if let serviceArray = peripheralDevice.services {
                for service in serviceArray {
                    connectedPeripheralServices.append(service)
                    peripheralDevice.discoverCharacteristics(nil, forService: service)
                }
            }
        }
        
        
    }
    
    private func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        // Look for set characteristics descriptors.
        
        // If not, do below.
        
        if let peripheralDevice = peripheralDevice {
            if let characteristicsArray = service.characteristics {
                for characteristic in characteristicsArray {
                    connectedPeripheralCharacteristics.append(characteristic)
                    peripheralDevice.discoverDescriptorsForCharacteristic(characteristic)
                }
            }
        }
    }
    
    private func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let  descriptorsArray = characteristic.descriptors {
            for descriptors in descriptorsArray {
                connectedPeripheralCharacteristicsDescriptors.append(descriptors)
            }
        }
        // End of the line.
    }
    
    private func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        // If we fail to connect, don't remember this device.
        
        if(automaticConnectionRetryOnFail == true && retryIndexOnFail < retriesAfterConnectionFail){
            reconnectTimer = NSTimer.scheduledTimerWithTimeInterval(timeBeforeAttemptingReconnectOnConnectionFail, target: self, selector: Selector("reconnectTimerExpired"), userInfo: nil, repeats: false)
        }
        else {
            lastConnectedPeripheralNSUUID = nil
        }
    }
    
    public func search(timeoutSecs: NSTimeInterval){
        searchComplete = false
        clearDiscoveredDevices()
        // Strange.  If a search for peripherals is initiated it cancels all connections
        // without firing didDisconnectPeripheral.  This compensates.
        clearConnectedDevices()
        activeCentralManager = CBCentralManager(delegate: self, queue: nil)
        searchTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(timeoutSecs, target: self, selector: Selector("searchTimerExpire"), userInfo: nil, repeats: false)
    }
    
    public func connectToDevice(serviceOfInterest: CBService, characteristicOfInterest: CBCharacteristic){
        
    }
    
    // #MARK: Connection Lost.
    private func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        // If connection is lost, remove it from the connected device dictionary.
        connectedPeripherals.removeValueForKey(peripheral.identifier)
        print("Lost connection to: \(peripheral.identifier)")
        
        if(automaticReconnectOnDisconnect && purposefulDisconnect == false){
            activePeripheralManager.state
            reconnectTimer = NSTimer.scheduledTimerWithTimeInterval(timeBeforeAttemptingReconnectOnDisconnect, target: self, selector: Selector("reconnectTimerExpired"), userInfo: nil, repeats: false)
        }
        else {
            //if let deviceStatusChanged = delegate?.deviceStatusChanged?(peripheral.identifier, deviceState: self.state){
                purposefulDisconnect = false
                //deviceStatusChanged
            //}
        }
        
        
    }
    
    public func disconnectFromPeriphera(deviceOfInterest: NSUUID)->Bool {
        let deviceToDisconnect = connectedPeripherals[deviceOfInterest]
        if let deviceToDisconnect = deviceToDisconnect {
            activeCentralManager.cancelPeripheralConnection(deviceToDisconnect)
            purposefulDisconnect = true
            return true
        }
        else
        {
            // ERROR: Device does not exist.
            return false
        }
    }
    
    /**
     ```swift
     println(getDeviceRSSI(myDeviceNSUUID))
     ```
     
     ```xml
     Output: -56
     ```
     */
    public func getAdvDeviceConnectable(deviceOfInterest: NSUUID)->Bool{
        if let discoveredDevicekCBAdvDataIsConnectable = discoveredDevicekCBAdvDataIsConnectable[deviceOfInterest] {
            let connectableFlag = discoveredDevicekCBAdvDataIsConnectable as? Bool
            if let connectableFlag = connectableFlag {
                return connectableFlag
            }
        }
        return false
    }
    
    public func getAdvDeviceName(deviceOfInterest: NSUUID)->String{
        if let discoveredDevicekCBAdvDataLocalName = discoveredDevicekCBAdvDataLocalName[deviceOfInterest] {
            let nameAsString = discoveredDevicekCBAdvDataLocalName as? String
            if let nameAsString = nameAsString {
                return nameAsString
            }
        }
        return ""
    }
    
    
    public func getAdvDeviceManufactureData(deviceOfInterest: NSUUID)->String{
        if let discoveredDevicekCBAdvDataManufacturerData = discoveredDevicekCBAdvDataManufacturerData[deviceOfInterest] {
            let data = discoveredDevicekCBAdvDataManufacturerData as? NSData
            if let data = data {
                let dataString = NSString(data: data, encoding: NSUTF16StringEncoding) as? String
                if let dataString = dataString {
                    return dataString
                }
            }
        }
        return ""
    }
    
    public func getAdvDeviceServiceData(deviceOfInterest: NSUUID) -> Array<String>{
        if let discoveredDevicekCBAdvDataServiceData = discoveredDevicekCBAdvDataServiceData[deviceOfInterest] {
            let dictionaryCast = discoveredDevicekCBAdvDataServiceData as? Dictionary<CBUUID, NSData>
            var cbuuidAsStringArray: Array<String> = []
            if let dictionaryCast = dictionaryCast {
                for CBUUID in dictionaryCast.values {
                    let cbuuidString = NSString(data: CBUUID, encoding: NSUTF16StringEncoding)
                    if let cbuuidString = cbuuidString {
                        cbuuidAsStringArray.append(cbuuidString as String)
                    }
                }
                return cbuuidAsStringArray
            }
        }
        return [""]
    }
    
    public func getAdvDeviceServiceUUIDasNSArray(deviceOfInterest: NSUUID)->NSArray{
        if let discoveredDevicekCBAdvDataServiceUUIDs = discoveredDevicekCBAdvDataServiceUUIDs[deviceOfInterest] {
            let discoveredDevicekCBAdvDataServiceUUIDStrings = discoveredDevicekCBAdvDataServiceUUIDs as? NSArray
            if let discoveredDevicekCBAdvDataServiceUUIDStrings = discoveredDevicekCBAdvDataServiceUUIDStrings
            {
                if(discoveredDevicekCBAdvDataServiceUUIDs.count > 0){
                    return discoveredDevicekCBAdvDataServiceUUIDStrings
                }
                else {
                    return []
                }
            }
        }
        return []
    }
    
    
    
    public func getAdvTxPowerLevel(deviceOfInterest: NSUUID)->Int{
        if let discoveredDevicekCBAdvDataTxPowerLevel = discoveredDevicekCBAdvDataTxPowerLevel[deviceOfInterest] {
            let txPowerLevelInt = discoveredDevicekCBAdvDataTxPowerLevel as? Int
            if let txPowerLevelInt = txPowerLevelInt
            {
                return txPowerLevelInt
            }
        }
        return 0
    }
    
    public func getAdvSolicitedUUID(deviceOfInterest: NSUUID)->NSArray?{
        if let discoveredDevicekCBAdvSolicitedServiceUUID = discoveredDevicekCBAdvSolicitedServiceUUID[deviceOfInterest] {
            let solicitedUUID = discoveredDevicekCBAdvSolicitedServiceUUID as? NSArray
            if let solicitedUUID = solicitedUUID
            {
                if(solicitedUUID.count > 0){
                    return solicitedUUID
                }
                else {
                    return []
                }
            }
        }
        return []
    }

    private func reconnectTimerExpired(){
        if let lastConnectedPeripheralNSUUID = lastConnectedPeripheralNSUUID {
            connectToDevice(lastConnectedPeripheralNSUUID)
        }
    }
    
}

class LocalBluetoothPeripheral: LocalPeripheral {
    
}

class LocalBluetoothLEPeripheral: LocalPeripheral {
    
}



