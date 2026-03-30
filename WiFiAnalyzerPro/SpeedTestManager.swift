import Foundation
import Combine

@MainActor
class SpeedTestManager: NSObject, ObservableObject {
    @Published var downloadSpeed: Double = 0.0
    @Published var uploadSpeed: Double = 0.0
    @Published var latency: Double = 0.0
    @Published var isTesting: Bool = false
    @Published var testProgress: Double = 0.0
    @Published var speedHistory: [Double] = []
    
    private let testFileSize = 10 * 1024 * 1024 // 10MB
    private let uploadFileSize = 1 * 1024 * 1024 // 1MB
    
    func runSpeedTest() async {
        isTesting = true
        testProgress = 0.0
        
        // Test latency
        await testLatency()
        testProgress = 0.33
        
        // Test download speed
        await testDownloadSpeed()
        testProgress = 0.66
        
        // Test upload speed
        await testUploadSpeed()
        testProgress = 1.0
        
        // Add to history
        speedHistory.append(downloadSpeed)
        if speedHistory.count > 20 {
            speedHistory.removeFirst()
        }
        
        isTesting = false
    }
    
    private func testLatency() async {
        let startTime = Date()
        
        do {
            let url = URL(string: "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png")!
            let (_, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let latency = Date().timeIntervalSince(startTime) * 1000
                await MainActor.run {
                    self.latency = latency
                }
            }
        } catch {
            print("Latency test error: \(error)")
        }
    }
    
    private func testDownloadSpeed() async {
        let startTime = Date()
        
        do {
            let url = URL(string: "https://speed.cloudflare.com/__down?bytes=\(testFileSize)")!
            let (_, _) = try await URLSession.shared.data(from: url)
            
            let downloadTime = Date().timeIntervalSince(startTime)
            let downloadMbps = (Double(testFileSize) * 8) / (downloadTime * 1_000_000)
            
            await MainActor.run {
                self.downloadSpeed = max(0, downloadMbps)
            }
        } catch {
            print("Download test error: \(error)")
            await MainActor.run {
                self.downloadSpeed = 0
            }
        }
    }
    
    private func testUploadSpeed() async {
        let startTime = Date()
        
        do {
            var request = URLRequest(url: URL(string: "https://httpbin.org/post")!)
            request.httpMethod = "POST"
            
            let uploadData = Data(count: uploadFileSize)
            let (_, response) = try await URLSession.shared.data(for: request, from: uploadData)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let uploadTime = Date().timeIntervalSince(startTime)
                let uploadMbps = (Double(uploadFileSize) * 8) / (uploadTime * 1_000_000)
                
                await MainActor.run {
                    self.uploadSpeed = max(0, uploadMbps)
                }
            }
        } catch {
            print("Upload test error: \(error)")
            await MainActor.run {
                self.uploadSpeed = 0
            }
        }
    }
}

// Extension for URLSession to support data upload
extension URLSession {
    func data(for request: URLRequest, from data: Data) async throws -> (Data, URLResponse) {
        var request = request
        request.httpBody = data
        return try await self.data(for: request)
    }
}
