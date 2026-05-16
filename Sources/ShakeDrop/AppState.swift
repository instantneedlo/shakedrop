import AppKit
import Combine

final class AppState: ObservableObject {
    let fileCollection = FileCollection()
    let shakeDetector = ShakeDetector()
    let menuBarManager = MenuBarManager()
    let panelWindow = DropPanelWindow()

    var isPanelVisible: Bool { panelWindow.isVisible }

    func setup() {
        menuBarManager.setup()
        menuBarManager.onTogglePanel = { [weak self] in
            self?.togglePanel()
        }

        panelWindow.fileCollection = fileCollection
        panelWindow.onDropURLs = { [weak self] urls in
            self?.fileCollection.add(urls: urls)
            self?.menuBarManager.updateFileCount(self?.fileCollection.count ?? 0)
        }
        panelWindow.onRemoveFile = { [weak self] index in
            self?.fileCollection.remove(at: index)
            self?.menuBarManager.updateFileCount(self?.fileCollection.count ?? 0)
        }
        panelWindow.onRemoveAll = { [weak self] in
            self?.fileCollection.removeAll()
            self?.menuBarManager.updateFileCount(0)
        }

        shakeDetector.onShakeDetected = { [weak self] point in
            self?.showPanel(at: point)
        }

        checkAccessibilityPermission()
        shakeDetector.start()
    }

    func showPanel(at point: CGPoint) {
        panelWindow.show(at: point)
        menuBarManager.updateFileCount(fileCollection.count)
    }

    func togglePanel() {
        if isPanelVisible {
            panelWindow.hide()
        } else {
            guard let mouseLocation = NSEvent.mouseLocation as CGPoint? else { return }
            panelWindow.show(at: mouseLocation)
        }
    }

    func shutdown() {
        shakeDetector.stop()
        panelWindow.close()
        menuBarManager.remove()
    }

    // MARK: - Permissions

    private func checkAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)

        if !trusted {
            print("[ShakeDrop] ⚠️ 需要辅助功能权限以监听鼠标事件")
        } else if !shakeDetector.isMonitoring {
            // 权限已授予但监听未启动，重试
            shakeDetector.start()
        }
    }
}
