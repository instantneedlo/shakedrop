import AppKit
import SwiftUI

final class DropPanelWindow {
    private var panel: NSPanel?
    private var hostingView: NSHostingView<DropPanelView>?
    private var localMonitor: Any?

    var fileCollection: FileCollection?
    var onDropURLs: (([URL]) -> Void)?
    var onRemoveFile: ((Int) -> Void)?
    var onRemoveAll: (() -> Void)?

    var isVisible: Bool { panel?.isVisible ?? false }

    var panelFrame: CGRect {
        panel?.frame ?? .zero
    }

    func show(at screenPoint: CGPoint) {
        guard let fileCollection else { return }

        if panel == nil {
            createPanel(with: fileCollection)
        }

        positionPanel(at: screenPoint)
        panel?.makeKeyAndOrderFront(nil)
        panel?.alphaValue = 0
        panel?.animator().alphaValue = 1
    }

    func hide() {
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            panel?.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            self?.panel?.orderOut(nil)
        }
    }

    func close() {
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
        panel?.close()
        panel = nil
        hostingView = nil
    }

    private func createPanel(with collection: FileCollection) {
        let contentView = DropPanelView(
            fileCollection: collection,
            onDropURLs: { [weak self] urls in
                self?.onDropURLs?(urls)
            },
            onRemoveFile: { [weak self] index in
                self?.onRemoveFile?(index)
            },
            onRemoveAll: { [weak self] in
                self?.onRemoveAll?()
            },
            isDragOutsidePanel: { [weak self] point in
                guard let frame = self?.panel?.frame else { return false }
                return !frame.contains(point)
            }
        )

        let hosting = NSHostingView(rootView: contentView)
        hosting.translatesAutoresizingMaskIntoConstraints = false

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 300),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )

        panel.contentView = hosting
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = false
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = true
        panel.backgroundColor = NSColor.windowBackgroundColor
        panel.hasShadow = true

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 {
                self?.hide()
                return nil
            }
            return event
        }

        self.panel = panel
        self.hostingView = hosting
    }

    private func positionPanel(at screenPoint: CGPoint) {
        guard let panel else { return }

        let offset: CGFloat = 20
        let screenFrame = NSScreen.main?.visibleFrame ?? .zero

        var origin = CGPoint(
            x: screenPoint.x + offset,
            y: screenPoint.y - panel.frame.height - offset
        )

        if origin.x + panel.frame.width > screenFrame.maxX {
            origin.x = screenPoint.x - panel.frame.width - offset
        }
        if origin.y < screenFrame.minY {
            origin.y = screenPoint.y + offset
        }

        panel.setFrameOrigin(origin)
    }
}
