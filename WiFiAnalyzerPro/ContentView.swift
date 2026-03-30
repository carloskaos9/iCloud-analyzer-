import SwiftUI
import Charts

struct ContentView: View {
    @StateObject private var networkManager = NetworkManager()
    @StateObject private var speedTestManager = SpeedTestManager()
    @StateObject private var locationManager = LocationManager()
    @State private var selectedTab = 0
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.97, green: 0.98, blue: 1.0),
                    Color(red: 0.93, green: 0.96, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Wi-Fi Analyzer Pro")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(Color(red: 0.06, green: 0.22, blue: 0.49))
                        
                        Text("Monitoramento de rede em tempo real")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(red: 0.06, green: 0.22, blue: 0.49))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                
                TabView(selection: $selectedTab) {
                    // Dashboard Tab
                    DashboardView(networkManager: networkManager, speedTestManager: speedTestManager)
                        .tag(0)
                    
                    // Speed Test Tab
                    SpeedTestView(speedTestManager: speedTestManager)
                        .tag(1)
                    
                    // Networks Tab
                    NetworksView(networkManager: networkManager)
                        .tag(2)
                    
                    // Location Tab
                    LocationView(locationManager: locationManager)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Tab Bar
                HStack(spacing: 0) {
                    TabBarItem(
                        icon: "gauge.with.dots.needle.bottom",
                        label: "Dashboard",
                        isSelected: selectedTab == 0,
                        action: { selectedTab = 0 }
                    )
                    
                    TabBarItem(
                        icon: "bolt.fill",
                        label: "Teste",
                        isSelected: selectedTab == 1,
                        action: { selectedTab = 1 }
                    )
                    
                    TabBarItem(
                        icon: "wifi",
                        label: "Redes",
                        isSelected: selectedTab == 2,
                        action: { selectedTab = 2 }
                    )
                    
                    TabBarItem(
                        icon: "location.fill",
                        label: "Local",
                        isSelected: selectedTab == 3,
                        action: { selectedTab = 3 }
                    )
                }
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -2)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            locationManager.requestLocationPermission()
        }
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @ObservedObject var networkManager: NetworkManager
    @ObservedObject var speedTestManager: SpeedTestManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Connection Status Card
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Status da Conexão")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            Text(networkManager.connectionType)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(red: 0.06, green: 0.22, blue: 0.49))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Circle()
                                .fill(networkManager.isConnected ? Color(red: 0.0, green: 0.82, blue: 0.52) : Color.red)
                                .frame(width: 12, height: 12)
                            
                            Text(networkManager.isConnected ? "Conectado" : "Desconectado")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Divider()
                    
                    HStack(spacing: 16) {
                        MetricCard(
                            title: "Latência",
                            value: String(format: "%.0f", networkManager.latency),
                            unit: "ms"
                        )
                        
                        MetricCard(
                            title: "Sinal",
                            value: String(networkManager.signalStrength),
                            unit: "%"
                        )
                        
                        MetricCard(
                            title: "Geração",
                            value: networkManager.networkGeneration,
                            unit: ""
                        )
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                
                // Speed Card
                VStack(spacing: 12) {
                    HStack {
                        Text("Velocidade Atual")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("Mbps")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Download")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            Text(String(format: "%.1f", speedTestManager.downloadSpeed))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.06, green: 0.22, blue: 0.49))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Upload")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            Text(String(format: "%.1f", speedTestManager.uploadSpeed))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.52))
                        }
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                
                // Speed History Chart
                if !speedTestManager.speedHistory.isEmpty {
                    VStack(spacing: 12) {
                        Text("Histórico de Velocidade")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Chart {
                            ForEach(Array(speedTestManager.speedHistory.enumerated()), id: \.offset) { index, value in
                                LineMark(
                                    x: .value("Teste", index),
                                    y: .value("Mbps", value)
                                )
                                .foregroundStyle(Color(red: 0.06, green: 0.22, blue: 0.49))
                                
                                PointMark(
                                    x: .value("Teste", index),
                                    y: .value("Mbps", value)
                                )
                                .foregroundStyle(Color(red: 0.0, green: 0.82, blue: 0.52))
                            }
                        }
                        .frame(height: 150)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
                
                // IP Information
                VStack(spacing: 12) {
                    HStack {
                        Text("Informações de IP")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("IP Local")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            Text(networkManager.ipAddress)
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(red: 0.06, green: 0.22, blue: 0.49))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("IP Público")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            Text(networkManager.publicIP)
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.52))
                        }
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            }
            .padding(16)
        }
    }
}

// MARK: - Speed Test View
struct SpeedTestView: View {
    @ObservedObject var speedTestManager: SpeedTestManager
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                // Download Speed
                VStack(spacing: 8) {
                    Text("Download")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Text(String(format: "%.1f", speedTestManager.downloadSpeed))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(red: 0.06, green: 0.22, blue: 0.49))
                    
                    Text("Mbps")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                
                // Progress
                if speedTestManager.isTesting {
                    ProgressView(value: speedTestManager.testProgress)
                        .tint(Color(red: 0.06, green: 0.22, blue: 0.49))
                        .padding(.horizontal, 24)
                }
                
                // Upload Speed
                VStack(spacing: 8) {
                    Text("Upload")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Text(String(format: "%.1f", speedTestManager.uploadSpeed))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.52))
                    
                    Text("Mbps")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            }
            
            Spacer()
            
            // Test Button
            Button(action: {
                Task {
                    await speedTestManager.runSpeedTest()
                }
            }) {
                HStack {
                    Image(systemName: "bolt.fill")
                    Text(speedTestManager.isTesting ? "Testando..." : "Iniciar Teste")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.06, green: 0.22, blue: 0.49))
                .cornerRadius(12)
            }
            .disabled(speedTestManager.isTesting)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.97, green: 0.98, blue: 1.0),
                    Color(red: 0.93, green: 0.96, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Networks View
struct NetworksView: View {
    @ObservedObject var networkManager: NetworkManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Redes Wi-Fi Disponíveis")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                Button(action: { networkManager.scanWiFiNetworks() }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color(red: 0.06, green: 0.22, blue: 0.49))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            if networkManager.wifiNetworks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                    
                    Text("Clique em Escanear para listar redes")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(networkManager.wifiNetworks) { network in
                            NetworkItemView(network: network)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            
            Spacer()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.97, green: 0.98, blue: 1.0),
                    Color(red: 0.93, green: 0.96, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Location View
struct LocationView: View {
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Localização")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                Button(action: { locationManager.startUpdatingLocation() }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color(red: 0.06, green: 0.22, blue: 0.49))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            VStack(spacing: 12) {
                LocationInfoCard(title: "Cidade", value: locationManager.city)
                LocationInfoCard(title: "País", value: locationManager.country)
                
                if let location = locationManager.location {
                    LocationInfoCard(
                        title: "Latitude",
                        value: String(format: "%.4f", location.latitude)
                    )
                    LocationInfoCard(
                        title: "Longitude",
                        value: String(format: "%.4f", location.longitude)
                    )
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.97, green: 0.98, blue: 1.0),
                    Color(red: 0.93, green: 0.96, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                List {
                    Section("Sobre") {
                        HStack {
                            Text("Versão")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Desenvolvedor")
                            Spacer()
                            Text("Carlos Kaos")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Section("Permissões") {
                        Text("Localização: Necessária para geolocalização")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Text("Rede Local: Necessária para escanear Wi-Fi")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Helper Views
struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.gray)
            
            HStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.06, green: 0.22, blue: 0.49))
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(red: 0.97, green: 0.98, blue: 1.0))
        .cornerRadius(8)
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? Color(red: 0.06, green: 0.22, blue: 0.49) : .gray)
            .padding(.vertical, 8)
        }
    }
}

struct NetworkItemView: View {
    let network: WiFiNetwork
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(network.ssid)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.06, green: 0.22, blue: 0.49))
                
                Text(network.security)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    ProgressView(value: Double(network.strength) / 100.0)
                        .frame(width: 60)
                        .tint(Color(red: 0.0, green: 0.82, blue: 0.52))
                    
                    Text("\(network.strength)%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

struct LocationInfoCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(red: 0.06, green: 0.22, blue: 0.49))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

#Preview {
    ContentView()
}
