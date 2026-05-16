# ShakeDrop — 开发计划

## Phase 0：项目脚手架 + 文档体系 ✅ 当前

- [x] 目录结构
- [x] docs/ 标准文档
- [x] CLAUDE.md
- [ ] Package.swift + Info.plist
- [ ] 最小可编译入口（空菜单栏图标）
- [ ] `swift build` 通过

## Phase 1：数据层 — FileCollection

- [ ] FileCollection 模型（@Observable，Set 去重）
- [ ] add(urls:) 含去重 + 存在性校验
- [ ] remove(at:) 单文件移除
- [ ] removeAll() 清空
- [ ] 单元测试 FileCollectionTests
- [ ] `swift test` 全部通过

## Phase 2：甩动检测 — ShakeDetector

- [ ] 全局 leftMouseDragged 监听
- [ ] 1.5s 窗口位置队列
- [ ] 方向反转计数算法
- [ ] 总位移阈值验证
- [ ] 2s 冷却机制
- [ ] 控制台日志输出
- [ ] Finder 拖文件甩动 → 日志确认检测

## Phase 3：基础面板 — Panel 空壳

- [ ] NSPanel 浮窗配置
- [ ] NSVisualEffectView 毛玻璃背景
- [ ] 空状态 DropPanelView
- [ ] 甩动触发 → 面板在鼠标附近弹出
- [ ] ESC / 点击外部关闭面板
- [ ] 弹出/关闭动画

## Phase 4：面板交互 — 拖入/拖出

- [ ] .onDrop 接收文件
- [ ] 图标+文件名列表
- [ ] 拖入悬停边框发光
- [ ] 文件插入弹性动画
- [ ] .onDrag 拖出全部文件
- [ ] FileManager.moveItem 移动
- [ ] 单文件删除按钮
- [ ] 全部清除按钮

## Phase 5：菜单栏 + 全局集成

- [ ] NSStatusBar 图标 + 菜单
- [ ] AppState 全局状态协调
- [ ] ShakeDetector ↔ AppState ↔ Panel 联动
- [ ] 辅助功能权限检测与引导
- [ ] 启动/退出流程

## Phase 6：打磨与边界处理

- [ ] 文件不存在错误提示
- [ ] 移动失败回退
- [ ] 覆盖确认（系统弹窗）
- [ ] 深色模式适配验证
- [ ] 性能优化
- [ ] 内存泄漏检查

---

## 每日工作流

1. 开工时查看 `docs/dev-log.md` 确认当前状态
2. 按当前 Phase 的 checklist 逐项完成
3. 每完成一项更新 `dev-log.md`
4. 每个 Phase 结束前运行 `swift build && swift test`
5. 提交代码并注明完成的 Phase
