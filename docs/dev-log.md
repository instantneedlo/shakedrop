# ShakeDrop — 开发日志

---

## 2026-05-16 — 项目完成

### 完成事项

**核心功能**
- 全局甩动检测（1.5s 窗口、≥4 次方向反转、2s 冷却）
- 毛玻璃风格暂存面板，鼠标附近弹出
- 文件拖入（去重、边框发光反馈、弹性动画）
- 单文件拖出（原生 NSDraggingSession）
- 全部文件拖出（DragAllButton、多 NSDraggingItem）
- 拖出后自动从列表移除
- 菜单栏图标 + 动态菜单

**工程化**
- SPM 项目结构 + macOS 14.0+
- 完整文档体系（requirements / technical / design / dev-plan / dev-log）
- CLAUDE.md 项目指引
- build-app.sh 一键打包 .app
- AppIcon.icns 图标生成
- Info.plist（LSUIElement 隐藏 Dock）

**最终状态**
- swift build ✅
- .app 已安装到 /Applications
- 图标：毛玻璃圆角底 + tray.and.arrow.down

### 待办事项
- （无）项目已完成

---

## 2026-05-18 — 修复空拖动误触发

### 完成事项

- 修复任意位置按住左键甩动也会弹出暂存框的问题
- `ShakeDetector` 在采样甩动前检查系统拖拽剪贴板中是否包含文件 URL
- 非文件拖拽时清空甩动采样，避免旧样本和空拖动混合触发
- 二次修复：记录鼠标按下时的拖拽剪贴板 `changeCount`，仅当本次拖拽期间剪贴板变化并包含文件 URL 时才触发
- `ShakeDetector.start()` 增加防重复监听保护

### 验证

- `swift build` ✅
- `swift test` ✅（9 tests passed）

### 文件清单

```
ShakeDrop/
├── Package.swift
├── CLAUDE.md
├── build-app.sh
├── Resources/
│   ├── Info.plist
│   ├── AppIcon.icns
│   └── generate-icon.swift
├── Sources/ShakeDrop/
│   ├── ShakeDropApp.swift
│   ├── AppState.swift
│   ├── ShakeDetector.swift
│   ├── FileCollection.swift
│   ├── Views/
│   │   └── DropPanelView.swift
│   ├── Windows/
│   │   └── DropPanelWindow.swift
│   └── MenuBar/
│       └── MenuBarManager.swift
├── Tests/ShakeDropTests/
│   └── FileCollectionTests.swift
└── docs/
    ├── requirements.md
    ├── technical-spec.md
    ├── design-spec.md
    ├── dev-plan.md
    └── dev-log.md
```
