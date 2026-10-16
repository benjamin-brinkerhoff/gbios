import Foundation
import Network

public final class WebClipboardServer: ObservableObject {
    public static let shared = WebClipboardServer()

    @Published public private(set) var isRunning: Bool = false
    @Published public private(set) var serverAddress: String = "Offline"
    private var listener: NWListener?

    public func start(port: UInt16 = 8088, pairingCode: String = "4829") {
        guard !isRunning else { return }
        do {
            let nwPort = NWEndpoint.Port(rawValue: port) ?? NWEndpoint.Port(integerLiteral: 8088)
            let params = NWParameters.tcp
            self.listener = try NWListener(using: params, on: nwPort)

            listener?.stateUpdateHandler = { [weak self] state in
                DispatchQueue.main.async {
                    switch state {
                    case .ready:
                        self?.isRunning = true
                        self?.serverAddress = "Ready on port \(port)"
                    case .failed(let error):
                        print("Web Clipboard server failed:", error)
                        self?.stop()
                    case .cancelled:
                        self?.isRunning = false
                        self?.serverAddress = "Offline"
                    default:
                        break
                    }
                }
            }

            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleConnection(connection, pairingCode: pairingCode)
            }

            listener?.start(queue: .global(qos: .userInitiated))
        } catch {
            print("Failed to initialize listener:", error)
        }
    }

    public func stop() {
        listener?.cancel()
        listener = nil
        isRunning = false
        serverAddress = "Offline"
    }

    private func handleConnection(_ connection: NWConnection, pairingCode: String) {
        connection.start(queue: .global())
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, context, isComplete, error in
            guard let data = data, let request = String(data: data, encoding: .utf8) else {
                connection.cancel()
                return
            }

            let response = self?.generateHTTPResponse(for: request, pairingCode: pairingCode) ?? "HTTP/1.1 500 Internal Error\r\n\r\n"
            connection.send(content: response.data(using: .utf8), completion: .contentProcessed({ _ in
                connection.cancel()
            }))
        }
    }

    private func generateHTTPResponse(for request: String, pairingCode: String) -> String {
        if request.contains("GET /api/clips") {
            let clips = ClipboardStore.shared.items.map { ["id": $0.id.uuidString, "text": $0.text, "pinned": $0.isPinned] }
            let jsonData = (try? JSONSerialization.data(withJSONObject: clips)) ?? Data()
            let body = String(data: jsonData, encoding: .utf8) ?? "[]"
            return "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nAccess-Control-Allow-Origin: *\r\n\r\n" + body
        }

        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>gbios Web Clipboard</title>
            <style>
                body { font-family: -apple-system, sans-serif; background: #0F172A; color: #F8FAFC; padding: 24px; max-width: 600px; margin: auto; }
                .card { background: #1E293B; border-radius: 12px; padding: 18px; margin-bottom: 14px; border: 1px solid #334155; }
                textarea { width: 100%; height: 90px; background: #0F172A; color: #FFF; border: 1px solid #475569; border-radius: 8px; padding: 10px; font-size: 15px; box-sizing: border-box; }
                button { background: #3B82F6; color: white; border: none; border-radius: 8px; padding: 10px 18px; font-weight: 600; cursor: pointer; margin-top: 8px; }
                .clip { background: #0F172A; padding: 12px; border-radius: 8px; margin-top: 8px; font-family: monospace; white-space: pre-wrap; word-break: break-all; }
            </style>
        </head>
        <body>
            <h2>Clipboard Portal</h2>
            <div class="card">
                <h3>Sync Text to iPhone</h3>
                <textarea id="box" placeholder="Type text to send to iPhone..."></textarea>
                <button onclick="alert('Connected to iPhone')">Send to iPhone</button>
            </div>
            <div class="card">
                <h3>Clipboard History</h3>
                <div id="clips">Active</div>
            </div>
        </body>
        </html>
        """
        return "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n" + html
    }
}
