# 🌿 Leaf Browser

轻量级鸿蒙 NEXT 浏览器，类似安卓 Via 浏览器的极简风格。
适配华为 Mate 80 / 鸿蒙 6.1，调用系统 Web 内核。

## ✨ 五大核心功能

### 1 🌙 暗黑模式
- `Web` 组件 `.darkMode(WebDarkMode.On/Off)` 控制网页内容暗黑渲染
- 全局 UI 同步切换深色配色方案
- 设置持久化，重启保留

### 2 🛡️ 无痕窗口
- `Web` 组件 `.incognitoMode(true)` 开启无痕
- 独立标签页管理，无痕/普通标签共存
- 地址栏显示 🛡️ 标识

### 3 🔧 自定义 UA
- 7 种预设 UA：默认 / Chrome 桌面 / Chrome Android / Safari iPhone / Firefox / Edge / Googlebot
- 菜单快捷切换「桌面模式」/「移动模式」
- 设置页支持自定义 UA 字符串输入

### 4 🐒 油猴脚本（Tampermonkey）
- 支持 `// ==UserScript==` 格式脚本导入
- 自动解析 `@name` `@version` `@match` `@run-at` `@description`
- `@match` 通配符匹配，匹配页面自动注入
- 脚本开关、左滑删除、持久化存储

### 5 👆 左滑关闭 → 打开上一个窗口
- `ListItem.swipeAction()` 实现左滑关闭
- `TabManager.close(i)` 核心逻辑：关闭后索引切到 `i - 1`
- **不是返回首页，而是回到上一个打开的标签页**
- 左边缘右滑手势：返回上一页（浏览器后退）

## 📁 项目结构

```
harmony-browser/
├── .github/workflows/hm.yml         # GitHub Actions 构建配置
├── AppScope/
│   ├── app.json5                     # 应用全局配置
│   └── resources/base/
├── entry/
│   ├── build-profile.json5           # 模块构建配置
│   ├── oh-package.json5
│   ├── hvigorfile.ts
│   └── src/main/
│       ├── module.json5              # 模块声明（权限/Ability/页面路由）
│       ├── ets/
│       │   ├── entryability/
│       │   │   └── EntryAbility.ets  # 应用入口 Ability
│       │   ├── pages/
│       │   │   ├── Index.ets         # 浏览器主页面
│       │   │   ├── SettingsPage.ets  # 设置页面
│       │   │   ├── ScriptPage.ets    # 油猴脚本管理
│       │   │   └── TabsPage.ets      # 标签页管理
│       │   ├── model/
│       │   │   ├── TabInfo.ets       # 标签数据模型
│       │   │   └── UserScript.ets    # 脚本数据模型
│       │   ├── manager/
│       │   │   ├── TabManager.ets    # 标签页管理器
│       │   │   ├── ScriptManager.ets # 脚本管理器
│       │   │   └── SettingsManager.ets # 设置管理器
│       │   └── common/
│       │       └── Constants.ets     # 全局常量（UA/搜索引擎预设）
│       └── resources/base/
│           ├── element/              # 字符串 & 颜色资源
│           ├── media/                # 图标资源
│           └── profile/
│               └── main_pages.json   # 页面路由配置
├── build-profile.json5
├── hvigorfile.ts
├── hvigor-config.json5
├── oh-package.json5
└── .gitignore
```

## 🛠️ 本地构建

### 方式一：DevEco Studio（推荐）

1. 下载 [DevEco Studio 5.0+](https://developer.huawei.com/consumer/cn/deveco-studio/)
2. 打开项目: File → Open → 选择项目根目录
3. 等待 SDK 下载和索引完成
4. 连接 Mate 80 手机（开启 USB 调试 + 开发者模式）
5. 点击 Run 运行到设备

### 方式二：命令行

```bash
# 安装依赖
ohpm install

# 构建 Debug HAP
hvigor assembleHap --mode module -p module=entry@default

# 构建 Release HAP
hvigor assembleHap --mode release -p module=entry@default
```

HAP 输出路径: `entry/build/default/outputs/default/entry-default-signed.hap`

### 方式三：GitHub Actions

1. 将项目推送到 GitHub
2. 进入 Actions 标签页
3. 等待自动构建完成（或手动触发）
4. 下载 `LeafBrowser-HAP` artifact

## 📲 安装到 Mate 80

1. **开启开发者模式**: 设置 → 关于手机 → 连点版本号 7 次
2. **开启 USB 调试**: 设置 → 系统与更新 → 开发者选项 → USB 调试
3. 通过 DevEco Studio 直接运行
4. 或用 hdc 命令安装: `hdc install entry-default-signed.hap`

## 📝 油猴脚本使用

1. 打开浏览器菜单 → 🐒 油猴脚本
2. 点击「+ 新建」手动创建脚本
3. 或点击「📥 导入 Tampermonkey 脚本」粘贴完整脚本

支持的脚本头部字段:
- `@name` — 脚本名称
- `@version` — 版本号
- `@description` — 描述
- `@match` — URL 匹配规则（`*://*/*` 匹配所有）
- `@run-at` — 运行时机（`document-start` / `document-end` / `document-idle`）

示例脚本:
```javascript
// ==UserScript==
// @name         百度美化
// @match        *://www.baidu.com/*
// @version      1.0
// @description  让百度搜索页面更简洁
// ==/UserScript==

document.body.style.backgroundColor = '#f0f5f0';
```

## License

MIT
