import { webview } from '@kit.ArkWeb'
import { router } from '@kit.ArkUI'
import { TabManager } from '../manager/TabManager'
import { ScriptManager } from '../manager/ScriptManager'
import { SettingsManager } from '../manager/SettingsManager'
import { TabInfo } from '../model/TabInfo'
import { AppConst } from '../common/Constants'

/**
 * 浏览器主页面
 * 
 * 功能：
 * 1. 🌙 暗黑模式 - Web 组件 darkMode + 全局深色 UI
 * 2. 🛡️ 无痕窗口 - Web 组件 incognitoMode
 * 3. 🔧 自定义 UA - Web 组件 userAgent
 * 4. 🐒 油猴脚本 - runJavaScript 注入
 * 5. 👆 左滑关闭回上一个 - PanGesture + closeTab → idx-1
 */
@Entry
@Component
struct Index {
  // ─── 状态 ────────────────────────────────
  @State url: string = AppConst.HOME_URL
  @State inputText: string = ''
  @State title: string = 'Leaf Browser'
  @State dark: boolean = false
  @State incognito: boolean = false
  @State tabCount: number = 1
  @State loading: boolean = false
  @State progress: number = 0
  @State menuOpen: boolean = false
  @State tabsOpen: boolean = false
  @State ua: string = ''

  // ─── 单例引用 ────────────────────────────
  private tabs: TabManager = TabManager.shared
  private scripts: ScriptManager = ScriptManager.shared
  private settings: SettingsManager = SettingsManager.shared
  private ctrl: webview.WebviewController = new webview.WebviewController()

  // ─── 手势坐标 ────────────────────────────
  private panStartX: number = 0
  private panStartY: number = 0

  // ═══════════════════════════════════════════
  //  生命周期
  // ═══════════════════════════════════════════

  async aboutToAppear() {
    // 初始化设置管理器
    await this.settings.init(getContext(this))
    this.dark = this.settings.darkMode
    this.ua = this.settings.customUA

    // 初始化脚本管理器
    await this.scripts.init(getContext(this))

    // 监听标签页变化
    this.tabs.onChange(() => {
      this.tabCount = this.tabs.count()
      const tab = this.tabs.current()
      this.url = tab.url
      this.inputText = tab.url
      this.incognito = tab.isIncognito
    })

    // 初始化当前标签页
    const tab = this.tabs.current()
    this.url = tab.url
    this.inputText = tab.url
    this.incognito = tab.isIncognito
    this.tabCount = this.tabs.count()
  }

  // ═══════════════════════════════════════════
  //  导航逻辑
  // ═══════════════════════════════════════════

  /** 导航到 URL 或搜索 */
  go(raw: string) {
    let target = raw.trim()
    if (!target) return

    // 判断是网址还是搜索关键词
    const isUrl = /^(https?:\/\/|[\w-]+\.[\w]{2,})/.test(target)
    if (!isUrl) {
      target = this.settings.searchPrefix() + encodeURIComponent(target)
    } else if (!target.startsWith('http')) {
      target = 'https://' + target
    }

    this.url = target
    this.inputText = target
    this.tabs.updateUrl(this.tabs.index(), target)
  }

  /** 注入油猴脚本 */
  inject(url: string) {
    try {
      const js = this.scripts.injectCode(url)
      if (js) {
        this.ctrl.runJavaScript(js)
      }
    } catch (e) {
      console.error('[Leaf] inject error:', e)
    }
  }

  // ═══════════════════════════════════════════
  //  主构建
  // ═══════════════════════════════════════════

  build() {
    Stack() {
      Column() {
        // ① 顶部地址栏
        this.AddressBar()

        // ② 加载进度
        if (this.loading) {
          Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
            .color($r('sys.color.leaf_primary'))
            .width('100%')
            .height(2)
        }

        // ③ Web 内容区
        this.WebArea()

        // ④ 底部工具栏
        this.BottomBar()
      }
      .width('100%')
      .height('100%')

      // ⑤ 菜单弹出层（覆盖在内容上方）
      if (this.menuOpen) {
        this.MenuPanel()
      }

      // ⑥ 标签页管理面板
      if (this.tabsOpen) {
        this.TabsPanel()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.dark ? '#111613' : '#FAFDF7')
  }

  // ─── ① 地址栏 ───────────────────────────

  @Builder AddressBar() {
    Row() {
      // 无痕标识
      if (this.incognito) {
        Text('\uD83D\uDEE1\uFE0F')
          .fontSize(13)
          .margin({ right: 4 })
      }

      // URL / 搜索输入框
      Row() {
        // 安全锁图标
        if (this.url.startsWith('https://')) {
          Text('\uD83D\uDD12')
            .fontSize(11)
            .margin({ right: 4 })
        }

        TextInput({ text: this.inputText, placeholder: '搜索或输入网址' })
          .layoutWeight(1)
          .height(34)
          .fontSize(13)
          .backgroundColor(Color.Transparent)
          .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
          .placeholderColor(this.dark ? '#4F5F50' : '#8A9E8B')
          .caretColor('#4A7C59')
          .type(InputType.Normal)
          .onChange(v => { this.inputText = v })
          .onSubmit(() => { this.go(this.inputText) })
      }
      .layoutWeight(1)
      .height(36)
      .padding({ left: 10, right: 10 })
      .backgroundColor(this.dark ? '#1E2620' : '#FFFFFF')
      .borderRadius(18)

      // 标签页数量
      Button() {
        Text(`${this.tabCount}`)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.dark ? '#C5D4C6' : '#4A7C59')
      }
      .width(32)
      .height(32)
      .margin({ left: 8 })
      .backgroundColor(this.dark ? '#1E2620' : '#E8F2EB')
      .borderRadius(8)
      .onClick(() => {
        this.tabsOpen = !this.tabsOpen
        this.menuOpen = false
      })
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
    .backgroundColor(this.dark ? '#111613' : '#FFFFFF')
    .alignItems(VerticalAlign.Center)
  }

  // ─── ③ Web 内容区 ────────────────────────

  @Builder WebArea() {
    Web({ src: this.url, controller: this.ctrl })
      .width('100%')
      .layoutWeight(1)
      // ★ 功能 1：暗黑模式
      .darkMode(this.dark ? WebDarkMode.On : WebDarkMode.Off)
      // ★ 功能 2：无痕窗口
      .incognitoMode(this.incognito)
      // ★ 功能 3：自定义 UA
      .userAgent(this.ua || undefined)
      .javaScriptAccess(true)
      .domStorageAccess(true)
      .cacheMode(CacheMode.Default)
      .allowWindowOpenMethod(true)
      .onPageBegin(e => {
        if (e) {
          this.loading = true
          this.url = e.url
          this.inputText = e.url
          this.tabs.updateUrl(this.tabs.index(), e.url)
        }
      })
      .onPageEnd(e => {
        this.loading = false
        this.progress = 100
        // ★ 功能 4：页面加载完成后注入油猴脚本
        if (e) this.inject(e.url)
      })
      .onProgressChange(e => {
        if (e) this.progress = e.newProgress
      })
      .onTitleReceive(e => {
        if (e) {
          this.title = e.title
          this.tabs.updateTitle(this.tabs.index(), e.title)
        }
      })
      .gesture(
        // ★ 功能 5：左边缘右滑返回上一页
        PanGesture({ fingers: 1, direction: PanDirection.Horizontal, distance: 50 })
          .onActionStart(e => {
            this.panStartX = e.fingerList[0].globalX
            this.panStartY = e.fingerList[0].globalY
          })
          .onActionEnd(e => {
            const dx = e.fingerList[0].globalX - this.panStartX
            const dy = Math.abs(e.fingerList[0].globalY - this.panStartY)
            // 从左边缘 30px 内、向右滑动 80px 以上 → 后退
            if (this.panStartX < 30 && dx > 80 && dy < 100) {
              try { this.ctrl.backward() } catch (_) {}
            }
          })
      )
  }

  // ─── ④ 底部工具栏 ────────────────────────

  @Builder BottomBar() {
    Row() {
      // 后退
      this.BarBtn('◀', () => { try { this.ctrl.backward() } catch (_) {} })
      // 前进
      this.BarBtn('▶', () => { try { this.ctrl.forward() } catch (_) {} })
      // 首页
      this.BarBtn('⌂', () => {
        this.url = AppConst.HOME_URL
        this.inputText = AppConst.HOME_URL
        this.ctrl.loadUrl(AppConst.HOME_URL)
      })
      // 菜单
      this.BarBtn('☰', () => {
        this.menuOpen = !this.menuOpen
        this.tabsOpen = false
      })
    }
    .width('100%')
    .height(46)
    .backgroundColor(this.dark ? '#111613' : '#FFFFFF')
    .border({ width: { top: 0.5 }, color: this.dark ? '#1E2620' : '#EAF0EC' })
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder BarBtn(label: string, action: () => void) {
    Button(label)
      .fontSize(17)
      .fontColor(this.dark ? '#6B7C6C' : '#5F7560')
      .backgroundColor(Color.Transparent)
      .layoutWeight(1)
      .height('100%')
      .onClick(action)
  }

  // ─── ⑤ 菜单面板 ──────────────────────────

  @Builder MenuPanel() {
    Column() {
      // 无痕模式
      this.SwitchRow('🛡️ 无痕模式', this.incognito, () => {
        this.incognito = !this.incognito
        const tab = this.tabs.add(AppConst.HOME_URL, this.incognito)
        this.url = tab.url
        this.inputText = tab.url
      })

      // 暗黑模式
      this.SwitchRow('🌙 暗黑模式', this.dark, () => {
        this.dark = !this.dark
        this.settings.save(AppConst.KEY_DARK_MODE, this.dark)
      })

      Divider().color(this.dark ? '#1E2620' : '#EAF0EC')

      // 新建标签页
      this.TapRow('➕ 新建标签页', () => {
        const tab = this.tabs.add(AppConst.HOME_URL, this.incognito)
        this.url = tab.url
        this.inputText = tab.url
        this.menuOpen = false
      })

      // 设置（UA / 搜索引擎）
      this.TapRow('⚙️ 设置', () => {
        this.menuOpen = false
        router.pushUrl({ url: 'pages/SettingsPage' })
      })

      // 油猴脚本
      this.TapRow('🐒 油猴脚本', () => {
        this.menuOpen = false
        router.pushUrl({ url: 'pages/ScriptPage' })
      })

      // 刷新
      this.TapRow('🔄 刷新', () => {
        try { this.ctrl.refresh() } catch (_) {}
        this.menuOpen = false
      })

      // 桌面版 UA 快捷切换
      this.TapRow('🖥️ 桌面模式', () => {
        this.ua = AppConst.UA_LIST[1].value
        this.settings.save(AppConst.KEY_CUSTOM_UA, this.ua)
        try { this.ctrl.refresh() } catch (_) {}
        this.menuOpen = false
      })

      // 移动版 UA 快捷切换
      this.TapRow('📱 移动模式', () => {
        this.ua = ''
        this.settings.save(AppConst.KEY_CUSTOM_UA, '')
        try { this.ctrl.refresh() } catch (_) {}
        this.menuOpen = false
      })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 12, bottom: 12 })
    .backgroundColor(this.dark ? '#1A1F1B' : '#FFFFFF')
    .borderRadius({ topLeft: 16, topRight: 16 })
    .shadow({ radius: 24, color: '#00000020', offsetY: -4 })
  }

  @Builder SwitchRow(label: string, isOn: boolean, action: () => void) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
        .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: isOn })
        .selectedColor('#4A7C59')
        .onChange(() => action())
    }
    .width('100%')
    .height(50)
  }

  @Builder TapRow(label: string, action: () => void) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
        .layoutWeight(1)
      Text('›')
        .fontSize(18)
        .fontColor(this.dark ? '#4F5F50' : '#A0B0A1')
    }
    .width('100%')
    .height(50)
    .onClick(action)
  }

  // ─── ⑥ 标签页管理面板 ────────────────────

  @Builder TabsPanel() {
    Column() {
      // 顶部操作栏
      Row() {
        Text(`${this.tabs.count()} 个标签页`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
          .layoutWeight(1)

        Button('+ 新建')
          .fontSize(13)
          .fontColor('#FFFFFF')
          .backgroundColor('#4A7C59')
          .borderRadius(16)
          .height(30)
          .padding({ left: 14, right: 14 })
          .onClick(() => {
            const tab = this.tabs.add(AppConst.HOME_URL, this.incognito)
            this.url = tab.url
            this.inputText = tab.url
            this.tabsOpen = false
          })

        Button('✕')
          .fontSize(16)
          .fontColor(this.dark ? '#6B7C6C' : '#8A9E8B')
          .backgroundColor(Color.Transparent)
          .margin({ left: 8 })
          .onClick(() => { this.tabsOpen = false })
      }
      .width('100%')
      .padding(14)

      // 标签列表 — 左滑关闭
      List() {
        ForEach(this.tabs.all(), (tab: TabInfo, i: number) => {
          ListItem() {
            this.TabRow(tab, i)
          }
          // ★ 功能 5：左滑关闭，关闭后打开上一个窗口
          .swipeAction({ end: this.SwipeCloseBtn(i) })
        }, (tab: TabInfo) => tab.id)
      }
      .width('100%')
      .layoutWeight(1)
      .divider({ strokeWidth: 0.5, color: this.dark ? '#1E2620' : '#EAF0EC' })
    }
    .width('100%')
    .height('75%')
    .padding({ top: 4 })
    .backgroundColor(this.dark ? '#111613' : '#FAFDF7')
    .borderRadius({ topLeft: 16, topRight: 16 })
    .shadow({ radius: 24, color: '#00000020', offsetY: -4 })
  }

  @Builder TabRow(tab: TabInfo, i: number) {
    Row() {
      Column() {
        Text(tab.title || '新标签页')
          .fontSize(14)
          .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(tab.url)
          .fontSize(11)
          .fontColor(this.dark ? '#4F5F50' : '#8A9E8B')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 无痕标签
      if (tab.isIncognito) {
        Text('🛡️')
          .fontSize(12)
          .margin({ left: 6 })
      }

      // 当前标签圆点
      if (i === this.tabs.index()) {
        Text('●')
          .fontSize(8)
          .fontColor('#4A7C59')
          .margin({ left: 6 })
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor(
      i === this.tabs.index()
        ? (this.dark ? '#1E2620' : '#E8F2EB')
        : Color.Transparent
    )
    .onClick(() => {
      this.tabs.switchTo(i)
      const cur = this.tabs.current()
      this.url = cur.url
      this.inputText = cur.url
      this.incognito = cur.isIncognito
      this.tabsOpen = false
    })
  }

  /**
   * ★ 核心：左滑关闭按钮
   * 关闭当前标签页后，TabManager.close() 会自动将索引切到 i-1（前一个）
   * 而不是回到首页
   */
  @Builder SwipeCloseBtn(i: number) {
    Button('关闭')
      .fontSize(13)
      .fontColor('#FFFFFF')
      .backgroundColor('#D94F4F')
      .borderRadius(6)
      .width(60)
      .height(52)
      .margin({ top: 4, bottom: 4 })
      .onClick(() => {
        const tab = this.tabs.close(i)
        if (tab) {
          this.url = tab.url
          this.inputText = tab.url
          this.incognito = tab.isIncognito
        }
        this.tabCount = this.tabs.count()
        if (this.tabs.count() <= 1) {
          this.tabsOpen = false
        }
      })
  }
}
