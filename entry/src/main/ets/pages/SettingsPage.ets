import { router } from '@kit.ArkUI'
import { SettingsManager } from '../manager/SettingsManager'
import { AppConst } from '../common/Constants'

/**
 * 设置页面
 * - 暗黑模式开关
 * - User-Agent 预设选择 / 自定义输入
 * - 搜索引擎切换
 * - 油猴脚本入口
 */
@Entry
@Component
struct SettingsPage {
  @State dark: boolean = false
  @State uaName: string = '默认（系统UA）'
  @State uaCustom: string = ''
  @State engineName: string = 'Bing'
  @State showUAInput: boolean = false
  @State customUAText: string = ''

  private settings: SettingsManager = SettingsManager.shared

  async aboutToAppear() {
    this.dark = this.settings.darkMode
    this.uaCustom = this.settings.customUA
    this.engineName = this.settings.searchEngine

    // 找到当前 UA 对应的预设名
    for (const item of AppConst.UA_LIST) {
      if (item.value === this.uaCustom) {
        this.uaName = item.name
        break
      }
    }
    if (this.uaCustom && this.uaName === '默认（系统UA）') {
      this.uaName = '自定义'
      this.customUAText = this.uaCustom
    }
  }

  build() {
    Column() {
      // ─── 顶部栏 ────────────────────────
      this.TopBar()

      // ─── 设置列表 ──────────────────────
      Scroll() {
        Column() {
          // ─── 外观 ──────────────────────
          this.SectionTitle('外观')
          this.SettingCard([
            this.DarkModeRow()
          ])

          // ─── User-Agent ────────────────
          this.SectionTitle('User-Agent')
          this.SettingCard(
            AppConst.UA_LIST.map(item => this.UARow(item.name, item.value))
          )

          // ─── 搜索引擎 ──────────────────
          this.SectionTitle('搜索引擎')
          this.SettingCard(
            AppConst.ENGINE_LIST.map(item => this.EngineRow(item.name))
          )

          // ─── 扩展 ──────────────────────
          this.SectionTitle('扩展')
          this.SettingCard([
            this.LinkRow('🐒 油猴脚本管理', () => {
              router.pushUrl({ url: 'pages/ScriptPage' })
            })
          ])

          // 底部留白
          Row().height(60)
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.dark ? '#111613' : '#FAFDF7')
  }

  // ─── 通用组件 ─────────────────────────────

  @Builder TopBar() {
    Row() {
      Button() {
        Text('← 返回')
          .fontSize(15)
          .fontColor(this.dark ? '#C5D4C6' : '#4A7C59')
      }
      .backgroundColor(Color.Transparent)
      .onClick(() => router.back())

      Text('设置')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text('').width(56)
    }
    .width('100%')
    .height(54)
    .padding({ left: 4, right: 12 })
    .backgroundColor(this.dark ? '#111613' : '#FFFFFF')
  }

  @Builder SectionTitle(label: string) {
    Text(label)
      .fontSize(12)
      .fontColor(this.dark ? '#4F5F50' : '#8A9E8B')
      .margin({ top: 20, bottom: 6, left: 20 })
      .width('100%')
  }

  @Builder SettingCard(rows: void[]) {
    Column() {
      ForEach(rows, (_: void, i: number) => {
        if (i > 0) {
          Divider().color(this.dark ? '#1E2620' : '#EAF0EC').padding({ left: 16 })
        }
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.dark ? '#1A1F1B' : '#FFFFFF')
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
  }

  // ─── 具体行 ───────────────────────────────

  @Builder DarkModeRow() {
    Row() {
      Text('🌙 暗黑模式')
        .fontSize(15)
        .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
        .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: this.dark })
        .selectedColor('#4A7C59')
        .onChange(v => {
          this.dark = v
          this.settings.save(AppConst.KEY_DARK_MODE, v)
        })
    }
    .width('100%')
    .height(50)
  }

  @Builder UARow(name: string, value: string) {
    Row() {
      Text(name)
        .fontSize(14)
        .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
        .layoutWeight(1)

      if (this.uaName === name) {
        Text('✓')
          .fontSize(14)
          .fontColor('#4A7C59')
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .height(46)
    .onClick(() => {
      this.uaName = name
      this.uaCustom = value
      this.showUAInput = false
      this.settings.save(AppConst.KEY_CUSTOM_UA, value)
    })
  }

  @Builder EngineRow(name: string) {
    Row() {
      Text(name)
        .fontSize(14)
        .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
        .layoutWeight(1)

      if (this.engineName === name) {
        Text('✓')
          .fontSize(14)
          .fontColor('#4A7C59')
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .height(46)
    .onClick(() => {
      this.engineName = name
      this.settings.save(AppConst.KEY_SEARCH_ENGINE, name)
    })
  }

  @Builder LinkRow(label: string, action: () => void) {
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
}
