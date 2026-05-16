import AppKit
import Foundation

final class ShakeDetector {
    var onShakeDetected: ((CGPoint) -> Void)?

    private let windowDuration: TimeInterval = 1.5
    private let minReversals = 4
    private let minDisplacement: CGFloat = 100
    private let cooldownDuration: TimeInterval = 2.0

    private var samples: [(point: CGPoint, timestamp: TimeInterval)] = []
    private var lastDetectionTime: TimeInterval = 0
    private var monitor: Any?

    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDragged) { [weak self] event in
            self?.processEvent(event)
        }

        if monitor == nil {
            print("[ShakeDrop] ⚠️ 无法监听全局鼠标事件 — 请授予辅助功能权限")
        }
    }

    func stop() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        samples.removeAll()
    }

    var isMonitoring: Bool { monitor != nil }

    // MARK: - Private

    private func processEvent(_ event: NSEvent) {
        let now = ProcessInfo.processInfo.systemUptime

        // 冷却期内直接跳过
        guard now - lastDetectionTime >= cooldownDuration else { return }

        let point = NSEvent.mouseLocation
        samples.append((point, now))
        pruneOldSamples(now: now)

        guard detectShake() else { return }

        lastDetectionTime = now
        samples.removeAll()
        onShakeDetected?(point)
    }

    private func pruneOldSamples(now: TimeInterval) {
        let cutoff = now - windowDuration
        samples.removeAll { $0.timestamp < cutoff }
    }

    private func detectShake() -> Bool {
        guard samples.count >= 5 else { return false }

        var reversals = 0
        var totalDisplacement: CGFloat = 0

        // 计算主运动轴：使用水平方向为主
        for i in 1..<samples.count {
            let prev = samples[i - 1]
            let curr = samples[i]
            let dx = curr.point.x - prev.point.x
            let dy = curr.point.y - prev.point.y
            totalDisplacement += sqrt(dx * dx + dy * dy)
        }

        guard totalDisplacement >= minDisplacement else { return false }

        // 方向反转检测：统计 X 轴方向变化
        var prevDirection: CGFloat?
        for i in 1..<samples.count {
            let dx = samples[i].point.x - samples[i - 1].point.x

            // 忽略微小移动（< 5pt）
            guard abs(dx) >= 5 else { continue }

            let direction: CGFloat = dx > 0 ? 1 : -1
            if let prev = prevDirection, prev != direction {
                reversals += 1
            }
            prevDirection = direction
        }

        return reversals >= minReversals
    }
}
