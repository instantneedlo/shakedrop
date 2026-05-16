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
