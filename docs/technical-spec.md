# ShakeDrop — 技术规格

## 技术栈

| 层级 | 技术 |
|------|------|
| UI 框架 | SwiftUI |
| 底层窗口 | AppKit (NSPanel) |
| 事件监听 | AppKit (NSEvent.addGlobalMonitorForEvents) |
| 数据模型 | Swift Observation (@Observable) |
| 包管理 | Swift Package Manager |
| 测试 | XCTest |
| 语言 | Swift 5.9+ |
| 最低系统 | macOS 14.0 (Sonoma) |

## 架构

```
┌─────────────────────────────────────────┐
│              ShakeDropApp                │
│  (@main, NSApplicationDelegate)         │
├─────────────────────────────────────────┤
│              AppState                    │
│  (ObservableObject, 全局协调)            │
├──────────┬──────────┬───────────────────┤
│ShakeDetector│FileCollection│MenuBarManager│
│(NSEvent)   │(@Observable) │(NSStatusBar) │
├──────────┴──────────┼───────────────────┤
│              DropPanelWindow             │
│              (NSPanel)                   │
│              ┌──────────┐               │
│              │DropPanelView│             │
│              │(SwiftUI)   │             │
│              └──────────┘               │
└─────────────────────────────────────────┘
```

## 核心模块

### ShakeDetector

- **输入**：全局 `leftMouseDragged` 事件
- **输出**：甩动检测回调，携带鼠标位置
- **算法**：
  1. 维护一个队列存储最近 1.5 秒内的 `(NSPoint, Date)` 元组
  2. 每次新事件到来，清除 1.5 秒前的旧记录
  3. 遍历队列，计算连续 movement 的 deltaX
  4. 统计 deltaX 符号变化次数（方向反转）
  5. 若方向反转 ≥4 次 且 总位移 ≥100pt → 判定为甩动
  6. 触发后进入 2 秒冷却期
- **权限**：需要辅助功能权限，否则 `addGlobalMonitorForEvents` 返回 nil

### FileCollection

- 使用 `@Observable` 宏
- 内部存储 `Set<URL>` 用于去重
- 对外暴露 `[URL]` 有序数组
- 操作：`add(urls:)`、`remove(at:)`、`removeAll()`
- 文件存在性校验：添加时检查 `FileManager.fileExists(atPath:)`

### DropPanelWindow

- NSPanel 子类
- `styleMask`: `.nonactivatingPanel` + `.titled` + `.closable` + `.resizable`（或 `.borderless` 用于极简风格）
- `level`: `.floating`
- `hidesOnDeactivate`: `false`
- `collectionBehavior`: `.canJoinAllSpaces` + `.fullScreenAuxiliary`
- 背景：NSVisualEffectView，`.hudWindow` material
- 尺寸：380x280 pt
- 位置：当前鼠标位置右下 +20pt

### DropPanelView

- SwiftUI 视图，内嵌在 NSHostingView 中
- 空状态：虚线矩形拖放区 + 提示文字
- 有文件状态：紧凑拖放区 + ScrollView 列表
- 拖入：`.onDrop(of: [.fileURL])` 
- 拖出：`.onDrag` 返回 NSItemProvider
- 动画：Spring animation, response 0.4, dampingFraction 0.6

### MenuBarManager

- 使用 `NSStatusBar.system.statusItem(withLength:)`
- SF Symbol: `tray.and.arrow.down`
- NSMenu 包含：状态摘要、显示/隐藏面板、关于、退出

## 数据流

```
用户拖拽甩动 → NSEvent → ShakeDetector → AppState.showPanel()
                                              ↓
                                     DropPanelWindow.show()
                                              ↓
用户拖入文件 → .onDrop → FileCollection.add(urls:)
                              ↓
                      DropPanelView 刷新列表（动画）
                              
用户拖出文件 → .onDrag → Finder 接收 → FileManager.moveItem()
                                        ↓
                                FileCollection.removeAll()
```

## 文件移动策略

- 拖出时对每个文件调用 `FileManager.moveItem(at:to:)`
- 如果目标路径已存在同名文件，使用 Finder 默认行为（系统弹窗确认覆盖）
- 移动失败时回退，保留在列表中并显示错误提示

## 安全与权限

- `com.apple.security.app-sandbox`：不启用沙盒（需要跨应用文件操作）
- `com.apple.security.files.user-selected.read-write`：如启用沙盒则必需
- 辅助功能权限：`NSEvent.addGlobalMonitorForEvents` 需要
- 无网络请求，无数据收集
