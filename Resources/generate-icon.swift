import AppKit

let sizes: [(size: CGFloat, name: String)] = [
    (16, "icon_16x16"),
    (32, "icon_16x16@2x"),
    (32, "icon_32x32"),
    (64, "icon_32x32@2x"),
    (128, "icon_128x128"),
    (256, "icon_128x128@2x"),
    (256, "icon_256x256"),
    (512, "icon_256x256@2x"),
    (512, "icon_512x512"),
    (1024, "icon_512x512@2x"),
]

let iconsetDir = "Resources/AppIcon.iconset"
try? FileManager.default.removeItem(atPath: iconsetDir)
try FileManager.default.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

let symbolConfig = NSImage.SymbolConfiguration(pointSize: 192, weight: .medium)
guard let symbol = NSImage(systemSymbolName: "tray.and.arrow.down", accessibilityDescription: "ShakeDrop")?
    .withSymbolConfiguration(symbolConfig) else {
    print("❌ 无法加载 SF Symbol")
    exit(1)
}

for entry in sizes {
    let s = entry.size                  // 画布尺寸
    let margin = s * 0.11              // 11% 安全区
    let contentSize = s - margin * 2    // 实际内容区域
    let corner = contentSize * 0.224   // macOS 图标圆角比例

    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()

    // 内容区域矩形（居中，四周留白）
    let contentRect = NSRect(x: margin, y: margin, width: contentSize, height: contentSize)

    // 毛玻璃面板
    let glassPath = NSBezierPath(roundedRect: contentRect, xRadius: corner, yRadius: corner)

    let gradient = NSGradient(colors: [
        NSColor.white.withAlphaComponent(0.70),
        NSColor.white.withAlphaComponent(0.40)
    ])
    gradient?.draw(in: glassPath, angle: 135)

    // 极细玻璃边框
    NSColor.white.withAlphaComponent(0.25).setStroke()
    glassPath.lineWidth = max(1, contentSize * 0.018)
    glassPath.stroke()

    // 微弱内阴影线
    let inset = contentRect.insetBy(dx: contentSize * 0.015, dy: contentSize * 0.015)
    let innerPath = NSBezierPath(roundedRect: inset, xRadius: corner * 0.92, yRadius: corner * 0.92)
    NSColor.black.withAlphaComponent(0.04).setStroke()
    innerPath.lineWidth = max(0.5, contentSize * 0.005)
    innerPath.stroke()

    // 居中 symbol — 占内容区 44%
    let symbolSize = contentSize * 0.44
    let symbolRect = NSRect(
        x: (s - symbolSize) / 2,
        y: (s - symbolSize) / 2 - s * 0.008, // 微偏上
        width: symbolSize,
        height: symbolSize
    )

    // 轻柔阴影
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.07)
    shadow.shadowOffset = NSSize(width: 0, height: -contentSize * 0.008)
    shadow.shadowBlurRadius = contentSize * 0.025
    shadow.set()

    NSColor.systemBlue.withAlphaComponent(0.82).setFill()
    symbol.draw(in: symbolRect)

    image.unlockFocus()

    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("❌ PNG 编码失败: \(entry.name)")
        exit(1)
    }
    try pngData.write(to: URL(fileURLWithPath: "\(iconsetDir)/\(entry.name).png"))
}

print("✅ iconset 已生成: \(iconsetDir)")
