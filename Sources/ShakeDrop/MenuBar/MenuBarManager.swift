import AppKit

final class MenuBarManager {
    private var statusItem: NSStatusItem?

    var onTogglePanel: (() -> Void)?
    var onQuit: (() -> Void)?

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "tray.and.arrow.down",
                accessibilityDescription: "ShakeDrop"
            )
            button.imagePosition = .imageOnly
        }

        let menu = NSMenu()
        let item = NSMenuItem(title: "显示暂存面板", action: #selector(togglePanel), keyEquivalent: "")
        item.target = self
        menu.addItem(item)
        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "退出 ShakeDrop", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    func updateFileCount(_ count: Int) {
        guard let menu = statusItem?.menu, let firstItem = menu.items.first else { return }
        firstItem.title = count > 0
            ? "暂存面板 (\(count) 个文件)"
            : "显示暂存面板"
    }

    func remove() {
        if let item = statusItem {
            NSStatusBar.system.removeStatusItem(item)
            statusItem = nil
        }
    }

    @objc private func togglePanel() {
        onTogglePanel?()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
