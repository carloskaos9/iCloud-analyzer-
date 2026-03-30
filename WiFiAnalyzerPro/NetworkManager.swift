import Foundation
import Network
import NetworkExtension
import Combine
import CoreTelephony
import Darwin

@MainActor
class NetworkManager: NSObject, ObservableObject {
    @Published var downlink: Double = 0.0
    @Published var uplink: Double = 0.0
    @Published var latency: Double = 0.0
    @Published var connectionType: String = "Desconhecido"
    @Published var signalStrength: Int = 0
    @Published var isConnected: Bool = false
    @Published var ipAddress: String = "Obtendo..."
    @Published var publicIP: String = "Obtendo..."
    @Published var networkGeneration: String = "N/A"
    @Published var wifiNetworks: [WiFiNetwork] = []
    @Published var connectedDevices: [ConnectedDevice] = []
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    override init() {
        super.init()
        setupNetworkMonitoring()
        fetchPublicIP()
    }
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateNetworkInfo(path)
            }
        }
        monitor.start(queue: queue)
    }
    
    private func updateNetworkInfo(_ path: NWPath) {
        isConnected = path.status == .satisfied
        
        // Determine connection type
        if path.usesInterfaceType(.wifi) {
            connectionType = "Wi-Fi"
            networkGeneration = "Wi-Fi"
            fetchWiFiInfo()
        } else if path.usesInterfaceType(.cellular) {
            connectionType = "Celular"
            detectNetworkGeneration()
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = "Ethernet"
            networkGeneration = "Ethernet"
        } else {
            connectionType = "Desconhecido"
        }
    }
    
    private func detectNetworkGeneration() {
        let telephonyInfo = CTTelephonyNetworkInfo()
        
        if #available(iOS 14.1, *) {
            if let currentRadioAccessTechnology = telephonyInfo.serviceCurrentRadioAccessTechnology?.values.first {
                switch currentRadioAccessTechnology {
                case CTRadioAccessTechnologyWCDMA:
                    networkGeneration = "3G"
                case CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA:
                    networkGeneration = "3G+"
                case CTRadioAccessTechnologyLTE:
                    networkGeneration = "4G LTE"
                default:
                    if #available(iOS 14.1, *) {
                        if currentRadioAccessTechnology == CTRadioAccessTechnologyNR || 
                           currentRadioAccessTechnology == CTRadioAccessTechnologyNRNSA {
                            networkGeneration = "5G"
                        } else {
                            networkGeneration = "Desconhecido"
                        }
                    } else {
                        networkGeneration = "Desconhecido"
                    }
                }
            }
        } else {
            networkGeneration = "Desconhecido"
        }
    }
    
    private func fetchWiFiInfo() {
        // Get local IP address
        if let localIP = getLocalIPAddress() {
            ipAddress = localIP
        }
        
        // Simulate signal strength (in real app, would use NEHotspotHelper)
        signalStrength = Int.random(in: 30...100)
    }
    
    private func getLocalIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        
        guard getifaddrs(&ifaddr) == 0 else {
            return nil
        }
        
        defer {
            if ifaddr != nil {
                freeifaddrs(ifaddr)
            }
        }
        
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            guard let interface = ptr?.pointee else { continue }
            
            // Check if address is valid
            guard interface.ifa_addr != nil else { continue }
            
            let addrFamily = interface.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) {
                if let name = String(cString: interface.ifa_name, encoding: .utf8),
                   (name == "en0" || name == "en1" || name == "en2" || name == "en3") {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    
                    let result = getnameinfo(
                        interface.ifa_addr,
                        socklen_t(interface.ifa_addr.pointee.sa_len),
                        &hostname,
                        socklen_t(hostname.count),
                        nil,
                        socklen_t(0),
                        NI_NUMERICHOST
                    )
                    
                    if result == 0 {
                        address = String(cString: hostname)
                        break
                    }
                }
            }
        }
        
        return address
    }
    
    func fetchPublicIP() {
        guard let url = URL(string: "https://api.ipify.org?format=json") else {
            publicIP = "Erro"
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("Erro ao buscar IP público: \(error)")
                DispatchQueue.main.async {
                    self?.publicIP = "Erro"
                }
                return
            }
            
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
               let ip = json["ip"] {
                DispatchQueue.main.async {
                    self?.publicIP = ip
                }
            }
        }.resume()
    }
    
    func scanWiFiNetworks() {
        // In a real app, would use NEHotspotHelper or similar
        // For now, return simulated networks
        wifiNetworks = [
            WiFiNetwork(ssid: "MyNetwork-5G", strength: 85, security: "WPA3"),
            WiFiNetwork(ssid: "Guest-WiFi", strength: 72, security: "WPA2"),
            WiFiNetwork(ssid: "NeighborNetwork", strength: 45, security: "WPA2"),
        ]
    }
    
    func scanConnectedDevices() {
        // Simulate device detection
        connectedDevices = [
            ConnectedDevice(ip: "192.168.1.1", hostname: "Roteador", mac: "00:1A:2B:3C:4D:00", type: "Gateway"),
            ConnectedDevice(ip: "192.168.1.100", hostname: "Este iPhone", mac: "00:1A:2B:3C:4D:01", type: "iPhone"),
        ]
    }
    
    deinit {
        monitor.cancel()
    }
}

struct WiFiNetwork: Identifiable {
    let id = UUID()
    let ssid: String
    let strength: Int
    let security: String
}

struct ConnectedDevice: Identifiable {
    let id = UUID()
    let ip: String
    let hostname: String
    let mac: String
    let type: String
}
