import Network
import Foundation

@Observable
class NetworkMonitor {
    private let monitor = NWPathMonitor()
    var isConnected = false

    static let shared = NetworkMonitor()

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
}
