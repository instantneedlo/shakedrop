# CLAUDE.md — ShakeDrop 项目指引

## 项目概述

ShakeDrop 是一个 macOS 菜单栏文件暂存工具。用户在 Finder 拖拽文件时甩动鼠标触发暂存面板，收集多个文件后一次性移动到目标位置。

## 标准文档索引

| 文档 | 路径 | 用途 |
|------|------|------|
| 需求规格 | [docs/requirements.md](docs/requirements.md) | 功能需求、非功能需求、约束 |
| 技术规格 | [docs/technical-spec.md](docs/technical-spec.md) | 架构、模块设计、数据流、权限 |
| 设计规范 | [docs/design-spec.md](docs/design-spec.md) | 色彩、布局、动画、字体、间距 |
| 开发计划 | [docs/dev-plan.md](docs/dev-plan.md) | 分阶段 checklist、每日工作流 |
| 开发日志 | [docs/dev-log.md](docs/dev-log.md) | 每日完成事项、待办、问题记录 |

## 工作说明

### 每次会话开始
1. 阅读 `docs/dev-log.md` 了解当前进度
2. 阅读 `docs/dev-plan.md` 确认当前 Phase 和待办项

### 开发流程
- 严格按照 Phase 顺序推进，不跳过
- 每个 Phase 内逐项完成 checklist
- 每完成一项更新 `docs/dev-log.md`
- Phase 结束前运行 `swift build && swift test`
- 一个 Phase 全部完成后再进入下一个

### 代码规范
- Swift 5.9+，使用 `@Observable` 宏（非 `@Published`）
- 文件组按模块分文件夹：Views / Windows / MenuBar
- 不写冗余注释，命名自解释
- 单文件不超过 300 行
- 优先使用 SwiftUI，仅在必要时使用 AppKit（窗口管理、全局事件）

### 构建与测试
```bash
# 构建
cd ShakeDrop && swift build

# 测试
cd ShakeDrop && swift test

# 运行
cd ShakeDrop && swift run
# 或在 Xcode 中打开 Package.swift
```

### 关键约束
- macOS 14.0+，ARM 原生
- LSUIElement = YES（无 Dock 图标）
- 需要辅助功能权限
- 文件操作使用 `FileManager.moveItem`（移动而非复制）
- 甩动算法：1.5s 窗口内 ≥4 次方向反转 + ≥100pt 位移

### 权限
- 辅助功能权限：`addGlobalMonitorForEvents` 需要，启动时检测
- 不启用 App Sandbox（需要跨应用文件操作）
