import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct DropPanelView: View {
    var fileCollection: FileCollection
    var onDropURLs: ([URL]) -> Void
    var onRemoveFile: (Int) -> Void
    var onRemoveAll: () -> Void
    var isDragOutsidePanel: (CGPoint) -> Bool

    @State private var isDropTargeted = false
    private let cornerRadius: CGFloat = 18

    var body: some View {
        VStack(spacing: 0) {
            header

            if !fileCollection.isEmpty {
                fileList
                footer
            }
        }
        .frame(width: 360, height: fileCollection.isEmpty ? 240 : 320)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    isDropTargeted ? Color.accentColor.opacity(0.75) : Color.black.opacity(0.08),
                    lineWidth: isDropTargeted ? 1.5 : 1
                )
        )
        .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 6)
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers: providers)
        }
        .animation(.easeOut(duration: 0.2), value: isDropTargeted)
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "arrow.down.to.line")
                .font(.system(size: fileCollection.isEmpty ? 28 : 20, weight: .regular))
                .foregroundStyle(.secondary)

            Text(fileCollection.isEmpty ? "拖拽文件到此处暂存" : "继续拖入文件")
                .font(.system(size: fileCollection.isEmpty ? 14 : 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: fileCollection.isEmpty ? 180 : 56)
        .padding(.top, 4)
    }

    private var fileList: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(Array(fileCollection.files.enumerated()), id: \.element) { index, url in
                    FileRow(
                        url: url,
                        isDragOutsidePanel: isDragOutsidePanel,
                        onRemove: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                onRemoveFile(index)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
    }

    private var footer: some View {
        HStack(spacing: 10) {
            Text("共 \(fileCollection.count) 个文件")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor.opacity(0.12))

                HStack(spacing: 5) {
                    Image(systemName: "tray.and.arrow.up.fill")
                        .font(.system(size: 11))
                    Text("拖出全部")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(Color.accentColor)

                DragAllButton(
                    urls: Array(fileCollection.files),
                    isDragOutsidePanel: isDragOutsidePanel,
                    onDragFinished: {
                        onRemoveAll()
                    }
                )
            }
            .frame(width: 110, height: 30)

            Button("全部清除") {
                withAnimation(.easeOut(duration: 0.2)) {
                    onRemoveAll()
                }
            }
            .font(.system(size: 11))
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.03))
        )
        .padding(.horizontal, 6)
        .padding(.bottom, 6)
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        var urls: [URL] = []
        let group = DispatchGroup()

        for provider in providers {
            group.enter()
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { data, _ in
                defer { group.leave() }
                guard let data = data as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                urls.append(url)
            }
        }

        group.notify(queue: .main) {
            onDropURLs(urls)
        }
        return true
    }
}

private struct FileRow: View {
    let url: URL
    let isDragOutsidePanel: (CGPoint) -> Bool
    let onRemove: () -> Void

    @State private var icon: NSImage?

    var body: some View {
        HStack(spacing: 8) {
            ZStack(alignment: .leading) {
                HStack(spacing: 8) {
                    if let icon {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "doc")
                            .frame(width: 24, height: 24)
                    }

                    Text(url.lastPathComponent)
                        .font(.system(size: 13))
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)

                SingleFileDragArea(
                    url: url,
                    isDragOutsidePanel: isDragOutsidePanel,
                    onDragFinished: { onRemove() }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.65))
        )
        .contentShape(Rectangle())
        .onAppear {
            icon = NSWorkspace.shared.icon(forFile: url.path)
        }
    }
}

struct SingleFileDragArea: NSViewRepresentable {
    let url: URL
    let isDragOutsidePanel: (CGPoint) -> Bool
    let onDragFinished: () -> Void

    func makeNSView(context: Context) -> SingleFileDragView {
        let view = SingleFileDragView()
        view.url = url
        view.isDragOutsidePanel = isDragOutsidePanel
        view.onDragFinished = onDragFinished
        return view
    }

    func updateNSView(_ nsView: SingleFileDragView, context: Context) {
        nsView.url = url
        nsView.isDragOutsidePanel = isDragOutsidePanel
        nsView.onDragFinished = onDragFinished
    }
}

final class SingleFileDragView: NSView, NSDraggingSource {
    var url: URL?
    var isDragOutsidePanel: ((CGPoint) -> Bool)?
    var onDragFinished: (() -> Void)?

    private var didBeginDrag = false

    override func mouseDown(with event: NSEvent) {
        didBeginDrag = false
    }

    override func mouseDragged(with event: NSEvent) {
        guard !didBeginDrag else { return }
        didBeginDrag = true
        guard let url else { return }

        let draggingItem = NSDraggingItem(pasteboardWriter: url as NSURL)
        let icon = NSWorkspace.shared.icon(forFile: url.path)

        draggingItem.setDraggingFrame(
            NSRect(x: 0, y: 0, width: 48, height: 48),
            contents: icon
        )

        let session = beginDraggingSession(with: [draggingItem], event: event, source: self)
        session.animatesToStartingPositionsOnCancelOrFail = true
    }

    func draggingSession(
        _ session: NSDraggingSession,
        sourceOperationMaskFor context: NSDraggingContext
    ) -> NSDragOperation {
        [.copy, .move]
    }

    func draggingSession(
        _ session: NSDraggingSession,
        endedAt screenPoint: NSPoint,
        operation: NSDragOperation
    ) {
        guard operation != [] else { return }
        guard isDragOutsidePanel?(screenPoint) == true else { return }

        DispatchQueue.main.async { [onDragFinished] in
            onDragFinished?()
        }
    }
}

struct DragAllButton: NSViewRepresentable {
    let urls: [URL]
    let isDragOutsidePanel: (CGPoint) -> Bool
    let onDragFinished: () -> Void

    func makeNSView(context: Context) -> DragAllView {
        let view = DragAllView(frame: NSRect(x: 0, y: 0, width: 110, height: 30))
        view.urls = urls
        view.isDragOutsidePanel = isDragOutsidePanel
        view.onDragFinished = onDragFinished
        return view
    }

    func updateNSView(_ nsView: DragAllView, context: Context) {
        nsView.urls = urls
        nsView.isDragOutsidePanel = isDragOutsidePanel
        nsView.onDragFinished = onDragFinished
    }
}

final class DragAllView: NSView, NSDraggingSource {
    var urls: [URL] = []
    var isDragOutsidePanel: ((CGPoint) -> Bool)?
    var onDragFinished: (() -> Void)?

    private var didBeginDrag = false
    private var dragSnapshot: [URL] = []

    override var acceptsFirstResponder: Bool { true }

    override func hitTest(_ point: NSPoint) -> NSView? {
        self
    }

    override func mouseDown(with event: NSEvent) {
        didBeginDrag = false
        dragSnapshot = urls
    }

    override func mouseDragged(with event: NSEvent) {
        guard !didBeginDrag else { return }
        didBeginDrag = true
        guard !dragSnapshot.isEmpty else { return }

        let draggingItems: [NSDraggingItem] = dragSnapshot.map { url in
            let item = NSDraggingItem(pasteboardWriter: url as NSURL)
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            item.setDraggingFrame(
                NSRect(x: 0, y: 0, width: 48, height: 48),
                contents: icon
            )
            return item
        }

        let session = beginDraggingSession(with: draggingItems, event: event, source: self)
        session.draggingFormation = .pile
        session.animatesToStartingPositionsOnCancelOrFail = true
    }

    func draggingSession(
        _ session: NSDraggingSession,
        sourceOperationMaskFor context: NSDraggingContext
    ) -> NSDragOperation {
        .every
    }

    func draggingSession(
        _ session: NSDraggingSession,
        endedAt screenPoint: NSPoint,
        operation: NSDragOperation
    ) {
        guard operation != [] else { return }
        guard isDragOutsidePanel?(screenPoint) == true else { return }

        DispatchQueue.main.async {
            self.onDragFinished?()
        }
    }
}